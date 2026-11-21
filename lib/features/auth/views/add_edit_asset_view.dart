import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/asset_controller.dart';
import '../models/asset.dart';
import 'components/asset_card_widget.dart';

/// Screen for adding a new asset or updating an existing one.
class AddEditAssetView extends StatefulWidget {
  final AssetController controller;
  final Asset? assetToEdit;

  const AddEditAssetView({
    super.key,
    required this.controller,
    this.assetToEdit,
  });

  bool get isEditing => assetToEdit != null;

  @override
  State<AddEditAssetView> createState() => _AddEditAssetViewState();
}

class _AddEditAssetViewState extends State<AddEditAssetView> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedType;
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;

  static const List<Map<String, dynamic>> _typeOptions = [
    {
      'type': 'REAL_ESTATE',
      'label': 'Bất động sản',
      'icon': Icons.apartment_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'type': 'VEHICLE',
      'label': 'Phương tiện',
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'type': 'GOLD',
      'label': 'Vàng & Kim loại',
      'icon': Icons.monetization_on_rounded,
      'color': Color(0xFFEAB308),
    },
    {
      'type': 'STOCK',
      'label': 'Chứng khoán',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFF8B5CF6),
    },
    {
      'type': 'CASH',
      'label': 'Tiền mặt & Tiết kiệm',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'type': 'OTHER',
      'label': 'Tài sản khác',
      'icon': Icons.category_rounded,
      'color': Color(0xFF64748B),
    },
  ];

  @override
  void initState() {
    super.initState();
    final asset = widget.assetToEdit;

    _selectedType = asset?.assetType ?? 'REAL_ESTATE';
    _nameController = TextEditingController(text: asset?.name ?? '');
    _valueController = TextEditingController(
      text: asset != null ? asset.currentValue.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  double _getParsedDouble(String text) {
    final clean = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  Asset _createPreviewAsset() {
    final existing = widget.assetToEdit;
    return Asset(
      id: existing?.id ?? 9999,
      userId: existing?.userId ?? 1,
      assetType: _selectedType,
      name: _nameController.text.trim().isEmpty
          ? 'Tên tài sản của bạn'
          : _nameController.text.trim(),
      currentValue: _getParsedDouble(_valueController.text),
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final currentValue = _getParsedDouble(_valueController.text);

    bool success;
    if (widget.isEditing) {
      success = await widget.controller.updateAsset(
        assetId: widget.assetToEdit!.id,
        assetType: _selectedType,
        name: name,
        currentValue: currentValue,
      );
    } else {
      success = await widget.controller.addAsset(
        assetType: _selectedType,
        name: name,
        currentValue: currentValue,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.successMessage ?? 'Thao tác thành công',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'Thao tác thất bại',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa thông tin tài sản' : 'Thêm tài sản mới'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Live Preview
                  const Text(
                    'Xem trước tài sản',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AssetCardWidget(asset: _createPreviewAsset()),

                  const SizedBox(height: 24),

                  // Asset Type Selector Grid
                  const Text(
                    'Loại tài sản *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.15,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _typeOptions.length,
                    itemBuilder: (context, index) {
                      final option = _typeOptions[index];
                      final isSelected = _selectedType == option['type'];
                      final color = option['color'] as Color;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = option['type'] as String;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.12)
                                : AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : AppTheme.borderColor,
                              width: isSelected ? 2 : 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                color: isSelected
                                    ? color
                                    : AppTheme.textSecondary,
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                option['label'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? color
                                      : AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Asset Name Input
                  const Text(
                    'Tên tài sản *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: AssetController.validateAssetName,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: Căn hộ Vinhomes, Xe Mazda...',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Current Value Input
                  const Text(
                    'Giá trị hiện tại (VNĐ) *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: AssetController.validateCurrentValue,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 500000000',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                      suffixText: 'VNĐ',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  ListenableBuilder(
                    listenable: widget.controller,
                    builder: (context, _) {
                      return AppButton(
                        text: widget.isEditing
                            ? 'Lưu thay đổi'
                            : 'Thêm tài sản',
                        isLoading: widget.controller.isActionLoading,
                        icon: widget.isEditing ? Icons.check : Icons.add,
                        onPressed: _submitForm,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
