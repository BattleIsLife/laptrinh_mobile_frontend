import '../models/debt.dart';
import '../models/payment.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/api_config.dart';

/// Các thao tác dữ liệu mà phần debt cần có.
abstract class DebtService {
  factory DebtService({
    ApiClient? apiClient,
    bool? useMock,
    required String token,
  }) {
    final shouldUseMock = useMock ?? ApiConfig.useMockService;
    if (shouldUseMock) {
      return MockDebtService();
    }
    return HttpProfileService(apiClient: apiClient, token: token);
  }
  Future<Debt> getDebt();
  Future<DebtPayment> getPayment();

  Future<Debt> addDebt(Debt debt);
  Future<DebtPayment> addDebtPayment(DebtPayment debtpayment);
}

/// Dữ liệu giả để làm giao diện trước khi backend có API hồ sơ.
class MockDebtService implements DebtService {
  Debt _debt = Debt(
    id: 'HC-88294',
    userId: 'user_1',
    lenderName: 'Home Credit',
    debtType: 'installment', // Khoản vay trả góp
    totalAmount: 100000000,
    remainingAmount: 75000000,
    creditLimit: 100000000,
    monthlyPayment: 3500000,
    interestRate: 12.5,
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2027, 1, 15),
    dueDayOfMonth: 2,
    status: 'active',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime.now(),
  );
  DebtPayment _debtpayments = DebtPayment(
    id: 'pay_1',
    debtId: 'HC-88294',
    dueDate: DateTime(2026, 9, 2),
    paymentDate: DateTime(2026, 9, 2),
    amountDue: 3500000,
    amountPaid: 3500000,
    isLate: false,
    dayLate: 0,
    status: 'paid',
    createdAt: DateTime(2026, 9, 2),
  );

  @override
  Future<Debt> getDebt() async => _debt;

  @override
  Future<DebtPayment> getPayment() async => _debtpayments;

  @override
  Future<Debt> addDebt(Debt debt) async {
    _debt = debt;
    return _debt;
  }

  @override
  Future<DebtPayment> addDebtPayment(DebtPayment debtpayment) async {
    _debtpayments = debtpayment;
    return _debtpayments;
  }
}

class HttpProfileService implements DebtService {
  final ApiClient _apiClient;
  final String _token;

  HttpProfileService({ApiClient? apiClient, required String token})
    : _apiClient = apiClient ?? ApiClient(),
      _token = token;
  @override
  Future<Debt> getDebt() async {
    final response = await _apiClient.get(
      ApiConfig.profileEndpoint,
      headers: {'Authorization': 'Bearer $_token'},
    );

    return Debt.fromJson(response['data']);
  }

  Future<DebtPayment> getPayment() async {
    final response = await _apiClient.get(
      ApiConfig.profileEndpoint,
      headers: {'Authorization': 'Bearer $_token'},
    );

    return DebtPayment.fromJson(response['data']);
  }

  @override
  Future<Debt> addDebt(Debt debt) async {
    final response = await _apiClient.post(
      ApiConfig.profileEndpoint,
      body: debt.toJson(),
      headers: {'Authorization': 'Bearer $_token'},
    );
    return Debt.fromJson(response['data']);
  }

  @override
  Future<DebtPayment> addDebtPayment(DebtPayment debtpayment) async {
    final response = await _apiClient.post(
      ApiConfig.profileEndpoint,
      body: debtpayment.toJson(),
      headers: {'Authorization': 'Bearer $_token'},
    );
    return DebtPayment.fromJson(response['data']);
  }
}
