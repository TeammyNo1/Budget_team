import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/wave_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
      // ถ้าสำเร็จ _AuthGate จะสลับหน้าให้เอง
    } catch (e) {
      if (mounted) setState(() => _error = 'เข้าสู่ระบบไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _BeachBackdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: Beach.oceanGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Beach.seaDeep.withOpacity(.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.beach_access,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Beach Budget',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Beach.seaDeep,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'บันทึกรายรับ–รายจ่าย ให้เงินไหลไปตามแผน\nสบาย ๆ เหมือนนั่งริมทะเล',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Beach.inkSoft, height: 1.5),
                  ),
                  const Spacer(),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Beach.coral.withOpacity(.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Beach.coral.withOpacity(.4)),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: Beach.coral)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _GoogleButton(busy: _busy, onTap: _signIn),
                  const SizedBox(height: 16),
                  const Text(
                    'ข้อมูลทั้งหมดเก็บในบัญชี Google ของคุณเอง',
                    style: TextStyle(fontSize: 12, color: Beach.inkSoft),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: busy ? null : onTap,
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.g_mobiledata, size: 30),
                  SizedBox(width: 6),
                  Text('เข้าสู่ระบบด้วย Google', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }
}

/// พื้นหลังทราย + คลื่นทะเลด้านล่าง
class _BeachBackdrop extends StatelessWidget {
  const _BeachBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Beach.shell, Beach.sand, Beach.sandDeep],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(painter: WavePainter()),
        ),
      ),
    );
  }
}
