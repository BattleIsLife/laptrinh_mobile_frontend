import 'dart:async';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../models/asset.dart';

/// Contract for Asset operations.
abstract class AssetService {
  /// Factory constructor returning [MockAssetService] or [HttpAssetService]
  /// based on configuration.
  factory AssetService({ApiClient? apiClient, bool? useMock}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockAssetService();
    }
    return HttpAssetService(apiClient: apiClient);
  }

  Future<List<Asset>> getAssets({
    int? page,
    int? month,
    int? year,
    String? token,
  });

  Future<Asset> getAssetById(int assetId, {String? token});

  Future<String> addAsset({
    required String assetType,
    required String name,
    required double currentValue,
    String? token,
  });

  Future<String> updateAsset({
    required int assetId,
    String? assetType,
    String? name,
    double? currentValue,
    String? token,
  });

  Future<String> deleteAsset(int assetId, {String? token});
}

/// Real HTTP implementation connecting to Node.js backend.
class HttpAssetService implements AssetService {
  final ApiClient _apiClient;

  HttpAssetService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<Asset>> getAssets({
    int? page,
    int? month,
    int? year,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (month != null && year != null) {
      queryParams['month'] = month;
      queryParams['year'] = year;
    }

    final response = await _apiClient.get(
      ApiConfig.assetsEndpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      token: token,
    );

    final rawData = response['data'];
    if (rawData is List) {
      return rawData
          .map((item) => Asset.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Asset> getAssetById(int assetId, {String? token}) async {
    final response = await _apiClient.get(
      ApiConfig.assetsEndpoint,
      queryParams: {'asset_id': assetId},
      token: token,
    );

    final rawData = response['data'];
    if (rawData is List && rawData.isNotEmpty) {
      return Asset.fromJson(rawData.first as Map<String, dynamic>);
    } else if (rawData is Map<String, dynamic>) {
      return Asset.fromJson(rawData);
    }
    throw ApiException('Không tìm thấy dữ liệu tài sản');
  }

  @override
  Future<String> addAsset({
    required String assetType,
    required String name,
    required double currentValue,
    String? token,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.assetsEndpoint,
      body: {
        'asset_type': assetType,
        'name': name,
        'current_value': currentValue,
      },
      token: token,
    );

    return response['message'] as String? ?? 'Đã thêm tài sản thành công';
  }

  @override
  Future<String> updateAsset({
    required int assetId,
    String? assetType,
    String? name,
    double? currentValue,
    String? token,
  }) async {
    final body = <String, dynamic>{'asset_id': assetId};
    if (assetType != null) body['asset_type'] = assetType;
    if (name != null) body['name'] = name;
    if (currentValue != null) body['current_value'] = currentValue;

    final response = await _apiClient.patch(
      ApiConfig.assetsEndpoint,
      body: body,
      token: token,
    );

    return response['message'] as String? ?? 'Sửa tài sản thành công';
  }

  @override
  Future<String> deleteAsset(int assetId, {String? token}) async {
    final response = await _apiClient.delete(
      ApiConfig.assetsEndpoint,
      body: {'asset_id': assetId},
      token: token,
    );

    return response['message'] as String? ?? 'Đã xóa tài sản thành công';
  }
}

/// In-memory mock service for testing, offline demo, and verification.
class MockAssetService implements AssetService {
  final Duration simulatedDelay;

  MockAssetService({this.simulatedDelay = const Duration(milliseconds: 400)});

  static final List<Asset> _mockAssets = [
    Asset(
      id: 1,
      userId: 1,
      assetType: 'REAL_ESTATE',
      name: 'Căn hộ Vinhomes Smart City',
      currentValue: 3200000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Asset(
      id: 2,
      userId: 1,
      assetType: 'VEHICLE',
      name: 'Mazda CX-5 2.0 Premium',
      currentValue: 780000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Asset(
      id: 3,
      userId: 1,
      assetType: 'GOLD',
      name: '5 lượng vàng miếng SJC 9999',
      currentValue: 420000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Asset(
      id: 4,
      userId: 1,
      assetType: 'STOCK',
      name: 'Danh mục cổ phiếu FPT & VCB',
      currentValue: 250000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Asset(
      id: 5,
      userId: 1,
      assetType: 'CASH',
      name: 'Sổ tiết kiệm Vietcombank 12 tháng',
      currentValue: 500000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Asset(
      id: 6,
      userId: 1,
      assetType: 'OTHER',
      name: 'Đồng hồ cao cấp Omega Seamaster',
      currentValue: 120000000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<Asset>> getAssets({
    int? page,
    int? month,
    int? year,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    List<Asset> result = List.from(_mockAssets);

    if (month != null && year != null) {
      result = result
          .where(
            (a) => a.createdAt.month == month && a.createdAt.year == year,
          )
          .toList();
    }

    if (page != null && page > 0) {
      final startIndex = (page - 1) * 10;
      if (startIndex >= result.length) return [];
      final endIndex = (startIndex + 10).clamp(0, result.length);
      return result.sublist(startIndex, endIndex);
    }

    return result;
  }

  @override
  Future<Asset> getAssetById(int assetId, {String? token}) async {
    await Future.delayed(simulatedDelay);
    final match = _mockAssets.where((a) => a.id == assetId);
    if (match.isEmpty) {
      throw ApiException('Không tìm thấy dữ liệu!');
    }
    return match.first;
  }

  @override
  Future<String> addAsset({
    required String assetType,
    required String name,
    required double currentValue,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final newId = _mockAssets.isEmpty
        ? 1
        : _mockAssets.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    final newAsset = Asset(
      id: newId,
      userId: 1,
      assetType: assetType,
      name: name,
      currentValue: currentValue,
      createdAt: now,
      updatedAt: now,
    );
    _mockAssets.add(newAsset);
    return 'Đã thêm tài sản thành công';
  }

  @override
  Future<String> updateAsset({
    required int assetId,
    String? assetType,
    String? name,
    double? currentValue,
    String? token,
  }) async {
    await Future.delayed(simulatedDelay);
    final index = _mockAssets.indexWhere((a) => a.id == assetId);
    if (index == -1) {
      throw ApiException('Không tìm thấy dữ liệu!');
    }

    final current = _mockAssets[index];
    _mockAssets[index] = current.copyWith(
      assetType: assetType,
      name: name,
      currentValue: currentValue,
      updatedAt: DateTime.now(),
    );
    return 'Sửa tài sản thành công';
  }

  @override
  Future<String> deleteAsset(int assetId, {String? token}) async {
    await Future.delayed(simulatedDelay);
    final index = _mockAssets.indexWhere((a) => a.id == assetId);
    if (index == -1) {
      throw ApiException('Xóa tài sản thất bại!!');
    }
    _mockAssets.removeAt(index);
    return 'Đã xóa tài sản thành công';
  }
}
