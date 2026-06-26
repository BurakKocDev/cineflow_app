import 'package:flutter/services.dart';

/// Haptic feedback helper sınıfı
class HapticFeedbackHelper {
  /// Hafif titreşim (seçim için)
  static void lightImpact() {
    HapticFeedback.selectionClick();
  }

  /// Orta titreşim (buton basımı için)
  static void mediumImpact() {
    HapticFeedback.lightImpact();
  }

  /// Güçlü titreşim (önemli aksiyonlar için)
  static void heavyImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Başarı titreşimi
  static void success() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Hata titreşimi
  static void error() {
    HapticFeedback.heavyImpact();
  }
}

