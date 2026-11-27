/// Model chứa dữ liệu yêu cầu Quên mật khẩu (gửi OTP và đặt lại mật khẩu).
class ForgotPasswordModel {
  final String email;
  final String otp;
  final String password;
  final String confirmPassword;

  const ForgotPasswordModel({
    required this.email,
    this.otp = '',
    this.password = '',
    this.confirmPassword = '',
  });

  /// Dữ liệu gửi lên API POST /api/auth/get_otp
  Map<String, dynamic> toGetOtpJson() {
    return {
      'email': email,
    };
  }

  /// Dữ liệu gửi lên API POST /api/auth/reset_password
  Map<String, dynamic> toResetPasswordJson() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'otp': otp,
    };
  }
}
