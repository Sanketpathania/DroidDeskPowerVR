import React, { useState, useEffect, useRef } from 'react';
import {
  Monitor,
  Terminal,
  Cpu,
  HardDrive,
  Layers,
  Settings,
  Play,
  Square,
  Sparkles,
  Download,
  ExternalLink,
  RefreshCw,
  Sliders,
  Maximize2,
  CheckCircle2,
  AlertCircle,
  FolderOpen,
  Code,
  Globe,
  Radio,
  Zap,
  Activity,
  Smartphone,
  ChevronRight,
  ShieldCheck,
  RotateCcw,
  Clock,
  BatteryCharging,
  Gauge,
  Box
} from 'lucide-react';
import BenchmarkTab from './components/BenchmarkTab';

interface AppPackage {
  id: string;
  name: string;
  desc: string;
  category: string;
  installed: boolean;
  size: string;
  icon: string;
  version: string;
}

const INITIAL_PACKAGES: AppPackage[] = [
  {
    id: 'firefox',
    name: 'Firefox Browser',
    desc: 'Fast, secure web browser with desktop extension support and hardware WebGL',
    category: 'Internet',
    installed: true,
    size: '142 MB',
    icon: 'globe',
    version: '128.0esr'
  },
  {
    id: 'code-oss',
    name: 'VS Code (code-oss)',
    desc: 'Desktop code editor with extensions, Git integration, and built-in terminal',
    category: 'Development',
    installed: true,
    size: '280 MB',
    icon: 'code',
    version: '1.92.1'
  },
  {
    id: 'gimp',
    name: 'GIMP',
    desc: 'Professional GNU Image Manipulation Program with PowerVR raster acceleration',
    category: 'Graphics',
    installed: false,
    size: '210 MB',
    icon: 'layers',
    version: '2.10.38'
  },
  {
    id: 'libreoffice',
    name: 'LibreOffice Suite',
    desc: 'Complete office suite for documents, spreadsheets, and presentations',
    category: 'Office',
    installed: false,
    size: '520 MB',
    icon: 'file',
    version: '24.2.5'
  },
  {
    id: 'vlc',
    name: 'VLC Media Player',
    desc: 'Universal media player supporting hardware-accelerated video decoding',
    category: 'Multimedia',
    installed: true,
    size: '88 MB',
    icon: 'media',
    version: '3.0.21'
  },
  {
    id: 'nodejs',
    name: 'Node.js 22 LTS',
    desc: 'Asynchronous event-driven JavaScript runtime and npm environment',
    category: 'Development',
    installed: true,
    size: '95 MB',
    icon: 'terminal',
    version: '22.13.0'
  },
  {
    id: 'htop',
    name: 'htop & Neofetch',
    desc: 'Interactive process viewer and system hardware diagnostic summary',
    category: 'Utilities',
    installed: true,
    size: '12 MB',
    icon: 'activity',
    version: '3.3.0'
  }
];

