import 'package:flutter/material.dart';
import 'package:app_mineradora/models/user.dart';
import 'package:app_mineradora/models/loading_record.dart';
import 'package:app_mineradora/services/database_service.dart';
import 'package:app_mineradora/services/api_service.dart';
import 'package:app_mineradora/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class OperatorScreen extends StatefulWidget {
  final User user;
  
  const OperatorScreen({super.key, required this.user});

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _tripsController = TextEditingController();
  final _truckTypeController = TextEditingController();
  
  int _selectedMachine = 1;
  bool _isSyncing = false;
  bool _isSaving = false;
  List<LoadingRecord> _pendingRecords = [];
  double _pricePerCubicMeter = 30.0; // Preço por m³
  
  final List<Map<String, dynamic>> _machines = [
    {'id': 1, 'name': 'Escavadeira CAT 320'},
    {'id': 2, 'name': 'Escavadeira Komatsu PC200'},
    {'id': 3, 'name': 'Pá Carregadeira JCB 3CX'},
    {'id': 4, 'name': 'Retroescavadeira CAT 416'},
    {'id': 5, 'name': 'Escavadeira HYDRA 1100'},
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadPendingRecords();
    _loadConfig();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _tripsController.dispose();
    _truckTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await ApiService.instance.getConfig();
      if (config != null && config['preco_m3'] != null) {
        setState(() {
          _pricePerCubicMeter = double.parse(config['preco_m3'].toString());
        });
      }
    } catch (e) {
      // Manter o valor padrão
    }
  }

  Future<void> _loadPendingRecords() async {
    final records = await DatabaseService.instance.getUnsyncedLoadingRecords(widget.user.id);
    setState(() {
      _pendingRecords = records;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final record = LoadingRecord(
        userId: widget.user.id,
        dataTrabalho: _dateController.text,
        machineId: _selectedMachine,
        numViagens: int.parse(_tripsController.text),
        tipoCaminhao: _truckTypeController.text,
        createdAt: DateTime.now().toIso8601String(),
      );

      await DatabaseService.instance.insertLoadingRecord(record);
      await _loadPendingRecords();

      // Limpar formulário
      _tripsController.clear();
      _truckTypeController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro salvo localmente!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Tentar sincronizar imediatamente
      await _syncPendingRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _syncPendingRecords() async {
    final isConnected = await ApiService.instance.checkConnectivity();
    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sem conexão. Os dados serão sincronizados quando houver internet.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final records = await DatabaseService.instance.getUnsyncedLoadingRecords(widget.user.id);
      int syncedCount = 0;
      
      for (var record in records) {
        final success = await ApiService.instance.syncLoadingRecord(record);
        if (success) {
          await DatabaseService.instance.markLoadingRecordAsSynced(record.id!);
          syncedCount++;
        }
      }

      await _loadPendingRecords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sincronização concluída! $syncedCount registros enviados.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro durante sincronização'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Operador - Carregamentos',
        user: widget.user,
        onSync: _syncPendingRecords,
        isSyncing: _isSyncing,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Novo Carregamento',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a data';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedMachine,
                        decoration: const InputDecoration(
                          labelText: 'Máquina',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.construction),
                        ),
                        items: _machines.map((machine) {
                          return DropdownMenuItem(
                            value: machine['id'],
                            child: Text(machine['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMachine = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma máquina';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tripsController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Viagens',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o número de viagens';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Número de viagens inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _truckTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Caminhão',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Preço por m³: R\$ ${_pricePerCubicMeter.toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            Text('Capacidade média por viagem: 1.5 m³'),
                            const SizedBox(height: 4),
                            Text(
                              'Valor estimado: R\$ ${(double.tryParse(_tripsController.text) != null ? double.parse(_tripsController.text) * 1.5 * _pricePerCubicMeter : 0).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Salvar Carregamento',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Registros Pendentes de Sincronização',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_pendingRecords.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_pendingRecords.length} pendente(s)',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_pendingRecords.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Nenhum registro pendente',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _pendingRecords.length,
                            itemBuilder: (context, index) {
                              final record = _pendingRecords[index];
                              final estimatedValue = record.estimatedCubicMeters * _pricePerCubicMeter;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Data: ${record.dataTrabalho}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text('Viagens: ${record.numViagens}'),
                                      Text('Máquina: ${_machines.firstWhere((m) => m['id'] == record.machineId)['name']}'),
                                      Text('Tipo: ${record.tipoCaminhao}'),
                                      Text('Valor estimado: R\$ ${estimatedValue.toStringAsFixed(2)}'),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.orange.shade300),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                                            SizedBox(width: 4),
                                            Text(
                                              'PENDENTE DE SINCRONIZAÇÃO',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}