import 'l10n/translate.dart';
import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const name = 'The Date';
  static const product = 'general';
  static const api = 'https://api.thedate.now/products/general';
  static const website = 'https://thedate.now';
  static const version = '2.1.0';
  static const supportUrl = '$website/soporte';
  static const deletionUrl = 'https://crea.thedate.now/delete-account';
  static const support = 'lucasraulsantillanarevalo@gmail.com';
  static const googleClient = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '802955936980-stjng7n36q7d8rp7s1buggn20chl0t8q.apps.googleusercontent.com',
  );
  static const headingFont = 'Nunito';
  static String get loginTitle => tr("Tu gente,\nmás cerca.");
  static String get homeTitle => tr("Ya vienen.");
  static String get giftsTitle => tr("Regalos con cariño.");
  static const accent = Color(0xFF7451AC),
      paper = Color(0xFFFFFFFF),
      ink = Color(0xFF241638),
      soft = Color(0xFFEAE2FC);
}
