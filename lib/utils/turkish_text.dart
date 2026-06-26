/// Türkçe alfabeye uygun büyük/küçük harf ve karşılaştırma yardımcıları.
///
/// Dart'taki varsayılan [String.toLowerCase], Türkçe `I`/`İ`/`ı`/`i`
/// kurallarını uygulamaz; bu yüzden arama ve eşleştirmede hata oluşur.
extension TurkishText on String {
  static const _turkishLowerMap = {
    'A': 'a',
    'B': 'b',
    'C': 'c',
    'Ç': 'ç',
    'D': 'd',
    'E': 'e',
    'F': 'f',
    'G': 'g',
    'Ğ': 'ğ',
    'H': 'h',
    'I': 'ı',
    'İ': 'i',
    'J': 'j',
    'K': 'k',
    'L': 'l',
    'M': 'm',
    'N': 'n',
    'O': 'o',
    'Ö': 'ö',
    'P': 'p',
    'R': 'r',
    'S': 's',
    'Ş': 'ş',
    'T': 't',
    'U': 'u',
    'Ü': 'ü',
    'V': 'v',
    'Y': 'y',
    'Z': 'z',
  };

  static const _turkishUpperMap = {
    'a': 'A',
    'b': 'B',
    'c': 'C',
    'ç': 'Ç',
    'd': 'D',
    'e': 'E',
    'f': 'F',
    'g': 'G',
    'ğ': 'Ğ',
    'h': 'H',
    'ı': 'I',
    'i': 'İ',
    'j': 'J',
    'k': 'K',
    'l': 'L',
    'm': 'M',
    'n': 'N',
    'o': 'O',
    'ö': 'Ö',
    'p': 'P',
    'r': 'R',
    's': 'S',
    'ş': 'Ş',
    't': 'T',
    'u': 'U',
    'ü': 'Ü',
    'v': 'V',
    'y': 'Y',
    'z': 'Z',
  };

  String toTurkishLowerCase() {
    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(_turkishLowerMap[char] ?? char.toLowerCase());
    }
    return buffer.toString();
  }

  String toTurkishUpperCase() {
    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(_turkishUpperMap[char] ?? char.toUpperCase());
    }
    return buffer.toString();
  }

  bool turkishContains(String other) {
    return toTurkishLowerCase().contains(other.toTurkishLowerCase());
  }

  int compareTurkish(String other) {
    return toTurkishLowerCase().compareTo(other.toTurkishLowerCase());
  }
}

/// Gemini ve diğer Türkçe metin üreticileri için ortak talimat.
const String turkishOrthographyInstruction =
    'Türkçe yanıtlarda doğru Türk alfabesini kullan: ı, i, ö, ü, ş, ğ, ç, İ. '
    'ASCII benzeri yazım kullanma (ör. "ogrenci" yerine "öğrenci", "isik" yerine "ışık").';
