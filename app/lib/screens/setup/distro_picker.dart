import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/screens/setup/de_picker.dart';

/// Distro selection screen — step 1 of setup wizard.
class DistroPickerScreen extends StatelessWidget {
  const DistroPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final freeStorage = (state.deviceInfo['availableStorageMB'] as num?)?.toInt() ?? 4096;
    final isStorageLow = freeStorage < 3000;

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

                // ── Header ──
                _buildStepIndicator(1, 3),
                const SizedBox(height: 20),

                Text('Choose Your Linux', style: DroidTheme.headingXl)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, duration: 400.ms),

                const SizedBox(height: 6),
                Text(
                  'Select a distribution tailored to your performance profile.',
                  style: DroidTheme.bodyMd,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // ── Pre-flight Hardware & Compatibility Card ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DroidTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DroidTheme.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isStorageLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: isStorageLow ? DroidTheme.warning : DroidTheme.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Storage: $freeStorage MB free ${isStorageLow ? '(Minimum 3GB recommended)' : '(Optimal)'}',
                              style: DroidTheme.bodySm.copyWith(
                                color: isStorageLow ? DroidTheme.warning : DroidTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: state.hasRoot ? DroidTheme.accent.withValues(alpha: 0.15) : DroidTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state.hasRoot ? 'ROOT CHROOT' : 'NATIVE PRoot',
                              style: DroidTheme.label.copyWith(
                                color: state.hasRoot ? DroidTheme.accent : DroidTheme.primary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.memory_rounded, size: 14, color: DroidTheme.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Android ${state.deviceInfo['androidVersion'] ?? (state.isAndroid17 ? '17' : '16')} · ${state.pageSizeKB}KB Pages · ${state.deviceInfo['brand'] ?? 'Device'}',
                              style: DroidTheme.monoSm.copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // ── Quick Start Presets ──
                Text(
                  'QUICK START PROFILES',
                  style: DroidTheme.label.copyWith(letterSpacing: 1.2, color: DroidTheme.textDim),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PresetChip(
                        label: 'Recommended Daily',
                        sub: 'Ubuntu + XFCE',
                        icon: Icons.thumb_up_alt_rounded,
                        color: DroidTheme.primary,
                        onTap: () {
                          state.setSelectedDistro('ubuntu');
                          state.setSelectedDE('xfce4');
                        },
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        label: 'Ultra Lightweight',
                        sub: 'Alpine + LXQt',
                        icon: Icons.bolt_rounded,
                        color: DroidTheme.alpineColor,
                        onTap: () {
                          state.setSelectedDistro('alpine');
                          state.setSelectedDE('lxqt');
                        },
                      ),
                      const SizedBox(width: 8),
                      _PresetChip(
                        label: 'Security Suite',
                        sub: 'Kali + XFCE',
                        icon: Icons.security_rounded,
                        color: DroidTheme.kaliColor,
                        onTap: () {
                          state.setSelectedDistro('kali');
                          state.setSelectedDE('xfce4');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Distro Cards ──
                Expanded(
                  child: ListView(
                    children: [
                      _DistroCard(
                        id: 'ubuntu',
                        name: 'Ubuntu 24.04 LTS',
                        description: 'Best overall experience. Huge package library, Touch-tuned XFCE4 & KDE support.',
                        size: '~350 MB download',
                        installTime: '~2 min install',
                        ramFootprint: '~250 MB RAM',
                        color: DroidTheme.ubuntuColor,
                        icon: Icons.circle,
                        recommended: true,
                        badge: 'BEST FOR TOUCH & APPS',
                        selected: state.selectedDistro == 'ubuntu',
                        onTap: () => state.setSelectedDistro('ubuntu'),
                      ),
                      const SizedBox(height: 12),
                      _DistroCard(
                        id: 'alpine',
                        name: 'Alpine Linux 3.20',
                        description: 'Ultra minimal and secure with musl libc. Fastest setup and lowest footprint.',
                        size: '~5 MB download',
                        installTime: '<1 min install',
                        ramFootprint: '~90 MB RAM',
                        color: DroidTheme.alpineColor,
                        icon: Icons.diamond_outlined,
                        recommended: false,
                        badge: 'ULTRA FAST & TINY',
                        selected: state.selectedDistro == 'alpine',
                        onTap: () => state.setSelectedDistro('alpine'),
                      ),
                      const SizedBox(height: 12),
                      _DistroCard(
                        id: 'kali',
                        name: 'Kali Linux Rolling',
                        description: 'Security testing suite with Nmap, Wireshark, Metasploit, and forensics tools.',
                        size: '~500 MB download',
                        installTime: '~3 min install',
                        ramFootprint: '~320 MB RAM',
                        color: DroidTheme.kaliColor,
                        icon: Icons.shield_outlined,
                        recommended: false,
                        badge: 'SECURITY & PENTESTING',
                        selected: state.selectedDistro == 'kali',
                        onTap: () => state.setSelectedDistro('kali'),
                      ),
                    ]
                        .animate(interval: 80.ms)
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.1, duration: 400.ms),
                  ),
                ),

                // ── Navigation ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const DEPickerScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Next: Desktop'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 18),
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
                  ? DroidTheme.primary
                  : isActive
                      ? DroidTheme.primary.withValues(alpha: 0.5)
                      : DroidTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DroidTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: DroidTheme.bodySm.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(sub, style: DroidTheme.monoSm.copyWith(fontSize: 10, color: DroidTheme.textDim)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DistroCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String size;
  final String installTime;
  final String ramFootprint;
  final Color color;
  final IconData icon;
  final bool recommended;
  final String badge;
  final bool selected;
  final VoidCallback onTap;

  const _DistroCard({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.installTime,
    required this.ramFootprint,
    required this.color,
    required this.icon,
    required this.recommended,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? DroidTheme.surfaceLight : DroidTheme.cardBg,
          borderRadius: BorderRadius.circular(DroidTheme.radiusLg),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : DroidTheme.surfaceBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ── Distro Icon ──
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),

                // ── Text Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: DroidTheme.headingSm),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: DroidTheme.label.copyWith(
                                color: color,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(description, style: DroidTheme.bodySm),
                    ],
                  ),
                ),

                // ── Selection Indicator ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected ? color : DroidTheme.textDim,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Resource Indicators ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DroidTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Indicator(Icons.download_rounded, size),
                  _Indicator(Icons.timer_outlined, installTime),
                  _Indicator(Icons.memory_rounded, ramFootprint),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Indicator(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: DroidTheme.textDim),
        const SizedBox(width: 4),
        Text(text, style: DroidTheme.monoSm.copyWith(fontSize: 10, color: DroidTheme.textMuted)),
      ],
    );
  }
}

