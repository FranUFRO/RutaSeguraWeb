import '../models/supervisor_verification.dart';
import 'api_client.dart';
import 'auth_service.dart';

class AdminDocumentService {
  const AdminDocumentService(this._api, this._auth);

  final ApiClient _api;
  final AuthService _auth;

  String get _adminId => _auth.adminId;

  Future<List<SupervisorVerification>> getPendingVerifications() async {
    final response = await _api.get('/$_adminId/verifications/pending');
    return (response['verifications'] as List? ?? const [])
        .map((item) => SupervisorVerification.fromJson(Map<String, dynamic>.from(item as Map)))
        .where((verification) => verification.primaryDocument != null)
        .toList();
  }

  Future<SupervisorDocumentFile> getDocument(String documentId) async {
    final response = await _api.get('/$_adminId/documents/$documentId');
    return SupervisorDocumentFile.fromJson(
      Map<String, dynamic>.from(response['document_data'] as Map? ?? const {}),
    );
  }

  Future<void> validateDocument({
    required String documentId,
    required DocumentReviewStatus status,
    required String notes,
  }) async {
    final documentStatus = switch (status) {
      DocumentReviewStatus.approved => 'APPROVED',
      DocumentReviewStatus.rejected => 'REJECTED',
      DocumentReviewStatus.pending => throw const ApiException('Selecciona aprobar o rechazar el documento.'),
    };
    await _api.put('/$_adminId/documents/$documentId/validate', {
      'document_status': documentStatus,
      'verification_notes': notes.trim().isEmpty ? 'Sin observaciones.' : notes.trim(),
      'approval_date': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
