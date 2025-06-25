import "package:dietitian/widget/common_themes.dart";
import "package:flutter/material.dart";

Widget customLoadingIndicator(String message) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 100.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withValues(alpha: 0.8),
          ),
          strokeWidth: 4.0,
        ),
      ),
      SizedBox(width: 10),
      Padding(
        padding: const EdgeInsets.only(right: 100.0),
        child: Text(message),
      ),
    ],
  );
}

Widget customLargeBoldColoredText(String text, BuildContext context) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).primaryColor,
    ),
  );
}

Widget customCardButton(
  IconData icon,
  String label,
  String? routeName,
  BuildContext context, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap ?? () => Navigator.pushNamed(context, routeName!),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.teal),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

Widget customElevatedButton({
  required VoidCallback onPressed,
  required IconData icon,
  required String label,
  required bool isValid,
}) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          isValid ? Colors.white.withValues(alpha: 0.9) : Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    ),
    onPressed: isValid ? onPressed : null,
    icon: Icon(icon, color: isValid ? Colors.teal : Colors.grey, size: 24),
    label: Text(
      label,
      style: TextStyle(
        color: isValid ? Colors.black : Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget customInputTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required TextInputType keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
    child: TextField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: customInputDecoration(label, icon),
      keyboardType: keyboardType,
    ),
  );
}

Widget customDropdownButton({
  required String selectedValue,
  required List<String> options,
  required ValueChanged<String?> onChanged,
  required String label,
  required IconData icon,
  String unselectedLabel = '未選択',
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
    child: DropdownButtonFormField<String>(
      value: selectedValue == '' ? unselectedLabel : selectedValue,
      style: TextStyle(color: Colors.black),
      decoration: customInputDecoration(label, icon),
      items:
          options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
      onChanged: onChanged,
    ),
  );
}