export default function App() {
  const [activeTab, setActiveTab] = useState<'overview' | 'display' | 'powervr' | 'benchmarks' | 'packages' | 'terminal' | 'diagnostics' | 'build'>('overview');
  const [isRunning, setIsRunning] = useState(true);
  const [selectedDE, setSelectedDE] = useState<'xfce4' | 'lxqt' | 'mate' | 'plasma'>('xfce4');
  const [resolutionMode, setResolutionMode] = useState<'200%' | '150%' | '100%' | '1080p'>('200%');
  const [touchMode, setTouchMode] = useState<'touchpad' | 'direct'>('touchpad');
  const [fpsLimit, setFpsLimit] = useState<'120' | '60'>('120');
  const [packages, setPackages] = useState<AppPackage[]>(INITIAL_PACKAGES);
  const [installingId, setInstallingId] = useState<string | null>(null);
  
  // PowerVR GPU optimization flags
  const [pvrLazyDescriptors, setPvrLazyDescriptors] = useState(true);
  const [pvrImmediateWsi, setPvrImmediateWsi] = useState(true);
  const [pvrMultiThreads, setPvrMultiThreads] = useState(8);
  const [pvrNoError, setPvrNoError] = useState(true);
  const [pvrDiskShaderCache, setPvrDiskShaderCache] = useState(true);
  const [pvrGlslOverride, setPvrGlslOverride] = useState(true);
  const [pvrDisableCompositorShadows, setPvrDisableCompositorShadows] = useState(true);
  const [pvrNodesBound, setPvrNodesBound] = useState(true);
  const [copiedProfile, setCopiedProfile] = useState(false);

  // Terminal state
  const [terminalHistory, setTerminalHistory] = useState<string[]>([
    '[*] DroidDesk Linux Subsystem v0.1.0 (Pixel 10 Pro XL Edition)',
    '[*] Hardware: Google Tensor G5 ("Laguna") · 8 Cores (1x X925 + 5x A725 + 2x A520)',
    '[*] GPU: Imagination Technologies PowerVR IMG DXT-48-1536 (No Ray Tracing)',
    '[*] Acceleration: Zink Gallium translation layer over Vulkan 1.3 ICD',
    '[*] Display: 1344 x 2992 Super Actua LTPO OLED · 120Hz · Scale: 200%',
    '[*] Profile: ZINK_DESCRIPTORS=lazy MESA_VK_WSI_PRESENT_MODE=immediate LP_NUM_THREADS=8',
    'Type "help", "neofetch", "glxinfo", "vulkaninfo", or "htop" to run commands.',
    ''
  ]);
  const [commandInput, setCommandInput] = useState('');
  const terminalBottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    terminalBottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [terminalHistory]);

  const handleCommand = (e: React.FormEvent) => {
    e.preventDefault();
    if (!commandInput.trim()) return;

    const cmd = commandInput.trim();
    const newHistory = [...terminalHistory, `droiddesk@pixel10-pro-xl:~$ ${cmd}`];

    if (cmd === 'clear') {
      setTerminalHistory([]);
      setCommandInput('');
      return;
    }

    if (cmd === 'help') {
      newHistory.push(
        'Available diagnostic commands:',
        '  neofetch     - Display system info & PowerVR GPU banner',
        '  glxinfo      - Show OpenGL / Zink Gallium renderer info',
        '  vulkaninfo   - Show Imagination IMG DXT Vulkan ICD info',
        '  htop         - View 8-core Tensor G5 CPU usage',
        '  powervr      - Inspect PowerVR device nodes & driver parameters',
        '  apt update   - Simulate repository package catalog update',
        '  uname -a     - Display Linux kernel version (6.1.75-android-tensor)',
        '  clear        - Clear terminal console'
      );
    } else if (cmd === 'neofetch') {
      newHistory.push(
        '        #####          droiddesk@pixel10-pro-xl',
        '       #######         ------------------------',
        '       ##O#O##         OS: Ubuntu 24.04.1 LTS aarch64 (PRoot/Chroot)',
        '       #VVVVV#         Host: Google Pixel 10 Pro XL (Tensor G5 "Laguna")',
        '     ##  VVV  ##       Kernel: 6.1.75-android15-tensor-g5',
        '    #          ##      Uptime: 2 hours, 14 mins',
        '   #            ##     Packages: 1482 (dpkg), 7 (flatpak)',
        '   #            ##     Shell: bash 5.2.21',
        '   ###        ###      Resolution: 1344x2992 @ 120Hz (Scaled 200%)',
        '     ###########       DE: XFCE 4.18 (X11 via LorieView)',
        '                       WM: Xfwm4',
        '                       Theme: Adwaita-dark [GTK2/3]',
        '                       Icons: Papirus-Dark [GTK2/3]',
        '                       Terminal: xfce4-terminal',
        '                       CPU: Google Tensor G5 (8 cores: 1x 3.4GHz, 5x 2.8GHz, 2x 2.1GHz)',
        '                       GPU: Imagination PowerVR IMG DXT-48-1536 (Zink HW Accel, No RT)',
        '                       Memory: 3840MiB / 16384MiB'
      );
    } else if (cmd === 'glxinfo' || cmd === 'glxinfo | grep -i opengl') {
      newHistory.push(
        'OpenGL vendor string: Mesa/Zink',
        'OpenGL renderer string: zink (PowerVR IMG DXT-48-1536)',
        'OpenGL core profile version string: 4.6 (Core Profile) Mesa 24.2.8',
        'OpenGL core profile shading language version string: 4.60',
        'OpenGL ES profile version string: OpenGL ES 3.2 Mesa 24.2.8',
        'Zink descriptors mode: lazy (Optimized for PowerVR TBDR architecture)',
        'WSI present mode: immediate (Vulkan swapchain latency: 2.1ms)'
      );
    } else if (cmd === 'vulkaninfo') {
      newHistory.push(
        'Vulkan Instance Version: 1.3.280',
        'Active ICD: /vendor/etc/vulkan/icd.d/powervr_icd.json',
        'GPU id : 0 (PowerVR IMG DXT-48-1536)',
        '  Device Type     : PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU',
        '  Driver Version  : 24.1.0-img-dxt48',
        '  API Version     : 1.3.280',
        '  Subgroup Size   : 32',
        '  ALU Pipelines   : 48 (1536 FP32 FLOPs/clock)',
        '  Ray Tracing HW  : Not Included (DXT-48 Raster & Compute Focus)',
        '  TBDR Tile Size  : 32x32 pixels'
      );
    } else if (cmd === 'htop') {
      newHistory.push(
        ' 1  [||||||||||||                34.2%]   Tasks: 74, 218 thr; 1 running',
        ' 2  [|||||||                     18.0%]   Load average: 1.12 0.85 0.64',
        ' 3  [||||||||                    21.4%]   Uptime: 02:14:38',
        ' 4  [||||||                      15.1%]',
        ' 5  [|||||||||                   23.5%]   PID USER      PRI  NI  VIRT   RES   SHR S CPU% MEM%   TIME+  Command',
        ' 6  [||||||                      14.8%]  1204 droiddesk  20   0 1480M  412M  128M S 24.0  2.5  1:12.4 xfce4-session',
        ' 7  [||||||||||||||||||          45.1%]  1258 droiddesk  20   0 2100M  680M  210M S 18.2  4.1  0:58.2 firefox-bin',
        ' 8  [||||||||||||                31.0%]  1312 droiddesk  20   0  890M  195M   84M S  6.4  1.2  0:22.5 Xwayland :0',
        'Mem [|||||||||||||||     3.8G/16.0G]    Swp [|                    0.1G/8.0G]'
      );
    } else if (cmd === 'powervr') {
      newHistory.push(
        '=== PowerVR IMG DXT Configuration Matrix ===',
        `Device Nodes: /dev/pvrsrvkm (${pvrNodesBound ? 'BOUND' : 'UNBOUND'}), /dev/pvr_sync (${pvrNodesBound ? 'BOUND' : 'UNBOUND'})`,
        `ZINK_DESCRIPTORS=${pvrLazyDescriptors ? 'lazy' : 'standard'}`,
        `MESA_VK_WSI_PRESENT_MODE=${pvrImmediateWsi ? 'immediate' : 'fifo'}`,
        `LP_NUM_THREADS=${pvrMultiThreads}`,
        `MESA_NO_ERROR=${pvrNoError ? '1' : '0'}`,
        `GALLIUM_DRIVER=zink`,
        `MESA_LOADER_DRIVER_OVERRIDE=zink`,
        'Display Target: Google Pixel 10 Pro XL (1344 x 2992 @ 120Hz)'
      );
    } else if (cmd === 'apt update') {
      newHistory.push(
        'Hit:1 http://ports.ubuntu.com/ubuntu-ports noble InRelease',
        'Hit:2 http://ports.ubuntu.com/ubuntu-ports noble-updates InRelease',
        'Hit:3 http://ports.ubuntu.com/ubuntu-ports noble-security InRelease',
        'Hit:4 https://dl.cloudsmith.io/public/termux/tur/deb/ubuntu noble InRelease',
        'Reading package lists... Done',
        'Building dependency tree... Done',
        'All 1482 packages are up to date.'
      );
    } else if (cmd === 'uname -a') {
      newHistory.push('Linux pixel10-pro-xl 6.1.75-android15-tensor-g5 #1 SMP PREEMPT aarch64 GNU/Linux');
    } else {
      newHistory.push(`bash: ${cmd}: command not found. Type "help" for diagnostic commands.`);
    }

    setTerminalHistory(newHistory);
    setCommandInput('');
  };

  const togglePackage = (id: string) => {
    setInstallingId(id);
    setTimeout(() => {
      setPackages(prev =>
        prev.map(p => {
          if (p.id === id) {
            const nextState = !p.installed;
            setTerminalHistory(h => [
              ...h,
              nextState
                ? `[apt] Successfully installed ${p.name} (${p.version})`
                : `[apt] Removed package ${p.name}`
            ]);
            return { ...p, installed: nextState };
          }
          return p;
        })
      );
      setInstallingId(null);
    }, 1200);
  };

  return (
    <div id="droiddesk-app" className="min-h-screen bg-[#0d0e15] text-[#e3e2ea] flex flex-col">
      {/* Top Navigation Bar */}
      <header id="main-header" className="border-b border-white/10 bg-[#12131c]/90 backdrop-blur sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-purple-600 via-indigo-600 to-cyan-500 p-0.5 flex items-center justify-center shadow-lg shadow-purple-900/30">
              <div className="w-full h-full bg-[#12131c] rounded-[10px] flex items-center justify-center">
                <Monitor className="w-5 h-5 text-cyan-400" />
              </div>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="font-bold text-lg text-white tracking-tight">DroidDesk</h1>
                <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-gradient-to-r from-purple-500/20 to-cyan-500/20 text-cyan-300 border border-cyan-500/30">
                  PowerVR DXT Edition
                </span>
              </div>
              <p className="text-xs text-neutral-400">Google Pixel 10 Pro XL · Tensor G5</p>
            </div>
          </div>

          {/* Desktop Status & Quick Action */}
          <div className="flex items-center gap-3">
            <div className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-lg bg-white/5 border border-white/10 text-xs">
              <div className={`w-2.5 h-2.5 rounded-full ${isRunning ? 'bg-emerald-400 animate-pulse' : 'bg-neutral-500'}`} />
              <span className="text-neutral-300">
                {isRunning ? `Desktop Running (${selectedDE.toUpperCase()})` : 'Desktop Idle'}
              </span>
            </div>

            <button
              id="toggle-desktop-btn"
              onClick={() => {
                setIsRunning(!isRunning);
                setTerminalHistory(prev => [
                  ...prev,
                  !isRunning
                    ? `[*] Starting ${selectedDE.toUpperCase()} on display :0 (PowerVR Zink Hardware Mode)`
                    : '[*] Stopping X11 desktop session'
                ]);
              }}
              className={`px-4 py-2 rounded-lg font-medium text-xs sm:text-sm flex items-center gap-2 transition-all cursor-pointer ${
                isRunning
                  ? 'bg-rose-500/20 text-rose-300 border border-rose-500/30 hover:bg-rose-500/30'
                  : 'bg-gradient-to-r from-purple-600 to-cyan-600 text-white shadow-lg shadow-purple-900/40 hover:opacity-90'
              }`}
            >
              {isRunning ? (
                <>
                  <Square className="w-4 h-4" /> Stop Desktop
                </>
              ) : (
                <>
                  <Play className="w-4 h-4 fill-current" /> Launch Desktop
                </>
              )}
            </button>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex overflow-x-auto no-scrollbar gap-1 border-t border-white/5">
          {[
            { id: 'overview', label: 'Overview', icon: Monitor },
            { id: 'display', label: 'Display & Session', icon: Maximize2 },
            { id: 'powervr', label: 'PowerVR GPU Tuning', icon: Zap },
            { id: 'benchmarks', label: '3D Benchmarks', icon: Gauge },
            { id: 'packages', label: 'App Catalog', icon: FolderOpen },
            { id: 'terminal', label: 'Terminal Console', icon: Terminal },
            { id: 'diagnostics', label: 'Diagnostics & CPU', icon: Activity },
            { id: 'build', label: 'APK Build & Export', icon: Download },
          ].map(tab => {
            const IconComponent = tab.icon;
            const active = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                id={`tab-${tab.id}`}
                onClick={() => setActiveTab(tab.id as any)}
                className={`py-3 px-3 sm:px-4 text-xs sm:text-sm font-medium border-b-2 flex items-center gap-2 whitespace-nowrap transition-colors cursor-pointer ${
                  active
                    ? 'border-cyan-400 text-cyan-400 bg-white/[0.03]'
                    : 'border-transparent text-neutral-400 hover:text-neutral-200 hover:bg-white/[0.01]'
                }`}
              >
                <IconComponent className={`w-4 h-4 ${active ? 'text-cyan-400' : 'text-neutral-400'}`} />
                {tab.label}
              </button>
            );
          })}
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* OVERVIEW TAB */}
        {activeTab === 'overview' && (
          <div className="space-y-6">
            {/* Pixel 10 Pro XL & PowerVR Hardware Acceleration Highlight Banner */}
            <div id="pvr-hardware-card" className="relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-[#1b152d] via-[#141426] to-[#0e1626] border border-purple-500/30 shadow-xl">
              <div className="absolute -right-8 -bottom-8 w-64 h-64 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none" />
              <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div>
                  <div className="flex items-center gap-2 text-cyan-400 text-xs font-semibold uppercase tracking-wider mb-2">
                    <Sparkles className="w-4 h-4" /> Pixel 10 Pro XL · Dedicated PowerVR Acceleration
                  </div>
                  <h2 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
                    Imagination PowerVR IMG DXT-48-1536
                  </h2>
                  <p className="text-neutral-300 text-sm mt-1 max-w-2xl leading-relaxed">
                    Configured for Pixel 10 Pro XL (Tensor G5 Laguna) featuring 48 ALU pipelines (1536 FP32 FLOPs/clock) without ray tracing overhead. Optimized for low-power sustained TBDR rasterization via Zink (OpenGL 4.6 over Vulkan 1.3).
                  </p>
                  <div className="flex flex-wrap gap-2 mt-4">
                    <span className="px-3 py-1 rounded-md text-xs font-medium bg-cyan-950/60 text-cyan-300 border border-cyan-800/60">
                      Zink + Vulkan 1.3
                    </span>
                    <span className="px-3 py-1 rounded-md text-xs font-medium bg-purple-950/60 text-purple-300 border border-purple-800/60">
                      DXT-48 (No Ray Tracing)
                    </span>
                    <span className="px-3 py-1 rounded-md text-xs font-medium bg-emerald-950/60 text-emerald-300 border border-emerald-800/60">
                      TBDR Lazy Descriptors
                    </span>
                    <span className="px-3 py-1 rounded-md text-xs font-medium bg-amber-950/60 text-amber-300 border border-amber-800/60">
                      120Hz Super Actua (200% Scale)
                    </span>
                  </div>
                </div>

                <div className="flex flex-col gap-2 min-w-[200px]">
                  <button
                    onClick={() => setActiveTab('benchmarks')}
                    className="w-full py-2 px-4 rounded-xl bg-gradient-to-r from-cyan-600 to-purple-600 hover:opacity-90 text-white text-sm font-semibold flex items-center justify-center gap-2 transition cursor-pointer shadow-lg shadow-cyan-900/30"
                  >
                    <Gauge className="w-4 h-4 text-amber-300" /> Run 3D Benchmark
                  </button>
                  <button
                    onClick={() => setActiveTab('powervr')}
                    className="w-full py-2 px-4 rounded-xl bg-cyan-500/15 hover:bg-cyan-500/25 text-cyan-300 border border-cyan-500/30 text-sm font-semibold flex items-center justify-center gap-2 transition cursor-pointer"
                  >
                    <Zap className="w-4 h-4" /> PowerVR Tuning Hub
                  </button>
                  <button
                    onClick={() => setActiveTab('display')}
                    className="w-full py-2 px-4 rounded-xl bg-white/5 hover:bg-white/10 text-neutral-300 border border-white/10 text-sm font-semibold flex items-center justify-center gap-2 transition cursor-pointer"
                  >
                    <Monitor className="w-4 h-4" /> Live Session View
                  </button>
                </div>
              </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="p-4 rounded-xl bg-[#141520] border border-white/5">
                <div className="flex items-center justify-between text-neutral-400 text-xs mb-1">
                  <span>Renderer Mode</span>
                  <Zap className="w-4 h-4 text-cyan-400" />
                </div>
                <div className="font-bold text-white text-base">Zink Gallium (HW)</div>
                <div className="text-xs text-emerald-400 mt-1 flex items-center gap-1">
                  <CheckCircle2 className="w-3 h-3" /> PowerVR IMG DXT Active
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#141520] border border-white/5">
                <div className="flex items-center justify-between text-neutral-400 text-xs mb-1">
                  <span>Tensor G5 CPU Cores</span>
                  <Cpu className="w-4 h-4 text-purple-400" />
                </div>
                <div className="font-bold text-white text-base">8 Cores Active</div>
                <div className="text-xs text-purple-300 mt-1">
                  1x X925 · 5x A725 · 2x A520
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#141520] border border-white/5">
                <div className="flex items-center justify-between text-neutral-400 text-xs mb-1">
                  <span>Super Actua Display</span>
                  <Smartphone className="w-4 h-4 text-amber-400" />
                </div>
                <div className="font-bold text-white text-base">1344 x 2992 · 120Hz</div>
                <div className="text-xs text-neutral-400 mt-1">
                  Scaled 200% (672 x 1496 dp)
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#141520] border border-white/5">
                <div className="flex items-center justify-between text-neutral-400 text-xs mb-1">
                  <span>Installed Apps</span>
                  <FolderOpen className="w-4 h-4 text-emerald-400" />
                </div>
                <div className="font-bold text-white text-base">{packages.filter(p => p.installed).length} Packages</div>
                <div className="text-xs text-neutral-400 mt-1">
                  VS Code, Firefox, VLC ready
                </div>
              </div>
            </div>

            {/* Desktop Environment Selector & Quick Actions */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Desktop Environment Picker */}
              <div className="lg:col-span-2 rounded-xl bg-[#141520] border border-white/5 p-5 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-white text-base">Desktop Environment</h3>
                    <p className="text-xs text-neutral-400">Select which X11 environment to run in the Linux rootfs</p>
                  </div>
                  <span className="text-xs px-2.5 py-1 rounded bg-purple-500/20 text-purple-300 font-mono">
                    Current: {selectedDE.toUpperCase()}
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {[
                    {
                      id: 'xfce4',
                      name: 'XFCE 4.18',
                      desc: 'Default lightweight, highly responsive, full hardware acceleration support',
                      rec: 'Recommended'
                    },
                    {
                      id: 'lxqt',
                      name: 'LXQt 1.4',
                      desc: 'Ultra-lightweight Qt-based desktop with minimum RAM footprint',
                      rec: 'Fastest'
                    },
                    {
                      id: 'mate',
                      name: 'MATE Desktop',
                      desc: 'Traditional GNOME 2 layout with modern GTK3 themes',
                      rec: 'Classic'
                    },
                    {
                      id: 'plasma',
                      name: 'KDE Plasma',
                      desc: 'Rich modern desktop experience with KWin OpenGL compositor',
                      rec: 'Power Users'
                    }
                  ].map(de => (
                    <button
                      key={de.id}
                      onClick={() => setSelectedDE(de.id as any)}
                      className={`p-3.5 rounded-xl border text-left transition cursor-pointer flex flex-col justify-between ${
                        selectedDE === de.id
                          ? 'bg-purple-900/20 border-purple-500 text-white'
                          : 'bg-white/[0.02] border-white/5 text-neutral-300 hover:bg-white/[0.04]'
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-semibold text-sm">{de.name}</span>
                        <span className="text-[10px] px-2 py-0.5 rounded bg-white/10 text-neutral-300">
                          {de.rec}
                        </span>
                      </div>
                      <p className="text-xs text-neutral-400 mt-2">{de.desc}</p>
                    </button>
                  ))}
                </div>
              </div>

              {/* Hardware Device Node Diagnostics */}
              <div className="rounded-xl bg-[#141520] border border-white/5 p-5 space-y-4 flex flex-col justify-between">
                <div>
                  <h3 className="font-bold text-white text-base">Kernel Node Passthrough</h3>
                  <p className="text-xs text-neutral-400">PowerVR kernel synchronization and Vulkan device bindings</p>
                  
                  <div className="mt-4 space-y-2.5 font-mono text-xs">
                    <div className="flex items-center justify-between p-2 rounded bg-black/40 border border-white/5">
                      <span className="text-neutral-300">/dev/pvrsrvkm</span>
                      <span className="text-emerald-400 font-semibold">Mounted [rw]</span>
                    </div>
                    <div className="flex items-center justify-between p-2 rounded bg-black/40 border border-white/5">
                      <span className="text-neutral-300">/dev/pvr_sync</span>
                      <span className="text-emerald-400 font-semibold">Mounted [rw]</span>
                    </div>
                    <div className="flex items-center justify-between p-2 rounded bg-black/40 border border-white/5">
                      <span className="text-neutral-300">/dev/dri/renderD128</span>
                      <span className="text-emerald-400 font-semibold">Active</span>
                    </div>
                    <div className="flex items-center justify-between p-2 rounded bg-black/40 border border-white/5">
                      <span className="text-neutral-300">powervr_icd.json</span>
                      <span className="text-cyan-400 font-semibold">Bound</span>
                    </div>
                  </div>
                </div>

                <div className="pt-3 border-t border-white/5 flex items-center justify-between text-xs text-neutral-400">
                  <span>Subsystem status</span>
                  <span className="text-emerald-400 flex items-center gap-1">
                    <CheckCircle2 className="w-3.5 h-3.5" /> All Nodes Connected
                  </span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* DISPLAY & SESSION TAB */}
        {activeTab === 'display' && (
          <div className="space-y-6">
            {/* Display Simulator Window */}
            <div className="rounded-2xl bg-[#141520] border border-white/10 overflow-hidden shadow-2xl">
              {/* Virtual Monitor Titlebar */}
              <div className="bg-[#1a1b2a] px-4 py-3 border-b border-white/10 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-rose-500/80" />
                  <div className="w-3 h-3 rounded-full bg-amber-500/80" />
                  <div className="w-3 h-3 rounded-full bg-emerald-500/80" />
                  <span className="text-xs text-neutral-400 font-mono ml-2">
                    LorieView Xwayland (:0) — {selectedDE.toUpperCase()} · Pixel 10 Pro XL (1344 x 2992 @ {fpsLimit}Hz)
                  </span>
                </div>
                <div className="flex items-center gap-3 text-xs">
                  <span className="px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 font-mono">
                    {fpsLimit} FPS
                  </span>
                  <span className="text-neutral-400">Scale: {resolutionMode}</span>
                </div>
              </div>

              {/* Desktop Workspace Canvas */}
              <div className="relative aspect-[16/9] sm:aspect-[21/9] bg-gradient-to-br from-[#1a1c36] via-[#101124] to-[#0c0d18] p-4 sm:p-8 flex flex-col justify-between overflow-hidden">
                {/* Simulated Desktop Wallpaper Background Grid */}
                <div className="absolute inset-0 bg-[linear-gradient(to_right,#ffffff05_1px,transparent_1px),linear-gradient(to_bottom,#ffffff05_1px,transparent_1px)] bg-[size:4rem_4rem] pointer-events-none" />

                {/* Simulated Floating Windows */}
                <div className="relative z-10 grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Floating Terminal Window */}
                  <div className="rounded-lg bg-[#0b0c14]/90 border border-cyan-500/30 shadow-2xl p-3 font-mono text-xs text-neutral-300">
                    <div className="flex items-center justify-between pb-2 mb-2 border-b border-white/10 text-neutral-400">
                      <span className="text-[11px] flex items-center gap-1.5 text-cyan-400">
                        <Terminal className="w-3 h-3" /> Terminal — xfce4-terminal
                      </span>
                      <span className="text-[10px]">bash</span>
                    </div>
                    <div className="space-y-1">
                      <p className="text-emerald-400">$ glxinfo -B | grep "OpenGL renderer"</p>
                      <p className="text-white">OpenGL renderer string: zink (PowerVR IMG DXT-48-1536)</p>
                      <p className="text-emerald-400">$ echo $ZINK_DESCRIPTORS</p>
                      <p className="text-cyan-300">lazy</p>
                      <p className="text-neutral-500 animate-pulse">droiddesk@pixel10-pro-xl:~$ _</p>
                    </div>
                  </div>

                  {/* Floating VS Code / Editor Preview */}
                  <div className="hidden md:block rounded-lg bg-[#0d1117]/90 border border-purple-500/30 shadow-2xl p-3 font-mono text-xs">
                    <div className="flex items-center justify-between pb-2 mb-2 border-b border-white/10 text-neutral-400">
                      <span className="text-[11px] flex items-center gap-1.5 text-purple-400">
                        <Code className="w-3 h-3" /> main.rs — Code - OSS
                      </span>
                      <span className="text-[10px] text-emerald-400">Rust 1.80</span>
                    </div>
                    <div className="text-neutral-400 space-y-1">
                      <p><span className="text-purple-400">fn</span> <span className="text-cyan-400">main</span>() &#123;</p>
                      <p className="pl-4">println!(<span className="text-amber-300">"PowerVR DXT HW Acceleration active!"</span>);</p>
                      <p>&#125;</p>
                    </div>
                  </div>
                </div>

                {/* Simulated Desktop Bottom Panel / Taskbar */}
                <div className="relative z-10 w-full h-10 rounded-lg bg-[#141624]/95 border border-white/10 px-3 flex items-center justify-between shadow-xl">
                  <div className="flex items-center gap-2">
                    <button className="px-2.5 py-1 rounded bg-purple-600 text-white font-bold text-xs flex items-center gap-1.5">
                      <Monitor className="w-3.5 h-3.5" /> Applications
                    </button>
                    <div className="h-4 w-px bg-white/10 mx-1" />
                    <button className="px-2 py-1 rounded bg-white/5 text-neutral-300 text-xs flex items-center gap-1">
                      <Terminal className="w-3 h-3 text-cyan-400" /> Terminal
                    </button>
                    <button className="px-2 py-1 rounded bg-white/5 text-neutral-300 text-xs flex items-center gap-1">
                      <Globe className="w-3 h-3 text-amber-400" /> Firefox
                    </button>
                  </div>

                  <div className="flex items-center gap-3 text-xs text-neutral-300 font-mono">
                    <span className="text-cyan-400">Zink 4.6</span>
                    <span className="text-neutral-500">|</span>
                    <span>12:00 PM</span>
                  </div>
                </div>
              </div>

              {/* Display Controls Bar */}
              <div className="bg-[#12131e] p-4 border-t border-white/5 grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="text-xs text-neutral-400 block mb-1">Display Scaling</label>
                  <div className="grid grid-cols-4 gap-1.5">
                    {(['200%', '150%', '100%', '1080p'] as const).map(mode => (
                      <button
                        key={mode}
                        onClick={() => setResolutionMode(mode)}
                        className={`py-1.5 text-xs rounded font-medium transition cursor-pointer ${
                          resolutionMode === mode
                            ? 'bg-cyan-500 text-black font-semibold'
                            : 'bg-white/5 text-neutral-300 hover:bg-white/10'
                        }`}
                      >
                        {mode}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="text-xs text-neutral-400 block mb-1">Input Emulation</label>
                  <div className="grid grid-cols-2 gap-1.5">
                    {[
                      { id: 'touchpad', label: 'Virtual Trackpad' },
                      { id: 'direct', label: 'Direct Touch' },
                    ].map(input => (
                      <button
                        key={input.id}
                        onClick={() => setTouchMode(input.id as any)}
                        className={`py-1.5 text-xs rounded font-medium transition cursor-pointer ${
                          touchMode === input.id
                            ? 'bg-purple-600 text-white font-semibold'
                            : 'bg-white/5 text-neutral-300 hover:bg-white/10'
                        }`}
                      >
                        {input.label}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="text-xs text-neutral-400 block mb-1">Super Actua Refresh Rate</label>
                  <div className="grid grid-cols-2 gap-1.5">
                    {[
                      { id: '120', label: '120Hz (LTPO)' },
                      { id: '60', label: '60Hz (Battery)' },
                    ].map(fps => (
                      <button
                        key={fps.id}
                        onClick={() => setFpsLimit(fps.id as any)}
                        className={`py-1.5 text-xs rounded font-medium transition cursor-pointer ${
                          fpsLimit === fps.id
                            ? 'bg-emerald-600 text-white font-semibold'
                            : 'bg-white/5 text-neutral-300 hover:bg-white/10'
                        }`}
                      >
                        {fps.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* POWERVR GPU TUNING TAB */}
        {activeTab === 'powervr' && (
          <div className="space-y-6">
            <div className="rounded-xl bg-[#141520] border border-white/5 p-6 space-y-6">
              <div>
                <h2 className="text-xl font-bold text-white flex items-center gap-2">
                  <Zap className="w-5 h-5 text-cyan-400" /> PowerVR & Tensor G5 Hardware Acceleration Tuning
                </h2>
                <p className="text-sm text-neutral-400 mt-1">
                  Fine-tune environmental variables, Vulkan translation parameters, and CPU fallback rasterization threads.
                </p>
              </div>

              {/* Pixel 10 DXT-48 Silicon Architecture Callout */}
              <div className="p-4 rounded-xl bg-purple-950/20 border border-purple-500/30 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-white text-sm">Pixel 10 / Tensor G5 ("Laguna") GPU Architecture</span>
                    <span className="text-[10px] px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 font-mono font-semibold">
                      PowerVR IMG DXT-48-1536
                    </span>
                  </div>
                  <p className="text-xs text-neutral-300 leading-relaxed">
                    Tensor G5 incorporates the <strong>PowerVR DXT-48</strong> core configuration without hardware ray tracing. Silicon is prioritized for peak rasterization power-efficiency and sustained desktop rendering across 48 ALU pipelines (1,536 FP32 FLOPs/clock).
                  </p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <span className="text-xs px-3 py-1.5 rounded-lg bg-white/5 border border-white/10 text-neutral-300 font-mono">
                    RT: Not Included
                  </span>
                  <span className="text-xs px-3 py-1.5 rounded-lg bg-emerald-500/20 border border-emerald-500/30 text-emerald-300 font-mono">
                    48 ALUs / 1536 FLOPs
                  </span>
                </div>
              </div>

              {/* Tuning Options List */}
              <div className="space-y-4">
                {/* Lazy Descriptors */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">Zink TBDR Lazy Descriptors</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-300 font-mono">
                        ZINK_DESCRIPTORS=lazy
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Eliminates frequent descriptor pool allocations on Imagination Technologies Tile-Based Deferred Rendering architecture, boosting draw-call throughput.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrLazyDescriptors(!pvrLazyDescriptors)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrLazyDescriptors ? 'bg-cyan-500' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrLazyDescriptors ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>

                {/* Immediate WSI Present */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">Immediate Vulkan WSI Presentation</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 font-mono">
                        MESA_VK_WSI_PRESENT_MODE=immediate
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Bypasses FIFO swapchain buffer queuing to deliver low-latency responsiveness to the Pixel 10 Pro XL 120Hz LTPO display.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrImmediateWsi(!pvrImmediateWsi)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrImmediateWsi ? 'bg-purple-600' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrImmediateWsi ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>

                {/* Multi-thread Fallback allocation */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-semibold text-white text-sm">CPU Rasterizer Worker Threads</span>
                        <span className="text-[11px] px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 font-mono">
                          LP_NUM_THREADS={pvrMultiThreads}
                        </span>
                      </div>
                      <p className="text-xs text-neutral-400 mt-1">
                        Allocates parallel worker threads across all 8 Google Tensor G5 CPU cores for any software rasterizer fallback paths.
                      </p>
                    </div>
                    <span className="text-sm font-mono font-bold text-emerald-400 px-3 py-1 bg-emerald-950/40 rounded border border-emerald-800/40">
                      {pvrMultiThreads} Threads
                    </span>
                  </div>
                  <input
                    type="range"
                    min="1"
                    max="8"
                    value={pvrMultiThreads}
                    onChange={e => setPvrMultiThreads(Number(e.target.value))}
                    className="w-full accent-emerald-500 cursor-pointer"
                  />
                  <div className="flex justify-between text-[10px] text-neutral-400 font-mono">
                    <span>1 Thread (Minimal)</span>
                    <span>4 Threads (Default)</span>
                    <span>8 Threads (Full Tensor G5 Allocation)</span>
                  </div>
                </div>

                {/* Mesa No Error Fast Path */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">OpenGL No-Error Fast Execution</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 font-mono">
                        MESA_NO_ERROR=1
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Disables redundant API error checking in production Mesa libraries to reduce CPU driver overhead.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrNoError(!pvrNoError)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrNoError ? 'bg-amber-500' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrNoError ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>

                {/* Disk Shader Cache */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">Persistent Disk Shader Cache</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-blue-500/20 text-blue-300 font-mono">
                        MESA_DISK_CACHE_DIR=~/.cache
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Caches compiled SPIR-V & GLSL pipelines to flash storage, eliminating micro-stutters during 3D scene transitions and application launches.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrDiskShaderCache(!pvrDiskShaderCache)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrDiskShaderCache ? 'bg-blue-500' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrDiskShaderCache ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>

                {/* GLSL 4.60 Core Profile Override */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">GLSL 4.60 Core Profile Override</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 font-mono">
                        MESA_GLSL_VERSION_OVERRIDE=460
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Forces reporting of OpenGL 4.6 / GLSL 460 support to prevent modern Linux desktop apps (Blender, Godot, Krita) from rejecting hardware acceleration.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrGlslOverride(!pvrGlslOverride)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrGlslOverride ? 'bg-emerald-500' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrGlslOverride ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>

                {/* XFWM4 Compositor Shadow Bypass */}
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 flex items-center justify-between gap-4">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-white text-sm">Bypass Window Shadows & Blending</span>
                      <span className="text-[11px] px-2 py-0.5 rounded bg-rose-500/20 text-rose-300 font-mono">
                        xfconf-query /use_compositing
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1">
                      Disables software alpha window shadows in XFCE, preventing excessive tile redraws across the PowerVR 32x32 TBDR tile buffer.
                    </p>
                  </div>
                  <button
                    onClick={() => setPvrDisableCompositorShadows(!pvrDisableCompositorShadows)}
                    className={`w-12 h-6 rounded-full transition-colors relative cursor-pointer ${
                      pvrDisableCompositorShadows ? 'bg-rose-500' : 'bg-neutral-700'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full bg-white absolute top-1 transition-transform ${
                        pvrDisableCompositorShadows ? 'left-7' : 'left-1'
                      }`}
                    />
                  </button>
                </div>
              </div>

              {/* Active Profile Summary */}
              <div className="p-4 rounded-xl bg-[#0e101a] border border-white/10 font-mono text-xs text-neutral-300 space-y-2">
                <div className="flex items-center justify-between">
                  <div className="text-cyan-400 font-semibold"># Active Environment Profile (/etc/profile.d/droiddesk.sh)</div>
                  <button
                    onClick={() => {
                      const snippet = [
                        'export DISPLAY=:0',
                        'export GALLIUM_DRIVER=zink',
                        'export MESA_LOADER_DRIVER_OVERRIDE=zink',
                        `export ZINK_DESCRIPTORS=${pvrLazyDescriptors ? 'lazy' : 'standard'}`,
                        `export MESA_VK_WSI_PRESENT_MODE=${pvrImmediateWsi ? 'immediate' : 'fifo'}`,
                        `export LP_NUM_THREADS=${pvrMultiThreads}`,
                        `export MESA_NO_ERROR=${pvrNoError ? '1' : '0'}`,
                        `export MESA_GL_VERSION_OVERRIDE=4.6`,
                        `export MESA_GLSL_VERSION_OVERRIDE=${pvrGlslOverride ? '460' : '330'}`,
                        `export MESA_GLES_VERSION_OVERRIDE=3.2`,
                        `export MESA_DISK_CACHE_DIR=${pvrDiskShaderCache ? '$HOME/.cache/mesa_shader_cache' : ''}`,
                        'export PVR_MESA=1',
                        'export PVR_DISABLE_SURFACE_CACHE=0'
                      ].filter(Boolean).join('\n');
                      navigator.clipboard.writeText(snippet);
                      setCopiedProfile(true);
                      setTimeout(() => setCopiedProfile(false), 2000);
                    }}
                    className="px-2.5 py-1 rounded bg-white/10 hover:bg-white/20 text-[11px] text-white flex items-center gap-1.5 transition cursor-pointer"
                  >
                    {copiedProfile ? '✓ Copied!' : 'Copy Script'}
                  </button>
                </div>
                <p>export DISPLAY=:0</p>
                <p>export GALLIUM_DRIVER=zink</p>
                <p>export MESA_LOADER_DRIVER_OVERRIDE=zink</p>
                <p>export ZINK_DESCRIPTORS={pvrLazyDescriptors ? 'lazy' : 'standard'}</p>
                <p>export MESA_VK_WSI_PRESENT_MODE={pvrImmediateWsi ? 'immediate' : 'fifo'}</p>
                <p>export LP_NUM_THREADS={pvrMultiThreads}</p>
                <p>export MESA_NO_ERROR={pvrNoError ? '1' : '0'}</p>
                <p>export MESA_GL_VERSION_OVERRIDE=4.6</p>
                <p>export MESA_GLSL_VERSION_OVERRIDE={pvrGlslOverride ? '460' : '330'}</p>
                <p>export MESA_GLES_VERSION_OVERRIDE=3.2</p>
                {pvrDiskShaderCache && <p>export MESA_DISK_CACHE_DIR=$HOME/.cache/mesa_shader_cache</p>}
                <p>export PVR_MESA=1</p>
                <p>export PVR_DISABLE_SURFACE_CACHE=0</p>
              </div>

              {/* Comprehensive PowerVR Optimization & Best Practices Guide */}
              <div className="space-y-4 pt-4 border-t border-white/10">
                <h3 className="text-base font-bold text-white flex items-center gap-2">
                  <ShieldCheck className="w-5 h-5 text-emerald-400" /> Pixel 10 PowerVR Compatibility & Best Practices
                </h3>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                  {/* Suggestion 1 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-cyan-300 flex items-center gap-2">
                      <span>1. TBDR Tile Buffer & Overdraw Elimination</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      PowerVR renders in discrete <strong>32x32 pixel tiles</strong> using Hidden Surface Removal (HSR). Avoid full-screen transparent overlays or active software compositing shadows that dirty the tile cache. Disabling XFWM4 shadows can reduce GPU memory traffic by over 40%.
                    </p>
                  </div>

                  {/* Suggestion 2 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-purple-300 flex items-center gap-2">
                      <span>2. Android Phantom Process Killer Bypass</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      Android 15/16 terminates background child processes exceeding 32 instances. If compiling large C++/Rust packages or running background servers, disable this restriction via ADB:
                    </p>
                    <code className="block p-2 rounded bg-black/40 text-[11px] font-mono text-neutral-300 select-all">
                      adb shell device_config put activity_manager max_phantom_processes 2147483647
                    </code>
                  </div>

                  {/* Suggestion 3 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-amber-300 flex items-center gap-2">
                      <span>3. Chromium / Web Browser GPU Flags</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      Launch Chromium or Firefox with hardware rasterization enabled and GPU blocklist ignored to route web rendering through Zink/PowerVR:
                    </p>
                    <code className="block p-2 rounded bg-black/40 text-[11px] font-mono text-neutral-300 select-all">
                      chromium --enable-features=CanvasOopRasterization --enable-gpu-rasterization --ignore-gpu-blocklist
                    </code>
                  </div>

                  {/* Suggestion 4 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-emerald-300 flex items-center gap-2">
                      <span>4. VS Code & Electron Desktop Apps</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      Electron apps should bypass the sandbox and use desktop OpenGL for direct DRI drawing on DISPLAY=:0:
                    </p>
                    <code className="block p-2 rounded bg-black/40 text-[11px] font-mono text-neutral-300 select-all">
                      code-oss --disable-gpu-sandbox --use-gl=desktop --ozone-platform=x11
                    </code>
                  </div>

                  {/* Suggestion 5 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-blue-300 flex items-center gap-2">
                      <span>5. Tensor G5 Multi-Core Thread Affinity</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      Tensor G5 utilizes 1x Cortex-X4, 5x Cortex-A720, and 2x Cortex-A520 cores. For intensive tasks, bind workloads to performance cores (cores 1-7) using <code className="text-cyan-300">taskset -c 1-7 &lt;command&gt;</code> to prevent scheduler thrashing on efficiency cores.
                    </p>
                  </div>

                  {/* Suggestion 6 */}
                  <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                    <div className="font-semibold text-rose-300 flex items-center gap-2">
                      <span>6. 120Hz Super Actua Display Synchronization</span>
                    </div>
                    <p className="text-neutral-400 leading-relaxed">
                      The Pixel 10 Pro XL features a 120Hz LTPO display (8.33ms frame budget). Running <code className="text-cyan-300">MESA_VK_WSI_PRESENT_MODE=immediate</code> eliminates VSync queue lag, producing snappy cursor tracking and low-latency interaction.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* 3D RENDERING BENCHMARKS TAB */}
        {activeTab === 'benchmarks' && <BenchmarkTab />}

        {/* APP CATALOG TAB */}
        {activeTab === 'packages' && (
          <div className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <h2 className="text-xl font-bold text-white">Application Catalog & Package Manager</h2>
                <p className="text-xs sm:text-sm text-neutral-400">
                  Pre-configured Debian & Ubuntu ARM64 desktop packages verified for PowerVR acceleration.
                </p>
              </div>
              <div className="flex items-center gap-2 text-xs font-mono text-neutral-400 bg-white/5 px-3 py-1.5 rounded-lg border border-white/5">
                <ShieldCheck className="w-4 h-4 text-emerald-400" /> APT Repository Connected
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {packages.map(pkg => (
                <div
                  key={pkg.id}
                  className="p-5 rounded-xl bg-[#141520] border border-white/5 hover:border-white/15 transition flex flex-col justify-between gap-4"
                >
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-lg bg-gradient-to-tr from-purple-500/20 to-cyan-500/20 border border-white/10 flex items-center justify-center shrink-0">
                      {pkg.id === 'firefox' && <Globe className="w-5 h-5 text-amber-400" />}
                      {pkg.id === 'code-oss' && <Code className="w-5 h-5 text-cyan-400" />}
                      {pkg.id === 'gimp' && <Layers className="w-5 h-5 text-purple-400" />}
                      {pkg.id === 'libreoffice' && <FolderOpen className="w-5 h-5 text-emerald-400" />}
                      {pkg.id === 'vlc' && <Radio className="w-5 h-5 text-orange-400" />}
                      {pkg.id === 'nodejs' && <Terminal className="w-5 h-5 text-green-400" />}
                      {pkg.id === 'htop' && <Activity className="w-5 h-5 text-rose-400" />}
                    </div>

                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="font-bold text-white text-sm">{pkg.name}</h3>
                        <span className="text-[11px] font-mono text-neutral-400">{pkg.size}</span>
                      </div>
                      <p className="text-xs text-neutral-400 mt-1 leading-relaxed">{pkg.desc}</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-3 border-t border-white/5">
                    <span className="text-[11px] px-2 py-0.5 rounded bg-white/5 text-neutral-300 font-mono">
                      v{pkg.version}
                    </span>

                    <button
                      disabled={installingId === pkg.id}
                      onClick={() => togglePackage(pkg.id)}
                      className={`px-3 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition cursor-pointer ${
                        pkg.installed
                          ? 'bg-rose-500/10 text-rose-300 hover:bg-rose-500/20 border border-rose-500/20'
                          : 'bg-cyan-500/20 text-cyan-300 hover:bg-cyan-500/30 border border-cyan-500/30'
                      }`}
                    >
                      {installingId === pkg.id ? (
                        <>
                          <RefreshCw className="w-3.5 h-3.5 animate-spin" /> Processing...
                        </>
                      ) : pkg.installed ? (
                        <>
                          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Installed (Uninstall)
                        </>
                      ) : (
                        <>
                          <Download className="w-3.5 h-3.5" /> Install Package
                        </>
                      )}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* TERMINAL TAB */}
        {activeTab === 'terminal' && (
          <div className="space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
              <div>
                <h2 className="text-xl font-bold text-white flex items-center gap-2">
                  <Terminal className="w-5 h-5 text-cyan-400" /> Linux Terminal Console
                </h2>
                <p className="text-xs text-neutral-400">
                  Interactive root shell inside PRoot/Chroot environment with PowerVR acceleration variables.
                </p>
              </div>

              {/* Pre-made quick command buttons */}
              <div className="flex flex-wrap gap-1.5">
                {['neofetch', 'glxinfo', 'vulkaninfo', 'htop', 'powervr', 'apt update', 'clear'].map(cmd => (
                  <button
                    key={cmd}
                    onClick={() => {
                      setCommandInput(cmd);
                    }}
                    className="px-2.5 py-1 rounded bg-white/5 hover:bg-white/10 text-neutral-300 font-mono text-xs border border-white/10 transition cursor-pointer"
                  >
                    {cmd}
                  </button>
                ))}
              </div>
            </div>

            {/* Terminal Screen */}
            <div className="rounded-xl bg-[#090a10] border border-white/10 overflow-hidden shadow-2xl flex flex-col h-[480px]">
              <div className="bg-[#12131e] px-4 py-2 border-b border-white/5 flex items-center justify-between">
                <span className="text-xs text-neutral-400 font-mono flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                  droiddesk@pixel10-pro-xl: /home/droiddesk (bash)
                </span>
                <button
                  onClick={() => setTerminalHistory([])}
                  className="text-xs text-neutral-400 hover:text-white flex items-center gap-1 cursor-pointer"
                >
                  <RotateCcw className="w-3 h-3" /> Clear Screen
                </button>
              </div>

              {/* Terminal Logs */}
              <div className="flex-1 p-4 overflow-y-auto font-mono text-xs sm:text-sm text-neutral-300 space-y-1">
                {terminalHistory.map((line, idx) => (
                  <div
                    key={idx}
                    className={`leading-relaxed whitespace-pre-wrap ${
                      line.startsWith('droiddesk@')
                        ? 'text-cyan-400 font-bold'
                        : line.startsWith('[*]')
                        ? 'text-purple-300'
                        : line.startsWith('OpenGL') || line.startsWith('Vulkan')
                        ? 'text-emerald-300'
                        : 'text-neutral-300'
                    }`}
                  >
                    {line}
                  </div>
                ))}
                <div ref={terminalBottomRef} />
              </div>

              {/* Command Input Bar */}
              <form onSubmit={handleCommand} className="p-3 bg-[#11121d] border-t border-white/5 flex items-center gap-2">
                <span className="text-cyan-400 font-mono text-sm font-bold pl-2">$</span>
                <input
                  type="text"
                  value={commandInput}
                  onChange={e => setCommandInput(e.target.value)}
                  placeholder="Enter Linux command (e.g. neofetch, glxinfo, vulkaninfo, htop)..."
                  className="flex-1 bg-transparent text-white font-mono text-xs sm:text-sm focus:outline-none placeholder-neutral-500"
                  autoFocus
                />
                <button
                  type="submit"
                  className="px-4 py-1.5 bg-cyan-500 hover:bg-cyan-400 text-black font-semibold rounded-lg text-xs transition cursor-pointer"
                >
                  Execute
                </button>
              </form>
            </div>
          </div>
        )}

        {/* DIAGNOSTICS TAB */}
        {activeTab === 'diagnostics' && (
          <div className="space-y-6">
            <div className="rounded-xl bg-[#141520] border border-white/5 p-6 space-y-6">
              <div>
                <h2 className="text-xl font-bold text-white flex items-center gap-2">
                  <Activity className="w-5 h-5 text-purple-400" /> System Diagnostics & Hardware Telemetry
                </h2>
                <p className="text-sm text-neutral-400 mt-1">
                  Real-time CPU cluster activity, memory utilization, and PowerVR graphics pipeline metrics.
                </p>
              </div>

              {/* 8-Core Tensor G5 Cluster breakdown */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-semibold text-white">Google Tensor G5 ("Laguna") CPU Cluster Activity</span>
                  <span className="text-xs font-mono text-neutral-400">8 Physical Cores</span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                  {[
                    { name: 'Core 0 (Cortex-X925 Prime)', freq: '3.40 GHz', load: 38, color: 'from-rose-500 to-amber-500' },
                    { name: 'Core 1 (Cortex-A725 Mid)', freq: '2.85 GHz', load: 24, color: 'from-purple-500 to-indigo-500' },
                    { name: 'Core 2 (Cortex-A725 Mid)', freq: '2.85 GHz', load: 29, color: 'from-purple-500 to-indigo-500' },
                    { name: 'Core 3 (Cortex-A725 Mid)', freq: '2.85 GHz', load: 18, color: 'from-purple-500 to-indigo-500' },
                    { name: 'Core 4 (Cortex-A725 Mid)', freq: '2.85 GHz', load: 22, color: 'from-purple-500 to-indigo-500' },
                    { name: 'Core 5 (Cortex-A725 Mid)', freq: '2.85 GHz', load: 16, color: 'from-purple-500 to-indigo-500' },
                    { name: 'Core 6 (Cortex-A520 Efficiency)', freq: '2.10 GHz', load: 12, color: 'from-emerald-500 to-cyan-500' },
                    { name: 'Core 7 (Cortex-A520 Efficiency)', freq: '2.10 GHz', load: 14, color: 'from-emerald-500 to-cyan-500' },
                  ].map((core, i) => (
                    <div key={i} className="p-3.5 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-neutral-300 font-medium truncate">{core.name}</span>
                        <span className="text-white font-mono font-bold">{core.load}%</span>
                      </div>
                      <div className="w-full h-2 rounded-full bg-black/40 overflow-hidden">
                        <div
                          className={`h-full bg-gradient-to-r ${core.color} rounded-full`}
                          style={{ width: `${core.load}%` }}
                        />
                      </div>
                      <div className="text-[10px] font-mono text-neutral-400">{core.freq}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Memory & Storage Gauges */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t border-white/5">
                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-neutral-300 font-semibold">16GB LPDDR5X RAM</span>
                    <span className="font-mono text-cyan-400 font-bold">3.8 GB / 16.0 GB (24%)</span>
                  </div>
                  <div className="w-full h-2.5 rounded-full bg-black/40 overflow-hidden">
                    <div className="h-full bg-cyan-500 rounded-full" style={{ width: '24%' }} />
                  </div>
                  <p className="text-xs text-neutral-400">12.2 GB available for Linux desktop applications and compilers.</p>
                </div>

                <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5 space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-neutral-300 font-semibold">Storage Space</span>
                    <span className="font-mono text-emerald-400 font-bold">142 GB Free / 256 GB</span>
                  </div>
                  <div className="w-full h-2.5 rounded-full bg-black/40 overflow-hidden">
                    <div className="h-full bg-emerald-500 rounded-full" style={{ width: '44%' }} />
                  </div>
                  <p className="text-xs text-neutral-400">Rootfs location: /data/data/com.termux/files/usr/var/lib/proot-distro</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* APK BUILD & EXPORT TAB */}
        {activeTab === 'build' && (
          <div className="space-y-6">
            {/* Header Banner */}
            <div className="p-6 rounded-2xl bg-gradient-to-br from-[#161729] via-[#121320] to-[#0c0d16] border border-cyan-500/30 space-y-3">
              <div className="flex items-center gap-2 text-cyan-400 text-xs font-semibold uppercase tracking-wider">
                <Download className="w-4 h-4" /> Pixel 10 Pro XL · Android APK Build Pipeline
              </div>
              <h2 className="text-2xl font-bold text-white">Export & Build DroidDesk APK</h2>
              <p className="text-sm text-neutral-300 max-w-3xl leading-relaxed">
                Because AI Studio Cloud Run containers run in a lightweight Node.js web runtime without the 10GB+ Android SDK and NDK compilation tools pre-installed, we have configured an automated <strong>GitHub Actions CI workflow</strong> and a <strong>local build script</strong> to compile the release APK directly for your Pixel 10 Pro XL.
              </p>
            </div>

            {/* Methods Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Option 1: Automated GitHub Actions Build */}
              <div className="p-6 rounded-xl bg-[#141520] border border-white/10 flex flex-col justify-between space-y-4">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-lg bg-purple-500/20 text-purple-400 flex items-center justify-center font-bold text-sm">
                        1
                      </div>
                      <h3 className="font-bold text-white text-base">Automated GitHub Actions Build</h3>
                    </div>
                    <span className="px-2.5 py-0.5 rounded bg-emerald-500/20 text-emerald-300 text-xs font-mono">
                      Workflow Configured
                    </span>
                  </div>

                  <p className="text-xs text-neutral-300 leading-relaxed">
                    A dedicated workflow file has been created at <code className="text-cyan-400 font-mono">.github/workflows/build-apk.yml</code>. Whenever code is pushed to your GitHub repository, GitHub's Ubuntu runners automatically compile the Flutter ARM64 APK with PowerVR support.
                  </p>

                  <div className="p-3.5 rounded-lg bg-black/40 border border-white/5 space-y-2 text-xs">
                    <span className="text-neutral-400 font-semibold block">How to push & trigger:</span>
                    <ol className="list-decimal list-inside space-y-1.5 text-neutral-300 pl-1">
                      <li>Open the top-right <strong>Export</strong> or <strong>Settings</strong> menu in Google AI Studio.</li>
                      <li>Select <strong>Export to GitHub</strong> to sync these changes directly to <code className="text-purple-300">Sanketpathania/DroidDeskPowerVR</code>.</li>
                      <li>Visit your repository on GitHub and navigate to the <strong>Actions</strong> tab.</li>
                      <li>The <strong className="text-white">Build DroidDesk PowerVR APK</strong> workflow will build the APK and generate the downloadable artifact: <code className="text-emerald-400">app-release.apk</code>.</li>
                    </ol>
                  </div>
                </div>

                <div className="p-3 rounded-lg bg-white/5 border border-white/5 flex items-center justify-between text-xs font-mono text-neutral-400">
                  <span>Workflow File:</span>
                  <span className="text-cyan-400">.github/workflows/build-apk.yml</span>
                </div>
              </div>

              {/* Option 2: Local Machine Compilation */}
              <div className="p-6 rounded-xl bg-[#141520] border border-white/10 flex flex-col justify-between space-y-4">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-lg bg-cyan-500/20 text-cyan-400 flex items-center justify-center font-bold text-sm">
                        2
                      </div>
                      <h3 className="font-bold text-white text-base">Compile Locally via Script</h3>
                    </div>
                    <span className="px-2.5 py-0.5 rounded bg-cyan-500/20 text-cyan-300 text-xs font-mono">
                      ./build-apk.sh
                    </span>
                  </div>

                  <p className="text-xs text-neutral-300 leading-relaxed">
                    If you have Flutter and Android SDK installed on your computer, you can clone or download the ZIP and compile the release APK with one command.
                  </p>

                  <div className="p-3 rounded-lg bg-black/50 border border-white/10 font-mono text-xs space-y-1 text-neutral-300">
                    <div className="text-neutral-500"># 1. Clone or download your repository</div>
                    <div className="text-cyan-400">git clone https://github.com/Sanketpathania/DroidDeskPowerVR.git</div>
                    <div className="text-cyan-400">cd DroidDeskPowerVR</div>
                    <div className="text-neutral-500 mt-2"># 2. Run the automated build script</div>
                    <div className="text-emerald-400">chmod +x build-apk.sh && ./build-apk.sh</div>
                    <div className="text-neutral-500 mt-2"># Output APK will be at:</div>
                    <div className="text-amber-300">app/build/app/outputs/flutter-apk/app-release.apk</div>
                  </div>
                </div>

                <div className="p-3 rounded-lg bg-white/5 border border-white/5 flex items-center justify-between text-xs font-mono text-neutral-400">
                  <span>Target ABI:</span>
                  <span className="text-purple-300">arm64-v8a (Tensor G5 / PowerVR)</span>
                </div>
              </div>
            </div>

            {/* Changes Included in This Build */}
            <div className="p-6 rounded-xl bg-[#141520] border border-white/5 space-y-4">
              <h3 className="font-bold text-white text-base flex items-center gap-2">
                <CheckCircle2 className="w-5 h-5 text-emerald-400" /> PowerVR & Pixel 10 Pro XL Changes Bundled in APK
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 text-xs">
                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">LinuxRuntime.kt</div>
                  <div className="text-neutral-400 mt-1">Zink driver injection, TBDR lazy descriptors, 8-thread Tensor G5 allocation</div>
                </div>

                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">MainActivity.kt</div>
                  <div className="text-neutral-400 mt-1">Pixel 10 Pro XL detection, PowerVR EGL probing, method channel reporting</div>
                </div>

                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">ChrootRuntime.kt</div>
                  <div className="text-neutral-400 mt-1">droiddesk-ha.sh hardware acceleration with PowerVR device node bindings</div>
                </div>

                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">RootfsManager.kt</div>
                  <div className="text-neutral-400 mt-1">Default environment profile with PVR_MESA=1 and LP_NUM_THREADS=8</div>
                </div>

                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">X11InputController.kt</div>
                  <div className="text-neutral-400 mt-1">High-DPI 200% display scaling for Pixel 10 Pro XL Super Actua display</div>
                </div>

                <div className="p-3 rounded-lg bg-white/[0.02] border border-white/5">
                  <div className="font-semibold text-white">termux-linux-setup.sh</div>
                  <div className="text-neutral-400 mt-1">PowerVR DXT detection, Vulkan loader generic, and kernel node passthrough</div>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Footer Status Bar */}
      <footer className="border-t border-white/5 bg-[#0f1018] py-4 text-xs text-neutral-400">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-400" />
            <span>DroidDesk Runtime: Active</span>
            <span className="text-neutral-600">•</span>
            <span>Target: Pixel 10 Pro XL</span>
            <span className="text-neutral-600">•</span>
            <span>GPU: PowerVR IMG DXT (Zink)</span>
          </div>

          <div className="flex items-center gap-4">
            <span className="text-neutral-400 font-mono">Display Scale: {resolutionMode}</span>
            <span className="text-neutral-600">•</span>
            <span className="text-neutral-400 font-mono">Threads: {pvrMultiThreads}</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
