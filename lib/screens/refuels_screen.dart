import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/refuel.dart';
import '../models/vehicle.dart';
import 'refuel_form.dart';

class RefuelsScreen extends StatefulWidget {
  final String? vehicleId;
  final String? vehicleName;
  const RefuelsScreen({super.key, this.vehicleId, this.vehicleName});

  @override
  State<RefuelsScreen> createState() => _RefuelsScreenState();
}

class _RefuelsScreenState extends State<RefuelsScreen> {
  final FirestoreService _fs = FirestoreService();
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId != null) {
      _selectedVehicleId = widget.vehicleId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.vehicleName != null
              ? 'Abastecimentos - ${widget.vehicleName}'
              : 'Abastecimentos')),
      body: Column(
        children: [
          if (widget.vehicleId == null)
            StreamBuilder<List<Vehicle>>(
              stream: _fs.getVehiclesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final vehicles = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedVehicleId,
                    hint: const Text('Selecione um veículo'),
                    items: vehicles
                        .map((v) => DropdownMenuItem<String?>(
                              value: v.id,
                              child: Text('${v.name} (${v.plate})'),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedVehicleId = val),
                  ),
                );
              },
            )
          else
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.directions_car),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(widget.vehicleName ?? 'Veículo selecionado')),
                ],
              ),
            ),
          Expanded(
            child: _selectedVehicleId == null
                ? const Center(child: Text('Selecione um veículo'))
                : StreamBuilder<List<Refuel>>(
                    stream: _fs.getRefuelsByVehicleStream(_selectedVehicleId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final items = snapshot.data!;
                      if (items.isEmpty)
                        return const Center(
                            child: Text('Nenhum abastecimento'));

                      // Ordena por data e calcula consumo
                      items.sort((a, b) => b.date.compareTo(a.date));

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final r = items[index];
                          final dateFormatted = DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(r.date));
                          final priceFormatted = NumberFormat.currency(
                                  locale: 'pt_BR', symbol: 'R\$')
                              .format(r.price);
                          final litersFormatted =
                              NumberFormat('#,##0.00', 'pt_BR')
                                  .format(r.liters);
                          final kmFormatted =
                              NumberFormat('#,###', 'pt_BR').format(r.km);
                          final pricePerLiter =
                              r.liters > 0 ? r.price / r.liters : 0;
                          final pricePerLiterFormatted = NumberFormat.currency(
                                  locale: 'pt_BR', symbol: 'R\$')
                              .format(pricePerLiter);

                          // Calcula consumo se houver abastecimento anterior
                          String? consumptionText;
                          if (index < items.length - 1) {
                            final previousRefuel = items[index + 1];
                            final kmDiff = r.km - previousRefuel.km;
                            if (kmDiff > 0 && r.liters > 0) {
                              final consumption = kmDiff / r.liters;
                              consumptionText =
                                  '${consumption.toStringAsFixed(2)} km/L';
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.local_gas_station),
                              ),
                              title: Text(
                                '$litersFormatted L • $priceFormatted',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$dateFormatted • $kmFormatted km'),
                                  Text(
                                    '$pricePerLiterFormatted/L${consumptionText != null ? ' • $consumptionText' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    tooltip: 'Editar',
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  RefuelForm(refuel: r)));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Excluir',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Confirmar exclusão'),
                                          content: const Text(
                                              'Deseja realmente excluir este abastecimento?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Excluir'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && r.id != null) {
                                        await _fs.deleteRefuel(r.id!);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Abastecimento excluído'),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _selectedVehicleId == null
            ? null
            : () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        RefuelForm(vehicleId: _selectedVehicleId!)));
              },
      ),
    );
  }
}
