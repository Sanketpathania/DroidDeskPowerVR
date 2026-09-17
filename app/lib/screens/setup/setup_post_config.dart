import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/screens/home_screen.dart';

/// Post-installation quick configuration screen.
/// Allows setting UI scaling, input mode, and queuing starter applications.
class SetupPostConfigScreen extends StatefulWidget {
  const SetupPostConfigScreen({super.key});

  @override
  State<SetupPostConfigScreen> createState() => _SetupPostConfigScreenState();
}

class _SetupPostConfigScreenState extends State<SetupPostConfigScreen> {
  int _currentTab = 0; // 0: Display & Scale, 1: Touch & Input, 2: Starter Apps

  static const List<_StarterAppInfo> _starterApps = [
    _StarterAppInfo(
      id: 'code_oss',
      name: 'VS Code (Code OSS)',
      description: 'Desktop code editor with extensions & Git support',
      icon: Icons.code_rounded,
      color: Color(0xFF23A8F2),
      size: '220 MB',
    ),
    _StarterAppInfo(
      id: 'firefox',
      name: 'Firefox ESR Browser',
      description: 'Full desktop web browser with dev tools & privacy protections',
      icon: Icons.public_rounded,
      color: Color(0xFFFF7139),
      size: '110 MB',
    ),
    _StarterAppInfo(
      id: 'gimp',
      name: 'GIMP Photo Editor',
      description: 'Photoshop alternative for image editing & graphics',
      icon: Icons.brush_rounded,
      color: Color(0xFFE5A50A),
      size: '160 MB',
    ),
    _StarterAppInfo(
      id: 'libreoffice',
      name: 'LibreOffice Office Suite',
      description: 'Word documents, spreadsheets, & presentation editor',
      icon: Icons.article_rounded,
      color: Color(0xFF18A303),
      size: '340 MB',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DroidTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Header Stepper ──
                _buildStepIndicator(3, 3),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DroidTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_rounded, color: DroidTheme.success, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Setup Successful!', style: DroidTheme.headingLg),
                        Text(
                          'Quickly customize your desktop experience',
                          style: DroidTheme.bodySm.copyWith(color: DroidTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // ── Sub-tabs ──
                Row(
                  children: [
                    _buildTabButton(0, '1. Display', Icons.aspect_ratio_rounded),
                    const SizedBox(width: 8),
                    _buildTabButton(1, '2. Input Mode', Icons.touch_app_rounded),
                    const SizedBox(width: 8),
                    _buildTabButton(2, '3. Starter Apps', Icons.apps_rounded),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Tab Content ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentTabContent(state),
                  ),
                ),

                // ── Bottom Action ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      if (_currentTab > 0)
                        OutlinedButton(
                          onPressed: () {
                            setState(() => _currentTab--);
                          },
                          child: const Text('Back'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentTab < 2) {
                            setState(() => _currentTab++);
                          } else {
                            // Finish and launch
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentTab == 2 ? DroidTheme.accent : DroidTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentTab == 2 ? 'Launch DroidDesk' : 'Continue',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _currentTab == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final active = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: active ? DroidTheme.surfaceLight : DroidTheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? DroidTheme.primary : DroidTheme.surfaceBorder,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? DroidTheme.primary : DroidTheme.textDim),
              const SizedBox(width: 4),
              Text(
                title,
                style: DroidTheme.bodySm.copyWith(
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active ? DroidTheme.textPrimary : DroidTheme.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(AppState state) {
    switch (_currentTab) {
      case 0:
        return _buildDisplayConfigTab(state);
      case 1:
        return _buildInputConfigTab(state);
      case 2:
      default:
        return _buildStarterAppsTab(state);
    }
  }

  Widget _buildDisplayConfigTab(AppState state) {
    final scaleOptions = [
      {'id': '150%', 'title': '150% Recommended Mobile', 'desc': 'Best balance for 6-7" phone screens with comfortable touch targets.'},
      {'id': '125%', 'title': '125% Balanced Workstation', 'desc': 'More desktop canvas space while maintaining readable UI.'},
      {'id': '100%', 'title': '100% Native 1:1 Pixel Density', 'desc': 'Maximum screen real-estate. Best when using external monitor or Dex.'},
      {'id': '200%', 'title': '200% High-DPI Tablet Scaling', 'desc': 'Large UI elements. Best for high-density tablets or accessibility.'},
    ];

    return ListView(
      key: const ValueKey(0),
      children: [
        Text(
          'Choose your default display scaling:',
          style: DroidTheme.bodyMd.copyWith(color: DroidTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        ...scaleOptions.map((opt) {
          final selected = state.postSetupScale == opt['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => state.setPostSetupScale(opt['id']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? DroidTheme.surfaceLight : DroidTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? DroidTheme.primary : DroidTheme.surfaceBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selected ? DroidTheme.primary.withValues(alpha: 0.15) : DroidTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        opt['id']!,
                        style: DroidTheme.monoSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selected ? DroidTheme.primary : DroidTheme.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt['title']!, style: DroidTheme.headingSm.copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(opt['desc']!, style: DroidTheme.bodySm.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? DroidTheme.primary : DroidTheme.textDim,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInputConfigTab(AppState state) {
    return ListView(
      key: const ValueKey(1),
      children: [
        Text(
          'Select your primary pointer & touch interaction model:',
          style: DroidTheme.bodyMd.copyWith(color: DroidTheme.textSecondary),
        ),
        const SizedBox(height: 14),
        _buildTouchOption(
          state: state,
          id: 'trackpad',
          title: 'Virtual Trackpad (Recommended)',
          desc: 'Touch anywhere to glide cursor with precision. Right click via two-finger tap, drag with double-tap hold.',
          icon: Icons.mouse_rounded,
        ),
        const SizedBox(height: 12),
        _buildTouchOption(
          state: state,
          id: 'direct',
          title: 'Direct Touch Digitizer',
          desc: 'Tapping on screen directly acts as a left-click cursor jump at that exact coordinate.',
          icon: Icons.touch_app_rounded,
        ),
      ],
    );
  }

  Widget _buildTouchOption({
    required AppState state,
    required String id,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final selected = state.postSetupTouchMode == id;
    return InkWell(
      onTap: () => state.setPostSetupTouchMode(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? DroidTheme.surfaceLight : DroidTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? DroidTheme.primary : DroidTheme.surfaceBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? DroidTheme.primary.withValues(alpha: 0.15) : DroidTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? DroidTheme.primary : DroidTheme.textDim, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DroidTheme.headingSm.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(desc, style: DroidTheme.bodySm.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? DroidTheme.primary : DroidTheme.textDim,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarterAppsTab(AppState state) {
    return ListView(
      key: const ValueKey(2),
      children: [
        Text(
          'Queue optional starter desktop tools for your Linux workspace:',
          style: DroidTheme.bodyMd.copyWith(color: DroidTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        ..._starterApps.map((app) {
          final queued = state.queuedStarterApps.contains(app.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => state.toggleQueuedStarterApp(app.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: queued ? DroidTheme.surfaceLight : DroidTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: queued ? app.color.withValues(alpha: 0.8) : DroidTheme.surfaceBorder,
                    width: queued ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: app.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(app.icon, color: app.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(app.name, style: DroidTheme.headingSm.copyWith(fontSize: 14)),
                              const Spacer(),
                              Text(app.size, style: DroidTheme.monoSm.copyWith(fontSize: 11, color: DroidTheme.textDim)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(app.description, style: DroidTheme.bodySm.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: queued,
                      activeColor: app.color,
                      onChanged: (_) => state.toggleQueuedStarterApp(app.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        final isCurrent = i == current - 1;
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isCurrent
                  ? DroidTheme.accent
                  : isActive
                      ? DroidTheme.primary
                      : DroidTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _StarterAppInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String size;

  const _StarterAppInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.size,
  });
}
