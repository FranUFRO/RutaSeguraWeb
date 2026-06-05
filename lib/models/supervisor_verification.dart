class SupervisorVerification {
  const SupervisorVerification({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rut,
    required this.organization,
    required this.location,
    required this.submittedAt,
    required this.documents,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String rut;
  final String organization;
  final String location;
  final DateTime submittedAt;
  final List<VerificationDocument> documents;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class VerificationDocument {
  const VerificationDocument({
    required this.id,
    required this.title,
    required this.fileName,
    required this.pageCount,
    required this.status,
  });

  final String id;
  final String title;
  final String fileName;
  final int pageCount;
  final DocumentReviewStatus status;
}

enum DocumentReviewStatus {
  pending,
  approved,
  rejected,
}

extension DocumentReviewStatusLabel on DocumentReviewStatus {
  String get label {
    return switch (this) {
      DocumentReviewStatus.pending => 'Pendiente',
      DocumentReviewStatus.approved => 'Validado',
      DocumentReviewStatus.rejected => 'Rechazado',
    };
  }
}
