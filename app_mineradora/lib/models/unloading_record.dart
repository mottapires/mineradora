class UnloadingRecord {
  final int? id;
  final int userId;
  final String dataSaida;
  final String placa;
  final double metrosCubicos;
  final String motorista;
  final bool synced;
  final String createdAt;

  UnloadingRecord({
    this.id,
    required this.userId,
    required this.dataSaida,
    required this.placa,
    required this.metrosCubicos,
    required this.motorista,
    this.synced = false,
    required this.createdAt,
  });

  factory UnloadingRecord.fromJson(Map<String, dynamic> json) {
    return UnloadingRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      dataSaida: json['data_saida'] as String,
      placa: json['placa'] as String,
      metrosCubicos: (json['metros_cubicos'] as num).toDouble(),
      motorista: json['motorista'] as String,
      synced: (json['synced'] as int) == 1,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'data_saida': dataSaida,
      'placa': placa,
      'metros_cubicos': metrosCubicos,
      'motorista': motorista,
      'synced': synced ? 1 : 0,
      'created_at': createdAt,
    };
  }
  
  // Método para calcular valor
  double calculateValue(double pricePerCubicMeter) => metrosCubicos * pricePerCubicMeter;
}