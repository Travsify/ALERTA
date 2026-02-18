import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/auth/screens/login_screen.dart';
import 'package:alerta_mobile/features/contacts/screens/trusted_contacts_screen.dart';
import 'package:alerta_mobile/features/contacts/services/trusted_contacts_service.dart';
import 'package:alerta_mobile/features/profile/services/medical_id_service.dart';
import 'package:alerta_mobile/features/profile/services/user_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final MedicalIdService _medicalService = MedicalIdService();
  final TrustedContactsService _contactsService = TrustedContactsService();
  final _storage = const FlutterSecureStorage();
  
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _profileService.loadProfile();
    await _medicalService.loadMedicalId();
    await _contactsService.loadContacts();
    
    final biometric = await _storage.read(key: 'biometric_enabled');
    setState(() {
      _biometricEnabled = biometric != 'false';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileService.profile;
    final medicalId = _medicalService.medicalId;
    final contacts = _contactsService.contacts;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.cardSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditProfileDialog(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.3),
                      Colors.black,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.successGreen, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text(
                          profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile?.name ?? 'User',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (profile?.isVerified ?? false) 
                            ? AppTheme.successGreen.withOpacity(0.2) 
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile?.isVerified == true ? 'ID: VERIFIED' : 'ID: PENDING',
                        style: TextStyle(
                          color: profile?.isVerified == true ? AppTheme.successGreen : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  _buildUserInfoCard(profile),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'TRUSTED CONTACTS'),
                  const SizedBox(height: 8),
                  ...contacts.take(2).map((c) => _buildContactTile(c.name, c.phone, true)),
                  _buildAddButton(context, 'Manage Contacts', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TrustedContactsScreen()));
                  }),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'MEDICAL ID'),
                  const SizedBox(height: 8),
                  _buildMedicalCard(context, medicalId),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'ZERO-COST NOTIFICATIONS'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white05),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          FontAwesomeIcons.telegram, 
                          'Connect Telegram', 
                          profile?.telegramChatId != null ? 'Connected: ${profile?.telegramChatId}' : 'Receive alerts via Telegram Bot',
                          onTap: () => _showTelegramConnectDialog(),
                        ),
                        const Divider(color: Colors.white12),
                        SwitchListTile(
                          value: profile?.notifyPush ?? true,
                          onChanged: (v) => _profileService.updateNotificationSettings(notifyPush: v),
                          activeColor: AppTheme.primaryBlue,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Fastest zero-cost alert', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                        SwitchListTile(
                          value: profile?.notifyTelegram ?? false,
                          onChanged: (v) => _profileService.updateNotificationSettings(notifyTelegram: v),
                          activeColor: const Color(0xFF0088cc),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Telegram Alerts', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Works on Social Data bundles', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'SECURITY SETTINGS'),
                  const SizedBox(height: 8),
                  _buildSecurityTile(Icons.lock, 'Change Master PIN', 'Update your main access code', 
                    onTap: () => _showChangePinDialog(isMasterPin: true)),
                  _buildSecurityTile(Icons.warning, 'Change Ghost PIN', 'Update your duress/silent alarm code', 
                    isWarning: true, onTap: () => _showChangePinDialog(isMasterPin: false)),
                  SwitchListTile(
                    value: _biometricEnabled, 
                    onChanged: (v) async {
                      await _storage.write(key: 'biometric_enabled', value: v.toString());
                      setState(() => _biometricEnabled = v);
                    },
                    activeColor: AppTheme.primaryRed,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Biometric Unlock', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Use FaceID/Fingerprint', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'APP SETTINGS'),
                  const SizedBox(height: 8),
                  _buildSettingsTile(Icons.notifications_outlined, 'Notifications', 'Manage alert preferences'),
                  _buildSettingsTile(Icons.help_outline, 'Help & Support', 'FAQ, Contact us'),
                  _buildSettingsTile(Icons.info_outline, 'About Alerta', 'Version 1.0.0'),
                  
                  const SizedBox(height: 32),
                  OutlinedButton(
                    onPressed: () => _showLogoutDialog(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryRed,
                      side: const BorderSide(color: AppTheme.primaryRed),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('LOGOUT'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', profile?.email ?? 'Not set'),
          const Divider(color: Colors.white12),
          _buildInfoRow(Icons.phone, 'Phone', profile?.phone ?? 'Not set'),
          const Divider(color: Colors.white12),
          _buildInfoRow(Icons.calendar_today, 'Member Since', 
            profile?.createdAt != null 
              ? '${profile!.createdAt!.day}/${profile.createdAt!.month}/${profile.createdAt!.year}'
              : 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white38,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContactTile(String name, String phone, bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white10,
          child: Text(name[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(phone, style: const TextStyle(color: Colors.white54)),
        trailing: isVerified 
          ? const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16)
          : const Icon(Icons.timer, color: Colors.orange, size: 16),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard(BuildContext context, MedicalId medicalId) {
    return GestureDetector(
      onTap: () => _showEditMedicalDialog(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRed.withOpacity(0.2), AppTheme.cardSurface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.heartPulse, color: AppTheme.primaryRed, size: 20),
                    SizedBox(width: 8),
                    Text('Emergency Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.edit, color: Colors.white38, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Blood Group', medicalId.bloodGroup.isEmpty ? 'Not Set' : medicalId.bloodGroup),
                _buildInfoItem('Genotype', medicalId.genotype.isEmpty ? 'Not Set' : medicalId.genotype),
                _buildInfoItem('Allergies', medicalId.allergies),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildSecurityTile(IconData icon, String title, String subtitle, {bool isWarning = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isWarning ? AppTheme.primaryRed : Colors.white).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isWarning ? AppTheme.primaryRed : Colors.white70),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 12),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white54),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 12),
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title - Coming Soon')));
      },
    );
  }

  // ========== DIALOGS ==========

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _profileService.profile?.name ?? '');
    final emailController = TextEditingController(text: _profileService.profile?.email ?? '');
    final phoneController = TextEditingController(text: _profileService.profile?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _profileService.updateProfile(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicalDialog() {
    final bloodController = TextEditingController(text: _medicalService.medicalId.bloodGroup);
    final genotypeController = TextEditingController(text: _medicalService.medicalId.genotype);
    final allergiesController = TextEditingController(text: _medicalService.medicalId.allergies);
    final conditionsController = TextEditingController(text: _medicalService.medicalId.conditions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Edit Medical ID', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Blood Group (e.g. O+)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: genotypeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Genotype (e.g. AA)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: allergiesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: conditionsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Medical Conditions'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _medicalService.updateMedicalId(
                _medicalService.medicalId.copyWith(
                  bloodGroup: bloodController.text,
                  genotype: genotypeController.text,
                  allergies: allergiesController.text,
                  conditions: conditionsController.text,
                ),
              );
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog({required bool isMasterPin}) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: Text(
          isMasterPin ? 'Change Master PIN' : 'Change Ghost PIN',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isMasterPin ? 'Current Master PIN' : 'Your Master PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isMasterPin ? 'New Master PIN' : 'New Ghost PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs do not match'), backgroundColor: Colors.red),
                );
                return;
              }
              if (newPinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4 digits'), backgroundColor: Colors.red),
                );
                return;
              }

              try {
                if (isMasterPin) {
                  await _profileService.changeMasterPin(currentPinController.text, newPinController.text);
                } else {
                  await _profileService.changeGhostPin(currentPinController.text, newPinController.text);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${isMasterPin ? 'Master' : 'Ghost'} PIN updated successfully'), backgroundColor: AppTheme.successGreen),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showTelegramConnectDialog() {
    final controller = TextEditingController(text: _profileService.profile?.telegramChatId ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Connect Telegram', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Message our bot @AlertaSecureBot\n2. Type /start to get your ID\n3. Paste the ID below',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Telegram Chat ID',
                hintText: 'e.g. 123456789',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _profileService.updateNotificationSettings(telegramChatId: controller.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout? All local data will be cleared.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () async {
              await _profileService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
