import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/contacts/services/trusted_contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final TrustedContactsService _service = TrustedContactsService();

  @override
  void initState() {
    super.initState();
    _service.loadContacts();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _showAddEditDialog([TrustedContact? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    String relationship = existing?.relationship ?? 'Family';
    bool receivesSOS = existing?.receivesSOS ?? true;
    bool receivesLocation = existing?.receivesLocation ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          title: Text(existing == null ? 'Add Contact' : 'Edit Contact', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '08012345678',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  dropdownColor: AppTheme.cardSurface,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: ['Family', 'Friend', 'Partner', 'Colleague', 'Other']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => relationship = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: existing?.telegramChatId ?? ''),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Telegram Chat ID (Optional)',
                    prefixIcon: Icon(FontAwesomeIcons.telegram),
                    hintText: 'e.g. 123456789',
                  ),
                  onChanged: (v) => existing = existing?.copyWith(telegramChatId: v),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Push Notification', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Zero-cost app alert', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: existing?.notifyPush ?? true,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (v) => setDialogState(() => existing = existing?.copyWith(notifyPush: v)),
                ),
                SwitchListTile(
                  title: const Text('Telegram Alert', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Works on Social Data', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: existing?.notifyTelegram ?? false,
                  activeColor: const Color(0xFF0088cc),
                  onChanged: (v) => setDialogState(() => existing = existing?.copyWith(notifyTelegram: v)),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Receives SOS Alerts', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Gets SMS when you trigger panic', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: receivesSOS,
                  activeColor: AppTheme.primaryRed,
                  onChanged: (v) => setDialogState(() => receivesSOS = v),
                ),
                SwitchListTile(
                  title: const Text('Receives Location', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Can track you during emergencies', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: receivesLocation,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (v) => setDialogState(() => receivesLocation = v),
                ),
              ],
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () {
                  _service.deleteContact(existing!.id);
                  Navigator.pop(context);
                },
                child: const Text('DELETE', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final contact = TrustedContact(
                  id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phone: phoneController.text,
                  relationship: relationship,
                  receivesSOS: receivesSOS,
                  receivesLocation: receivesLocation,
                  telegramChatId: existing?.telegramChatId,
                  notifyPush: existing?.notifyPush ?? true,
                  notifyTelegram: existing?.notifyTelegram ?? false,
                );

                if (existing?.id == null) {
                  _service.addContact(contact);
                } else {
                  _service.updateContact(contact);
                }
                Navigator.pop(context);
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        backgroundColor: Colors.transparent,
      ),
      body: _service.contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.userShield, size: 64, color: Colors.white24),
                  const SizedBox(height: 24),
                  const Text('No Trusted Contacts', style: TextStyle(color: Colors.white54, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('Add people who will receive your SOS alerts', style: TextStyle(color: Colors.white38)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Contact'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _service.contacts.length,
              itemBuilder: (context, index) {
                final contact = _service.contacts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryRed.withOpacity(0.2),
                      child: Text(contact.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(contact.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.phone, style: const TextStyle(color: Colors.white54)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (contact.receivesSOS)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('SOS', style: TextStyle(color: AppTheme.primaryRed, fontSize: 10)),
                              ),
                            if (contact.receivesLocation)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('LOCATION', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 10)),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54),
                      onPressed: () => _showAddEditDialog(contact),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _service.contacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              backgroundColor: AppTheme.primaryRed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
