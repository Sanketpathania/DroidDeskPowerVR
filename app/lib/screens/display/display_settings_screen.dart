import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  String _selectedResPreset = '150%';
  int _targetWidth = 1994;
  int _targetHeight = 896;
  double _uiScale = 1.5;
  String _touchMode = 'trackpad'; // 'trackpad' or 'direct'
  bool _lock120Hz = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display & Session Settings'),
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
            // ── Resolution Presets ──
            _buildResolutionPresetsCard(),

            const SizedBox(height: 16),

            // ── UI Scale & Refresh Rate ──
            _buildScaleAndRefreshCard(),

            const SizedBox(height: 16),

            // ── Touch & Pointer Interaction ──
            _buildTouchModeCard(),

            const SizedBox(height: 16),

            // ── Desktop Environment Switcher ──
            _buildDeSwitcherCard(state),

            const SizedBox(height: 24),

            // ── Apply Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Display set to ${_targetWidth}x$_targetHeight (${(_uiScale * 100).toInt()}%) · Touch: $_touchMode',
                      ),
                      backgroundColor: DroidTheme.success,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text(
                  'Apply Display Configuration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DroidTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionPresetsCard() {
    final presets = [
      _ResPreset(
        id: '200%',
        name: '200% Integer Scaling',
        resolution: '1496 × 672',
        desc: 'Fastest 3D frame rates & maximum battery longevity on Tensor G5.',
        color: DroidTheme.accent,
        width: 1496,
        height: 672,
      ),
      _ResPreset(
        id: '150%',
        name: '150% Balanced (Recommended)',
        resolution: '1994 × 896',
        desc: 'Crisp font rendering with ideal touch target sizing for OLED display.',
        color: DroidTheme.secondary,
        width: 1994,
        height: 896,
      ),
      _ResPreset(
        id: '100%',
        name: '100% Native 3K Super Actua',
        resolution: '2992 × 1344',
        desc: 'Pixel-for-pixel native density. Recommended when using bluetooth mouse.',
        color: const Color(0xFF38BDF8),
        width: 2992,
        height: 1344,
      ),
      _ResPreset(
        id: '1080p',
        name: '1080p Standard Monitor',
        resolution: '1920 × 1080',
        desc: '16:9 standard ratio for USB-C DisplayPort external monitor casting.',
        color: const Color(0xFFFBBF24),
        width: 1920,
        height: 1080,
      ),
    ];

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
              const Icon(Icons.aspect_ratio_rounded, size: 18, color: DroidTheme.primaryLight),
              const SizedBox(width: 8),
              Text('DISPLAY RESOLUTION & SCALING PRESETS', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in presets) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedResPreset = p.id;
                  _targetWidth = p.width;
                  _targetHeight = p.height;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedResPreset == p.id
                      ? p.color.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedResPreset == p.id
                        ? p.color
                        : DroidTheme.surfaceBorder,
                    width: _selectedResPreset == p.id ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: p.id,
                      groupValue: _selectedResPreset,
                      activeColor: p.color,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedResPreset = val;
                            _targetWidth = p.width;
                            _targetHeight = p.height;
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.name,
                                style: DroidTheme.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                p.resolution,
                                style: DroidTheme.monoSm.copyWith(
                                  color: p.color,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.desc,
                            style: DroidTheme.bodySm.copyWith(
                              color: DroidTheme.textDim,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScaleAndRefreshCard() {
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
              const Icon(Icons.speed_rounded, size: 18, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              Text('REFRESH RATE & INTERFACE SCALING', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 14),

          // 120Hz Lock
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Actua 120Hz LTPO OLED Lock',
                      style: DroidTheme.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Locks display to 120 FPS frame flips for ultra-fluid cursor tracking (8.33ms budget).',
                      style: DroidTheme.bodySm.copyWith(
                        color: DroidTheme.textDim,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _lock120Hz,
                activeColor: Colors.cyanAccent,
                onChanged: (v) => setState(() => _lock120Hz = v),
              ),
            ],
          ),
          _divider(),

          // UI Scale Factor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Desktop UI DPI Scaling',
                style: DroidTheme.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(_uiScale * 100).toInt()}% Scale',
                style: DroidTheme.monoSm.copyWith(
                  color: DroidTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<double>(
            segments: const [
              ButtonSegment(value: 1.0, label: Text('100%')),
              ButtonSegment(value: 1.25, label: Text('125%')),
              ButtonSegment(value: 1.5, label: Text('150%')),
              ButtonSegment(value: 2.0, label: Text('200%')),
            ],
            selected: {_uiScale},
            onSelectionChanged: (val) {
              setState(() => _uiScale = val.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTouchModeCard() {
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
              const Icon(Icons.touch_app_rounded, size: 18, color: DroidTheme.secondary),
              const SizedBox(width: 8),
              Text('TOUCH POINTER & INPUT INTERACTION', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _touchOptionTile(
                  id: 'trackpad',
                  title: 'Virtual Trackpad',
                  desc: 'Relative swipe cursor movement with fine-grain tap to click.',
                  icon: Icons.mouse_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _touchOptionTile(
                  id: 'direct',
                  title: 'Direct Touch',
                  desc: 'Immediate finger digitizer click directly beneath finger contact.',
                  icon: Icons.fingerprint_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _touchOptionTile({
    required String id,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final selected = _touchMode == id;
    return GestureDetector(
      onTap: () => setState(() => _touchMode = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? DroidTheme.secondary.withValues(alpha: 0.15)
              : Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? DroidTheme.secondary : DroidTheme.surfaceBorder,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? DroidTheme.secondary : DroidTheme.textDim,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: DroidTheme.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : DroidTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: DroidTheme.bodySm.copyWith(
                color: DroidTheme.textDim,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeSwitcherCard(AppState state) {
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
              const Icon(Icons.desktop_windows_rounded, size: 18, color: DroidTheme.accent),
              const SizedBox(width: 8),
              Text('DESKTOP ENVIRONMENT SELECTION', style: DroidTheme.label),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Currently active Desktop: ${state.selectedDE.toUpperCase()}',
            style: DroidTheme.bodyMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'XFCE4 is the recommended lightweight desktop for PowerVR TBDR GPU performance.',
            style: DroidTheme.bodySm.copyWith(color: DroidTheme.textDim, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 20,
      color: DroidTheme.surfaceBorder.withValues(alpha: 0.5),
    );
  }
}

class _ResPreset {
  final String id;
  final String name;
  final String resolution;
  final String desc;
  final Color color;
  final int width;
  final int height;

  _ResPreset({
    required this.id,
    required this.name,
    required this.resolution,
    required this.desc,
    required this.color,
    required this.width,
    required this.height,
  });
}
