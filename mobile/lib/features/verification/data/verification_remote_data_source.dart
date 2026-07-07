import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../domain/entities/verification_status_result.dart';
import '../domain/failures/verification_failure.dart';

/// Remote verification API access via Dio.
class VerificationRemoteDataSource {
  VerificationRemoteDataSource(this._dio);

  final Dio _dio;

  /// Submits CNIC and face registration data for admin review.
  Future<VerificationStatusResult> submitVerification(
    VerificationSubmission submission,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.verificationSubmit,
      data: {
        'cnicNumber': submission.cnicNumber,
        'cnicFrontImageUrl': submission.cnicFrontImageUrl,
        'cnicBackImageUrl': submission.cnicBackImageUrl,
      },
    );

    return _parseStatus(response.data);
  }

  /// Fetches the authenticated user's verification status.
  Future<VerificationStatusResult> getVerificationStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.verificationStatus,
    );

    return _parseStatus(response.data);
  }

  VerificationStatusResult _parseStatus(Map<String, dynamic>? body) {
    final data = _readDataMap(body);
    final statusJson = data['status'];

    if (statusJson is! Map<String, dynamic>) {
      throw const VerificationFailure(
        'Unexpected response from verification API.',
      );
    }

    return VerificationStatusResult.fromJson(statusJson);
  }

  Map<String, dynamic> _readDataMap(Map<String, dynamic>? body) {
    if (body == null) {
      throw const VerificationFailure('Empty response from verification API.');
    }

    if (body['success'] == false) {
      throw VerificationFailure(_messageFromBody(body));
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const VerificationFailure(
        'Unexpected response from verification API.',
      );
    }

    return data;
  }

  /// Converts Dio and API envelope errors into [VerificationFailure].
  static VerificationFailure mapException(Object error) {
    if (error is VerificationFailure) {
      return error;
    }

    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        return VerificationFailure(_messageFromBody(responseData));
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const VerificationFailure(
            'Connection timed out. Check your network and try again.',
          );
        case DioExceptionType.connectionError:
          return const VerificationFailure(
            'Unable to reach the server. Check your connection and API URL.',
          );
        default:
          return const VerificationFailure(
            'Network request failed. Please try again.',
          );
      }
    }

    return const VerificationFailure('Something went wrong. Please try again.');
  }

  static String _messageFromBody(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['msg'] is String) {
        return first['msg'] as String;
      }
      if (first is String) {
        return first;
      }
    }

    return 'Request failed. Please try again.';
  }
}
