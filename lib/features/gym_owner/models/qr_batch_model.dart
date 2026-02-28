class QrBatchModel {
  final int id;
  final int gymId;
  final String gymName;
  final String batchName;
  final int totalCodes;
  final String createdAt;
  final List<String> codes;

  const QrBatchModel({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.batchName,
    required this.totalCodes,
    required this.createdAt,
    required this.codes,
  });

  factory QrBatchModel.fromJson(Map<String, dynamic> json) {
    return QrBatchModel(
      id: (json['id'] as num).toInt(),
      gymId: (json['gymId'] as num).toInt(),
      gymName: json['gymName'] as String? ?? '',
      batchName: json['batchName'] as String? ?? '',
      totalCodes: (json['totalCodes'] as num).toInt(),
      createdAt: json['createdAt'] as String? ?? '',
      codes: (json['codes'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(growable: false),
    );
  }
}
