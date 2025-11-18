import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/firestore_service.dart';

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleForm({super.key, this.vehicle});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _nameCtrl.text = widget.vehicle!.name;
      _plateCtrl.text = widget.vehicle!.plate;
      _kmCtrl.text = widget.vehicle!.km.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.vehicle != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar veículo' : 'Novo veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Veículo',
                  hintText: 'Ex: Fusca Azul, Civic 2020',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o nome';
                  if (v.trim().length < 3) return 'Nome muito curto';
                  return null;
                },
              ),
              TextFormField(
                controller: _plateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'ABC-1234 ou ABC1D23',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a placa';
                  // Validação básica de placa brasileira (antiga ou Mercosul)
                  final plate = v.replaceAll('-', '').toUpperCase();
                  if (plate.length != 7) return 'Placa deve ter 7 caracteres';
                  return null;
                },
              ),
              TextFormField(
                controller: _kmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem',
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quilometragem';
                  final km = int.tryParse(v);
                  if (km == null || km < 0) return 'Quilometragem inválida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  child: Text(editing ? 'Salvar Alterações' : 'Criar Veículo'),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final vehicle = Vehicle(
                      id: widget.vehicle?.id,
                      name: _nameCtrl.text.trim(),
                      plate: _plateCtrl.text.trim().toUpperCase(),
                      km: int.tryParse(_kmCtrl.text) ?? 0,
                    );

                    try {
                      if (editing) {
                        if (vehicle.id != null) {
                          await _fs.updateVehicle(vehicle.id!, vehicle);
                        }
                      } else {
                        await _fs.addVehicle(vehicle);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(editing
                                ? 'Veículo atualizado com sucesso!'
                                : 'Veículo criado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao salvar: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
