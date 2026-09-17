import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/services/platform_bridge.dart';
import 'package:droiddesk/screens/setup/de_install_screen.dart';
import 'package:droiddesk/screens/apps/app_catalog_screen.dart';
import 'package:droiddesk/screens/benchmarks/benchmark_screen.dart';
import 'package:droiddesk/screens/powervr/powervr_tuning_screen.dart';
import 'package:droiddesk/screens/diagnostics/diagnostics_screen.dart';
import 'package:droiddesk/screens/display/display_settings_screen.dart';
import 'package:droiddesk/screens/terminal/terminal_screen.dart';

/// Home dashboard — shown after setup is complete.
/// Central hub for launching the desktop, terminal, and managing the environment.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icons/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DroidDesk', style: DroidTheme.headingSm),
                          Text(
                            state.isRunning ? 'Desktop Running' : 'Ready',
                            style: DroidTheme.bodySm.copyWith(
                              color: state.isRunning
                                  ? DroidTheme.accent
                                  : DroidTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DisplaySettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.display_settings_rounded,
                          color: Colors.cyanAccent,
                        ),
                        tooltip: 'Display & Session',
                      ),
                      IconButton(
                        onPressed: () => _showSettings(context),
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: DroidTheme.textMuted,
                        ),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Status Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildStatusCard(context, state)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.05, duration: 500.ms),
                ),
              ),

              // ── PowerVR / Pixel 10 Pro XL Hardware Hub Card ──
              if (state.isPowerVR || state.isPixel10)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1F1232), Color(0xFF120E1E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
                        border: Border.all(
                          color: DroidTheme.secondary.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DroidTheme.secondary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DroidTheme.secondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.memory_rounded,
                                  color: DroidTheme.secondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.isPixel10ProXL
                                          ? 'Pixel 10 Pro XL · PowerVR DXT Active'
                                          : 'PowerVR / IMG GPU Active',
                                      style: DroidTheme.headingSm.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Hardware acceleration & Tensor G5 multi-threading',
                                      style: DroidTheme.bodySm.copyWith(
                                        color: DroidTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _featureChip('Zink + Vulkan 1.3', DroidTheme.accent),
                              _featureChip('TBDR Lazy Descriptors', DroidTheme.secondary),
                              _featureChip('8-Core Threading', const Color(0xFF38BDF8)),
                              _featureChip('Super Actua 120Hz', Colors.cyanAccent),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const PowerVrTuningScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.tune_rounded, size: 15),
                                  label: const Text(
                                    'GPU Tuning',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DroidTheme.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const BenchmarkScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.speed_rounded, size: 15, color: Color(0xFF38BDF8)),
                                  label: const Text(
                                    '3D Benchmarks',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ),
                ),

              // ── Quick Actions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text(
                    'CORE MODULES & TOOLS',
                    style: DroidTheme.label,
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      // Installation is only actionable when setup is missing.
                      if (!state.isDEInstalled) ...[
                        _ActionCard(
                          icon: Icons.download_rounded,
                          title: 'Install ${state.selectedDE.toUpperCase()}',
                          subtitle: 'Install desktop environment packages (one-time setup)',
                          color: DroidTheme.secondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DEInstallScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ── Launch Desktop / Reconnect ──
                      if (state.isRunning)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActionCard(
                            icon: Icons.fullscreen_rounded,
                            title: 'Return to Desktop',
                            subtitle: '${state.selectedDE.toUpperCase()} is running in background',
                            color: DroidTheme.primary,
                            gradient: DroidTheme.primaryGradient,
                            onTap: () {
                              state.launchDesktopActivity();
                            },
                          ),
                        ),

                      _ActionCard(
                        icon: state.isRunning
                            ? Icons.stop_circle_rounded
                            : Icons.desktop_mac_rounded,
                        title: state.isRunning ? 'Stop Server' : 'Launch Desktop',
                        subtitle: state.isRunning
                            ? 'Shutdown Linux environment'
                            : 'Start ${state.selectedDE.toUpperCase()} desktop environment',
                        color: state.isRunning ? DroidTheme.error : DroidTheme.primary,
                        gradient: state.isRunning ? null : DroidTheme.primaryGradient,
                        onTap: () async {
                          if (state.isRunning) {
                            state.stopLinux();
                          } else {
                            if (!state.isDEInstalled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No Desktop Environment installed. Please complete setup first.',
                                  ),
                                  backgroundColor: DroidTheme.error,
                                ),
                              );
                              return;
                            }
                            await state.startLinux(mode: 'x11');
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── PowerVR GPU Tuning Hub ──
                      _ActionCard(
                        icon: Icons.tune_rounded,
                        title: 'PowerVR GPU Tuning Hub',
                        subtitle: 'Configure Zink Gallium, TBDR Lazy Descriptors & Threading',
                        color: DroidTheme.secondary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PowerVrTuningScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── 3D GPU Benchmarks ──
                      _ActionCard(
                        icon: Icons.speed_rounded,
                        title: '3D GPU Benchmarks',
                        subtitle: 'Stress test PowerVR DXT-48-1536 & real-time frame telemetry',
                        color: const Color(0xFF38BDF8),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BenchmarkScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Software Store / App Catalog ──
                      _ActionCard(
                        icon: Icons.apps_rounded,
                        title: 'Linux Software Catalog',
                        subtitle: 'Install VS Code, LibreOffice, GIMP, Blender, Godot & tools',
                        color: DroidTheme.primaryLight,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AppCatalogScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Diagnostics & CPU Monitor ──
                      _ActionCard(
                        icon: Icons.developer_board_rounded,
                        title: 'Diagnostics & CPU Monitor',
                        subtitle: 'Tensor G5 8-core topology, GPU nodes & RAM partition health',
                        color: const Color(0xFF34D399),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DiagnosticsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Linux Terminal Console ──
                      _ActionCard(
                        icon: Icons.terminal_rounded,
                        title: 'Interactive Linux Terminal',
                        subtitle: 'Full shell console with quick diagnostic commands',
                        color: const Color(0xFFFBBF24),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TerminalScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // ── Display & Session Settings ──
                      _ActionCard(
                        icon: Icons.display_settings_rounded,
                        title: 'Display & Session Manager',
                        subtitle: 'Resolution modes (150% / 3K Native), 120Hz lock & touch mode',
                        color: Colors.cyanAccent,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DisplaySettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                    ].animate(interval: 60.ms).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05, duration: 400.ms),
                  ),
                ),
              ),

              // ── System Info ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text(
                    'SYSTEM OVERVIEW',
                    style: DroidTheme.label,
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DroidTheme.cardBg,
                      borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
                      border: Border.all(color: DroidTheme.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'Distribution',
                          _distroLabel(state.installedDistro),
                        ),
                        _divider(),
                        _infoRow('Desktop', state.selectedDE.toUpperCase()),
                        _divider(),
                        _infoRow('GPU', state.gpuType),
                        _divider(),
                        _infoRow(
                          'Renderer',
                          state.deviceInfo['graphicsMode']?.toString() ?? 'Zink + Vulkan HW',
                        ),
                        _divider(),
                        _infoRow(
                          'Device',
                          '${state.deviceInfo['brand'] ?? 'Google'} ${state.deviceInfo['model'] ?? 'Pixel 10 Pro XL'}',
                        ),
                        _divider(),
                        _infoRow(
                          'Android',
                          '${state.deviceInfo['androidVersion'] ?? (state.isAndroid17 ? '17' : '16')} (SDK ${state.deviceInfo['sdkVersion'] ?? (state.isAndroid17 ? '37' : '36')})',
                        ),
                        _divider(),
                        _infoRow(
                          'Kernel Pages',
                          '${state.pageSizeKB} KB (Android 17 / 16KB Page Aligned)',
                        ),
                        _divider(),
                        _infoRow(
                          'RAM',
                          '${state.deviceInfo['totalRamMB'] ?? '16384'} MB',
                        ),
                        _divider(),
                        _infoRow(
                          'Storage Free',
                          '${state.deviceInfo['availableStorageMB'] ?? '128000'} MB',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Card ──

  Widget _buildStatusCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: state.isRunning
            ? const LinearGradient(
                colors: [Color(0xFF0D2818), Color(0xFF0A1F14)],
              )
            : DroidTheme.cardGradient,
        borderRadius: BorderRadius.circular(DroidTheme.radiusLg),
        border: Border.all(
          color: state.isRunning
              ? DroidTheme.accent.withValues(alpha: 0.3)
              : DroidTheme.surfaceBorder,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.isRunning ? DroidTheme.accent : DroidTheme.textDim,
              boxShadow: state.isRunning
                  ? [
                      BoxShadow(
                        color: DroidTheme.accent.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isRunning ? 'Desktop Active' : 'Desktop Idle',
                  style: DroidTheme.headingSm.copyWith(
                    color: state.isRunning
                        ? DroidTheme.accent
                        : DroidTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.isRunning
                      ? '${state.selectedDE.toUpperCase()} · ${_distroLabel(state.installedDistro)}'
                      : 'Tap "Launch Desktop" to start Linux GUI',
                  style: DroidTheme.bodySm,
                ),
              ],
            ),
          ),
          if (state.isRunning)
            ElevatedButton(
              onPressed: () => state.launchDesktopActivity(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DroidTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Open GUI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: DroidTheme.bodySm),
          const Spacer(),
          Text(
            value,
            style: DroidTheme.monoSm.copyWith(color: DroidTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: DroidTheme.surfaceBorder.withValues(alpha: 0.5),
    );
  }

  String _distroLabel(String distro) {
    switch (distro) {
      case 'ubuntu-chroot':
        return 'Ubuntu 24.04 (chroot)';
      case 'ubuntu':
        return 'Ubuntu 24.04';
      case 'alpine':
        return 'Alpine Linux 3.20';
      case 'kali':
        return 'Kali Linux';
      case 'termux-native':
        return 'Termux Native';
      default:
        return distro;
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DroidTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings & Controls', style: DroidTheme.headingLg),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.memory_rounded,
                color: DroidTheme.secondary,
              ),
              title: const Text('PowerVR GPU Tuning'),
              subtitle: const Text('Configure Zink, TBDR and driver flags'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PowerVrTuningScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.speed_rounded,
                color: Color(0xFF38BDF8),
              ),
              title: const Text('3D GPU Benchmarks'),
              subtitle: const Text('Stress test PowerVR DXT-48-1536'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BenchmarkScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.battery_charging_full,
                color: DroidTheme.warning,
              ),
              title: const Text('Battery Optimization'),
              subtitle: const Text('Disable to prevent session killing'),
              onTap: () {
                DroidDeskPlatform.requestBatteryOptimization();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: DroidTheme.monoSm.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Small Action Card widget ──

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient != null
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: gradient == null ? DroidTheme.cardBg : null,
          borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DroidTheme.headingSm.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DroidTheme.bodySm.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: DroidTheme.textDim),
          ],
        ),
      ),
    );
  }
}
