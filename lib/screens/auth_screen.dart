import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'orbit_main_screen.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthStep { welcome, phone, otp, profile }

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthStep _currentStep = AuthStep.welcome;
  
  late AnimationController _bgRotationController;
  late AnimationController _pulseController;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // OTP İçin Odak ve Kontrol Yönetimi
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _bgRotationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgRotationController.dispose();
    _pulseController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    for (var node in _otpFocusNodes) { node.dispose(); }
    for (var controller in _otpControllers) { controller.dispose(); }
    super.dispose();
  }

  void _nextStep(AuthStep next) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep = next;
    });
  }

  void _finishAuth() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OrbitMainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgRotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _bgRotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  painter: AuthBackgroundPainter(pulseValue: _pulseController.value),
                ),
              );
            }
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStepWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case AuthStep.welcome: return _buildWelcomeStep();
      case AuthStep.phone: return _buildPhoneStep();
      case AuthStep.otp: return _buildOtpStep();
      case AuthStep.profile: return _buildProfileStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 10)]
          ),
          child: const Icon(Icons.radar, size: 80, color: Colors.cyanAccent),
        ),
        const SizedBox(height: 40),
        const Text("ORBIT", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 8.0)),
        const SizedBox(height: 10),
        const Text("Yeni Nesil Telsiz Ağı", style: TextStyle(color: Colors.cyanAccent, fontSize: 16, letterSpacing: 2.0, fontStyle: FontStyle.italic)),
        const SizedBox(height: 80),
        
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return GestureDetector(
              onTap: () => _nextStep(AuthStep.phone),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3 + (_pulseController.value * 0.3)), blurRadius: 20)]
                ),
                child: const Text("YÖRÜNGEYE KATIL", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            );
          }
        )
      ],
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      key: const ValueKey('phone'),
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cell_tower, size: 60, color: Colors.cyanAccent),
          const SizedBox(height: 30),
          const Text("Kimliğini Doğrula", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          const Text("Rehberindeki arkadaşlarınla anında eşleşmek için numaranı gir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 40),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.3)))),
                  child: const Text("+90", style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2.0),
                    decoration: const InputDecoration(hintText: "5XX XXX XX XX", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          GestureDetector(
            onTap: () => _nextStep(AuthStep.otp),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: const Text("KOD GÖNDER", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          )
        ],
      ),
    );
  }

  // --- GÜNCELLENEN AŞAMA 3: SMS KODU (OTP) ---
  Widget _buildOtpStep() {
    // DÜZELTME 2: Ekran oluşturulduktan hemen sonra ilk kutucuğa odaklan.
    // Bu sayede klavye otomatik olarak açılacaktır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == AuthStep.otp) {
        _otpFocusNodes[0].requestFocus();
      }
    });

    return Padding(
      key: const ValueKey('otp'),
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read, size: 60, color: Colors.greenAccent),
          const SizedBox(height: 30),
          const Text("Kodu Gir", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Text("+90 ${_phoneController.text.isEmpty ? '555...' : _phoneController.text} numarasına gönderilen 6 haneli kodu gir.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 45, height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.1), blurRadius: 10)]
                ),
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  // autofocus: index == 0, // <-- BU SATIRI KALDIRDIK, manuel odaklama kullanıyoruz.
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 5) {
                        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                      } else {
                        FocusScope.of(context).unfocus();
                      }
                    } else {
                      if (index > 0) {
                        FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                      }
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          
          GestureDetector(
            onTap: () => _nextStep(AuthStep.profile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
              child: const Text("DOĞRULA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return Padding(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Kimliğini Yarat", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 40),
          
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade900, border: Border.all(color: Colors.cyanAccent, width: 2)),
                child: const Icon(Icons.person, size: 50, color: Colors.white54),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent),
                child: const Icon(Icons.add_a_photo, size: 20, color: Colors.black),
              )
            ],
          ),
          const SizedBox(height: 40),

          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            cursorColor: Colors.cyanAccent,
            decoration: const InputDecoration(
              hintText: "Adın Soyadın",
              hintStyle: TextStyle(color: Colors.white30),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          const SizedBox(height: 60),

          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: _finishAuth,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.4 + (_pulseController.value * 0.4)), blurRadius: 20, spreadRadius: 2)]
                  ),
                  // DÜZELTME 1: Metni Flexible ile sarmalayıp, Row'u ortaladık.
                  // Artık metin sığmazsa "..." şeklinde kısaltılacak ve taşma olmayacak.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Flexible(
                        child: Text(
                          "BENİ YÖRÜNGEYE FIRLAT", 
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.rocket_launch, color: Colors.black, size: 20),
                    ],
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}

class AuthBackgroundPainter extends CustomPainter {
  final double pulseValue;
  AuthBackgroundPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    void drawRing(double radius, Color color, double strokeW, double blur) {
      final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeW..maskFilter = MaskFilter.blur(BlurStyle.solid, blur);
      canvas.drawCircle(center, radius, paint);
    }
    drawRing(size.width * 0.6, Colors.cyanAccent.withValues(alpha: 0.1), 1, 10);
    drawRing(size.width * 0.8, Colors.blueAccent.withValues(alpha: 0.05), 2, 20);
    drawRing(size.width * 1.0, Colors.purpleAccent.withValues(alpha: 0.05), 1, 15);
    drawRing(size.width * 1.2, Colors.greenAccent.withValues(alpha: 0.03 + (pulseValue * 0.05)), 4, 30);
  }
  @override
  bool shouldRepaint(covariant AuthBackgroundPainter oldDelegate) => true;
}