import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/security_provider.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _enteredPin = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _triggerBiometricOnStart();
  }

  void _triggerBiometricOnStart() async {
    final sec = Provider.of<SecurityProvider>(context, listen: false);
    if (sec.isBiometricEnabled) {
      final success = await sec.unlockWithBiometrics();
      if (success && mounted) {
        widget.onUnlocked();
      }
    }
  }

  void _onNumberTap(String number) async {
    if (_enteredPin.length < 4) {
      setState(() {
        _isError = false;
        _enteredPin += number;
      });

      if (_enteredPin.length == 4) {
        final sec = Provider.of<SecurityProvider>(context, listen: false);
        final valid = await sec.unlockWithPin(_enteredPin);
        if (valid && mounted) {
          widget.onUnlocked();
        } else {
          setState(() {
            _isError = true;
            _enteredPin = '';
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter Security PIN',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isError ? 'Incorrect PIN, please try again' : 'Access your medical history records',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: _isError ? AppColors.error : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError
                          ? AppColors.error
                          : isFilled
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh,
                      border: Border.all(
                        color: isFilled ? AppColors.primary : AppColors.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),

              // Custom Keypad
              Column(
                children: [
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((num) => _buildKeypadButton(num)).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Biometrics button
                        IconButton(
                          onPressed: () async {
                            final sec = Provider.of<SecurityProvider>(context, listen: false);
                            final ok = await sec.unlockWithBiometrics();
                            if (ok && mounted) widget.onUnlocked();
                          },
                          icon: const Icon(Icons.fingerprint, size: 34, color: AppColors.primary),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(68, 68),
                          ),
                        ),
                        _buildKeypadButton('0'),
                        IconButton(
                          onPressed: _onBackspace,
                          icon: const Icon(Icons.backspace_outlined, size: 26, color: AppColors.onSurfaceVariant),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(68, 68),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String num) {
    return InkWell(
      onTap: () => _onNumberTap(num),
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          num,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
