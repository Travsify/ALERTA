import 'package:alerta_mobile/core/services/connectivity_service.dart';
import 'package:alerta_mobile/core/theme/typography.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final ThreatRadarService _threatRadar = ThreatRadarService();
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _threatRadar.startMonitoring();
    _threatRadar.addListener(_onThreatUpdate);
    _connectivity.addListener(_onConnectivityChange);
    
    // Enable Shake to Panic
    ShakeToPanicService().enable();
  }

  @override
  void dispose() {
    _threatRadar.removeListener(_onThreatUpdate);
    _threatRadar.dispose();
    _connectivity.removeListener(_onConnectivityChange);
    ShakeToPanicService().disable();
    super.dispose();
  }

  void _onThreatUpdate() {
    if (_threatRadar.nearestThreat != null && mounted) {
      setState(() {}); // Rebuild to show alert
    }
  }

  void _onConnectivityChange() {
    if (mounted) setState(() {});
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
          // Device Offline Banner
          if (_connectivity.isOffline)
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'OFFLINE MODE - SOS via SMS/Mesh only',
                      style: AppTypography.labelMedium.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: -1, end: 0),

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
                            style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _threatRadar.nearestThreat!.name,
                            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _switchTab(1), // Go to Map
                      child: Text('VIEW MAP', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
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
                 style: AppTypography.bodyMedium,
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
                   title: Text('Timer Active', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                   subtitle: Text('${(deadMan.secondsRemaining / 60).floor()}m ${deadMan.secondsRemaining % 60}s remaining', style: AppTypography.bodySmall.copyWith(color: AppTheme.primaryRed)),
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
          title: Text('Ghost Mode', style: AppTypography.heading2),
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
                title: Text('Calculator Mode', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
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
                title: Text('Weather Mode', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
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
                        Text('Hi, $userName', style: AppTypography.heading2),
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
            Semantics(
              label: 'Emergency SOS Button. Hold for 3 seconds to send distress signal to trusted contacts.',
              button: true,
              child: Container(
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
                      Text('TAP FOR EMERGENCY', style: AppTypography.panicButton),
                      Text('Hold for 3 seconds', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            ), // end Semantics

            const SizedBox(height: 32),
            Text('Prevention Tools', style: AppTypography.labelLarge.copyWith(color: Colors.white54)),
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
    return Semantics(
      label: '$title. $subtitle',
      button: true,
      child: Material(
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
              Text(title, style: AppTypography.labelLarge.copyWith(color: Colors.white, letterSpacing: 0)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
