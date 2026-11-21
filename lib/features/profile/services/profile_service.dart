import '../models/profile.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';

/// Các thao tác dữ liệu mà phần hồ sơ cần có.
abstract class ProfileService {
  factory ProfileService({ApiClient? apiClient, bool? useMock, String? token}) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockProfileService();
    }
    if (token == null || token.trim().isEmpty) {
      throw ArgumentError('Cần token để gọi profile API');
    }
    return HttpProfileService(apiClient: apiClient, token: token);
  }
  Future<Profile> getProfile();

  Future<Profile> updateProfile(Profile profile);
}

/// Dữ liệu giả để làm giao diện trước khi backend có API hồ sơ.
class MockProfileService implements ProfileService {
  Profile _profile = Profile(
    id: 88926,
    fullName: 'Nguyễn Văn An',
    email: 'an@example.com',
    phone: '0900000000',
    occupation: 'Nhân viên',
    numberofdependents: 0,
    monthlyincome: 0,
  );

  @override
  Future<Profile> getProfile() async => _profile;

  @override
  Future<Profile> updateProfile(Profile profile) async {
    _profile = profile;
    return _profile;
  }
}

class HttpProfileService implements ProfileService {
  final ApiClient _apiClient;
  final String _token;

  HttpProfileService({ApiClient? apiClient, required String token})
    : _apiClient = apiClient ?? ApiClient(),
      _token = token;
  @override
  Future<Profile> getProfile() async {
    final response = await _apiClient.get(
      ApiConfig.profileEndpoint,
      headers: {'Authorization': 'Bearer $_token'},
    );

    return Profile.fromJson(response['data']);
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final response = await _apiClient.patch(
      ApiConfig.profileEndpoint,
      body: profile.toUpdate(),
      headers: {'Authorization': 'Bearer $_token'},
    );
    return Profile.fromJson(response['data']);
  }
}
