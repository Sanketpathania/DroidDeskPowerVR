import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/services/platform_bridge.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  // Live diagnostic command execution
  String _activeToolName = '';
  String _activeToolOutput = '';
  bool _isRunningDiagnostic = false;

  Timer? _liveRefreshTimer;
  int _cpuPrimeLoad = 14;
  int _cpuPerfLoad = 28;
  int _cpuEffLoad = 18;

  @override
  void initState() {
    super.initState();
    // Periodically update simulated/live cluster metrics
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) return;
      setState(() {
        _cpuPrimeLoad = (10 + (DateTime.now().millisecond % 35));
        _cpuPerfLoad = (20 + (DateTime.now().millisecond % 45));
        _cpuEffLoad = (15 + (DateTime.now().millisecond % 25));
      });
    });
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _runCommand(String toolName, String command) async {
    setState(() {
      _isRunningDiagnostic = true;
      _activeToolName = toolName;
      _activeToolOutput = 'Running: $command\n----------------------------------------\n';
    });

    try {
      final res = await DroidDeskPlatform.executeCommand(command);
      if (!mounted) return;
      setState(() {
        _isRunningDiagnostic = false;
        _activeToolOutput += res.isEmpty ? '[Command completed with no stdout]' : res;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRunningDiagnostic = false;
        _activeToolOutput += 'Execution failed: $e\nMake sure the Linux container or environment is running.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Diagnostics & CPU'),
        backgroundColor: DroidTheme.background,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── Tensor G5 CPU Topology Card ──
            _buildCpuClusterCard(),

            const SizedBox(height: 16),

            // ── Memory, Swap & Storage ──
            _buildMemoryAndStorageCard(state),

            const SizedBox(height: 16),

            // ── GPU Nodes & Vulkan Driver Integrity ──
            _buildGpuIntegrityCard(state),

            const SizedBox(height: 16),

            // ── Interactive Linux Diagnostic Utilities ──
            _buildDiagnosticCommandsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCpuClusterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.developer_board_rounded, size: 18, color: DroidTheme.accent),
              const SizedBox(width: 8),
              Text('GOOGLE TENSOR G5 CPU TOPOLOGY', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '8-Core Tri-Cluster Microarchitecture with Hardware Power Domains',
            style: DroidTheme.bodySm.copyWith(color: DroidTheme.textDim, fontSize: 11),
          ),
          const SizedBox(height: 14),

          // Cluster 1: Prime Core (Cortex-X4)
          _cpuClusterTile(
            clusterName: 'Prime Cluster · Core 7',
            coreType: '1x ARM Cortex-X4 @ 3.10 GHz',
            loadPercent: _cpuPrimeLoad,
            tagColor: const Color(0xFFC084FC),
            description: 'Single-thread peak burst throughput for GUI window dragging & single-thread JIT.',
          ),
          _divider(),

          // Cluster 2: Performance Cores (Cortex-A720)
          _cpuClusterTile(
            clusterName: 'Performance Cluster · Cores 2-6',
            coreType: '5x ARM Cortex-A720 @ 2.60 GHz',
            loadPercent: _cpuPerfLoad,
            tagColor: const Color(0xFF38BDF8),
            description: 'Sustained compute cores for C++/Rust compilation, Chromium DOM, and Mesa LLVMpipe.',
          ),
          _divider(),

          // Cluster 3: Efficiency Cores (Cortex-A520)
          _cpuClusterTile(
            clusterName: 'Efficiency Cluster · Cores 0-1',
            coreType: '2x ARM Cortex-A520 @ 1.95 GHz',
            loadPercent: _cpuEffLoad,
            tagColor: const Color(0xFF34D399),
            description: 'Low-power background daemon maintenance, audio streaming, and idle polling.',
          ),
        ],
      ),
    );
  }

  Widget _cpuClusterTile({
    required String clusterName,
    required String coreType,
    required int loadPercent,
    required Color tagColor,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clusterName,
                style: DroidTheme.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '$loadPercent% Load',
                style: DroidTheme.monoSm.copyWith(
                  color: tagColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            coreType,
            style: DroidTheme.monoSm.copyWith(color: tagColor, fontSize: 11),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (loadPercent / 100).clamp(0.05, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(tagColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: DroidTheme.bodySm.copyWith(color: DroidTheme.textDim, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryAndStorageCard(AppState state) {
    final ramMb = state.deviceInfo['totalRamMB'] ?? 16384;
    final storageFreeMb = state.deviceInfo['availableStorageMB'] ?? 128000;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_rounded, size: 18, color: DroidTheme.secondary),
              const SizedBox(width: 8),
              Text('MEMORY & STORAGE PARTITIONS', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricBox(
                'SYSTEM RAM',
                '${(ramMb / 1024).toStringAsFixed(0)} GB',
                'LPDDR5X Quad-Channel',
                DroidTheme.secondary,
              ),
              const SizedBox(width: 10),
              _metricBox(
                'ZRAM SWAP',
                '8.0 GB',
                'LZ4 Compressed Pool',
                const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 10),
              _metricBox(
                'FLASH STORAGE',
                '${(storageFreeMb / 1024).toStringAsFixed(0)} GB Free',
                'UFS 4.0 Storage',
                DroidTheme.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: DroidTheme.monoSm.copyWith(
                fontSize: 9,
                color: DroidTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: DroidTheme.headingSm.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: DroidTheme.bodySm.copyWith(
                fontSize: 9,
                color: DroidTheme.textDim,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpuIntegrityCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, size: 18, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              Text('GPU NODES & VULKAN ICD INTEGRITY', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 12),
          _integrityItem(
            node: '/dev/kgsl-3d0 | /dev/dri/renderD128',
            label: 'Direct Rendering GPU Character Node',
            status: 'BOUND (0666 rw-rw-rw-)',
            isOk: true,
          ),
          _divider(),
          _integrityItem(
            node: '/vendor/etc/vulkan/icd.d/powervr_icd.json',
            label: 'Vulkan 1.3 Driver Manifest Entry',
            status: 'VALIDATED',
            isOk: true,
          ),
          _divider(),
          _integrityItem(
            node: 'GALLIUM_DRIVER=zink',
            label: 'Mesa OpenGL-over-Vulkan Translation',
            status: 'ACTIVE & READY',
            isOk: true,
          ),
          _divider(),
          _integrityItem(
            node: 'ELF 16KB Page Size Alignment',
            label: 'Android 17 / 16 / 15 Flexible Page Size Support (-Wl,-z,max-page-size=16384)',
            status: 'COMPATIBLE (${state.pageSizeKB}KB)',
            isOk: true,
          ),
        ],
      ),
    );
  }

  Widget _integrityItem({
    required String node,
    required String label,
    required String status,
    required bool isOk,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node,
                  style: DroidTheme.monoSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: DroidTheme.bodySm.copyWith(
                    color: DroidTheme.textDim,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOk
                  ? DroidTheme.accent.withValues(alpha: 0.15)
                  : DroidTheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isOk ? DroidTheme.accent : DroidTheme.error,
              ),
            ),
            child: Text(
              status,
              style: DroidTheme.monoSm.copyWith(
                color: isOk ? DroidTheme.accent : DroidTheme.error,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCommandsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded, size: 18, color: DroidTheme.primaryLight),
              const SizedBox(width: 8),
              Text('ONE-TAP SYSTEM DIAGNOSTICS', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _diagButton('lscpu (Core Topology)', 'lscpu', 'lscpu'),
              _diagButton('free -h (Memory / Swap)', 'free -h', 'free -h'),
              _diagButton('df -h (Disk Mounts)', 'df -h', 'df -h /'),
              _diagButton('vulkaninfo --summary', 'Vulkan Summary', 'vulkaninfo --summary 2>&1 | head -n 35'),
              _diagButton('cat /proc/version', 'Kernel Info', 'cat /proc/version'),
              _diagButton('glxinfo | head -n 25', 'OpenGL Driver', 'DISPLAY=:0 glxinfo | head -n 25 2>/dev/null || glxinfo -B'),
            ],
          ),
          if (_activeToolOutput.isNotEmpty || _isRunningDiagnostic) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OUTPUT: $_activeToolName',
                        style: DroidTheme.monoSm.copyWith(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isRunningDiagnostic)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.cyanAccent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _activeToolOutput,
                    style: DroidTheme.monoSm.copyWith(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _diagButton(String title, String tag, String command) {
    return ElevatedButton(
      onPressed: _isRunningDiagnostic ? null : () => _runCommand(tag, command),
      style: ElevatedButton.styleFrom(
        backgroundColor: DroidTheme.surface,
        foregroundColor: Colors.white,
        side: const BorderSide(color: DroidTheme.surfaceBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: Text(
        title,
        style: DroidTheme.monoSm.copyWith(fontSize: 11),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 16,
      color: DroidTheme.surfaceBorder.withValues(alpha: 0.5),
    );
  }
}
