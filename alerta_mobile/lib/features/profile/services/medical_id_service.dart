import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MedicalId {
  final String bloodGroup;
  final String genotype;
  final String allergies;
  final String conditions;
  final String medications;
  final String emergencyHospital;
  final String doctorName;
  final String doctorPhone;

  MedicalId({
    this.bloodGroup = '',
    this.genotype = '',
    this.allergies = 'None',
    this.conditions = 'None',
    this.medications = 'None',
    this.emergencyHospital = '',
    this.doctorName = '',
    this.doctorPhone = '',
  });

  Map<String, dynamic> toJson() => {
    'bloodGroup': bloodGroup,
    'genotype': genotype,
    'allergies': allergies,
    'conditions': conditions,
    'medications': medications,
    'emergencyHospital': emergencyHospital,
    'doctorName': doctorName,
    'doctorPhone': doctorPhone,
  };

  factory MedicalId.fromJson(Map<String, dynamic> json) => MedicalId(
    bloodGroup: json['bloodGroup'] ?? '',
    genotype: json['genotype'] ?? '',
    allergies: json['allergies'] ?? 'None',
    conditions: json['conditions'] ?? 'None',
    medications: json['medications'] ?? 'None',
    emergencyHospital: json['emergencyHospital'] ?? '',
    doctorName: json['doctorName'] ?? '',
    doctorPhone: json['doctorPhone'] ?? '',
  );

  MedicalId copyWith({
    String? bloodGroup,
    String? genotype,
    String? allergies,
    String? conditions,
    String? medications,
    String? emergencyHospital,
    String? doctorName,
    String? doctorPhone,
  }) => MedicalId(
    bloodGroup: bloodGroup ?? this.bloodGroup,
    genotype: genotype ?? this.genotype,
    allergies: allergies ?? this.allergies,
    conditions: conditions ?? this.conditions,
    medications: medications ?? this.medications,
    emergencyHospital: emergencyHospital ?? this.emergencyHospital,
    doctorName: doctorName ?? this.doctorName,
    doctorPhone: doctorPhone ?? this.doctorPhone,
  );
}

class MedicalIdService extends ChangeNotifier {
  static final MedicalIdService _instance = MedicalIdService._internal();
  factory MedicalIdService() => _instance;
  MedicalIdService._internal();

  final _storage = const FlutterSecureStorage();
  static const String _medicalKey = 'medical_id';

  MedicalId _medicalId = MedicalId();
  MedicalId get medicalId => _medicalId;

  Future<void> loadMedicalId() async {
    try {
      final data = await _storage.read(key: _medicalKey);
      if (data != null) {
        _medicalId = MedicalId.fromJson(jsonDecode(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading medical ID: $e');
    }
  }

  Future<void> updateMedicalId(MedicalId medicalId) async {
    _medicalId = medicalId;
    await _storage.write(key: _medicalKey, value: jsonEncode(_medicalId.toJson()));
    notifyListeners();
  }
}
