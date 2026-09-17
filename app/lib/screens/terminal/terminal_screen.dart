import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:droiddesk/theme/droid_theme.dart';
import 'package:droiddesk/state/app_state.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    final state = context.read<AppState>();
    state.removeListener(_onStateChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runCommand([String? directCmd]) async {
    final cmd = (directCmd ?? _controller.text).trim();
    if (cmd.isEmpty) return;

    _history.add(cmd);
    _historyIndex = _history.length;
    _controller.clear();

    final state = context.read<AppState>();

    if (cmd == 'clear') {
      state.clearTerminal();
      return;
    }

    await state.executeCommand(cmd);
  }

  void _copyOutput() {
    final state = context.read<AppState>();
    final text = state.terminalOutput.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terminal output copied to clipboard'),
        backgroundColor: DroidTheme.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final quickCommands = [
      'neofetch',
      'glxinfo -B',
      'vulkaninfo --summary',
      'htop',
      'powervr',
      'apt update',
      'df -h',
      'lscpu',
      'clear',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.terminal_rounded, color: DroidTheme.secondary, size: 20),
            const SizedBox(width: 8),
            const Text('Linux Shell Terminal'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: DroidTheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                state.isProotTerminal
                    ? 'PRoot'
                    : state.hasRoot
                    ? 'Chroot'
                    : 'Native',
                style: DroidTheme.monoSm.copyWith(
                  color: DroidTheme.secondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white70),
            tooltip: 'Copy Output',
            onPressed: _copyOutput,
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.white70),
            tooltip: 'Clear Terminal',
            onPressed: () => state.clearTerminal(),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded, size: 20, color: DroidTheme.error),
            tooltip: 'Interrupt (Ctrl+C)',
            onPressed: () {
              state.interruptCommand();
              state.appendTerminalOutput('\n^C (Command interrupted)\n');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Quick Command Pills ──
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF0B0E14),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickCommands.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cmd = quickCommands[index];
                  return ActionChip(
                    label: Text(
                      cmd,
                      style: DroidTheme.monoSm.copyWith(
                        color: cmd == 'clear' ? Colors.redAccent : DroidTheme.accent,
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    side: BorderSide(
                      color: (cmd == 'clear' ? Colors.redAccent : DroidTheme.accent).withValues(alpha: 0.3),
                    ),
                    onPressed: () => _runCommand(cmd),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: DroidTheme.surfaceBorder),

            // ── Terminal Stdout Output ──
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: state.terminalOutput.isEmpty
                    ? Center(
                        child: Text(
                          'DroidDesk Linux Shell Ready.\nEnter a command or tap a quick action above.',
                          textAlign: TextAlign.center,
                          style: DroidTheme.monoSm.copyWith(
                            color: DroidTheme.textDim,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.terminalOutput.length,
                        itemBuilder: (context, index) {
                          final line = state.terminalOutput[index];
                          Color textColor = const Color(0xFFCBD5E1);

                          if (line.startsWith('\$')) {
                            textColor = DroidTheme.accent;
                          } else if (line.contains('[ERR]') || line.contains('Error') || line.contains('failed')) {
                            textColor = const Color(0xFFF87171);
                          } else if (line.contains('[OK]') || line.contains('success')) {
                            textColor = const Color(0xFF34D399);
                          } else if (line.contains('PowerVR') || line.contains('Zink')) {
                            textColor = const Color(0xFF38BDF8);
                          }

                          return SelectableText(
                            line,
                            style: DroidTheme.mono.copyWith(
                              color: textColor,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ── Command Input Line ──
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F141C),
                border: Border(
                  top: BorderSide(color: DroidTheme.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '\$ ',
                    style: DroidTheme.mono.copyWith(
                      color: DroidTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: DroidTheme.mono.copyWith(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Linux command...',
                        hintStyle: TextStyle(color: DroidTheme.textDim),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _runCommand(),
                      autofocus: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _runCommand(),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    color: DroidTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
