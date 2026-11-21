class Profile {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? occupation;
  final DateTime? dateofbirth;
  final int numberofdependents;
  final double monthlyincome;
  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.occupation,
    this.dateofbirth,
    required this.numberofdependents,
    required this.monthlyincome,
  });
  //chuyển một object nhận từ backend trả về thành một object Profile
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      occupation: json['occupation'] ?? '',
      dateofbirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      numberofdependents: json['number_of_dependents'] ?? 0,
      monthlyincome:
          double.tryParse(json['monthly_income']?.toString() ?? '') ?? 0.0,
    );
  }
  //biến hồ sơ thành một json để gửi lên backend phục vụ việc update thông tin hồ sơ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'occupation': occupation,
      if (dateofbirth != null)
        'dateofbirth':
            '${dateofbirth!.year.toString().padLeft(4, '0')}-'
            '${dateofbirth!.month.toString().padLeft(2, '0')}-'
            '${dateofbirth!.day.toString().padLeft(2, '0')}',
      'number_of_dependents': numberofdependents,
      'monthly_income': monthlyincome,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'full_name': fullName,
      'occupation': occupation,
      if (dateofbirth != null)
        'dateofbirth':
            '${dateofbirth!.year.toString().padLeft(4, '0')}-'
            '${dateofbirth!.month.toString().padLeft(2, '0')}-'
            '${dateofbirth!.day.toString().padLeft(2, '0')}',
      'number_of_dependents': numberofdependents,
      'monthly_income': monthlyincome,
    };
  }
}
