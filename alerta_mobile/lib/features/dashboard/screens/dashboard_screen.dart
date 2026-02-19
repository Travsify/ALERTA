import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:alerta_mobile/features/panic/services/dead_man_service.dart';
import 'package:alerta_mobile/features/panic/services/panic_service.dart';
import 'package:alerta_mobile/features/prevention/screens/blackbox_screen.dart';
import 'package:alerta_mobile/features/prevention/screens/safety_map_screen.dart';
import 'package:alerta_mobile/features/prevention/screens/transport_vetting_screen.dart';
import 'package:alerta_mobile/features/profile/screens/profile_screen.dart';
import 'package:alerta_mobile/features/recovery/screens/crisis_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alerta_mobile/features/guardian/screens/guardian_mode_screen.dart';
import 'package:alerta_mobile/features/threat_radar/services/threat_radar_service.dart';
import 'package:alerta_mobile/features/panic/services/shake_to_panic_service.dart';
import 'package:alerta_mobile/features/fake_call/screens/fake_call_screen.dart';
import 'package:alerta_mobile/features/live_location/screens/share_trip_screen.dart';
import 'package:alerta_mobile/features/contacts/screens/trusted_contacts_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alerta_mobile/features/subscription/services/subscription_service.dart';
import 'package:alerta_mobile/features/subscription/screens/subscription_screen.dart';
import 'package:alerta_mobile/features/profile/services/user_profile_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final ThreatRadarService _threatRadar = ThreatRadarService();

  @override
  void initState() {
    super.initState();
    _threatRadar.startMonitoring();
    _threatRadar.addListener(_onThreatUpdate);
    
    // Enable Shake to Panic
    ShakeToPanicService().enable();
  }

  @override
  void dispose() {
    _threatRadar.removeListener(_onThreatUpdate);
    _threatRadar.dispose();
    ShakeToPanicService().disable();
    super.dispose();
  }

  void _onThreatUpdate() {
    if (_threatRadar.nearestThreat != null && mounted) {
      setState(() {}); // Rebuild to show alert
    }
  }

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Pass the switch callback to HomeView
    final List<Widget> screens = [
      HomeView(onSwitchTab: _switchTab),
      const SafetyMapScreen(),
      const CrisisLogScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Threat Radar Alert Banner
          if (_threatRadar.nearestThreat != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              color: _threatRadar.nearestThreat!.type == 'danger' ? AppTheme.primaryRed : AppTheme.warningOrange,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THREAT DETECTED - ${_threatRadar.distanceToThreat?.toStringAsFixed(0)}m AWAY',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            _threatRadar.nearestThreat!.name,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _switchTab(1), // Go to Map
                      child: const Text('VIEW MAP', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: -1, end: 0),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.cardSurface,
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Protection'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Live Map'),
          NavigationDestination(icon: Icon(Icons.lock_clock), selectedIcon: Icon(Icons.lock_clock), label: 'Crisis Log'),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final Function(int) onSwitchTab; // Add callback

  const HomeView({super.key, required this.onSwitchTab});

  // ... _showGhostModeDialog implementation below ...
  void _showDeadManSwitchDialog(BuildContext context) {
    final deadMan = DeadManService();
    int minutes = 10;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          title: const Text('Dead Man\'s Switch', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.clock, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'If you don\'t check in before the timer expires, an automated SOS will be sent to your contacts.',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (!deadMan.isActive) ...[
                Text('Set Timer: $minutes min', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Slider(
                  value: minutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: AppTheme.primaryRed,
                  onChanged: (v) => setDialogState(() => minutes = v.toInt()),
                ),
              ] else ...[
                 ListTile(
                   title: const Text('Timer Active', style: TextStyle(color: Colors.white)),
                   subtitle: Text('${(deadMan.secondsRemaining / 60).floor()}m ${deadMan.secondsRemaining % 60}s remaining', style: const TextStyle(color: AppTheme.primaryRed)),
                   trailing: const CircularProgressIndicator(color: AppTheme.primaryRed, strokeWidth: 2),
                 ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            if (!deadMan.isActive)
              ElevatedButton(
                onPressed: () {
                  deadMan.start(minutes);
                  Navigator.pop(context);
                },
                child: const Text('Start Timer'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                onPressed: () {
                  deadMan.stop();
                  Navigator.pop(context);
                },
                child: const Text('I AM SAFE (STOP)'),
              ),
          ],
        ),
      ),
    );
  }

  void _showGhostModeDialog(BuildContext context) {
    String selectedMode = 'calculator';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          title: const Text('Ghost Mode', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.ghost, size: 48, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Disguise the app icon and name as "Calculator" or "Weather" to hide it from intruders.',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.calculate, color: Colors.orange),
                title: const Text('Calculator Mode', style: TextStyle(color: Colors.white)),
                onTap: () => setDialogState(() => selectedMode = 'calculator'),
                trailing: Radio<String>(
                  value: 'calculator', 
                  groupValue: selectedMode, 
                  onChanged: (v) => setDialogState(() => selectedMode = v!), 
                  activeColor: AppTheme.primaryRed
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blue),
                title: const Text('Weather Mode', style: TextStyle(color: Colors.white)),
                onTap: () => setDialogState(() => selectedMode = 'weather'),
                trailing: Radio<String>(
                  value: 'weather', 
                  groupValue: selectedMode, 
                  onChanged: (v) => setDialogState(() => selectedMode = v!),
                  activeColor: AppTheme.primaryRed
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                const storage = FlutterSecureStorage();
                await storage.write(key: 'ghost_mode_enabled', value: 'true');
                await storage.write(key: 'ghost_mode_type', value: selectedMode);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Ghost Mode Active: App will simulate a ${selectedMode == 'calculator' ? 'Calculator' : 'Weather App'} on next launch.'),
                    backgroundColor: Colors.grey,
                  ));
                }
              },
              child: const Text('Activate Disguise'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subService = SubscriptionService();
    final sub = subService.subscription;
    final statusColor = sub.isTrialActive ? Colors.orange : (sub.isSubscribed ? AppTheme.successGreen : AppTheme.primaryRed);
    final statusText = sub.isTrialActive ? 'TRIAL: ${sub.daysRemaining}d' : (sub.isSubscribed ? 'PRO ACTIVE' : 'EXPIRED');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedBuilder(
                  animation: UserProfileService(),
                  builder: (context, _) {
                    final userProfile = UserProfileService().profile;
                    final userName = userProfile?.name.split(' ').first ?? 'User';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: statusColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              statusText, 
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Hi, $userName', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    );
                  }
                ),
                CircleAvatar(
                  backgroundColor: AppTheme.cardSurface,
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white), 
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    }
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // Panic Button
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRed.withOpacity(0.8), AppTheme.primaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryRed.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                     // For tap
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hold for 3 seconds to trigger SOS!')));
                  },
                  onLongPress: () async {
                    // Trigger Panic
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('SENDING SOS... DO NOT CLOSE APP'),
                      backgroundColor: AppTheme.primaryRed,
                      duration: Duration(seconds: 5),
                    ));
                    
                    try {
                       await PanicService().triggerPanic();
                       if (context.mounted) {
                          showDialog(context: context, builder: (_) => const AlertDialog(
                            title: Text('ALERTA SENT', style: TextStyle(color: Colors.red)),
                            content: Text("Your location and details have been sent to trusted contacts."),
                          ));
                       }
                    } catch (e) {
                       if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                       }
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app_rounded, size: 48, color: Colors.white)
                          .animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds, begin: const Offset(1,1), end: const Offset(1.2, 1.2)).then().scale(begin: const Offset(1.2, 1.2), end: const Offset(1,1)),
                      const SizedBox(height: 16),
                      Text('TAP FOR EMERGENCY', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text('Hold for 3 seconds', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text('Prevention Tools', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54)),
            const SizedBox(height: 16),

            // Tools Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    icon: FontAwesomeIcons.car,
                    title: 'Vett Ride',
                    subtitle: 'Check Plate No.',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportVettingScreen())),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.usersViewfinder,
                    title: 'Checkpoints',
                    subtitle: 'View Reports',
                    color: Colors.orange,
                    onTap: () => onSwitchTab(1), // Switch to Map Tab
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.fileAudio,
                    title: 'Blackbox',
                    subtitle: 'Manage Evidence',
                     color: Colors.purple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlackboxScreen())),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.personWalking,
                    title: 'Guardian Mode',
                    subtitle: 'Journey Monitor',
                    color: AppTheme.successGreen,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianModeScreen())),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.ghost,
                    title: 'Ghost Mode',
                    subtitle: 'App Disguise',
                    color: Colors.grey,
                    onTap: () => _showGhostModeDialog(context),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.phone,
                    title: 'Fake Call',
                    subtitle: 'Escape Tool',
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FakeCallScreen())),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.locationArrow,
                    title: 'Share Trip',
                    subtitle: 'Live Location',
                    color: AppTheme.primaryBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShareTripScreen())),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.clock,
                    title: "Dead Man's",
                    subtitle: 'Auto-SOS Timer',
                    color: Colors.redAccent,
                    onTap: () => _showDeadManSwitchDialog(context),
                  ),
                  _FeatureCard(
                    icon: FontAwesomeIcons.userShield,
                    title: 'Contacts',
                    subtitle: 'Trusted People',
                    color: Colors.pink,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrustedContactsScreen())),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.1),
                child: FaIcon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
