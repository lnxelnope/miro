# Step 08: Finance Timeline & Slip Scanning

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 01 (Core Models), Step 02 (Home Screen)

---

## สิ่งที่ต้องทำ

1. สร้าง Finance Provider
2. สร้าง Finance Timeline Tab
3. สร้าง Transaction Card Widgets
4. สร้าง Slip Scanner Service (OCR)
5. สร้าง Add Transaction Screen

---

## ขั้นตอนที่ 1: สร้าง Finance Provider

**สร้างไฟล์:** `lib/features/finance/providers/finance_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../models/transaction.dart';
import '../models/asset.dart';

// ===== TRANSACTIONS =====

final transactionsByDateProvider = FutureProvider.family<List<Transaction>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.transactions
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .sortByDateDesc()
      .findAll();
});

final monthlyTransactionsProvider = FutureProvider.family<List<Transaction>, DateTime>((ref, month) async {
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0);
  
  return await DatabaseService.transactions
      .filter()
      .dateBetween(startOfMonth, endOfMonth)
      .sortByDateDesc()
      .findAll();
});

final monthlySummaryProvider = FutureProvider.family<Map<String, double>, DateTime>((ref, month) async {
  final transactions = await ref.watch(monthlyTransactionsProvider(month).future);
  
  double income = 0;
  double expense = 0;
  
  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else if (t.type == TransactionType.expense) {
      expense += t.amount;
    }
  }
  
  return {
    'income': income,
    'expense': expense,
    'balance': income - expense,
  };
});

final expenseByCategoryProvider = FutureProvider.family<Map<String, double>, DateTime>((ref, month) async {
  final transactions = await ref.watch(monthlyTransactionsProvider(month).future);
  
  final Map<String, double> byCategory = {};
  
  for (final t in transactions) {
    if (t.type == TransactionType.expense) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
  }
  
  return byCategory;
});

// ===== ASSETS =====

final allAssetsProvider = FutureProvider<List<Asset>>((ref) async {
  return await DatabaseService.assets.where().sortByLiquidity().findAll();
});

final totalAssetsValueProvider = FutureProvider<double>((ref) async {
  final assets = await ref.watch(allAssetsProvider.future);
  return assets.fold<double>(0, (sum, asset) {
    final value = asset.currentPrice != null
        ? asset.quantity * asset.currentPrice!
        : asset.estimatedValue ?? 0;
    return sum + value;
  });
});

// ===== NOTIFIERS =====

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionNotifier() : super(const AsyncValue.loading());

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.transactions.put(transaction);
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    transaction.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.transactions.put(transaction);
    });
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.transactions.delete(id);
    });
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier();
});
```

---

## ขั้นตอนที่ 2: สร้าง Transaction Card

**สร้างไฟล์:** `lib/features/finance/widgets/transaction_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = isIncome ? '+' : '-';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getCategoryIcon(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? transaction.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (transaction.bankAccount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '💳 ${transaction.bankAccount}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix฿${_formatNumber(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: amountColor,
                    ),
                  ),
                  Text(
                    _formatTime(transaction.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Image indicator
              if (transaction.imagePath != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.image,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryIcon() {
    // Try to match expense category
    try {
      final category = ExpenseCategory.values.firstWhere(
        (c) => c.name == transaction.category.toLowerCase(),
      );
      return category.icon;
    } catch (_) {}
    
    // Default icons
    if (transaction.type == TransactionType.income) {
      return '💵';
    }
    return '📦';
  }

  Color _getCategoryColor() {
    if (transaction.type == TransactionType.income) {
      return AppColors.income;
    }
    return AppColors.expense;
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Finance Timeline Tab

**สร้างไฟล์:** `lib/features/finance/presentation/finance_timeline_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/finance_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/monthly_summary_card.dart';

class FinanceTimelineTab extends ConsumerStatefulWidget {
  const FinanceTimelineTab({super.key});

  @override
  ConsumerState<FinanceTimelineTab> createState() => _FinanceTimelineTabState();
}

