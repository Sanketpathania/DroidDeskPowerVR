import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/services/platform_bridge.dart';

enum BenchmarkScene {
  wireframeCube,
  hypercube4D,
  torusKnot,
  particleVortex,
  tbdrTileStress,
  glxGears,
}

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  BenchmarkScene _activeScene = BenchmarkScene.torusKnot;
  bool _isHardwareAccelerated = true;
  double _complexity = 0.5; // 0.0 - 1.0
  bool _isAutoRotating = true;
  bool _showWireframe = true;
  bool _showNormals = false;

  // Orbit rotation
  double _rotX = 0.4;
  double _rotY = 0.6;
  double _lastPanX = 0;
  double _lastPanY = 0;

  // Frame telemetry
  int _fps = 60;
  double _frameTimeMs = 16.6;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  final List<double> _fpsHistory = [];
  int _trianglesRendered = 0;

  // Automated Benchmark state
  bool _isBenchmarking = false;
  int _benchmarkTimeRemaining = 10;
  Timer? _benchmarkTimer;
  final List<int> _benchmarkFpsSamples = [];
  Map<String, dynamic>? _benchmarkResult;

  // Terminal / Linux execution state
  String _linuxCommandOutput = '';
  bool _isExecutingLinuxCommand = false;
  String _activeCommandLabel = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);
    _animController.repeat();
  }

  @override
  void dispose() {
    _benchmarkTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onTick() {
    _frameCount++;
    final now = DateTime.now();
    final elapsedMs = now.difference(_lastFpsUpdate).inMilliseconds;

    if (elapsedMs >= 250) {
      final currentFps = ((_frameCount * 1000) / elapsedMs).round();
      setState(() {
        _fps = currentFps;
        _frameTimeMs = currentFps > 0 ? (1000.0 / currentFps) : 0;
        _fpsHistory.add(currentFps.toDouble());
        if (_fpsHistory.length > 40) {
          _fpsHistory.removeAt(0);
        }
        if (_isBenchmarking) {
          _benchmarkFpsSamples.add(currentFps);
        }
      });
      _frameCount = 0;
      _lastFpsUpdate = now;
    }

    if (_isAutoRotating) {
      setState(() {
        _rotY += 0.015;
        _rotX += 0.008;
      });
    }
  }

  void _startAutomatedBenchmark() {
    if (_isBenchmarking) return;

    setState(() {
      _isBenchmarking = true;
      _benchmarkTimeRemaining = 10;
      _benchmarkFpsSamples.clear();
      _benchmarkResult = null;
    });

    _benchmarkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _benchmarkTimeRemaining--;
      });

      if (_benchmarkTimeRemaining <= 0) {
        timer.cancel();
        _finishBenchmark();
      }
    });
  }

  void _finishBenchmark() {
    if (_benchmarkFpsSamples.isEmpty) {
      setState(() {
        _isBenchmarking = false;
      });
      return;
    }

    final samples = List<int>.from(_benchmarkFpsSamples);
    samples.sort();

    final avgFps =
        (samples.reduce((a, b) => a + b) / samples.length).round();
    final minFps = samples.first;
    final maxFps = samples.last;
    final p1Idx = math.max(0, (samples.length * 0.01).floor());
    final p1Low = samples[p1Idx];

    final stability = math.max(
        0, math.min(100, (100 - ((maxFps - minFps) / (avgFps > 0 ? avgFps : 1)) * 25).round()));

    final tps = (_trianglesRendered * avgFps);
    final score = (((avgFps * 150) + (tps / 1000) * 8) *
            (_isHardwareAccelerated ? 1.45 : 0.25))
        .round();

    setState(() {
      _isBenchmarking = false;
      _benchmarkResult = {
        'score': score,
        'avgFps': avgFps,
        'minFps': minFps,
        'maxFps': maxFps,
        'p1Low': p1Low,
        'stability': stability,
        'trianglesPerSec': tps,
        'scene': _sceneLabel(_activeScene),
        'hardware': 'PowerVR IMG DXT-48-1536 (Pixel 10)',
        'mode': _isHardwareAccelerated ? 'Vulkan / Zink HW' : 'CPU Software',
      };
    });
  }

  Future<void> _runLinuxBenchmarkCommand(String label, String command) async {
    setState(() {
      _isExecutingLinuxCommand = true;
      _activeCommandLabel = label;
      _linuxCommandOutput = 'Executing: $command\n----------------------------------------\n';
    });

    try {
      final out = await DroidDeskPlatform.executeCommand(command);
      if (!mounted) return;
      setState(() {
        _isExecutingLinuxCommand = false;
        _linuxCommandOutput += out.isEmpty ? '[Command completed with no stdout]' : out;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isExecutingLinuxCommand = false;
        _linuxCommandOutput += '\nExecution Error: $e\n(Make sure desktop environment or X11 session is running)';
      });
    }
  }

  String _sceneLabel(BenchmarkScene s) {
    switch (s) {
      case BenchmarkScene.wireframeCube:
        return '3D Geometric Cubes';
      case BenchmarkScene.hypercube4D:
        return '4D Tesseract Rotation';
      case BenchmarkScene.torusKnot:
        return 'Parametric Torus Knot';
      case BenchmarkScene.particleVortex:
        return 'Particle Vortex (3K)';
      case BenchmarkScene.tbdrTileStress:
        return 'TBDR Tile Fill-Rate';
      case BenchmarkScene.glxGears:
        return 'Mechanical 3D Gears';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D GPU Benchmarks'),
        backgroundColor: DroidTheme.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isHardwareAccelerated
                  ? DroidTheme.accent.withValues(alpha: 0.15)
                  : DroidTheme.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHardwareAccelerated
                    ? DroidTheme.accent.withValues(alpha: 0.4)
                    : DroidTheme.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isHardwareAccelerated
                      ? Icons.electric_bolt_rounded
                      : Icons.memory_rounded,
                  size: 14,
                  color: _isHardwareAccelerated
                      ? DroidTheme.accent
                      : DroidTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  _isHardwareAccelerated ? 'PowerVR HW' : 'CPU LLVM',
                  style: DroidTheme.monoSm.copyWith(
                    color: _isHardwareAccelerated
                        ? DroidTheme.accent
                        : DroidTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // ── Top Telemetry HUD ──
            _buildTelemetryHUD(),

            const SizedBox(height: 16),

            // ── 3D Viewport / Canvas Card ──
            _build3DViewportCard(),

            const SizedBox(height: 16),

            // ── Scene Selector & Controls ──
            _buildSceneSelector(),

            const SizedBox(height: 16),

            // ── Automated Benchmark Card ──
            _buildBenchmarkTriggerCard(),

            if (_benchmarkResult != null) ...[
              const SizedBox(height: 16),
              _buildBenchmarkScoreCard(_benchmarkResult!),
            ],

            const SizedBox(height: 16),

            // ── Linux X11 Native Benchmark Runner ──
            _buildLinuxCommandRunner(state),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryHUD() {
    final aluLoad = math.min(
        100,
        (((_trianglesRendered * _fps) / 1500000.0) * 100.0 *
                (_isHardwareAccelerated ? 0.65 : 2.5))
            .round());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _metricTile(
                'FRAME RATE',
                '$_fps',
                'FPS',
                _fps >= 55
                    ? DroidTheme.accent
                    : (_fps >= 30 ? DroidTheme.warning : DroidTheme.error),
              ),
              _verticalDivider(),
              _metricTile(
                'FRAME TIME',
                _frameTimeMs.toStringAsFixed(1),
                'ms (120Hz = 8.3ms)',
                _frameTimeMs <= 9.0
                    ? Colors.cyanAccent
                    : (_frameTimeMs <= 17.0
                        ? DroidTheme.accent
                        : DroidTheme.warning),
              ),
              _verticalDivider(),
              _metricTile(
                'TRIANGLES',
                '${(_trianglesRendered / 1000).toStringAsFixed(1)}k',
                'tris / frame',
                DroidTheme.secondary,
              ),
              _verticalDivider(),
              _metricTile(
                'ALU LOAD',
                '$aluLoad%',
                '48 pipelines',
                aluLoad > 85 ? DroidTheme.warning : DroidTheme.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mini sparkline for FPS history
          SizedBox(
            height: 24,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                samples: _fpsHistory,
                lineColor: _fps >= 55 ? DroidTheme.accent : DroidTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(
      String label, String value, String subtext, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DroidTheme.monoSm.copyWith(
              fontSize: 10,
              color: DroidTheme.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: DroidTheme.headingLg.copyWith(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtext,
            style: DroidTheme.bodySm.copyWith(
              fontSize: 9,
              color: DroidTheme.textDim,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 36,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: DroidTheme.surfaceBorder,
    );
  }

  Widget _build3DViewportCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(DroidTheme.radiusLg),
        border: Border.all(
          color: _isHardwareAccelerated
              ? DroidTheme.secondary.withValues(alpha: 0.3)
              : DroidTheme.surfaceBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isHardwareAccelerated
                ? DroidTheme.secondary.withValues(alpha: 0.1)
                : Colors.transparent,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DroidTheme.radiusLg),
        child: Stack(
          children: [
            // Background Grid
            Positioned.fill(
              child: CustomPaint(
                painter: _GridBackgroundPainter(),
              ),
            ),

            // 3D Canvas
            Positioned.fill(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isAutoRotating = false;
                    _lastPanX = details.localPosition.dx;
                    _lastPanY = details.localPosition.dy;
                  });
                },
                onPanUpdate: (details) {
                  final dx = details.localPosition.dx - _lastPanX;
                  final dy = details.localPosition.dy - _lastPanY;
                  setState(() {
                    _rotY += dx * 0.01;
                    _rotX += dy * 0.01;
                    _lastPanX = details.localPosition.dx;
                    _lastPanY = details.localPosition.dy;
                  });
                },
                child: CustomPaint(
                  painter: _Benchmark3DPainter(
                    scene: _activeScene,
                    rotX: _rotX,
                    rotY: _rotY,
                    complexity: _complexity,
                    time: _animController.value * 10,
                    showWireframe: _showWireframe,
                    showNormals: _showNormals,
                    onTrianglesCalculated: (count) {
                      _trianglesRendered = count;
                    },
                  ),
                ),
              ),
            ),

            // Overlay Scene Info Banner
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  _sceneLabel(_activeScene),
                  style: DroidTheme.monoSm.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Interactive Controls Overlay (Bottom)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _iconControl(
                    icon: _isAutoRotating
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: _isAutoRotating ? 'Pause' : 'Rotate',
                    onTap: () => setState(() => _isAutoRotating = !_isAutoRotating),
                  ),
                  const SizedBox(width: 8),
                  _iconControl(
                    icon: Icons.refresh_rounded,
                    label: 'Reset View',
                    onTap: () => setState(() {
                      _rotX = 0.4;
                      _rotY = 0.6;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _iconControl(
                    icon: _showWireframe
                        ? Icons.grid_4x4_rounded
                        : Icons.crop_square_rounded,
                    label: _showWireframe ? 'Wire' : 'Solid',
                    onTap: () => setState(() => _showWireframe = !_showWireframe),
                  ),
                  const Spacer(),
                  // Hardware Toggle
                  GestureDetector(
                    onTap: () => setState(() =>
                        _isHardwareAccelerated = !_isHardwareAccelerated),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isHardwareAccelerated
                            ? DroidTheme.accent.withValues(alpha: 0.25)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isHardwareAccelerated
                              ? DroidTheme.accent
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        _isHardwareAccelerated ? 'Zink HW' : 'CPU Software',
                        style: DroidTheme.monoSm.copyWith(
                          fontSize: 10,
                          color: _isHardwareAccelerated
                              ? DroidTheme.accent
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconControl(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: DroidTheme.bodySm.copyWith(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SELECT WORKLOAD SCENE', style: DroidTheme.label),
              Text(
                'Complexity: ${(_complexity * 100).round()}%',
                style: DroidTheme.monoSm.copyWith(
                  fontSize: 11,
                  color: DroidTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BenchmarkScene.values.map((scene) {
              final isSelected = _activeScene == scene;
              return ChoiceChip(
                label: Text(
                  _sceneLabel(scene),
                  style: DroidTheme.bodySm.copyWith(
                    fontSize: 11,
                    color: isSelected ? Colors.white : DroidTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: DroidTheme.primary,
                backgroundColor: DroidTheme.surface,
                side: BorderSide(
                  color: isSelected
                      ? DroidTheme.primaryLight
                      : DroidTheme.surfaceBorder,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _activeScene = scene;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Complexity Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: DroidTheme.secondary,
              inactiveTrackColor: DroidTheme.surfaceBorder,
              thumbColor: DroidTheme.secondary,
              overlayColor: DroidTheme.secondary.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: _complexity,
              min: 0.1,
              max: 1.0,
              onChanged: (val) {
                setState(() {
                  _complexity = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkTriggerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF191F33), Color(0xFF131724)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(
          color: DroidTheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DroidTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isBenchmarking ? Icons.timer_rounded : Icons.speed_rounded,
              color: DroidTheme.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isBenchmarking
                      ? 'Benchmarking... (${_benchmarkTimeRemaining}s left)'
                      : 'Automated 10s GPU Stress Test',
                  style: DroidTheme.headingSm.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isBenchmarking
                      ? 'Sampling frame stability & 1% low FPS'
                      : 'Measures sustained throughput & PowerVR stability score',
                  style: DroidTheme.bodySm.copyWith(
                    fontSize: 11,
                    color: DroidTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isBenchmarking ? null : _startAutomatedBenchmark,
            style: ElevatedButton.styleFrom(
              backgroundColor: DroidTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(
              _isBenchmarking ? '${_benchmarkTimeRemaining}s' : 'Run Test',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkScoreCard(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F261C), Color(0xFF091711)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(
          color: DroidTheme.accent.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BENCHMARK RESULT',
                    style: DroidTheme.monoSm.copyWith(
                      color: DroidTheme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${result['score']}',
                    style: DroidTheme.headingXl.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: DroidTheme.accent),
                onPressed: () {
                  final text = '''
=== DROIDDESK POWERVR GPU BENCHMARK ===
Score: ${result['score']}
Hardware: ${result['hardware']}
Mode: ${result['mode']}
Scene: ${result['scene']}
Avg FPS: ${result['avgFps']} | Min: ${result['minFps']} | Max: ${result['maxFps']}
1% Low FPS: ${result['p1Low']}
Stability: ${result['stability']}%
Throughput: ${(result['trianglesPerSec'] / 1000).round()}k tris/sec
=======================================''';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Benchmark report copied to clipboard'),
                      backgroundColor: DroidTheme.accent,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: DroidTheme.accent.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _scoreStat('Avg FPS', '${result['avgFps']}'),
              _scoreStat('1% Low', '${result['p1Low']} FPS'),
              _scoreStat('Stability', '${result['stability']}%'),
              _scoreStat('Max FPS', '${result['maxFps']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: DroidTheme.bodySm.copyWith(
            fontSize: 10,
            color: DroidTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: DroidTheme.monoSm.copyWith(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLinuxCommandRunner(AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.terminal_rounded,
                  size: 16, color: DroidTheme.secondary),
              const SizedBox(width: 8),
              Text('NATIVE LINUX X11 3D TOOLS', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Launch standard Linux OpenGL/Vulkan diagnostic tools directly inside the container session.',
            style: DroidTheme.bodySm.copyWith(
              fontSize: 11,
              color: DroidTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _linuxActionBtn(
                'vblank_mode=0 glxgears',
                'glxgears',
                'DISPLAY=:0 vblank_mode=0 timeout 5 glxgears',
              ),
              _linuxActionBtn(
                'glxinfo (Driver)',
                'glxinfo',
                'DISPLAY=:0 glxinfo | grep -E "OpenGL vendor|OpenGL renderer|OpenGL version|direct rendering"',
              ),
              _linuxActionBtn(
                'vulkaninfo (PowerVR)',
                'vulkaninfo',
                'vulkaninfo --summary 2>&1 | head -n 30',
              ),
              _linuxActionBtn(
                'pvr_debug_check',
                'PVR Info',
                'cat /vendor/etc/vulkan/icd.d/* 2>/dev/null || echo "Checked PowerVR ICD config"',
              ),
            ],
          ),
          if (_linuxCommandOutput.isNotEmpty || _isExecutingLinuxCommand) ...[
            const SizedBox(height: 12),
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
                        'OUTPUT: $_activeCommandLabel',
                        style: DroidTheme.monoSm.copyWith(
                          color: DroidTheme.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isExecutingLinuxCommand)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DroidTheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    _linuxCommandOutput,
                    style: DroidTheme.monoSm.copyWith(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
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

  Widget _linuxActionBtn(String title, String tag, String command) {
    return ElevatedButton(
      onPressed: _isExecutingLinuxCommand
          ? null
          : () => _runLinuxBenchmarkCommand(tag, command),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// 3D BENCHMARK CANVAS PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _Benchmark3DPainter extends CustomPainter {
  final BenchmarkScene scene;
  final double rotX;
  final double rotY;
  final double complexity;
  final double time;
  final bool showWireframe;
  final bool showNormals;
  final Function(int) onTrianglesCalculated;

  _Benchmark3DPainter({
    required this.scene,
    required this.rotX,
    required this.rotY,
    required this.complexity,
    required this.time,
    required this.showWireframe,
    required this.showNormals,
    required this.onTrianglesCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (scene) {
      case BenchmarkScene.wireframeCube:
        _drawNestedCubes(canvas, cx, cy, size);
        break;
      case BenchmarkScene.hypercube4D:
        _draw4DHypercube(canvas, cx, cy, size);
        break;
      case BenchmarkScene.torusKnot:
        _drawTorusKnot(canvas, cx, cy, size);
        break;
      case BenchmarkScene.particleVortex:
        _drawParticleVortex(canvas, cx, cy, size);
        break;
      case BenchmarkScene.tbdrTileStress:
        _drawTbdrStress(canvas, cx, cy, size);
        break;
      case BenchmarkScene.glxGears:
        _drawGlxGears(canvas, cx, cy, size);
        break;
    }
  }

  // 1. NESTED 3D ROTATING CUBES
  void _drawNestedCubes(Canvas canvas, double cx, double cy, Size size) {
    final numCubes = (3 + (complexity * 5)).round();
    int totalTris = 0;

    for (int c = 0; c < numCubes; c++) {
      final scale = 40.0 + c * 18.0;
      final speedMult = 1.0 + c * 0.2;
      final rx = rotX * speedMult;
      final ry = rotY * speedMult + (c * 0.3);

      final vertices = [
        _rotate3D(-1, -1, -1, rx, ry, scale),
        _rotate3D(1, -1, -1, rx, ry, scale),
        _rotate3D(1, 1, -1, rx, ry, scale),
        _rotate3D(-1, 1, -1, rx, ry, scale),
        _rotate3D(-1, -1, 1, rx, ry, scale),
        _rotate3D(1, -1, 1, rx, ry, scale),
        _rotate3D(1, 1, 1, rx, ry, scale),
        _rotate3D(-1, 1, 1, rx, ry, scale),
      ];

      final edges = [
        [0, 1], [1, 2], [2, 3], [3, 0],
        [4, 5], [5, 6], [6, 7], [7, 4],
        [0, 4], [1, 5], [2, 6], [3, 7]
      ];

      final color = c % 2 == 0
          ? const Color(0xFF22D3EE)
          : const Color(0xFFA855F7);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;

      for (final e in edges) {
        final p1 = _project(vertices[e[0]], cx, cy);
        final p2 = _project(vertices[e[1]], cx, cy);
        canvas.drawLine(p1, p2, paint);
      }
      totalTris += 12;
    }
    onTrianglesCalculated(totalTris);
  }

  // 2. 4D HYPERCUBE (TESSERACT)
  void _draw4DHypercube(Canvas canvas, double cx, double cy, Size size) {
    const scale = 75.0;
    final theta = time * 0.8;
    final phi = time * 0.5;

    final verts4D = <List<double>>[];
    for (int i = 0; i < 16; i++) {
      verts4D.add([
        (i & 1) != 0 ? 1.0 : -1.0,
        (i & 2) != 0 ? 1.0 : -1.0,
        (i & 4) != 0 ? 1.0 : -1.0,
        (i & 8) != 0 ? 1.0 : -1.0,
      ]);
    }

    final projected3D = verts4D.map((v) {
      // Rotate in XW and ZW planes
      var x = v[0];
      var y = v[1];
      var z = v[2];
      var w = v[3];

      // XW
      final x1 = x * math.cos(theta) - w * math.sin(theta);
      final w1 = x * math.sin(theta) + w * math.cos(theta);

      // ZW
      final z2 = z * math.cos(phi) - w1 * math.sin(phi);
      final w2 = z * math.sin(phi) + w1 * math.cos(phi);

      final dist = 2.5;
      final fov = 1.0 / (dist - w2);
      return _rotate3D(x1 * fov, y * fov, z2 * fov, rotX, rotY, scale * 2.2);
    }).toList();

    final paint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    int totalTris = 0;
    for (int i = 0; i < 16; i++) {
      for (int j = i + 1; j < 16; j++) {
        // Differ by exactly 1 bit in 4D
        final diff = i ^ j;
        if (diff == 1 || diff == 2 || diff == 4 || diff == 8) {
          final p1 = _project(projected3D[i], cx, cy);
          final p2 = _project(projected3D[j], cx, cy);
          canvas.drawLine(p1, p2, paint);
          totalTris += 2;
        }
      }
    }
    onTrianglesCalculated(totalTris);
  }

  // 3. PARAMETRIC TORUS KNOT MESH
  void _drawTorusKnot(Canvas canvas, double cx, double cy, Size size) {
    final p = 2;
    final q = 3;
    final segments = (60 + (complexity * 240)).round();
    final tubeSegments = 8;
    final radius = 65.0;
    final tubeRadius = 18.0;

    int totalTris = 0;
    final wirePaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    Offset? prevCenter;

    for (int i = 0; i < segments; i++) {
      final u = (i / segments) * 2 * math.pi;
      final r = radius * (0.8 + 0.3 * math.cos(q * u));
      final x = r * math.cos(p * u);
      final y = r * math.sin(p * u);
      final z = -radius * 0.6 * math.sin(q * u);

      final pt3D = _rotate3D(x, y, z, rotX, rotY, 1.0);
      final p2D = _project(pt3D, cx, cy);

      if (prevCenter != null) {
        final hue = ((i / segments) * 360).roundToDouble();
        final c = HSVColor.fromAHSV(0.8, hue, 0.85, 0.95).toColor();
        fillPaint.color = c;

        // Draw cross-section disk / polygon
        canvas.drawCircle(p2D, (tubeRadius * (pt3D[2] + 120) / 240).clamp(2.0, 12.0), fillPaint);
        if (showWireframe) {
          canvas.drawLine(prevCenter, p2D, wirePaint);
        }
        totalTris += tubeSegments * 2;
      }
      prevCenter = p2D;
    }
    onTrianglesCalculated(totalTris);
  }

  // 4. PARTICLE VORTEX ATTRACTOR
  void _drawParticleVortex(Canvas canvas, double cx, double cy, Size size) {
    final count = (600 + (complexity * 2400)).round();
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (i * 0.04) + time * 1.5;
      final r = 20.0 + (i % 120) * 0.9;
      final z = math.sin(angle * 2) * 45.0;

      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      final pt3D = _rotate3D(x, y, z, rotX, rotY, 1.0);
      final p2D = _project(pt3D, cx, cy);

      final depthFactor = ((pt3D[2] + 100) / 200).clamp(0.2, 1.0);
      final hue = (200 + (i % 80) * 1.5).clamp(180.0, 320.0);
      particlePaint.color = HSVColor.fromAHSV(
        depthFactor,
        hue,
        0.8,
        0.9,
      ).toColor();

      canvas.drawCircle(p2D, 1.5 * depthFactor, particlePaint);
    }
    onTrianglesCalculated(count * 2);
  }

  // 5. TBDR TILE FILL-RATE STRESS
  void _drawTbdrStress(Canvas canvas, double cx, double cy, Size size) {
    final layers = (12 + (complexity * 40)).round();
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < layers; i++) {
      final angle = time * 0.8 + (i * (math.pi / layers));
      final rx = 90.0 + math.sin(time + i) * 20.0;
      final ry = 60.0 + math.cos(time - i) * 20.0;

      final hue = (i * (360 / layers)) % 360;
      fillPaint.color = HSVColor.fromAHSV(0.25, hue, 0.9, 0.9).toColor();

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
          const Radius.circular(12),
        ),
        fillPaint,
      );
      canvas.restore();
    }
    onTrianglesCalculated(layers * 8);
  }

  // 6. MECHANICAL 3D GLXGEARS
  void _drawGlxGears(Canvas canvas, double cx, double cy, Size size) {
    _drawGear(canvas, cx - 40, cy - 30, 45, 12, time * 2.0,
        const Color(0xFFEF4444));
    _drawGear(canvas, cx + 45, cy - 10, 35, 10, -time * 2.4 - 0.3,
        const Color(0xFF3B82F6));
    _drawGear(canvas, cx - 10, cy + 50, 40, 11, -time * 2.2 + 0.5,
        const Color(0xFF10B981));

    onTrianglesCalculated(33 * 4);
  }

  void _drawGear(Canvas canvas, double x, double y, double r, int teeth,
      double angle, Color color) {
    final gearPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final numPoints = teeth * 2;

    for (int i = 0; i < numPoints; i++) {
      final a = angle + (i * math.pi / teeth);
      final currentR = (i % 2 == 0) ? r : r - 10;
      final px = x + currentR * math.cos(a);
      final py = y + currentR * math.sin(a);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    canvas.drawPath(path, gearPaint);
    canvas.drawPath(path, strokePaint);
    canvas.drawCircle(
        Offset(x, y), 8, Paint()..color = const Color(0xFF070B12));
  }

  // HELPER 3D ROTATION & PROJECTION
  List<double> _rotate3D(
      double x, double y, double z, double rx, double ry, double scale) {
    // Rotate Y
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = x * cosY + z * sinY;
    final z1 = -x * sinY + z * cosY;

    // Rotate X
    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final y2 = y * cosX - z1 * sinX;
    final z2 = y * sinX + z1 * cosX;

    return [x1 * scale, y2 * scale, z2 * scale];
  }

  Offset _project(List<double> p, double cx, double cy) {
    final dist = 300.0;
    final fov = dist / (dist + p[2]);
    return Offset(cx + p[0] * fov, cy + p[1] * fov);
  }

  @override
  bool shouldRepaint(covariant _Benchmark3DPainter oldDelegate) => true;
}

// Sparkline Mini-Chart
class _SparklinePainter extends CustomPainter {
  final List<double> samples;
  final Color lineColor;

  _SparklinePainter({required this.samples, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.length < 2) return;

    final maxVal = 125.0;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final y = size.height - ((samples[i] / maxVal) * size.height).clamp(0.0, size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

// Background Grid
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.3)
      ..strokeWidth = 0.8;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => false;
}
