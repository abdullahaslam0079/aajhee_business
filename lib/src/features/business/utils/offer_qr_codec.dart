import 'dart:convert';

import 'package:aajhee_business/src/features/business/domain/entities/offer.dart';

/// Encodes offer data into a QR payload string for the Aajhee user app scanner.
///
/// Format: `AAJHEE:` + JSON with version, offerId, qr_code, and branch_id.
/// The consumer app resolves the offer via `/api/offers/by-qr/{qr_code}?branch_id=`.
class OfferQrCodec {
  OfferQrCodec._();

  static const prefix = 'AAJHEE:';

  static String encode(
    Offer offer, {
    String? branchId,
  }) {
    final payload = <String, dynamic>{
      'v': 1,
      'offerId': int.tryParse(offer.id) ?? offer.id,
      'qr_code': offer.qrCode,
      'token': offer.qrCode,
    };
    if (branchId != null && branchId.isNotEmpty) {
      final parsedBranchId = int.tryParse(branchId);
      payload['branch_id'] = parsedBranchId ?? branchId;
    }
    return '$prefix${jsonEncode(payload)}';
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
