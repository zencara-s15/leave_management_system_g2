import 'package:flutter/material.dart';

import 'db_connection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';
  static const double _logoContainerSize = 140;
  static const double _logoSize = 112;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B47E8),
      body: InkWell(
        key: const Key('home-hero-panel'),
        onTap: () {
          Navigator.pushNamed(context, DbConnectionScreen.routeName);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF4B47E8),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: _logoContainerSize,
                    height: _logoContainerSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: _logoSize,
                        height: _logoSize,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.work_history_rounded,
                                size: 60,
                                color: Color(0xFF4B47E8),
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Leave Management\nSystem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
