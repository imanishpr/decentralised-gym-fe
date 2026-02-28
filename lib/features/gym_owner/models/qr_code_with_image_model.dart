class QrCodeWithImageModel {
  final int gymId;
  final String gymName;
  final String code;
  final String qrPngBase64;

  const QrCodeWithImageModel({
    required this.gymId,
    required this.gymName,
    required this.code,
    required this.qrPngBase64,
  });

  factory QrCodeWithImageModel.fromJson(Map<String, dynamic> json) {
    return QrCodeWithImageModel(
      gymId: (json['gymId'] as num).toInt(),
      gymName: json['gymName'] as String? ?? '',
      code: json['code'] as String? ?? '',
      qrPngBase64: json['qrPngBase64'] as String? ?? '',
    );
  }
}
