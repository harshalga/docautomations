import 'package:docautomations/services/log_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/common/operation_result.dart';
import 'package:docautomations/datamodels/master/image_asset.dart';

import 'package:docautomations/datamodels/master/prescription_layout.dart';
import 'package:docautomations/datamodels/master/prescription_theme.dart';

import 'package:docautomations/repositories/layout_repository.dart';
import 'package:docautomations/repositories/theme_repository.dart';

import 'package:docautomations/services/theme_cache/theme_cache_manager.dart';

import 'package:docautomations/services/logger_service.dart';

import 'dart:async';

class PrescLayoutSettingsScreen extends StatefulWidget {
  const PrescLayoutSettingsScreen({super.key});

  @override
  State<PrescLayoutSettingsScreen> createState() =>
      _PrescLayoutSettingsScreenState();
}

class _PrescLayoutSettingsScreenState
    extends State<PrescLayoutSettingsScreen> {

  //===========================================================================
  // Dependencies
  //===========================================================================

  late final LayoutRepository _layoutRepository;
  late final ThemeRepository _themeRepository;
  late final ThemeCacheManager _themeCacheManager;

  //===========================================================================
  // State
  //===========================================================================

  bool _loading = true;
  bool _saving = false;
  bool _refreshingThemes = false;

  String? _errorMessage;

  PrescriptionLayout? _layout;

  List<PrescriptionTheme> _themes = [];

  String? _selectedThemeId;

  double _headerHeightCm = 5.5;
  double _footerHeightCm = 1.5;

  double _leftMarginCm = 1.0;
  double _rightMarginCm = 1.0;
  double _topMarginCm = 0.0;
  double _bottomMarginCm = 0.0;

  String _pageSize = "A4";

  bool _printLetterHead = true;
  bool _printSignature = true;
  bool _showPrescriptionQRCode = true;
  bool _showWatermark = false;
  bool _showPageNumber = false;

  //===========================================================================
  // Initialization
  //===========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    _layoutRepository = context.read<LayoutRepository>();
    _themeRepository = context.read<ThemeRepository>();
    _themeCacheManager = context.read<ThemeCacheManager>();

    await _loadSettings();
  }


