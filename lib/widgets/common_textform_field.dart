import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int? maxLine;
  final TextInputType? keyboard;
  final bool obscure;
  final Widget? prefix;
  final IconData? suffix;
  final VoidCallback? onSuffix;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;

  const AppTextField({
    required this.ctrl,
    required this.hint,
    this.maxLine,
    this.keyboard,
    this.obscure = false,
    this.prefix,
    this.suffix,
    this.onSuffix,
    this.validator,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      onChanged: onChange,
      maxLines: maxLine,
      style: const TextStyle(
        fontFamily: _AppTokens.font,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _AppTokens.navy,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: _AppTokens.font,
          fontSize: 14,
          color: _AppTokens.textDim,
        ),
        filled: true,
        fillColor: _AppTokens.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefix: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffix != null
            ? GestureDetector(
                onTap: onSuffix,
                child: Icon(suffix, size: 20, color: const Color(0xAA1A1A2E)),
              )
            : null,
        border: _border(),
        enabledBorder: _border(color: _AppTokens.border),
        focusedBorder: _border(color: _AppTokens.primary, width: 1.5),
        errorBorder: _border(color: const Color(0xFFC62828)),
        focusedErrorBorder: _border(color: const Color(0xFFC62828), width: 1.5),
        errorStyle: const TextStyle(
            fontFamily: _AppTokens.font,
            fontSize: 11,
            color: Color(0xFFC62828)),
      ),
    );
  }

  OutlineInputBorder _border(
      {Color color = _AppTokens.border, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _RememberToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _RememberToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? _AppTokens.primary : _AppTokens.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? _AppTokens.primary : const Color(0xFFCCCCCC),
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text('Remember me',
              style: TextStyle(
                fontFamily: _AppTokens.font,
                fontSize: 13,
                color: _AppTokens.navy.withOpacity(0.55),
              )),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _AppTokens.primaryDark,
            _AppTokens.primary,
            _AppTokens.primaryLight
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _AppTokens.primary.withOpacity(0.42),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.12),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sign In',
                          style: TextStyle(
                            fontFamily: _AppTokens.font,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          )),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _AppTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _AppTokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(
                  fontFamily: _AppTokens.font,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _AppTokens.navy,
                )),
          ],
        ),
      ),
    );
  }
}

class _AppTokens {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFD94F1A);
  static const Color primaryLight = Color(0xFFFF8C5A);
  static const Color primaryGlow = Color(0x70FF6B35);
  static const Color navy = Color(0xFF1A1A2E);
  static const Color bg = Color(0xFFFFF8F5);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFEFEFEF);
  static const Color textSub = Color(0x886B6B7B);
  static const Color textDim = Color(0x441A1A2E);
  static const String font = 'Poppins';
}
