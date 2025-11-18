import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle.dart';
import '../models/refuel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ========== VEHICLES ==========
  Future<String> addVehicle(Vehicle v) async {
    if (_userId == null) throw Exception('Usuário não autenticado');
    final data = v.toMap();
    data['userId'] = _userId;
    final docRef = await _db.collection('vehicles').add(data);
    return docRef.id;
  }

  Stream<List<Vehicle>> getVehiclesStream() {
    if (_userId == null) return Stream.value([]);
    return _db
        .collection('vehicles')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snap) {
      final vehicles = snap.docs.map((d) {
        final data = d.data();
        final m = Map<String, dynamic>.from(data);
        m['id'] = d.id;
        return Vehicle.fromMap(m);
      }).toList();
      // Ordenar no código ao invés de no Firestore para evitar índice composto
      vehicles.sort((a, b) => a.name.compareTo(b.name));
      return vehicles;
    });
  }

  Future<bool> updateVehicle(String id, Vehicle v) async {
    try {
      await _db.collection('vehicles').doc(id).update(v.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      // Excluir abastecimentos relacionados
      final refuels = await _db
          .collection('refuels')
          .where('vehicle_id', isEqualTo: id)
          .get();
      for (var doc in refuels.docs) {
        await doc.reference.delete();
      }
      await _db.collection('vehicles').doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== REFUELS ==========
  Future<String> addRefuel(Refuel r) async {
    if (_userId == null) throw Exception('Usuário não autenticado');
    final data = r.toMap();
    data['userId'] = _userId;
    final docRef = await _db.collection('refuels').add(data);
    return docRef.id;
  }

  Stream<List<Refuel>> getRefuelsByVehicleStream(String vehicleId) {
    if (_userId == null) return Stream.value([]);
    return _db
        .collection('refuels')
        .where('userId', isEqualTo: _userId)
        .where('vehicle_id', isEqualTo: vehicleId)
        .snapshots()
        .map((snap) {
      final refuels = snap.docs.map((d) {
        final data = d.data();
        final m = Map<String, dynamic>.from(data);
        m['id'] = d.id;
        return Refuel.fromMap(m);
      }).toList();
      // Ordenar no código ao invés de no Firestore para evitar índice composto
      refuels.sort((a, b) => b.date.compareTo(a.date));
      return refuels;
    });
  }

  Future<bool> updateRefuel(String id, Refuel r) async {
    try {
      await _db.collection('refuels').doc(id).update(r.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRefuel(String id) async {
    try {
      await _db.collection('refuels').doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
