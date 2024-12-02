// email_service.dart

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final smtpServer = gmail('diopmail.test@gmail.com', 'anfg kvwo qjof tled');
    
    final message = Message()
      ..from = Address('diopmail.test@gmail.com', 'APPLI')
      ..recipients.add(to)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'email: $e');
    }
  }
}