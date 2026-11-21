import 'package:flutter/material.dart';

import '../../controllers/profile_controller.dart';

import '../../models/profile.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileInfoCard extends StatefulWidget {
  final Profile profile;
  final ProfileController profileController;
  const ProfileInfoCard({
    super.key,
    required this.profile,
    required this.profileController,
  });
  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  bool _isEditing = false;

  late TextEditingController _phoneController;
  late TextEditingController _fullNameController;
  late TextEditingController _occupationController;
  late TextEditingController _dependentsController;
  late TextEditingController _incomeController;
  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.profile.phone);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _occupationController = TextEditingController(
      text: widget.profile.occupation,
    );
    _dependentsController = TextEditingController(
      text: widget.profile.numberofdependents.toString(),
    );
    _incomeController = TextEditingController(
      text: widget.profile.monthlyincome.toString(), //widget là đối tượng widget hiện tại mà State đang quản lý. Nếu ProfileInfoCard khai báo thuộc tính profile, thì trong lớp State bạn truy cập nó bằng widget.profile
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _occupationController.dispose();
    _dependentsController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    Profile updatedProfile = Profile(
      id: widget.profile.id,
      fullName: _fullNameController.text,
      email: widget.profile.email,
      phone: widget.profile.phone,
      occupation: _occupationController.text,
      numberofdependents: int.tryParse(_dependentsController.text) ?? 0,
      monthlyincome: double.tryParse(_incomeController.text) ?? 0.0,
      dateofbirth: widget.profile.dateofbirth,
    );
    final bool success = await widget.profileController.updateprofile(
      updatedProfile,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hồ sơ đã được cập nhật thành công!')),
      );
      // Handle success case
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAccountSection(),
        const SizedBox(height: 16),
        _buildPersonalSection(),
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!_isEditing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          icon: const Icon(Icons.edit),
          label: const Text('Cập nhật thông tin cá nhân'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.profileController.isSaving ? null : () => _save(),
            icon: widget.profileController.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              widget.profileController.isSaving ? 'Đang lưu...' : 'Lưu',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _isEditing = false),
            icon: const Icon(
              Icons.cancel,
              color: Color.fromARGB(255, 222, 109, 101),
            ),
            label: const Text('huỷ'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildCard(
      icon: Icons.lock_outline,
      title: 'THÔNG TIN TÀI KHOẢN & BẢO MẬT',
      children: [
        _buildRowWithAction(
          label: 'Mã người dùng',
          value: (widget.profile.id).toString(),
          action: TextButton.icon(
            onPressed: () {
              print('sao chép');
            },
            label: const Text('Sao chép', style: TextStyle(fontSize: 12)),
            icon: const Icon(Icons.copy, size: 12),
          ),
        ),
        _buildDivider(),
        _buildRow(label: 'Số điện thoại', value: widget.profile.phone),
        _buildDivider(),
        _buildRow(label: 'Email', value: widget.profile.email),
        _buildDivider(),
        _buildRowWithAction(
          label: 'Mật khẩu',
          value: '••••••••',
          action: TextButton.icon(
            onPressed: () {
              //  navigate sang màn hình đổi mật khẩu
            },
            icon: const Icon(Icons.lock_reset, size: 14),
            label: const Text('Đổi mật khẩu', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return _buildCard(
      icon: Icons.person_outline,
      title: 'THÔNG TIN NHÂN KHẨU & NGHỀ NGHIỆP',
      children: [
        _isEditing
            ? _buildEditRow(label: 'Họ và tên', controller: _fullNameController)
            : _buildRow(label: 'Họ và tên', value: widget.profile.fullName),
        _buildDivider(),
        _buildRow(
          label: 'Ngày sinh',
          value: widget.profile.dateofbirth != null
              ? '${widget.profile.dateofbirth!.day.toString().padLeft(2, '0')}/'
                    '${widget.profile.dateofbirth!.month.toString().padLeft(2, '0')}/'
                    '${widget.profile.dateofbirth!.year}'
              : 'Chưa cập nhật',
        ),
        _buildDivider(),
        _isEditing
            ? _buildEditRow(
                label: 'Nghề nghiệp',
                controller: _occupationController,
              )
            : _buildRow(
                label: 'Nghề nghiệp',
                value: widget.profile.occupation ?? 'Chưa cập nhật',
              ),
        _buildDivider(),
        _isEditing
            ? _buildEditRow(
                label: 'Số người phụ thuộc',
                controller: _dependentsController,
                keyboardType: TextInputType.number,
              )
            : _buildRow(
                label: 'Số người phụ thuộc',
                value: '${widget.profile.numberofdependents} người',
              ),
        _buildDivider(),
        _isEditing
            ? _buildEditRow(
                label: 'Thu nhập hàng tháng',
                controller: _incomeController,
                keyboardType: TextInputType.number,
              )
            : _buildRow(
                label: 'Thu nhập hàng tháng',
                value: '${_formatMoney(widget.profile.monthlyincome)} đ',
                valueColor: Colors.blue,
              ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRowWithAction({
    required String label,
    required String value,
    required Widget action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        action,
      ],
    );
  }

  Widget _buildEditRow({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade100);
  String _formatMoney(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
