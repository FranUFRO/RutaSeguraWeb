enum DocumentReviewStatus { pending, approved, rejected }

class SupervisorVerification {
  const SupervisorVerification({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.email,
    required this.phone,
    required this.rut,
    required this.organization,
    required this.documents,
  });

  final String id;
  final String organizationId;
  final String name;
  final String email;
  final String phone;
  final String rut;
  final String organization;
  final List<VerificationDocument> documents;

  VerificationDocument? get primaryDocument => documents.isEmpty ? null : documents.first;

  factory SupervisorVerification.fromJson(Map<String, dynamic> json) {
    final supervisor = Map<String, dynamic>.from((json['supervisor'] as Map?) ?? const {});
    final organization = Map<String, dynamic>.from((json['organization'] as Map?) ?? const {});

    return SupervisorVerification(
      id: (supervisor['id_user'] ?? '').toString(),
      organizationId: (organization['id_organization'] ?? '').toString(),
      name: (supervisor['full_name'] ?? 'Supervisor sin asignar').toString(),
      email: (supervisor['email'] ?? '').toString(),
      phone: (supervisor['phone_number'] ?? '').toString(),
      rut: (supervisor['rut'] ?? '').toString(),
      organization: (organization['name'] ?? 'Sin organización').toString(),
      documents: (json['documents'] as List? ?? const [])
          .map((item) => VerificationDocument.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    return parts.isEmpty
        ? '?'
        : (parts.length == 1 ? parts.first[0] : '${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}

class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.fileName,
    required this.status,
  });

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

class SupervisorDocumentFile {
  const SupervisorDocumentFile({
    required this.fileName,
    required this.fileType,
    required this.contentBase64,
    this.uploadDate,
  });

  final String fileName;
  final String fileType;
  final String contentBase64;
  final String? uploadDate;

  factory SupervisorDocumentFile.fromJson(Map<String, dynamic> json) => SupervisorDocumentFile(
        fileName: (json['file_name'] ?? 'documento.pdf').toString(),
        fileType: (json['file_type'] ?? 'PDF').toString(),
        uploadDate: json['upload_date']?.toString(),
        contentBase64: (json['content_base64'] ?? '').toString(),
      );
}
