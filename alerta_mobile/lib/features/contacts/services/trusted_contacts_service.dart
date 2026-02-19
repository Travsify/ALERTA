import 'dart:convert';
import 'package:alerta_mobile/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool receivesSOS;
  final bool receivesLocation;
  final String? telegramChatId;
  final bool notifyPush;
  final bool notifyTelegram;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.receivesSOS = true,
    this.receivesLocation = true,
    this.telegramChatId,
    this.notifyPush = true,
    this.notifyTelegram = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relationship': relationship,
    'receives_sos': receivesSOS,
    'receives_location': receivesLocation,
    'telegram_chat_id': telegramChatId,
    'notify_push': notifyPush,
    'notify_telegram': notifyTelegram,
  };

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
    id: json['id'].toString(),
    name: json['name'],
    phone: json['phone'],
    relationship: json['relationship'] ?? 'Guardian',
    receivesSOS: json['receives_sos'] ?? true,
    receivesLocation: json['receives_location'] ?? true,
    telegramChatId: json['telegram_chat_id'],
    notifyPush: json['notify_push'] ?? true,
    notifyTelegram: json['notify_telegram'] ?? false,
  );

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    bool? receivesSOS,
    bool? receivesLocation,
    String? telegramChatId,
    bool? notifyPush,
    bool? notifyTelegram,
  }) => TrustedContact(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    relationship: relationship ?? this.relationship,
    receivesSOS: receivesSOS ?? this.receivesSOS,
    receivesLocation: receivesLocation ?? this.receivesLocation,
    telegramChatId: telegramChatId ?? this.telegramChatId,
    notifyPush: notifyPush ?? this.notifyPush,
    notifyTelegram: notifyTelegram ?? this.notifyTelegram,
  );
}

class TrustedContactsService extends ChangeNotifier {
  static final TrustedContactsService _instance = TrustedContactsService._internal();
  factory TrustedContactsService() => _instance;
  TrustedContactsService._internal();

  final _storage = const FlutterSecureStorage();
  final _api = ApiService();
  static const String _storageKey = 'trusted_contacts';

  List<TrustedContact> _contacts = [];
  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  /// Load contacts from secure storage or server
  Future<void> loadContacts() async {
    try {
      // 1. Try server first
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        final response = await _api.get('/contacts');
        if (response.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(response.body);
          _contacts = jsonList.map((json) => TrustedContact.fromJson(json)).toList();
          await _saveContactsLocally();
          notifyListeners();
          return;
        }
      }

      // 2. Fallback to local
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _contacts = jsonList.map((json) => TrustedContact.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    }
  }

  /// Save contacts to local storage
  Future<void> _saveContactsLocally() async {
    final jsonList = _contacts.map((c) => c.toJson()).toList();
    await _storage.write(key: _storageKey, value: jsonEncode(jsonList));
  }

  /// Add a new contact
  Future<void> addContact(TrustedContact contact) async {
    try {
      final response = await _api.post('/contacts', {
        'name': contact.name,
        'phone': contact.phone,
        'relationship': contact.relationship,
        'receives_sos': contact.receivesSOS,
        'receives_location': contact.receivesLocation,
        'telegram_chat_id': contact.telegramChatId,
        'notify_push': contact.notifyPush,
        'notify_telegram': contact.notifyTelegram,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _contacts.add(TrustedContact.fromJson(data));
      } else {
        // Optimistic local add if server fails
        _contacts.add(contact);
      }
    } catch (e) {
      _contacts.add(contact);
    }
    await _saveContactsLocally();
    notifyListeners();
  }

  /// Update an existing contact
  Future<void> updateContact(TrustedContact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      
      try {
        await _api.put('/contacts/${contact.id}', {
          'name': contact.name,
          'phone': contact.phone,
          'relationship': contact.relationship,
          'receives_sos': contact.receivesSOS,
          'receives_location': contact.receivesLocation,
          'telegram_chat_id': contact.telegramChatId,
          'notify_push': contact.notifyPush,
          'notify_telegram': contact.notifyTelegram,
        });
      } catch (e) {
        debugPrint('Error updating contact on server: $e');
      }

      await _saveContactsLocally();
      notifyListeners();
    }
  }

  /// Delete a contact
  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    
    try {
      await _api.delete('/contacts/$id');
    } catch (e) {
      debugPrint('Error deleting contact on server: $e');
    }

    await _saveContactsLocally();
    notifyListeners();
  }

  /// Get phone numbers for SOS
  List<String> getSOSNumbers() {
    return _contacts
        .where((c) => c.receivesSOS)
        .map((c) => c.phone)
        .toList();
  }

  /// Get phone numbers for location sharing
  List<String> getLocationShareNumbers() {
    return _contacts
        .where((c) => c.receivesLocation)
        .map((c) => c.phone)
        .toList();
  }
}
