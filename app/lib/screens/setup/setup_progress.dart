import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/screens/setup/setup_post_config.dart';

/// Setup progress screen — step 3 of setup wizard.
/// Shows 5 granular milestones, live speed metrics, terminal drawer, and recovery controls.
class SetupProgressScreen extends StatefulWidget {
  const SetupProgressScreen({super.key});

  @override
  State<SetupProgressScreen> createState() => _SetupProgressScreenState();
}

class _SetupProgressScreenState extends State<SetupProgressScreen> {
  bool _started = false;
  bool _showTerminalLogs = false;
  DateTime? _setupStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSetup();
    });
  }

  Future<void> _startSetup() async {
    if (_started) return;
    _started = true;
    _setupStartTime = DateTime.now();
    final state = context.read<AppState>();

    final freeStorage = (state.deviceInfo['availableStorageMB'] as num?)?.toInt();
    if (freeStorage != null && freeStorage < 2048) {
      final continueAnyway =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              icon: const Icon(
                Icons.storage_rounded,
                color: DroidTheme.warning,
                size: 38,
              ),
              title: const Text('Low storage'),
              content: Text(
                'Only $freeStorage MB is available. Desktop Essentials works best with at least 2 GB free. You can continue, but package installation may fail.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Go back'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Continue anyway'),
                ),
              ],
            ),
          ) ??
          false;
      if (!continueAnyway) {
        _started = false;
        if (mounted) Navigator.of(context).maybePop();
        return;
      }
    }

    final rooted = await state.detectRootForSetup();
    if (!mounted) return;

    var useRoot = false;
    if (rooted) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              icon: const Icon(
                Icons.admin_panel_settings_rounded,
                color: DroidTheme.accent,
                size: 38,
              ),
              title: const Text('Root access detected'),
              content: const Text(
                'Your device is rooted. Continue with the rooted chroot '
                'runtime for the best performance and full Linux support?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Continue with root'),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) {
        _started = false;
        if (mounted) Navigator.of(context).maybePop();
        return;
      }
      useRoot = true;
    }

    if (!mounted) return;
    state.runSetup(useRoot: useRoot);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final phase = _getPhase(state);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Progress Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STEP 3 OF 3: INSTALLATION',
                      style: DroidTheme.label.copyWith(letterSpacing: 1.2, color: DroidTheme.textDim),
                    ),
                    IconButton(
                      icon: Icon(
                        _showTerminalLogs ? Icons.dashboard_customize_rounded : Icons.terminal_rounded,
                        color: DroidTheme.secondary,
                        size: 20,
                      ),
                      tooltip: _showTerminalLogs ? 'Show Visual Stepper' : 'Show Live Console',
                      onPressed: () => setState(() => _showTerminalLogs = !_showTerminalLogs),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Circular Progress & Speed Indicator ──
                CircularPercentIndicator(
                  radius: 72,
                  lineWidth: 6,
                  percent: phase.progress.clamp(0.0, 1.0),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        phase.icon,
                        size: 32,
                        color: phase.error ? DroidTheme.error : DroidTheme.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(phase.progress * 100).toInt()}%',
                        style: DroidTheme.headingSm.copyWith(
                          color: phase.error ? DroidTheme.error : DroidTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  progressColor: phase.error ? DroidTheme.error : DroidTheme.primary,
                  backgroundColor: DroidTheme.surfaceBorder,
                  circularStrokeCap: CircularStrokeCap.round,
                  animateFromLastPercent: true,
                  animation: true,
                  animationDuration: 400,
                ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // ── Phase Title & Message ──
                Text(
                  phase.title,
                  style: DroidTheme.headingLg,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 4),

                Text(
                  phase.message,
                  style: DroidTheme.bodySm.copyWith(
                    color: phase.error ? DroidTheme.error : DroidTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (state.isDownloading && state.downloadSpeedMBs > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: DroidTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚡ ${state.downloadSpeedMBs.toStringAsFixed(1)} MB/s',
                      style: DroidTheme.monoSm.copyWith(color: DroidTheme.secondary, fontSize: 11),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── Switch between Granular Checklist & Terminal Console ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _showTerminalLogs
                        ? _buildInstallLog(state.setupLog.isEmpty ? 'Waiting for package manager output...' : state.setupLog)
                        : _buildFiveStageChecklist(state),
                  ),
                ),

                // ── Bottom Actions / Recovery Controls ──
                if (phase.error) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Clean Slate Reset'),
                                      content: const Text('This will unmount lingering file handles and clear the temporary directory for a fresh setup.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: DroidTheme.error),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Reset Clean'),
                                        ),
                                      ],
                                    ),
                                  ) ?? false;
                                  if (confirmed) {
                                    await state.resetInstallation();
                                    _started = false;
                                    _startSetup();
                                  }
                                },
                                icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                                label: const Text('Clean Reset'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  state.repairAndRetry();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DroidTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.build_rounded, size: 16),
                                label: const Text('Repair & Retry'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (phase.complete) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SetupPostConfigScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DroidTheme.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Configure & Launch Desktop',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiveStageChecklist(AppState state) {
    final isChroot = state.hasRoot;
    final extractP = state.extractProgress;
    final downloadP = state.downloadProgress;

    final steps = [
      _ChecklistItem(
        stage: 1,
        label: 'Pre-flight & Storage Verification',
        detail: 'Checked storage, page alignment, & CPU sandbox.',
        done: true,
        active: false,
      ),
      _ChecklistItem(
        stage: 2,
        label: isChroot ? 'Download ${state.selectedDistro.toUpperCase()} Archive' : 'Retrieve Native Termux Bootstrap',
        detail: isChroot
            ? (state.isDownloading ? '${(downloadP * 100).toInt()}% · ${(downloadP * 350).toInt()}/350 MB' : 'Rootfs verified')
            : (extractP >= 0.08 ? 'Bootstrap downloaded' : 'Unpacking bootstrap package'),
        done: isChroot ? downloadP >= 1.0 : extractP >= 0.08,
        active: isChroot ? state.isDownloading : (extractP < 0.08 && !state.isSetupComplete),
        progress: isChroot ? (state.isDownloading ? downloadP : null) : (extractP < 0.08 ? extractP / 0.08 : null),
      ),
      _ChecklistItem(
        stage: 3,
        label: 'Filesystem Extraction & Permissions',
        detail: 'Setting up POSIX ownership and socket bindings.',
        done: isChroot ? extractP >= 0.3 : extractP >= 0.25,
        active: isChroot ? (state.isExtracting && extractP < 0.3) : (extractP >= 0.08 && extractP < 0.25),
      ),
      _ChecklistItem(
        stage: 4,
        label: 'Desktop Environment (${state.selectedDE.toUpperCase()})',
        detail: 'Installing window manager, panels, & terminal.',
        done: isChroot ? extractP >= 0.85 : extractP >= 0.70,
        active: isChroot ? (state.isInstallingDE || extractP >= 0.3 && extractP < 0.85) : (extractP >= 0.25 && extractP < 0.70),
      ),
      _ChecklistItem(
        stage: 5,
        label: 'Touch Display & Audio Pipeline',
        detail: 'Configuring PULSEAUDIO and DPI acceleration.',
        done: state.isSetupComplete,
        active: (extractP >= 0.70 || state.isInstallingDE) && !state.isSetupComplete,
      ),
    ];

    return ListView.separated(
      key: const ValueKey('checklist'),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = steps[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: item.active
                ? DroidTheme.surfaceLight
                : item.done
                    ? DroidTheme.cardBg
                    : DroidTheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item.active
                  ? DroidTheme.primary.withValues(alpha: 0.6)
                  : item.done
                      ? DroidTheme.accent.withValues(alpha: 0.3)
                      : DroidTheme.surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.done
                      ? DroidTheme.accent.withValues(alpha: 0.15)
                      : item.active
                          ? DroidTheme.primary.withValues(alpha: 0.15)
                          : DroidTheme.surface,
                ),
                child: Center(
                  child: item.done
                      ? const Icon(Icons.check_rounded, color: DroidTheme.accent, size: 16)
                      : item.active
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: DroidTheme.primary),
                            )
                          : Text(
                              '${item.stage}',
                              style: DroidTheme.monoSm.copyWith(color: DroidTheme.textDim, fontSize: 11),
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: DroidTheme.bodySm.copyWith(
                        fontWeight: item.active || item.done ? FontWeight.w600 : FontWeight.normal,
                        color: item.done
                            ? DroidTheme.textPrimary
                            : item.active
                                ? DroidTheme.textPrimary
                                : DroidTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.detail,
                      style: DroidTheme.monoSm.copyWith(
                        fontSize: 10,
                        color: item.active ? DroidTheme.secondary : DroidTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.progress != null)
                Text(
                  '${(item.progress! * 100).toInt()}%',
                  style: DroidTheme.monoSm.copyWith(color: DroidTheme.primary, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstallLog(String log) {
    final cleanLog = log.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
    return Container(
      key: const ValueKey('terminal'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF080D18),
        border: Border.all(color: DroidTheme.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Text(
          cleanLog,
          style: DroidTheme.monoSm.copyWith(
            color: DroidTheme.textSecondary,
            height: 1.35,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  _PhaseInfo _getPhase(AppState state) {
    if (state.errorMessage != null) {
      return _PhaseInfo(
        title: 'Installation Paused',
        message: state.errorMessage!,
        progress: 0,
        icon: Icons.error_outline_rounded,
        error: true,
        complete: false,
      );
    }

    if (state.isDownloading) {
      return _PhaseInfo(
        title: 'Downloading Rootfs',
        message: state.downloadStatus.isNotEmpty ? state.downloadStatus : 'Downloading distribution image...',
        progress: state.downloadProgress * 0.45,
        icon: Icons.cloud_download_rounded,
        error: false,
        complete: false,
      );
    }

    if (state.isExtracting || state.isInstallingDE) {
      if (!state.hasRoot) {
        return _PhaseInfo(
          title: state.extractProgress < 0.08 ? 'Unpacking Bootstrap' : 'Configuring Desktop',
          message: state.extractStatus.isNotEmpty ? state.extractStatus : 'Setting up native Linux packages...',
          progress: state.extractProgress,
          icon: state.extractProgress < 0.08 ? Icons.inventory_2_rounded : Icons.terminal_rounded,
          error: false,
          complete: false,
        );
      }
      return _PhaseInfo(
        title: state.isInstallingDE ? 'Installing Desktop' : 'Extracting Filesystem',
        message: state.extractStatus.isNotEmpty ? state.extractStatus : 'Extracting filesystem & configuring permissions...',
        progress: 0.45 + state.extractProgress * 0.5,
        icon: state.isInstallingDE ? Icons.desktop_windows_rounded : Icons.unarchive_rounded,
        error: false,
        complete: false,
      );
    }

    if (state.isSetupComplete) {
      return _PhaseInfo(
        title: 'Setup Completed Successfully!',
        message: 'Your Linux environment is ready for final customization.',
        progress: 1.0,
        icon: Icons.check_circle_rounded,
        error: false,
        complete: true,
      );
    }

    return _PhaseInfo(
      title: 'Preparing Setup',
      message: 'Running pre-flight system diagnostics...',
      progress: 0.05,
      icon: Icons.settings_suggest_rounded,
      error: false,
      complete: false,
    );
  }
}

class _PhaseInfo {
  final String title;
  final String message;
  final double progress;
  final IconData icon;
  final bool error;
  final bool complete;

  _PhaseInfo({
    required this.title,
    required this.message,
    required this.progress,
    required this.icon,
    required this.error,
    required this.complete,
  });
}

class _ChecklistItem {
  final int stage;
  final String label;
  final String detail;
  final bool done;
  final bool active;
  final double? progress;

  _ChecklistItem({
    required this.stage,
    required this.label,
    required this.detail,
    required this.done,
    required this.active,
    this.progress,
  });
}

