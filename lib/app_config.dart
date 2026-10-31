import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const name = 'The Date';
  static const product = 'general';
  static const api = 'https://api.thedate.now/products/general';
  static const website = 'https://thedate.now';
  static const support = 'lucasraulsantillanarevalo@gmail.com';
  static const googleClient = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '802955936980-stjng7n36q7d8rp7s1buggn20chl0t8q.apps.googleusercontent.com',
  );
  static const headingFont = 'Nunito';
  static const loginTitle = 'Tu celebración,\nsin complicaciones.';
  static const homeTitle = 'Ya dijeron que sí.';
  static const giftsTitle = 'Cada detalle\ntiene un nombre.';
  static const accent = Color(0xFF7451AC),
      paper = Color(0xFFFFF9ED),
      ink = Color(0xFF241638),
      soft = Color(0xFFF4B93C);
}
