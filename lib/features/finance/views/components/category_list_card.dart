import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CategoryItem {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String? badge;
  final String? amount;
  final Color? amountColor;
  final bool hasArrow;
  final VoidCallback? onTap; //không trả về dữ liệu không kèm tham số khai báo lớp con và lớp cha sử dụng
  const CategoryItem({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    this.badge,
    this.amount,
    this.amountColor,
    this.hasArrow = false,
    this.onTap,
  });
}

class CategoryListCard extends StatelessWidget {
  const CategoryListCard({super.key});
  List<CategoryItem> _buildItems(BuildContext context) {
    return [
      CategoryItem(
        icon: Icons.arrow_downward,
        iconBgColor: const Color(0xFFE8F5E9),
        label: 'Thu nhập',
        badge: '2 nguồn',
        amount: '25.000.000 đ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Thu nhập'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.shopping_cart_outlined,
        iconBgColor: const Color(0xFFFFF3E0),
        label: 'Chi tiêu',
        amount: '17.000.000 đ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Chi tiêu'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.credit_card_outlined,
        iconBgColor: const Color(0xFFFFEBEE),
        label: 'Khoản',
        badge: '2 đang hoạt động',
        amount: '125.000.000 đ',
        amountColor: Colors.red,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(body: Center(child: Text('Khoản'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.savings_outlined,
        iconBgColor: const Color(0xFFE3F2FD),
        label: 'Tiết kiệm',
        amount: '45.000.000 đ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Tiết kiệm'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.inventory_2_outlined,
        iconBgColor: const Color(0xFFF3E5F5),
        label: 'Tài sản',
        badge: '3 danh mục',
        amount: '350.000.000 đ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Tài sản'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.credit_score_outlined,
        iconBgColor: const Color(0xFFE8EAF6),
        label: 'Tài khoản tín dụng',
        hasArrow: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Tài khoản tín dụng'))),
          ),
        ),
      ),
      CategoryItem(
        icon: Icons.request_page_outlined,
        iconBgColor: const Color(0xFFE8F5E9),
        label: 'Yêu cầu tín dụng mới',
        hasArrow: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Yêu cầu tín dụng mới')),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh mục quản lý',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${items.length} phần mục',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true, //dùng để core list phân tử lại khít vs số phần tử
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildItem(items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(CategoryItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                if (item.amount != null)
                  Text(
                    item.amount.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: item.amountColor ?? AppTheme.textPrimary,
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
