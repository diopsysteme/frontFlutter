import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneAuthInput extends StatefulWidget {
  final bool isOtpMode;
  final Function(String) onPhoneSubmitted;
  final Function(String) onOtpSubmitted;
  final VoidCallback onResendOtp;

  const PhoneAuthInput({
    Key? key,
    this.isOtpMode = false,
    required this.onPhoneSubmitted,
    required this.onOtpSubmitted,
    required this.onResendOtp,
  }) : super(key: key);

  @override
  State<PhoneAuthInput> createState() => _PhoneAuthInputState();
}

class _PhoneAuthInputState extends State<PhoneAuthInput> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return widget.isOtpMode
        ? _buildOtpInput()
        : _buildPhoneInput();
  }

  Widget _buildPhoneInput() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone_rounded),
            labelText: 'Numéro de téléphone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => widget.onPhoneSubmitted(_phoneController.text),
          child: Text(
            'Envoyer le code OTP',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            labelText: 'Code OTP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLength: 6,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => widget.onOtpSubmitted(_otpController.text),
          child: Text(
            'Vérifier le code',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onResendOtp,
          child: Text(
            'Renvoyer le code',
            style: GoogleFonts.poppins(color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
