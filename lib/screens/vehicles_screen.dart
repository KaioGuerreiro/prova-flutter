import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/vehicle.dart';
import 'vehicle_form.dart';
import 'refuels_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Veículos')),
      body: StreamBuilder<List<Vehicle>>(
        stream: _fs.getVehiclesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData)
            return const Center(child: Text('Nenhum veículo cadastrado'));
          final items = snapshot.data!;
          if (items.isEmpty)
            return const Center(child: Text('Nenhum veículo cadastrado'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final v = items[index];
              final kmFormatted = NumberFormat('#,###', 'pt_BR').format(v.km);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.directions_car),
                  ),
                  title: Text(
                    v.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${v.plate} \u2022 $kmFormatted km'),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RefuelsScreen(
                            vehicleId: v.id, vehicleName: v.name)));
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => VehicleForm(vehicle: v)));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text(
                                  'Deseja realmente excluir o veículo "${v.name}"? Todos os abastecimentos relacionados também serão excluídos.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && v.id != null) {
                            await _fs.deleteVehicle(v.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veículo excluído com sucesso'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const VehicleForm()));
          setState(() {});
        },
      ),
    );
  }
}
