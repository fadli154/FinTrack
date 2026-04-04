import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.sticky_note_2_outlined,
              size: 80,
              color: colors.tertiary.withAlpha(300),
            ),
            const SizedBox(height: 15),
            Text(
              'Tidak Ada catatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.tertiary.withAlpha(300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
