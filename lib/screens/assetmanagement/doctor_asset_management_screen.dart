
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:docautomations/controllers/application_controller.dart';

import 'package:docautomations/device_assets/asset_type.dart';

import 'package:docautomations/repositories/doctor_repository.dart';

import 'package:docautomations/services/image/image_service.dart';
import 'package:docautomations/services/image/procesed_image.dart';

class DoctorAssetManagementScreen extends StatefulWidget {
  const DoctorAssetManagementScreen({super.key});

  @override
  State<DoctorAssetManagementScreen> createState() =>
      _DoctorAssetManagementScreenState();
}

class _DoctorAssetManagementScreenState
    extends State<DoctorAssetManagementScreen> {

  //--------------------------------------------------------------------------
  // Dependencies
  //--------------------------------------------------------------------------

  final ImageService _imageService = ImageService();

  DoctorRepository get _repository =>
      context.read<DoctorRepository>();

  //--------------------------------------------------------------------------
  // State
  //--------------------------------------------------------------------------

  bool _logoBusy = false;

  bool _signatureBusy = false;

  //--------------------------------------------------------------------------
  // Messages
  //--------------------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;

      if (status == 401 || status == 403) {
        return 'Authentication failed. Please sign in again.';
      }

      if (status == 413) {
        return 'The image is too large.';
      }

      if (status == 415) {
        return 'Unsupported image format. Select a PNG, JPG or WebP image.';
      }

      if (status != null) {
        return 'Server request failed (HTTP $status).';
      }

      return 'Unable to connect to the server. Check your connection.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  //--------------------------------------------------------------------------
  // Pick Image
  //--------------------------------------------------------------------------

  Future<ProcessedImage?> _pickImage() async {
    try {
      return await _imageService.pickImage();
    } catch (error) {
      _showMessage(_errorMessage(error));
      return null;
    }
  }

  //==========================================================================
  // REFRESH
  //==========================================================================

  //--------------------------------------------------------------------------
  // Refresh Logo
  //--------------------------------------------------------------------------

  Future<void> _refreshLogo() async {
    if (_logoBusy || _signatureBusy) return;

    setState(() => _logoBusy = true);

    try {
      await context
          .read<ApplicationController>()
          .synchronizeDoctorAsset(AssetType.logo);
    } catch (error) {
      _showMessage(
        'Unable to refresh clinic logo: ${_errorMessage(error)}',
      );
    } finally {
      if (mounted) {
        setState(() => _logoBusy = false);
      }
    }
  }

  //--------------------------------------------------------------------------
  // Refresh Signature
  //--------------------------------------------------------------------------

  Future<void> _refreshSignature() async {
    if (_signatureBusy || _logoBusy) return;

    setState(() => _signatureBusy = true);

    try {
      await context
          .read<ApplicationController>()
          .synchronizeDoctorAsset(AssetType.signature);
    } catch (error) {
      _showMessage(
        'Unable to refresh doctor signature: ${_errorMessage(error)}',
      );
    } finally {
      if (mounted) {
        setState(() => _signatureBusy = false);
      }
    }
  }

  //--------------------------------------------------------------------------
  // Refresh All
  //--------------------------------------------------------------------------

  Future<void> _refreshAll() async {
    if (_logoBusy || _signatureBusy) return;

    // Synchronize sequentially to avoid duplicate profile requests.

    await _refreshLogo();

    if (!mounted) return;

    await _refreshSignature();
  }

  //==========================================================================
  // UPLOAD / REPLACE
  //==========================================================================

  //--------------------------------------------------------------------------
  // Save Logo
  //--------------------------------------------------------------------------

  Future<void> _saveLogo() async {
    if (_logoBusy || _signatureBusy) return;

    final image = await _pickImage();

    if (image == null || !mounted) return;

    setState(() => _logoBusy = true);

    bool serverSaved = false;

    try {
      final controller = context.read<ApplicationController>();

      final result = controller.doctorLogoBytes == null
          ? await _repository.addDoctorLogo(
              bytes: image.bytes,
              fileName: 'clinic-logo.jpg',
              mimeType: image.mimeType,
            )
          : await _repository.replaceDoctorLogo(
              bytes: image.bytes,
              fileName: 'clinic-logo.jpg',
              mimeType: image.mimeType,
            );

      if (!mounted) return;

      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      serverSaved = true;

      // Fetch latest metadata, synchronize cache and update controller.

      await controller.synchronizeDoctorAsset(
        AssetType.logo,
      );

      if (!mounted) return;

      _showMessage('Clinic logo saved successfully.');
    } catch (error) {
      if (serverSaved) {
        _showMessage(
          'Clinic logo was saved on the server, but local '
          'synchronization failed: ${_errorMessage(error)}. '
          'Please use Refresh to synchronize it.',
        );
      } else {
        _showMessage(
          'Unable to save clinic logo: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _logoBusy = false);
      }
    }
  }

  //--------------------------------------------------------------------------
  // Save Signature
  //--------------------------------------------------------------------------

  Future<void> _saveSignature() async {
    if (_signatureBusy || _logoBusy) return;

    final image = await _pickImage();

    if (image == null || !mounted) return;

    setState(() => _signatureBusy = true);

    bool serverSaved = false;

    try {
      final controller = context.read<ApplicationController>();

      final result = controller.doctorSignatureBytes == null
          ? await _repository.addDoctorSignature(
              bytes: image.bytes,
              fileName: 'doctor-signature.jpg',
              mimeType: image.mimeType,
            )
          : await _repository.replaceDoctorSignature(
              bytes: image.bytes,
              fileName: 'doctor-signature.jpg',
              mimeType: image.mimeType,
            );

      if (!mounted) return;

      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      serverSaved = true;

      // Fetch latest metadata, synchronize cache and update controller.

      await controller.synchronizeDoctorAsset(
        AssetType.signature,
      );

      if (!mounted) return;

      _showMessage('Doctor signature saved successfully.');
    } catch (error) {
      if (serverSaved) {
        _showMessage(
          'Doctor signature was saved on the server, but local '
          'synchronization failed: ${_errorMessage(error)}. '
          'Please use Refresh to synchronize it.',
        );
      } else {
        _showMessage(
          'Unable to save doctor signature: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _signatureBusy = false);
      }
    }
  }

  //==========================================================================
  // DELETE
  //==========================================================================

  //--------------------------------------------------------------------------
  // Confirm Delete
  //--------------------------------------------------------------------------

  Future<bool> _confirmDelete(String assetName) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Delete $assetName?'),
            content: Text(
              'This will permanently remove the saved $assetName '
              'from your doctor account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  //--------------------------------------------------------------------------
  // Delete Logo
  //--------------------------------------------------------------------------

  Future<void> _deleteLogo() async {
    if (_logoBusy || _signatureBusy) return;

    final controller = context.read<ApplicationController>();

    if (controller.doctorLogoBytes == null) return;

    if (!await _confirmDelete('clinic logo')) return;

    if (!mounted) return;

    setState(() => _logoBusy = true);

    bool serverDeleted = false;

    try {
      final result = await _repository.deleteDoctorLogo();

      if (!mounted) return;

      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      serverDeleted = true;

      // Server metadata now reports that the logo does not exist.
      // Synchronization removes the local file and manifest entry.

      await controller.synchronizeDoctorAsset(
        AssetType.logo,
      );

      if (!mounted) return;

      _showMessage('Clinic logo deleted successfully.');
    } catch (error) {
      if (serverDeleted) {
        _showMessage(
          'Clinic logo was deleted on the server, but local '
          'synchronization failed: ${_errorMessage(error)}. '
          'Please use Refresh to synchronize it.',
        );
      } else {
        _showMessage(
          'Unable to delete clinic logo: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _logoBusy = false);
      }
    }
  }

  //--------------------------------------------------------------------------
  // Delete Signature
  //--------------------------------------------------------------------------

  Future<void> _deleteSignature() async {
    if (_signatureBusy || _logoBusy) return;

    final controller = context.read<ApplicationController>();

    if (controller.doctorSignatureBytes == null) return;

    if (!await _confirmDelete('doctor signature')) return;

    if (!mounted) return;

    setState(() => _signatureBusy = true);

    bool serverDeleted = false;

    try {
      final result = await _repository.deleteDoctorSignature();

      if (!mounted) return;

      if (!result.success) {
        _showMessage(result.message);
        return;
      }

      serverDeleted = true;

      // Synchronize deletion with local cache and controller.

      await controller.synchronizeDoctorAsset(
        AssetType.signature,
      );

      if (!mounted) return;

      _showMessage('Doctor signature deleted successfully.');
    } catch (error) {
      if (serverDeleted) {
        _showMessage(
          'Doctor signature was deleted on the server, but local '
          'synchronization failed: ${_errorMessage(error)}. '
          'Please use Refresh to synchronize it.',
        );
      } else {
        _showMessage(
          'Unable to delete doctor signature: ${_errorMessage(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _signatureBusy = false);
      }
    }
  }

  //==========================================================================
  // ASSET CARD
  //==========================================================================

  Widget _assetCard({
    required String title,
    required String description,
    required IconData icon,
    required Uint8List? bytes,
    required bool busy,
    required VoidCallback onSave,
    required VoidCallback onRefresh,
    required VoidCallback onDelete,
  }) {
    final exists = bytes != null && bytes.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh from server',
                  onPressed: busy ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 170,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: busy && !exists
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : exists
                      ? Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Center(
                            child: Text(
                              'Unable to display this image.',
                            ),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text('No image uploaded'),
                          ],
                        ),
            ),

            const SizedBox(height: 8),

            Text(
              exists ? 'Saved on server' : 'Not configured',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy ? null : onSave,
                  icon: Icon(
                    exists ? Icons.swap_horiz : Icons.upload,
                  ),
                  label: Text(
                    exists ? 'Replace' : 'Upload',
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: busy ? null : onRefresh,
                  icon: const Icon(Icons.sync),
                  label: const Text('Refresh'),
                ),

                OutlinedButton.icon(
                  onPressed: busy || !exists ? null : onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),

            if (busy) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  //==========================================================================
  // BUILD
  //==========================================================================

  @override
  Widget build(BuildContext context) {
    // ApplicationController is the single source of truth for images.

    final controller = context.watch<ApplicationController>();

    final logoBytes = controller.doctorLogoBytes;

    final signatureBytes = controller.doctorSignatureBytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Asset Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh all assets',
            onPressed: (_logoBusy || _signatureBusy)
                ? null
                : _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Manage the images used on your prescriptions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            _assetCard(
              title: 'Clinic Logo',
              description: 'Displayed on your prescription letterhead.',
              icon: Icons.local_hospital_outlined,
              bytes: logoBytes,
              busy: _logoBusy,
              onSave: _saveLogo,
              onRefresh: _refreshLogo,
              onDelete: _deleteLogo,
            ),

            _assetCard(
              title: 'Doctor Signature',
              description:
                  'Printed in the signature area of your prescription.',
              icon: Icons.draw_outlined,
              bytes: signatureBytes,
              busy: _signatureBusy,
              onSave: _saveSignature,
              onRefresh: _refreshSignature,
              onDelete: _deleteSignature,
            ),
          ],
        ),
      ),
    );
  }
}
