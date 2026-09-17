import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/state/app_state.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/services/platform_bridge.dart';

class AppCatalogScreen extends StatefulWidget {
  const AppCatalogScreen({super.key});

  @override
  State<AppCatalogScreen> createState() => _AppCatalogScreenState();
}

class _AppCatalogScreenState extends State<AppCatalogScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  static const List<_CatalogApp> _allApps = [
    // Development
    _CatalogApp(
      id: 'code_oss',
      name: 'VS Code (Code OSS)',
      description: 'Desktop source-code editor with extensions and terminal integration.',
      icon: Icons.code_rounded,
      color: Color(0xFF23A8F2),
      category: 'dev',
      package: 'code-oss',
      size: '220 MB',
    ),
    _CatalogApp(
      id: 'nodejs',
      name: 'Node.js & npm',
      description: 'JavaScript & TypeScript runtime engine with full npm package ecosystem.',
      icon: Icons.javascript_rounded,
      color: Color(0xFF68A063),
      category: 'dev',
      package: 'nodejs npm',
      size: '85 MB',
    ),
    _CatalogApp(
      id: 'python3',
      name: 'Python 3 & Pip',
      description: 'Python interpreter with pip package manager and scientific libraries.',
      icon: Icons.terminal_rounded,
      color: Color(0xFF38BDF8),
      category: 'dev',
      package: 'python3 python3-pip python3-venv',
      size: '95 MB',
    ),
    _CatalogApp(
      id: 'godot',
      name: 'Godot Game Engine',
      description: 'Open source 2D and 3D game creation engine with OpenGL renderer.',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF478CBF),
      category: 'dev',
      package: 'godot3',
      size: '140 MB',
    ),

    // Productivity & Office
    _CatalogApp(
      id: 'libreoffice',
      name: 'LibreOffice Suite',
      description: 'Complete office suite: Writer, Calc, Impress, and Draw for documents.',
      icon: Icons.article_rounded,
      color: Color(0xFF18A303),
      category: 'productivity',
      package: 'libreoffice',
      size: '340 MB',
    ),

    // Graphics & 3D
    _CatalogApp(
      id: 'gimp',
      name: 'GIMP Image Editor',
      description: 'GNU Image Manipulation Program for photo retouching and graphic design.',
      icon: Icons.brush_rounded,
      color: Color(0xFFE5A50A),
      category: 'graphics',
      package: 'gimp',
      size: '160 MB',
    ),
    _CatalogApp(
      id: 'blender',
      name: 'Blender 3D Suite',
      description: '3D modeling, sculpting, animation, and rendering suite for PowerVR.',
      icon: Icons.view_in_ar_rounded,
      color: Color(0xFFF5792A),
      category: 'graphics',
      package: 'blender',
      size: '280 MB',
    ),
    _CatalogApp(
      id: 'inkscape',
      name: 'Inkscape Vector Graphics',
      description: 'Professional vector graphics editor for SVG, logos, and illustrations.',
      icon: Icons.gesture_rounded,
      color: Color(0xFFC084FC),
      category: 'graphics',
      package: 'inkscape',
      size: '190 MB',
    ),
    _CatalogApp(
      id: 'krita',
      name: 'Krita Digital Painting',
      description: 'Digital painting and illustration suite with customizable brushes.',
      icon: Icons.palette_rounded,
      color: Color(0xFFF472B6),
      category: 'graphics',
      package: 'krita',
      size: '210 MB',
    ),
    _CatalogApp(
      id: 'imagemagick',
      name: 'ImageMagick CLI',
      description: 'Command-line image conversion, batch resizing, and processing tools.',
      icon: Icons.image_rounded,
      color: DroidTheme.primaryLight,
      category: 'graphics',
      package: 'imagemagick',
      size: '45 MB',
    ),

    // Media & Browsers
    _CatalogApp(
      id: 'firefox',
      name: 'Firefox Browser',
      description: 'Full-featured desktop web browser with GPU hardware acceleration.',
      icon: Icons.public_rounded,
      color: Color(0xFFFF7139),
      category: 'media',
      package: 'firefox-esr',
      size: '130 MB',
    ),
    _CatalogApp(
      id: 'chromium',
      name: 'Chromium Browser',
      description: 'Open-source browser engine with multi-process tab sandboxing.',
      icon: Icons.travel_explore_rounded,
      color: Color(0xFF4285F4),
      category: 'media',
      package: 'chromium',
      size: '180 MB',
    ),
    _CatalogApp(
      id: 'vlc',
      name: 'VLC Media Player',
      description: 'Versatile media player supporting all audio, video, and streaming formats.',
      icon: Icons.play_circle_fill_rounded,
      color: Color(0xFFFF9500),
      category: 'media',
      package: 'vlc',
      size: '80 MB',
    ),
    _CatalogApp(
      id: 'audacity',
      name: 'Audacity Audio Studio',
      description: 'Multi-track audio editor and recorder for podcasting and music.',
      icon: Icons.graphic_eq_rounded,
      color: Color(0xFF005AC1),
      category: 'media',
      package: 'audacity',
      size: '75 MB',
    ),

    // Utilities
    _CatalogApp(
      id: 'mesa_utils',
      name: 'Mesa 3D Utils & Glxgears',
      description: 'OpenGL & Vulkan diagnostic utilities (glxinfo, glxgears, es2gears).',
      icon: Icons.speed_rounded,
      color: Color(0xFF34D399),
      category: 'utilities',
      package: 'mesa-utils vulkan-tools',
      size: '25 MB',
    ),
    _CatalogApp(
      id: 'neofetch',
      name: 'Neofetch & Htop Tools',
      description: 'CLI system information card and interactive real-time process viewer.',
      icon: Icons.info_outline_rounded,
      color: Color(0xFFA855F7),
      category: 'utilities',
      package: 'neofetch htop',
      size: '15 MB',
    ),
  ];

  static const _prootDebian = _CatalogApp(
    id: 'proot_debian',
    name: 'Debian (PRoot Base)',
    description: 'Minimal PRoot compatibility environment for unrooted non-standard setups.',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFFD70A53),
    category: 'utilities',
    package: 'proot-distro',
    size: '110 MB',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshOptionalApps();
    });
  }

  Future<void> _installApp(_CatalogApp app) async {
    final state = context.read<AppState>();

    // For apps that use standard state installer:
    if (app.id == 'firefox' || app.id == 'code_oss' || app.id == 'nodejs' || app.id == 'imagemagick' || app.id == 'proot_debian') {
      final ok = await state.installOptionalApp(app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '${app.name} installed' : '${app.name} installation failed.'),
          backgroundColor: ok ? DroidTheme.success : DroidTheme.error,
        ),
      );
      return;
    }

    // Direct apt installation for newly added catalog items
    state.appendTerminalOutput('\n\$ sudo apt update && sudo apt install -y ${app.package}\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting installation of ${app.name}...'),
        backgroundColor: DroidTheme.secondary,
      ),
    );

    try {
      await DroidDeskPlatform.executeCommand('apt update && DEBIAN_FRONTEND=noninteractive apt install -y ${app.package}');
      state.optionalApps[app.id] = true;
      state.notifyListeners();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${app.name} installed successfully!'),
          backgroundColor: DroidTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Installation finished (${app.name})'),
          backgroundColor: DroidTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final allList = state.hasRoot ? _allApps : [..._allApps, _prootDebian];

    final filteredApps = allList.where((app) {
      final matchesCat = _selectedCategory == 'all' || app.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linux Software Catalog'),
        backgroundColor: DroidTheme.background,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: DroidTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // ── Search & Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search Linux packages (VS Code, LibreOffice, GIMP...)',
                  hintStyle: const TextStyle(color: DroidTheme.textDim, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: DroidTheme.textDim),
                  filled: true,
                  fillColor: DroidTheme.cardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: DroidTheme.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: DroidTheme.surfaceBorder),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // ── Categories Pills ──
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _catChip('all', 'All Software (${allList.length})'),
                  const SizedBox(width: 8),
                  _catChip('dev', 'Development'),
                  const SizedBox(width: 8),
                  _catChip('productivity', 'Productivity & Office'),
                  const SizedBox(width: 8),
                  _catChip('graphics', 'Graphics & 3D'),
                  const SizedBox(width: 8),
                  _catChip('media', 'Media & Web'),
                  const SizedBox(width: 8),
                  _catChip('utilities', 'Diagnostics & Tools'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Software List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  for (final app in filteredApps) ...[
                    _buildAppCard(state, app),
                    const SizedBox(height: 10),
                  ],
                  if (state.installingOptionalApp != null || state.optionalInstallLog.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInstallPanel(state),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catChip(String id, String label) {
    final selected = _selectedCategory == id;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: DroidTheme.secondary.withValues(alpha: 0.25),
      backgroundColor: Colors.white.withValues(alpha: 0.04),
      labelStyle: TextStyle(
        color: selected ? Colors.white : DroidTheme.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? DroidTheme.secondary : DroidTheme.surfaceBorder,
      ),
      onSelected: (_) => setState(() => _selectedCategory = id),
    );
  }

  Widget _buildAppCard(AppState state, _CatalogApp app) {
    final installed = state.optionalApps[app.id] == true;
    final installing = state.installingOptionalApp == app.id;
    final busy = state.installingOptionalApp != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DroidTheme.cardBg,
        borderRadius: BorderRadius.circular(DroidTheme.radiusMd),
        border: Border.all(
          color: installed
              ? DroidTheme.success.withValues(alpha: 0.45)
              : DroidTheme.surfaceBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: app.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(app.icon, color: app.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        app.name,
                        style: DroidTheme.headingSm.copyWith(fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        app.size,
                        style: DroidTheme.monoSm.copyWith(
                          color: DroidTheme.textDim,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(app.description, style: DroidTheme.bodySm.copyWith(fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  'pkg: ${app.package}',
                  style: DroidTheme.monoSm.copyWith(
                    color: DroidTheme.textDim,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (installed)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DroidTheme.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: DroidTheme.success, size: 20),
            )
          else if (installing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            ElevatedButton(
              onPressed: busy ? null : () => _installApp(app),
              style: ElevatedButton.styleFrom(
                backgroundColor: DroidTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Install', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildInstallPanel(AppState state) {
    final cleanLog = state.optionalInstallLog.replaceAll(
      RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'),
      '',
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF080D18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DroidTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.optionalInstallStatus.isEmpty
                      ? 'Package Installation Log'
                      : state.optionalInstallStatus,
                  style: DroidTheme.headingSm,
                ),
              ),
              Text(
                '${(state.optionalInstallProgress * 100).round()}%',
                style: DroidTheme.monoSm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: state.installingOptionalApp == null
                ? null
                : state.optionalInstallProgress,
          ),
          if (cleanLog.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: SingleChildScrollView(
                reverse: true,
                child: SelectableText(
                  cleanLog,
                  style: DroidTheme.monoSm.copyWith(height: 1.35),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogApp {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final String package;
  final String size;

  const _CatalogApp({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.package,
    required this.size,
  });
}
