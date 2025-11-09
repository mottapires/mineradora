class LoadingRecord {
  final int? id;
  final int userId;
  final String dataTrabalho;
  final int machineId;
  final int numViagens;
  final String tipoCaminhao;
  final bool synced;
  final String createdAt;

  LoadingRecord({
    this.id,
    required this.userId,
    required this.dataTrabalho,
    required this.machineId,
    required this.numViagens,
    required this.tipoCaminhao,
    this.synced = false,
    required this.createdAt,
  });

  factory LoadingRecord.fromJson(Map<String, dynamic> json) {
    return LoadingRecord(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      dataTrabalho: json['data_trabalho'] as String,
      machineId: json['machine_id'] as int,
      numViagens: json['num_viagens'] as int,
      tipoCaminhao: json['tipo_caminhao'] as String,
      synced: (json['synced'] as int) == 1,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'data_trabalho': dataTrabalho,
      'machine_id': machineId,
      'num_viagens': numViagens,
      'tipo_caminhao': tipoCaminhao,
      'synced': synced ? 1 : 0,
      'created_at': createdAt,
    };
  }
  
  // Método para calcular metros cúbicos estimados
  double get estimatedCubicMeters => numViagens * 1.5;
  
  // Método para calcular valor estimado
  double get estimatedValue => estimatedCubicMeters * 30.0;
}