import 'dart:convert';

import 'package:goluto_business/src/features/business/domain/entities/offer.dart';

/// Encodes offer data into a QR payload string for the GoLuto user app scanner.
///
/// Format: `GOLUTO:` + JSON with version, offerId, and qr_code UUID.
/// The consumer app validates the UUID against the backend scan/redeem APIs.
class OfferQrCodec {
  OfferQrCodec._();

  static const prefix = 'GOLUTO:';

  static String encode(Offer offer) {
    final payload = jsonEncode({
      'v': 1,
      'offerId': int.tryParse(offer.id) ?? offer.id,
      'qr_code': offer.qrCode,
      // Legacy alias kept for older scanner builds.
      'token': offer.qrCode,
    });
    return '$prefix$payload';
  }

  static Map<String, dynamic>? decode(String raw) {
    if (!raw.startsWith(prefix)) return null;
    try {
      return jsonDecode(raw.substring(prefix.length)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