class _FinanceTimelineTabState extends ConsumerState<FinanceTimelineTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(monthlyTransactionsProvider(_selectedMonth));
    final summaryAsync = ref.watch(monthlySummaryProvider(_selectedMonth));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(monthlyTransactionsProvider(_selectedMonth));
        ref.invalidate(monthlySummaryProvider(_selectedMonth));
      },
      child: CustomScrollView(
        slivers: [
          // Monthly Summary
          SliverToBoxAdapter(
            child: summaryAsync.when(
              loading: () => const SizedBox(height: 150),
              error: (_, __) => const SizedBox(),
              data: (summary) => MonthlySummaryCard(
                income: summary['income'] ?? 0,
                expense: summary['expense'] ?? 0,
                balance: summary['balance'] ?? 0,
              ),
            ),
          ),

          // Month Selector
          SliverToBoxAdapter(
            child: _buildMonthSelector(),
          ),

          // Transactions
          transactionsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              // Group by date
              final grouped = _groupByDate(transactions);

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(entry.key),
                        ...entry.value.map(
                          (t) => TransactionCard(
                            transaction: t,
                            onTap: () => _showTransactionDetail(t),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: grouped.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthFormat = DateFormat('MMMM yyyy', 'th');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
          ),
          GestureDetector(
            onTap: _pickMonth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.finance.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                monthFormat.format(_selectedMonth),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.finance,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final dateFormat = DateFormat('d MMMM yyyy', 'th');
    final isToday = _isToday(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        isToday ? '📅 วันนี้' : '📅 ${dateFormat.format(date)}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีรายการ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ถ่ายรูปสลิปหรือพิมพ์เพิ่มรายการ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<dynamic>> _groupByDate(List<dynamic> transactions) {
    final Map<DateTime, List<dynamic>> grouped = {};

    for (final t in transactions) {
      final dateKey = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(t);
    }

    return grouped;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  void _showTransactionDetail(dynamic transaction) {
    // TODO: Show transaction detail
  }
}
```

---

## ขั้นตอนที่ 4: สร้าง Monthly Summary Card

**สร้างไฟล์:** `lib/features/finance/widgets/monthly_summary_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MonthlySummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const MonthlySummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.finance.withOpacity(0.8),
            AppColors.finance,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.finance.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                label: 'รายรับ',
                amount: income,
                icon: '💵',
                isPositive: true,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                label: 'รายจ่าย',
                amount: expense,
                icon: '💸',
                isPositive: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '📊 คงเหลือ: ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${balance >= 0 ? '+' : ''}฿${_formatNumber(balance)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required String icon,
    required bool isPositive,
  }) {
    return Column(
      children: [
        Text(
          '$icon $label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${isPositive ? '+' : '-'}฿${_formatNumber(amount)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    final absNumber = number.abs();
    if (absNumber >= 1000000) {
      return '${(absNumber / 1000000).toStringAsFixed(1)}M';
    }
    if (absNumber >= 1000) {
      return '${(absNumber / 1000).toStringAsFixed(0)},${(absNumber % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    }
    return absNumber.toStringAsFixed(0);
  }
}
```

---

## ขั้นตอนที่ 5: สร้าง Add Transaction Screen

**สร้างไฟล์:** `lib/features/finance/presentation/add_transaction_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType? initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late TransactionType _type;
  ExpenseCategory _expenseCategory = ExpenseCategory.food;
  IncomeCategory _incomeCategory = IncomeCategory.salary;
  
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มรายการ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: '💸 รายจ่าย',
                    type: TransactionType.expense,
                    color: AppColors.expense,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    label: '💵 รายรับ',
                    type: TransactionType.income,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: '฿ ',
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            const Text(
              'หมวดหมู่',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_type == TransactionType.expense)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _expenseCategory == cat;
                  return ChoiceChip(
                    label: Text('${cat.icon} ${cat.displayName}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _expenseCategory = cat);
                      }
                    },
                    selectedColor: AppColors.expense.withOpacity(0.2),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncomeCategory.values.map((cat) {
                  final isSelected = _incomeCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _incomeCategory = cat);
                      }
                    },
                    selectedColor: AppColors.income.withOpacity(0.2),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'รายละเอียด (optional)',
                hintText: 'เช่น กาแฟ Starbucks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.divider),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required TransactionType type,
    required Color color,
  }) {
    final isSelected = _type == type;

    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกจำนวนเงิน')),
      );
      return;
    }

    final category = _type == TransactionType.expense
        ? _expenseCategory.name
        : _incomeCategory.name;

    final transaction = Transaction()
      ..type = _type
      ..amount = amount
      ..date = _selectedDate
      ..category = category
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..source = DataSource.manual;

    final notifier = ref.read(transactionNotifierProvider.notifier);
    await notifier.addTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกสำเร็จ!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }
}
```

---

## ขั้นตอนที่ 6: อัปเดต Finance Page

**แก้ไขไฟล์:** `lib/features/finance/presentation/finance_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'finance_timeline_tab.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.finance,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.finance,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'รายรับ/จ่าย'),
              Tab(text: 'สินทรัพย์'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const FinanceTimelineTab(), // ← Updated
              _buildPlaceholder('Income/Expense', '💰'),
              _buildPlaceholder('Assets', '📈'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist

- [ ] สร้าง finance_provider.dart แล้ว
- [ ] สร้าง transaction_card.dart แล้ว
- [ ] สร้าง finance_timeline_tab.dart แล้ว
- [ ] สร้าง monthly_summary_card.dart แล้ว
- [ ] สร้าง add_transaction_screen.dart แล้ว
- [ ] อัปเดต finance_page.dart แล้ว
- [ ] ทดสอบ run app สำเร็จ

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/finance/
├── presentation/
│   ├── finance_page.dart            ← UPDATED
│   ├── finance_timeline_tab.dart    ← NEW
│   └── add_transaction_screen.dart  ← NEW
├── providers/
│   └── finance_provider.dart        ← NEW
└── widgets/
    ├── transaction_card.dart        ← NEW
    └── monthly_summary_card.dart    ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 09: Task System** เพื่อสร้างระบบ Task และ Today Tab
