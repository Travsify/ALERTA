import 'package:alerta_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DummyDashboardScreen extends StatelessWidget {
  const DummyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fake Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Status: BASIC', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                      Text('Hi, User', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: IconButton(icon: const Icon(Icons.person, color: Colors.white30), onPressed: () {}),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // Non-functional Panic Button
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 48, color: Colors.white24),
                    SizedBox(height: 16),
                    Text('SYSTEM SECURE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white38)),
                    Text('No active threats in area', style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text('Safety Tips', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Fake Tips (Static)
              Expanded(
                child: ListView(
                  children: [
                    _buildFakeTip(context, 'Avoid walking alone at night', 'Stay in well-lit areas.'),
                    _buildFakeTip(context, 'Keep your phone charged', 'A full battery is your best friend.'),
                    _buildFakeTip(context, 'Trust your intuition', 'If something feels wrong, leave.'),
                    _buildFakeTip(context, 'Stay aware of surroundings', 'Avoid using headphones in transit.'),
                  ],
                ),
              ),
              
              // Bottom Help Link
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Contact Support', style: TextStyle(color: Colors.white24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFakeTip(BuildContext context, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
