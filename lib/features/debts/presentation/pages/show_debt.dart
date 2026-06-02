import 'package:flutter/material.dart';

class SharedDebtsView extends StatelessWidget {
  const SharedDebtsView({super.key});

  // بيانات تجريبية مع تحسين التنسيق
  final List<Map<String, dynamic>> mockDebts = const [
    {
      "title": "شراء أغراض المنزل",
      "amount": 250.0,
      "status": "Pending",
      "date": "05 يونيو 2026",
    },
    {
      "title": "سداد فاتورة الكهرباء",
      "amount": 120.0,
      "status": "Paid",
      "date": "20 مايو 2026",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      appBar: AppBar(
        foregroundColor: Color.fromARGB(255, 246, 92, 128),
        title: const Text(
          "الديون المشتركة",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: mockDebts.length,
        itemBuilder: (context, index) {
          final debt = mockDebts[index];
          final isPaid = debt['status'] == 'Paid';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                // أيقونة ديناميكية متطورة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isPaid ? Colors.green : Colors.amber).withOpacity(
                      0.15,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_outline_rounded
                        : Icons.pending_actions_rounded,
                    color: isPaid ? Colors.greenAccent : Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 18),

                // تفاصيل الدين
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debt['date'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // المبلغ
                Text(
                  "${debt['amount']} \$",
                  style: TextStyle(
                    color: isPaid
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
