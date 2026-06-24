import 'dart:convert';

import 'package:goluto_business/src/features/business/domain/entities/offer.dart';

/// Encodes offer data into a QR payload string for the GoLuto user app scanner.
///
/// Format: `GOLUTO:` + JSON with version, offerId, and token.
/// The user app reads [Barcode.rawValue] as an opaque string today; this
/// contract is ready for future parsing and redemption API calls.
class OfferQrCodec {
  OfferQrCodec._();

  static const prefix = 'GOLUTO:';

  static String encode(Offer offer) {
    final payload = jsonEncode({
      'v': 1,
      'offerId': offer.id,
      'businessId': offer.businessId,
      'token': offer.qrToken,
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
