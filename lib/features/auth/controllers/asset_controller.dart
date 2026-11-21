import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../models/asset.dart';
import '../services/asset_service.dart';

/// Controller coordinating Asset management state and business logic.
///
/// Follows MVC architecture and extends [ChangeNotifier] for reactive updates.
/// Decoupled from [BuildContext] for clean unit and widget testing.
class AssetController extends ChangeNotifier {
  final AssetService _assetService;

  List<Asset> _assets = [];
  Asset? _selectedAsset;

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _selectedTypeFilter = 'ALL';
  int? _filterMonth;
  int? _filterYear;
  String _searchQuery = '';
  String? _token;

  AssetController({AssetService? assetService, String? token})
    : _assetService = assetService ?? AssetService() {
    _token = token;
  }

  // --- Getters ---
  List<Asset> get assets => _assets;
  Asset? get selectedAsset => _selectedAsset;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get selectedTypeFilter => _selectedTypeFilter;
  int? get filterMonth => _filterMonth;
  int? get filterYear => _filterYear;
  String get searchQuery => _searchQuery;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  void setTypeFilter(String type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setDateFilter(int? month, int? year) {
    _filterMonth = month;
    _filterYear = year;
    notifyListeners();
    fetchAssets(month: _filterMonth, year: _filterYear);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearDateFilter() {
    _filterMonth = null;
    _filterYear = null;
    notifyListeners();
    fetchAssets();
  }

  /// Filtered list of assets according to [selectedTypeFilter] and [searchQuery].
  List<Asset> get filteredAssets {
    return _assets.where((asset) {
      bool matchesType = true;
      if (_selectedTypeFilter != 'ALL') {
        matchesType = asset.assetType == _selectedTypeFilter;
      }

      bool matchesSearch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        matchesSearch = asset.name.toLowerCase().contains(query) ||
            asset.typeDisplay.toLowerCase().contains(query);
      }

      return matchesType && matchesSearch;
    }).toList();
  }

  // --- Aggregated Financial Metrics ---

  /// Total portfolio valuation
  double get totalAssetValue =>
      _assets.fold(0.0, (sum, a) => sum + a.currentValue);

  int get totalAssetCount => _assets.length;

  /// Valuation grouped by asset type
  Map<String, double> get valuationByType {
    final map = <String, double>{};
    for (final asset in _assets) {
      map[asset.assetType] = (map[asset.assetType] ?? 0.0) + asset.currentValue;
    }
    return map;
  }

  // --- Static Validations (Based on Backend Specs) ---

  static const List<String> validAssetTypes = [
    'REAL_ESTATE',
    'VEHICLE',
    'GOLD',
    'STOCK',
    'CASH',
    'OTHER',
  ];

  static String? validateAssetType(String? value) {
    if (value == null || !validAssetTypes.contains(value.toUpperCase())) {
      return "Loại tài sản không hợp lệ, phải là 'REAL_ESTATE', 'VEHICLE', 'GOLD', 'STOCK', 'CASH' hoặc 'OTHER'";
    }
    return null;
  }

  static String? validateAssetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên tài sản';
    }
    return null;
  }

  static String? validateCurrentValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập giá trị tài sản';
    }
    final clean = value.replaceAll('.', '').replaceAll(',', '.').trim();
    final number = double.tryParse(clean);
    if (number == null || number <= 0) {
      return 'Giá trị hiện tại phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
    }
    return null;
  }

  // --- Asset Operations ---

  /// Fetches assets list from API with optional month & year filter.
  Future<void> fetchAssets({int? page, int? month, int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assets = await _assetService.getAssets(
        page: page,
        month: month ?? _filterMonth,
        year: year ?? _filterYear,
        token: _token,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi không xác định khi tải danh sách tài sản: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches detail for a single asset by ID.
  Future<Asset?> fetchAssetDetail(int assetId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final asset = await _assetService.getAssetById(assetId, token: _token);
      _selectedAsset = asset;
      _isLoading = false;
      notifyListeners();
      return asset;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải chi tiết tài sản: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Adds a new asset.
  Future<bool> addAsset({
    required String assetType,
    required String name,
    required double currentValue,
  }) async {
    final typeErr = validateAssetType(assetType);
    if (typeErr != null) {
      _errorMessage = typeErr;
      notifyListeners();
      return false;
    }

    final nameErr = validateAssetName(name);
    if (nameErr != null) {
      _errorMessage = nameErr;
      notifyListeners();
      return false;
    }

    if (currentValue <= 0) {
      _errorMessage =
          'Giá trị hiện tại phải là 1 số thập phân dương, tối đa 2 chữ số sau dấu phảy';
      notifyListeners();
      return false;
    }

    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _assetService.addAsset(
        assetType: assetType,
        name: name.trim(),
        currentValue: currentValue,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchAssets();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm tài sản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing asset.
  Future<bool> updateAsset({
    required int assetId,
    String? assetType,
    String? name,
    double? currentValue,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _assetService.updateAsset(
        assetId: assetId,
        assetType: assetType,
        name: name?.trim(),
        currentValue: currentValue,
        token: _token,
      );

      _successMessage = msg;
      _isActionLoading = false;
      await fetchAssets();

      if (_selectedAsset != null && _selectedAsset!.id == assetId) {
        await fetchAssetDetail(assetId);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật tài sản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes an asset.
  Future<bool> deleteAsset(int assetId) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _assetService.deleteAsset(assetId, token: _token);
      _successMessage = msg;
      _isActionLoading = false;
      await fetchAssets();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa tài sản: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
