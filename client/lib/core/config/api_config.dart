import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');

  static Uri get baseUri {
    if (_override.isNotEmpty) {
      return Uri.parse(_override);
    }

    if (kIsWeb) {
      return Uri.parse('http://localhost:8000');
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => Uri.parse('http://10.0.2.2:8000'),
      _ => Uri.parse('http://127.0.0.1:8000'),
    };
  }
}
