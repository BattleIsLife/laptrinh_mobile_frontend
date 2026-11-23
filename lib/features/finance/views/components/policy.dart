import 'package:flutter/material.dart';

class Policy extends StatelessWidget {
  const Policy({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 145, 178, 205).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromARGB(255, 145, 178, 205).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                255,
                168,
                198,
                223,
              ).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.blue,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Chính sách bảo toàn lịch sử dữ liệu\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: 'Hệ thống hỗ trợ Xem, Thêm (+), và Sửa. Dữ liệu kế hoạch tín dụng mới do người dùng tự nhập để mở phòng kế hoạch cá nhân, không thay thế phê duyệt từ ngân hàng. Đối với các khoản vay hoặc tài khoản đã có phát sinh giao dịch, hãy chuyển trạng thái sang ',
                  ),
                  TextSpan(
                    text: '"Đã tất toán / Đã đóng"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' thay vì xóa để duy trì độ tin cậy cho báo cáo tín dụng cá nhân.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
