import 'package:dio/dio.dart';
import 'package:aajhee_business/src/services/dio_service.dart';
import 'package:aajhee_business/src/utils/failure.dart';
import 'package:aajhee_business/src/utils/typedefs.dart';
import 'package:fpdart/fpdart.dart';

class CommerceApiService {
  CommerceApiService(this._dio);

  final DioService _dio;

  FutureEither<List<Map<String, dynamic>>> getProducts() async {
    final result = await _dio.get('/business/products');
    return result.fold(left, (response) {
      final data = response.data;
      if (data is List) {
        return right(data.cast<Map<String, dynamic>>());
      }
      if (data is Map && data['results'] is List) {
        return right((data['results'] as List).cast<Map<String, dynamic>>());
      }
      return left(ServerFailure('Unexpected products response.'));
    });
  }

  FutureEither<Map<String, dynamic>> createProduct(
    Map<String, dynamic> payload,
  ) async {
    final result = await _dio.post('/business/products', data: payload);
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final result = await _dio.patch('/business/products/$id', data: payload);
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<void> deleteProduct(int id) async {
    final result = await _dio.delete('/business/products/$id');
    return result.map((_) {});
  }

  FutureEither<Map<String, dynamic>> applyDiscount(
    int id, {
    double? discountPercent,
    double? salePrice,
    bool clear = false,
  }) async {
    final result = await _dio.post(
      '/business/products/$id/discount',
      data: {
        if (clear) 'clear': true,
        if (discountPercent != null) 'discount_percent': discountPercent,
        if (salePrice != null) 'sale_price': salePrice,
      },
    );
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> bulkDiscount({
    required double discountPercent,
    List<int>? productIds,
    bool allProducts = false,
  }) async {
    final result = await _dio.post(
      '/business/products/bulk-discount',
      data: {
        'discount_percent': discountPercent,
        'all_products': allProducts,
        if (productIds != null) 'product_ids': productIds,
      },
    );
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<List<Map<String, dynamic>>> getOrders({String? status}) async {
    final result = await _dio.get(
      '/business/orders',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return result.fold(left, (response) {
      final data = response.data;
      if (data is List) {
        return right(data.cast<Map<String, dynamic>>());
      }
      if (data is Map && data['results'] is List) {
        return right((data['results'] as List).cast<Map<String, dynamic>>());
      }
      return left(ServerFailure('Unexpected orders response.'));
    });
  }

  FutureEither<Map<String, dynamic>> updateOrderStatus(
    String publicId,
    String status, {
    String reason = '',
  }) async {
    final result = await _dio.post(
      '/business/orders/$publicId/status',
      data: {'status': status, 'reason': reason},
    );
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> reviewPaymentProof(
    String publicId,
    int proofId, {
    required String reviewStatus,
    String note = '',
  }) async {
    final result = await _dio.post(
      '/business/orders/$publicId/payment-proofs/$proofId/review',
      data: {'review_status': reviewStatus, 'review_note': note},
    );
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> getStats() async {
    final result = await _dio.get('/business/stats');
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> getFulfillment(int branchId) async {
    final result = await _dio.get('/business/branches/$branchId/fulfillment');
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<Map<String, dynamic>> updateFulfillment(
    int branchId,
    Map<String, dynamic> payload,
  ) async {
    final result = await _dio.patch(
      '/business/branches/$branchId/fulfillment',
      data: payload,
    );
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }

  FutureEither<List<Map<String, dynamic>>> getContacts(int branchId) async {
    final result = await _dio.get('/business/branches/$branchId/contacts');
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      return left(ServerFailure('Unexpected contacts response.'));
    });
  }

  FutureEither<List<Map<String, dynamic>>> saveContacts(
    int branchId,
    List<Map<String, dynamic>> contacts,
  ) async {
    final result = await _dio.put(
      '/business/branches/$branchId/contacts',
      data: contacts,
    );
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      return left(ServerFailure('Unexpected contacts response.'));
    });
  }

  FutureEither<List<Map<String, dynamic>>> getCategories() async {
    final result = await _dio.get('/categories');
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      if (data is Map && data['results'] is List) {
        return right((data['results'] as List).cast<Map<String, dynamic>>());
      }
      return left(ServerFailure('Unexpected categories response.'));
    });
  }

  FutureEither<Map<String, dynamic>> updatePresence(
    Map<String, dynamic> payload,
  ) async {
    final result = await _dio.patch('/business/presence', data: payload);
    return result.fold(left, (r) => right(Map<String, dynamic>.from(r.data as Map)));
  }
}
