import 'package:docautomations/device_assets/asset_type.dart';

import 'server_asset_metadata.dart';

class ServerAssets {
  final ServerAssetMetadata logo;
  final ServerAssetMetadata signature;
  final ServerAssetMetadata header;
  final ServerAssetMetadata footer;

  const ServerAssets({
    required this.logo,
    required this.signature,
    required this.header,
    required this.footer,
  });

  factory ServerAssets.fromJson(dynamic json) {
    final map = json is Map
        ? Map<String, dynamic>.from(json)
        : <String, dynamic>{};

    return ServerAssets(
      logo: ServerAssetMetadata.fromJson(map["logo"]),
      signature: ServerAssetMetadata.fromJson(map["signature"]),
      header: ServerAssetMetadata.fromJson(map["header"]),
      footer: ServerAssetMetadata.fromJson(map["footer"]),
    );
  }

  ServerAssetMetadata getAsset(AssetType type) {
    switch (type) {
      case AssetType.logo:
        return logo;
      case AssetType.signature:
        return signature;
      case AssetType.header:
        return header;
      case AssetType.footer:
        return footer;
    }
  }
}