bool get _selectedThemeIsAvailable {
  if (_selectedThemeId == null) return true;

  return _themes.any(
    (theme) => theme.id == _selectedThemeId,
  );
}
  //===========================================================================
  // Load Settings
  //===========================================================================

  Future<void> _loadSettings() async {
    try {


      //-------------------------------------------------------------------------
// TEMPORARY: Clear old theme cache
//-------------------------------------------------------------------------
// await LoggerService.debug(
//   "Temporary clearing theme cache...",
// );
// await _themeCacheManager.clearCache();

// await LoggerService.debug(
//   "Temporary clearing after theme cache...",
// );

      //-------------------------------------------------------------------------
      // Load cached themes first
      //-------------------------------------------------------------------------

      final cachedThemes =
          await _themeCacheManager.loadCachedThemes();

          await LoggerService.debug(
  "Refreshing themes from backend...",
);

      if (!mounted) return;

      setState(() {
        _themes = cachedThemes;
      });

      //-------------------------------------------------------------------------
      // Load Doctor Layout
      //-------------------------------------------------------------------------

      final layoutResult =
          await _layoutRepository.getDoctorLayout();

      if (!layoutResult.success) {
        throw Exception(layoutResult.message);
      }

      final layout = layoutResult.data as PrescriptionLayout;

      if (!mounted) return;

      setState(() {
        _layout = layout;
        _applyLayout(layout);
      });

      //-------------------------------------------------------------------------
      // Refresh Themes from Backend
      //-------------------------------------------------------------------------
 LoggerService.debug("Refreshing themes from backend...");
      await _refreshThemes();
      LoggerService.debug(
"Theme refresh completed. Available themes: ${_themes.length}");
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  //===========================================================================
  // Apply Layout
  //===========================================================================

  void _applyLayout(PrescriptionLayout layout) {
    _headerHeightCm = layout.headerHeightCm;
    _footerHeightCm = layout.footerHeightCm;

    _leftMarginCm = layout.leftMarginCm;
    _rightMarginCm = layout.rightMarginCm;
    _topMarginCm = layout.topMarginCm;
    _bottomMarginCm = layout.bottomMarginCm;

    _pageSize = layout.pageSize;

    _printLetterHead = layout.printLetterHead;
    _printSignature = layout.printSignature;
    _showPrescriptionQRCode = layout.showPrescriptionQRCode;
    _showWatermark = layout.showWatermark;
    _showPageNumber = layout.showPageNumber;

    _selectedThemeId = layout.selectedTheme?.id;
  }

  //===========================================================================
  // Refresh Themes
  //===========================================================================

  Future<void> _refreshThemes() async {
    if (_refreshingThemes) return;
     

    setState(() {
      _refreshingThemes = true;
    });

    try {
      final themes = await _themeCacheManager.synchronize(
        fetchThemes: () async {
          final result = await _themeRepository.getAllThemes();

          if (!result.success) {
            throw Exception(result.message);
          }

          return List<PrescriptionTheme>.from(
            result.data as List,
          );
        },
      );


  
      unawaited(
  LoggerService.debug(
    "THEMES LOADED: ${themes.length}",
  ),
);

for (final theme in themes) {
  unawaited(
    LoggerService.debug(
      "THEME: ${theme.name}",
    ),
  );

  unawaited(
    LoggerService.debug(
      "HEADER LENGTH: ${theme.headerBackgroundImage?.imageData.length}",
    ),
  );

  unawaited(
    LoggerService.debug(
      "FOOTER LENGTH: ${theme.footerBackgroundImage?.imageData.length}",
    ),
  );
}

      if (!mounted) return;

      setState(() {
        // Update the catalogue only.
  // Do not change _selectedThemeId here.
        _themes = themes;
      });
    } catch (error) {
      // Keep cached themes when the network is unavailable.
      if (_themes.isEmpty && mounted) {
        setState(() {
          _errorMessage =
              "Unable to load prescription themes: $error";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshingThemes = false;
        });
      }
    }
  }

  //===========================================================================
  // Save Layout
  //===========================================================================

  Future<void> _saveLayout() async {
    if (_layout == null || _saving) return;

    if (_selectedThemeId != null &&
        !_themes.any((theme) => theme.id == _selectedThemeId)) {
      _showMessage("Please select an available theme.");
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final request = <String, dynamic>{
        "_id": _layout!.id,
        "doctorId": _layout!.doctorId,

        "headerHeightCm": _headerHeightCm,
        "footerHeightCm": _footerHeightCm,

        "leftMarginCm": _leftMarginCm,
        "rightMarginCm": _rightMarginCm,
        "topMarginCm": _topMarginCm,
        "bottomMarginCm": _bottomMarginCm,

        "pageSize": _pageSize,

        "printLetterHead": _printLetterHead,
        "printSignature": _printSignature,
        "showPrescriptionQRCode": _showPrescriptionQRCode,
        "showWatermark": _showWatermark,
        "showPageNumber": _showPageNumber,

        "selectedThemeId": _selectedThemeId,
      };

      final result =
          await _layoutRepository.updateDoctorLayout(request);

      if (!result.success) {
        throw Exception(result.message);
      }

      final updatedLayout = result.data as PrescriptionLayout;

      if (!mounted) return;

      setState(() {
        _layout = updatedLayout;
        _applyLayout(updatedLayout);
      });

      _showMessage(result.message);
    } catch (error) {
      _showMessage("Unable to save layout: $error");
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  //===========================================================================
  // Reset Layout
  //===========================================================================

  Future<void> _resetLayout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Prescription Layout"),
        content: const Text(
          "This will restore your default prescription layout settings. "
          "Do you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _saving = true;
    });

    try {
      final result =
          await _layoutRepository.resetDoctorLayout();

      if (!result.success) {
        throw Exception(result.message);
      }

      final layout = result.data as PrescriptionLayout;

      if (!mounted) return;

      setState(() {
        _layout = layout;
        _applyLayout(layout);
      });

      _showMessage(result.message);
    } catch (error) {
      _showMessage("Unable to reset layout: $error");
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  //===========================================================================
  // Message
  //===========================================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  //===========================================================================
  // Build
  //===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Layout Settings"),
        actions: [
          IconButton(
            tooltip: "Refresh themes",
            onPressed: _refreshingThemes ? null : _refreshThemes,
            icon: _refreshingThemes
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _resetLayout,
                        child: const Text("Reset"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveLayout,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_layout == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? "Unable to load prescription layout.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _errorMessage = null;
                  });
                  _loadSettings();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (_errorMessage != null) ...[
          _buildWarning(_errorMessage!),
          const SizedBox(height: 16),
        ],

        if (!_selectedThemeIsAvailable) ...[
  _buildWarning(
    "Your previously selected theme is no longer available. "
    "Please select another active theme before saving.",
  ),
  const SizedBox(height: 16),
],

        _buildThemeSection(),

        const SizedBox(height: 24),

        _buildPageSection(),

        const SizedBox(height: 24),

        _buildDimensionsSection(),

        const SizedBox(height: 24),

        _buildPrintOptionsSection(),
      ],
    );
  }

  //===========================================================================
  // Theme Selection
  //===========================================================================

  Widget _buildThemeSection() {
    return _section(
      title: "Prescription Theme",
      subtitle: "Select a theme with its matching header and footer.",
      child: _themes.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text("No active themes are available."),
            )
          : Column(
              children: _themes.map(_buildThemeCard).toList(),
            ),
    );
  }

  Widget _buildThemeCard(PrescriptionTheme theme) {
    final selected = theme.id == _selectedThemeId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedThemeId = theme.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: theme.id,
                    groupValue: _selectedThemeId,
                    onChanged: (value) {
                      setState(() {
                        _selectedThemeId = value;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      theme.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildPremiumBadge(theme.isPremium),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildThemeImage(
                      label: "Header",
                      asset: theme.headerBackgroundImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildThemeImage(
                      label: "Footer",
                      asset: theme.footerBackgroundImage,
                    ),
                  ),
                ],
              ),

              if (theme.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  theme.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildThemeImage({
  //   required String label,
  //   required  ImageAsset? asset,
  // }) {
  //   final bytes = asset?.bytes;


  //   debugPrint("========== $label IMAGE ==========");
  // debugPrint("Asset is null: ${asset == null}");

  // if (asset != null) {
  //   debugPrint("Image MIME: ${asset.mimeType}");
  //   debugPrint("Image data length: ${asset.imageData.length}");
  //   debugPrint("Image bytes length: ${asset.bytes?.length}");
  // }


  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: Theme.of(context).textTheme.labelMedium,
  //       ),
  //       const SizedBox(height: 6),
  //       Container(
  //         height: 95,
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).colorScheme.surfaceContainerHighest,
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(
  //             color: Theme.of(context).dividerColor,
  //           ),
  //         ),
  //         clipBehavior: Clip.antiAlias,
  //         child: bytes == null
  //             ? const Center(
  //                 child: Text(
  //                   "No image",
  //                   style: TextStyle(fontSize: 12),
  //                 ),
  //               )
  //             : Image.memory(
  //                 bytes,
  //                 fit: BoxFit.contain,
  //                 errorBuilder: (_, __, ___) {
  //                   return const Center(
  //                     child: Icon(Icons.broken_image_outlined),
  //                   );
  //                 },
  //               ),
  //       ),
  //     ],
  //   );
  // }
Widget _buildThemeImage({
  required String label,
  required ImageAsset? asset,
}) {
  final bytes = asset?.bytes;

  debugPrint("========== $label IMAGE ==========");
debugPrint("Asset null: ${asset == null}");
debugPrint("MIME: ${asset?.mimeType}");
debugPrint("Base64 length: ${asset?.imageData.length}");
debugPrint("Base64 prefix: ${asset?.imageData.substring(
  0,
  (asset.imageData.length).clamp(0, 20),
)}");
debugPrint("Decoded bytes: ${bytes?.length}");

if (bytes != null && bytes.length >= 8) {
  debugPrint("Image signature: ${bytes.take(8).toList()}");
}

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      const SizedBox(height: 6),
      Container(
        height: 95,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: bytes == null || bytes.isEmpty
            ? const Center(
                child: Text("No image"),
              )
            : Image.memory(
                bytes,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  unawaited(
                    LoggerService.error(
                      "Failed to render $label image",
                      error: error,
                      stack: stackTrace,
                    ),
                  );

                  return const Center(
                    child: Icon(Icons.broken_image_outlined),
                  );
                },
              ),
      ),
    ],
  );
}
  Widget _buildPremiumBadge(bool isPremium) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPremium
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPremium ? "PREMIUM" : "FREE",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPremium ? Colors.orange.shade800 : Colors.green.shade800,
        ),
      ),
    );
  }

  //===========================================================================
  // Page Settings
  //===========================================================================

  Widget _buildPageSection() {
    return _section(
      title: "Page Settings",
      child: DropdownButtonFormField<String>(
        value: _pageSize,
        decoration: const InputDecoration(
          labelText: "Page Size",
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: "A4", child: Text("A4")),
          DropdownMenuItem(value: "LETTER", child: Text("Letter")),
          DropdownMenuItem(value: "LEGAL", child: Text("Legal")),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _pageSize = value;
            });
          }
        },
      ),
    );
  }

  //===========================================================================
  // Dimensions
  //===========================================================================

  Widget _buildDimensionsSection() {
    return _section(
      title: "Layout Dimensions",
      subtitle: "All measurements are in centimetres (cm).",
      child: Column(
        children: [
          _buildNumberField(
            label: "Header Height",
            value: _headerHeightCm,
            onChanged: (value) => _headerHeightCm = value,
          ),
          _buildNumberField(
            label: "Footer Height",
            value: _footerHeightCm,
            onChanged: (value) => _footerHeightCm = value,
          ),
          const Divider(),
          _buildNumberField(
            label: "Left Margin",
            value: _leftMarginCm,
            onChanged: (value) => _leftMarginCm = value,
          ),
          _buildNumberField(
            label: "Right Margin",
            value: _rightMarginCm,
            onChanged: (value) => _rightMarginCm = value,
          ),
          _buildNumberField(
            label: "Top Margin",
            value: _topMarginCm,
            onChanged: (value) => _topMarginCm = value,
          ),
          _buildNumberField(
            label: "Bottom Margin",
            value: _bottomMarginCm,
            onChanged: (value) => _bottomMarginCm = value,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextFormField(
        key: ValueKey("$label-$value"),
        initialValue: value.toString(),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: "cm",
          border: const OutlineInputBorder(),
        ),
        onChanged: (text) {
          final parsed = double.tryParse(text);

          if (parsed != null && parsed >= 0) {
            onChanged(parsed);
               }
            },
      ),
    );
  }

  //===========================================================================
  // Print Options
  //===========================================================================

  Widget _buildPrintOptionsSection() {
    return _section(
      title: "Print Options",
      child: Column(
        children: [
          _buildSwitch(
            title: "Print Letterhead",
            value: _printLetterHead,
            onChanged: (value) => _printLetterHead = value,
          ),
          _buildSwitch(
            title: "Print Signature",
            value: _printSignature,
            onChanged: (value) => _printSignature = value,
          ),
          _buildSwitch(
            title: "Show Prescription QR Code",
            value: _showPrescriptionQRCode,
            onChanged: (value) => _showPrescriptionQRCode = value,
          ),
          _buildSwitch(
            title: "Show Watermark",
            value: _showWatermark,
            onChanged: (value) => _showWatermark = value,
          ),
          _buildSwitch(
            title: "Show Page Number",
            value: _showPageNumber,
            onChanged: (value) => _showPageNumber = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        setState(() {
          onChanged(newValue);
        });
      },
    );
  }

  //===========================================================================
  // Shared Widgets
  //===========================================================================

  Widget _section({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildWarning(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}