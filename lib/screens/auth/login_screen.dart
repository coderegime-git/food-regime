import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/routes/app_routes.dart';
import 'package:food_delivery_app/utils/api_service.dart';
import 'package:food_delivery_app/utils/helper.dart';
import 'package:food_delivery_app/utils/sharedpreference_helper.dart';
import 'package:food_delivery_app/utils/validator.dart';
import 'package:go_router/go_router.dart';

import '../../constants/asset_constants.dart';
import '../../widgets/common_textform_field.dart';

class LoginScreen extends StatefulWidget {
  bool? isGuest;

  LoginScreen({super.key, this.isGuest = false});

  @override
  State<LoginScreen> createState() => _PhoneEntryState();
}

class _PhoneEntryState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  String _code = '+91';
  bool _loading = false;
  final phoneNumberForm = GlobalKey<FormState>();
  late final AnimationController _ac;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 80), _ac.forward);
  }

  @override
  void dispose() {
    _ac.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    try {
      if (!phoneNumberForm.currentState!.validate()) {
        return;
      }
      FocusScope.of(context).unfocus();
      if (!(_formKey.currentState?.validate() ?? false)) return;
      setState(() => _loading = true);
      final data = await apiService.sendOTP(phoneNumber: _ctrl.text.trim());

      print(data);
      if (data['statusCode'] == 1) {
        Helper().showToast(context, data['message'], data['statusCode']);
        await Future.delayed(const Duration(milliseconds: 1400));
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.of(context).push(_slidePageRoute(
          OtpVerifyScreen(
            code: _code,
            phone: _ctrl.text.trim(),
            otp: data['otp'].toString(),
          ),
        ));
      } else {
        Helper().showToast(context, "Failed to send", 0);
        setState(() => _loading = false);
      }
    } catch (e) {
      print(e.toString());
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery
        .of(context)
        .padding;
    return WillPopScope(
      onWillPop: () async {
        if (widget.isGuest == false) {
          return true;
        } else {
          Navigator.of(context).pop();
        }
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _C.bg,
        body: Form(
          key: phoneNumberForm,
          child: Stack(children: [
            const _BgArt(),
            SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Stack(
                          children: [
                            Center(
                                child: Image.asset(
                                  AssetConstants.loginScreen,
                                  fit: BoxFit.cover,
                                  height: 400,
                                  width: double.infinity,
                                )),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsetsGeometry.all(8),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.isGuest == false) {
                                        if (mounted) context.go(AppRoutes.home);
                                      } else {
                                        if (mounted) context.canPop();
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.orange.shade100,
                                                offset: Offset(0, 4),
                                                blurRadius: 2,
                                                spreadRadius: 2)
                                          ],
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          gradient: const LinearGradient(
                                              colors: [
                                                _C.primary,
                                                Colors.orangeAccent
                                              ])),
                                      child: const Text(
                                        "Skip",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),

                        //      _BackBtn(onTap: () => Navigator.maybePop(context)),

                        // Illustration

                        // Heading

                        // Heading
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Enter your\nphone number',
                                  style: TextStyle(
                                    fontFamily: _C.font,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: _C.ink,
                                    height: 1.18,
                                  )),
                              const SizedBox(height: 10),
                              Text(
                                  "We'll send a one-time code to verify\nyour identity. No password needed!",
                                  style: TextStyle(
                                    fontFamily: _C.font,
                                    fontSize: 14,
                                    height: 1.6,
                                    color: _C.ink.withOpacity(0.5),
                                  )),
                              const SizedBox(height: 20),

                              // Phone input
                              AppTextField(
                                ctrl: _ctrl,
                                keyboard: TextInputType.number,
                                //code: _code,
                                prefix: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  child: const Text(
                                    "+91",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                validator: (v) {
                                  print(_ctrl);
                                  return Validator.validatePhoneNumber(v!);
                                },
                                onChange: (v) {
                                  //   setState(() => _code = v!);
                                },
                                hint: 'Mobile number',
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.lock_outline_rounded,
                                      size: 13, color: _C.primary),
                                  const SizedBox(width: 5),
                                  Text(
                                      'Your number is never shared with anyone.',
                                      style: TextStyle(
                                        fontFamily: _C.font,
                                        fontSize: 11,
                                        color: _C.ink.withOpacity(0.35),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 32),

                              _BigBtn(
                                  label: 'Send OTP',
                                  icon: Icons.send_rounded,
                                  loading: _loading,
                                  onTap: _send),
                              const SizedBox(height: 24),

                              // _Divider(label: 'or sign in with'),
                              // const SizedBox(height: 18),
                              //
                              // Row(
                              //   children: [
                              //     Expanded(child: _SocialTile(emoji: '🌐', label: 'Google', onTap: () {})),
                              //     const SizedBox(width: 12),
                              //     Expanded(child: _SocialTile(emoji: '🍎', label: 'Apple', onTap: () {})),
                              //   ],
                              // ),
                              // const SizedBox(height: 28),
                              //
                              // Center(
                              //   child: RichText(
                              //     text: TextSpan(
                              //       style: TextStyle(fontFamily: _C.font, fontSize: 13, color: _C.ink.withOpacity(0.5)),
                              //       children: [
                              //         const TextSpan(text: 'Already have an account?  '),
                              //         WidgetSpan(
                              //           child: GestureDetector(
                              //             onTap: () {},
                              //             child: const Text('Sign in',
                              //                 style: TextStyle(
                              //                   fontFamily: _C.font, fontSize: 13,
                              //                   fontWeight: FontWeight.w800, color: _C.primary,
                              //                 )),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class OtpVerifyScreen extends StatefulWidget {
  final String code;
  final String phone;
  final String otp;

  const OtpVerifyScreen(
      {super.key, required this.code, required this.phone, required this.otp});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerifyScreen>
    with TickerProviderStateMixin {
  static const int _len = 6;
  static const int _resendSecs = 30;

  final _ctrls = List.generate(_len, (_) => TextEditingController());
  final _nodes = List.generate(_len, (_) => FocusNode());
  bool _loading = false;
  bool _success = false;
  bool _error = false;
  int _tick = _resendSecs;
  Timer? _timer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Entrance
  late final AnimationController _enterAc;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Shake
  late final AnimationController _shakeAc;
  late final Animation<double> _shakeX;

  // Success scale
  late final AnimationController _successAc;
  late final Animation<double> _successScale;

  // Per-box bounce
  late final List<AnimationController> _boxAc;
  late final List<Animation<double>> _boxS;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();

    _enterAc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _enterAc, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterAc, curve: Curves.easeOutCubic));

    _shakeAc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -11.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -11.0, end: 11.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 11.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeAc, curve: Curves.easeInOut));

    _successAc = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _successScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _successAc, curve: Curves.elasticOut));

    _boxAc = List.generate(
        _len,
            (_) =>
            AnimationController(
                vsync: this, duration: const Duration(milliseconds: 260)));
    _boxS = _boxAc
        .map((c) =>
        Tween<double>(begin: 1.0, end: 1.2)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    Future.delayed(const Duration(milliseconds: 80), () {
      _enterAc.forward();
      _startTimer();
      Future.delayed(const Duration(milliseconds: 350), () async {
        for (int i = 0; i < widget.otp.length; i++) {
          _ctrls[i].text = widget.otp[i];
        }
        if (_ctrls.length >= 5) {
          await _verify();
        }
        //   if (mounted) _nodes[5].requestFocus();
      });
    });
  }

  void _startTimer() {
    _tick = _resendSecs;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_tick > 0) {
          _tick--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _enterAc.dispose();
    _shakeAc.dispose();
    _successAc.dispose();
    for (final c in _boxAc)
      c.dispose();
    for (final c in _ctrls)
      c.dispose();
    for (final n in _nodes)
      n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  bool get _full => _otp.length == _len;

  void _onChange(int i, String v) {
    // Handle paste
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (int j = 0; j < _len && j < digits.length; j++) {
        _ctrls[j].text = digits[j];
        _boxAc[j].forward(from: 0);
      }
      final next = digits.length < _len ? digits.length : _len - 1;
      _nodes[next].requestFocus();
      setState(() {});
      if (_full) Future.delayed(const Duration(milliseconds: 120), _verify);
      return;
    }
    if (v.isNotEmpty) {
      _boxAc[i].forward(from: 0);
      if (i < _len - 1) {
        _nodes[i + 1].requestFocus();
      } else {
        _nodes[i].unfocus();
      }
    }
    setState(() {});
    if (_full) Future.delayed(const Duration(milliseconds: 120), _verify);
  }

  void _onKey(int i, RawKeyEvent e) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
        i > 0) {
      _ctrls[i - 1].clear();
      _nodes[i - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _verify() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_loading || _success) return;

      setState(() {
        _loading = true;
        _error = false;
        _success = false;
      });
      if (!mounted) return;
      final data =
      await apiService.verifyOTP(phoneNumber: widget.phone, otp: _otp);
      print(data);
      if (data['statusCode'] == 1) {
        Helper().showToast(context, data['message'], data['statusCode']);
        SharedPreferenceHelper.setAuthToken(data['access_token']);
        SharedPreferenceHelper.saveRefreshToken(data['refresh_token']);
        SharedPreferenceHelper.setUserId(data['user']['id']);
        final res = await apiService.getProfile();
        SharedPreferenceHelper.setUserObject(res);
        setState(() {
          _loading = false;
          _success = true;
        });
        _successAc.forward();
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Helper().showToast(context, '🎉  Verified! Welcome to FoodRegime!',
              data['statusCode']);
        }
        if (data['first_time_with_role']) {
          if (mounted) {
            await context.push(AppRoutes.editProfilePath("fromHome"));
          }
        } else {
          if (mounted) context.go(AppRoutes.home);
        }
      } else {
        setState(() {
          _loading = false;
          _success = false;
        });
        Helper().showToast(context, 'Invalid or Expired OTP', 0);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _success = true;
      });
    }
  }

  void _resend() async {
    if (_tick > 0) return;
    for (final c in _ctrls)
      c.clear();
    setState(() => _error = false);
    _nodes[0].requestFocus();
    _startTimer();
    final data = await apiService.sendOTP(phoneNumber: widget.phone);

    print(data);
    if (data['statusCode'] == 1) {
      Helper().showToast(context, data['message'], data['statusCode']);

      Future.delayed(const Duration(milliseconds: 350), () async {
        for (int i = 0; i < data['otp']
            .toString()
            .length; i++) {
          _ctrls[i].text = data['otp'].toString()[i];
        }
        if (_ctrls.length >= 5) {
          await _verify();
        }
        //   if (mounted) _nodes[5].requestFocus();
      });

      //   if (mounted) _nodes[5].requestFocus();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
      Text(msg, style: const TextStyle(fontFamily: _C.font, fontSize: 13)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: _C.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery
        .of(context)
        .padding;
    return Scaffold(
      backgroundColor: _C.bg,
      body: Form(
        key: _formKey,
        child: Stack(children: [
          const _BgArt(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, pad.bottom + 24),
                  children: [
                    //  _BackBtn(onTap: () => Navigator.maybePop(context)),
                    const SizedBox(height: 44),

                    // Animated illustration
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _success
                            ? ScaleTransition(
                          key: const ValueKey('ok'),
                          scale: _successScale,
                          child: Image.asset(
                            AssetConstants.otpSuccess,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                            : _error
                            ? const _IconBox(
                            key: const ValueKey('err'),
                            color: const Color(0xFFC62828),
                            icon: Icons.warning_amber_rounded)
                            : Image.asset(
                          AssetConstants.password,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Heading
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _success
                          ? const Text('You\'re verified! 🎉',
                          key: ValueKey('h_ok'),
                          style: TextStyle(
                            fontFamily: _C.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                            height: 1.2,
                          ))
                          : _error
                          ? const Text('Wrong code.\nTry again.',
                          key: ValueKey('h_err'),
                          style: TextStyle(
                            fontFamily: _C.font,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC62828),
                            height: 1.2,
                          ))
                          : const Text('Check your\nmessages',
                          key: ValueKey('h_def'),
                          style: TextStyle(
                            fontFamily: _C.font,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: _C.ink,
                            height: 1.18,
                          )),
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontFamily: _C.font,
                            fontSize: 14,
                            height: 1.6,
                            color: _C.ink.withOpacity(0.5)),
                        children: [
                          const TextSpan(
                              text: 'Enter the 6-digit code sent to\n'),
                          TextSpan(
                            text: '${widget.code} ${widget.phone}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: _C.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // OTP boxes with shake
                    Center(
                      child: ConstrainedBox(
                        constraints:
                        const BoxConstraints(maxWidth: kIsWeb ? 520 : 320),
                        child: AnimatedBuilder(
                          animation: _shakeX,
                          builder: (_, child) =>
                              Transform.translate(
                                offset: Offset(_shakeX.value, 0),
                                child: child,
                              ),
                          child: SizedBox(
                            width: kIsWeb ? 400 : double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  _len,
                                      (i) =>
                                      ScaleTransition(
                                        scale: _boxS[i],
                                        child: _OtpBox(
                                          ctrl: _ctrls[i],
                                          node: _nodes[i],
                                          success: _success,
                                          error: _error,
                                          onChanged: (v) => _onChange(i, v),
                                          onKey: (e) => _onKey(i, e),
                                        ),
                                      )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Center(
                    //   child: Text('Hint: type "000000" to test wrong OTP',
                    //       style: TextStyle(
                    //         fontFamily: _C.font, fontSize: 11,
                    //         color: _C.ink.withOpacity(0.3),
                    //       )),
                    // ),
                    const SizedBox(height: 36),

                    _BigBtn(
                      label: _success ? 'Continue' : 'Verify Code',
                      icon: _success
                          ? Icons.arrow_forward_rounded
                          : Icons.verified_user_rounded,
                      loading: _loading,
                      enabled: _full && !_success,
                      onTap: _verify,
                    ),
                    const SizedBox(height: 32),

                    // Resend
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Didn't get the code?  ",
                                style: TextStyle(
                                    fontFamily: _C.font,
                                    fontSize: 13,
                                    color: _C.ink.withOpacity(0.5))),
                            GestureDetector(
                              onTap: _tick == 0 ? _resend : null,
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontFamily: _C.font,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _tick == 0
                                      ? _C.primary
                                      : _C.ink.withOpacity(0.25),
                                ),
                                child: const Text('Resend OTP'),
                              ),
                            ),
                          ],
                        ),
                        if (_tick > 0) ...[
                          const SizedBox(height: 14),
                          _Ring(seconds: _tick, total: _resendSecs),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── OTP Box ─────────────────────────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final bool success;
  final bool error;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;

  const _OtpBox({
    required this.ctrl,
    required this.node,
    required this.success,
    required this.error,
    required this.onChanged,
    required this.onKey,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.node.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _focused = widget.node.hasFocus);
  }

  @override
  void dispose() {
    widget.node.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.ctrl.text.isNotEmpty;

    final Color borderC = widget.success
        ? const Color(0xFF2E7D32)
        : widget.error
        ? const Color(0xFFC62828)
        : _focused
        ? _C.primary
        : filled
        ? _C.primary.withOpacity(0.5)
        : const Color(0xFFE0E0E0);

    final Color bgC = widget.success
        ? const Color(0xFFE8F5E9)
        : widget.error
        ? const Color(0xFFFFEBEE)
        : _focused
        ? _C.primary.withOpacity(0.04)
        : filled
        ? _C.primary.withOpacity(0.05)
        : Colors.white;

    final Color textC = widget.success
        ? const Color(0xFF2E7D32)
        : widget.error
        ? const Color(0xFFC62828)
        : _C.ink;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC, width: _focused ? 2.0 : 1.5),
        boxShadow: _focused
            ? [
          BoxShadow(
              color: _C.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ]
            : [],
      ),
      // Use a Stack so the TextField fills the box without any padding fighting
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: widget.onKey,
        child: Center(
          child: TextField(
            controller: widget.ctrl,
            focusNode: widget.node,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontFamily: _C.font,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textC,
              height: 1.0,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              isDense: true,
              filled: false,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}

// ─── Countdown Ring ───────────────────────────────────────────────────────────
class _Ring extends StatelessWidget {
  final int seconds;
  final int total;

  const _Ring({required this.seconds, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: seconds / total,
            strokeWidth: 3.5,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: const AlwaysStoppedAnimation(_C.primary),
          ),
          Text('${seconds}s',
              style: const TextStyle(
                fontFamily: _C.font,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.primary,
              )),
        ],
      ),
    );
  }
}

// ─── Background Art ───────────────────────────────────────────────────────────
class _BgArt extends StatelessWidget {
  const _BgArt();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: [
        Positioned(
          top: -90,
          right: -90,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _C.primary.withOpacity(0.1),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -70,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _C.primary.withOpacity(0.07),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _Dots())),
      ]),
    );
  }
}

class _Dots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _C.primary.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    const s = 28.0;
    for (double x = s / 2; x < size.width; x += s) {
      for (double y = s / 2; y < size.height; y += s) {
        canvas.drawCircle(Offset(x, y), 1.8, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IconBox({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.42),
              blurRadius: 22,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 48),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;

  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 15, color: _C.ink),
      ),
    );
  }
}

class _BigBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _BigBtn({
    required this.label,
    required this.icon,
    required this.loading,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return AnimatedOpacity(
      opacity: active ? 1.0 : 0.58,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD94F1A), Color(0xFFFF6B35), Color(0xFFFF8C5A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
            BoxShadow(
                color: _C.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.1),
            onTap: active ? onTap : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                Text(label,
                    style: const TextStyle(
                      fontFamily: _C.font,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    )),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;

  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) =>
      Row(children: [
        Expanded(child: Divider(color: Colors.grey.withOpacity(0.22))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(label,
                style: TextStyle(
                    fontFamily: _C.font,
                    fontSize: 11,
                    color: Colors.grey.withOpacity(0.55)))),
        Expanded(child: Divider(color: Colors.grey.withOpacity(0.22))),
      ]);
}

class _SocialTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _SocialTile(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: _C.font,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.ink)),
          ]),
        ),
      );
}

// ─── Route helper ─────────────────────────────────────────────────────────────
Route _slidePageRoute(Widget page) =>
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
      transitionDuration: const Duration(milliseconds: 360),
    );

// ─── Design tokens ────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFFFF6B35);
  static const ink = Color(0xFF1A1A2E);
  static const bg = Colors.white;
  static const String font = 'Poppins';
}
