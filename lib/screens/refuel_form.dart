import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/refuel.dart';
import '../services/firestore_service.dart';

class RefuelForm extends StatefulWidget {
  final Refuel? refuel;
  final String? vehicleId;
  const RefuelForm({super.key, this.refuel, this.vehicleId});

  @override
  State<RefuelForm> createState() => _RefuelFormState();
}

class _RefuelFormState extends State<RefuelForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.refuel != null) {
      _dateCtrl.text = widget.refuel!.date;
      _litersCtrl.text = widget.refuel!.liters.toString();
      _priceCtrl.text = widget.refuel!.price.toString();
      _kmCtrl.text = widget.refuel!.km.toString();
    } else {
      // Define data atual para novo abastecimento
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.refuel != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar abastecimento' : 'Novo abastecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Data do Abastecimento',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a data' : null,
              ),
              TextFormField(
                controller: _litersCtrl,
                decoration: const InputDecoration(
                  labelText: 'Litros',
                  prefixIcon: Icon(Icons.local_gas_station),
                  suffixText: 'L',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe os litros';
                  final liters = double.tryParse(v.replaceAll(',', '.'));
                  if (liters == null || liters <= 0) {
                    return 'Quantidade inválida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Valor Total',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final price = double.tryParse(v.replaceAll(',', '.'));
                  if (price == null || price <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem Atual',
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
                  child: Text(editing
                      ? 'Salvar Alterações'
                      : 'Registrar Abastecimento'),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final refuel = Refuel(
                      id: widget.refuel?.id,
                      vehicleId: widget.refuel?.vehicleId ?? widget.vehicleId!,
                      date: _dateCtrl.text,
                      liters: double.tryParse(
                              _litersCtrl.text.replaceAll(',', '.')) ??
                          0.0,
                      price: double.tryParse(
                              _priceCtrl.text.replaceAll(',', '.')) ??
                          0.0,
                      km: int.tryParse(_kmCtrl.text) ?? 0,
                    );

                    try {
                      if (editing) {
                        if (refuel.id != null) {
                          await _fs.updateRefuel(refuel.id!, refuel);
                        }
                      } else {
                        await _fs.addRefuel(refuel);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(editing
                                ? 'Abastecimento atualizado!'
                                : 'Abastecimento registrado!'),
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
