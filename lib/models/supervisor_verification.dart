enum DocumentReviewStatus { pending, approved, rejected }

class SupervisorVerification {
  const SupervisorVerification({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rut,
    required this.organization,
    required this.documents,
  });
  final String id;
  final String name;
  final String email;
  final String phone;
  final String rut;
  final String organization;
  final List<VerificationDocument> documents;

  factory SupervisorVerification.fromJson(Map<String, dynamic> json) {
    final supervisors = json['supervisors'] as List? ?? const [];
    final supervisor = supervisors.isEmpty
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(supervisors.first as Map);
    return SupervisorVerification(
      id: (json['id_organization'] ?? '').toString(),
      name: (supervisor['full_name'] ?? 'Supervisor sin asignar').toString(),
      email: (supervisor['email'] ?? '').toString(),
      phone: (supervisor['phone_number'] ?? '').toString(),
      rut: (supervisor['rut'] ?? '').toString(),
      organization: (json['organization'] ?? '').toString(),
      documents: (json['documents'] as List? ?? const [])
          .map((item) => VerificationDocument.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    return parts.isEmpty ? '?' : (parts.length == 1 ? parts.first[0] : '${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}

class VerificationDocument {
  const VerificationDocument({required this.id, required this.fileName, required this.status});
  final String id;
  final String fileName;
  final DocumentReviewStatus status;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) => VerificationDocument(
        id: (json['id_document'] ?? '').toString(),
        fileName: (json['file_name'] ?? 'documento.pdf').toString(),
        status: switch ((json['document_status'] ?? '').toString().toUpperCase()) {
          'APPROVED' => DocumentReviewStatus.approved,
          'REJECTED' => DocumentReviewStatus.rejected,
          _ => DocumentReviewStatus.pending,
        },
      );
}
