import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  final String title;

  const MyAccountPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.person,
              size: 80,
              color: colors.tertiary, // ✅ ambil dari theme
            ),
            const SizedBox(height: 15),
            Text(
              'Tidak Ada Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
