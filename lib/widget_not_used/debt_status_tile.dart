import 'package:flutter/material.dart';

/* تمثيل بصري للديون المذكورة في متطلبات النظام (صفحة 15) */
class DebtStatusTile extends StatelessWidget {
  final String personName;
  final double amount;
  final bool isIOweThem; // هل أنا المدين أم الدائن؟

  const DebtStatusTile({
    required this.personName,
    required this.amount,
    required this.isIOweThem,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIOweThem ? Colors.red[100] : Colors.green[100],
        child: Icon(
          isIOweThem ? Icons.arrow_outward : Icons.arrow_downward,
          color: isIOweThem ? Colors.red : Colors.green,
        ),
      ),
      title: Text(personName),
      subtitle: Text(isIOweThem ? "يجب أن تدفع له" : "يجب أن يدفع لك"),
      trailing: Text(
        "\$${amount.toStringAsFixed(2)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIOweThem ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
