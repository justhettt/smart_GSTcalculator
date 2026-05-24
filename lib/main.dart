import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CalculatorApp());
}

// ─── THEME NOTIFIER ──────────────────────────────────────────────────────────
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

// ─── COLOR SCHEME (RED PREMIUM THEME) ────────────────────────────────────────
class AppTheme {
  final bool isDark;
  const AppTheme(this.isDark);

  // Shared accent colors — RED THEME
  static const accent    = Color(0xFFFF3B3B);
  static const accentAlt = Color(0xFFFF6B6B);
  static const cyan      = Color(0xFFFF8A80);   // was cyan, now soft red-orange hint
  static const red       = Color(0xFFFF3B3B);

  // Adaptive colors
  Color get bg      => isDark ? const Color(0xFF0F0A0A) : const Color(0xFFFFF5F5);
  Color get surface => isDark ? const Color(0xFF1A0F0F) : const Color(0xFFFFFFFF);
  Color get glass   => isDark ? const Color(0xFF251515) : const Color(0xFFFFECEC);
  Color get border  => isDark ? const Color(0xFF3A2020) : const Color(0xFFFFCDD2);
  Color get textPri => isDark ? const Color(0xFFFFF0F0) : const Color(0xFF1A0000);
  Color get textSec => isDark ? const Color(0xFFAA6666) : const Color(0xFF994444);
  Color get opBg    => isDark ? const Color(0xFF2A1515) : const Color(0xFFFFE8E8);
  Color get numBg   => isDark ? const Color(0xFF180E0E) : const Color(0xFFFFF8F8);
  Color get shadow  => isDark ? Colors.black : const Color(0xFFFFAAAA);
  Color get orbA    => isDark ? accent.withOpacity(0.10) : accent.withOpacity(0.06);
  Color get orbB    => isDark ? accentAlt.withOpacity(0.07) : accentAlt.withOpacity(0.04);
}

// ─── APP ─────────────────────────────────────────────────────────────────────
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: AppTheme(false).bg),
          darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme(true).bg),
          home: const MainScreen(),
        );
      },
    );
  }
}

// ─── MAIN SCREEN WITH TAB NAVIGATION ────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabIndex = 0;

  static const _tabs = ['Calc', 'GST', 'Unit', 'Currency'];
  static const _tabIcons = [
    Icons.calculate_rounded,
    Icons.receipt_long_rounded,
    Icons.swap_horiz_rounded,
    Icons.currency_exchange_rounded,
  ];

  bool get _isDark => themeNotifier.value == ThemeMode.dark;
  AppTheme get th   => AppTheme(_isDark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, __, ___) {
        final t = th;
        return Scaffold(
          backgroundColor: t.bg,
          body: Column(children: [
            // ── Top tab bar ──
            SafeArea(
              bottom: false,
              child: _buildTabBar(t),
            ),
            // ── Active view ──
            Expanded(child: _buildView()),
          ]),
        );
      },
    );
  }

  Widget _buildTabBar(AppTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withOpacity(0.15),
            blurRadius: 12, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final on = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: on ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: on
                      ? [BoxShadow(
                    color: AppTheme.accent.withOpacity(0.4),
                    blurRadius: 12, spreadRadius: 1,
                  )]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_tabIcons[i], size: 16,
                        color: on ? Colors.white : t.textSec),
                    const SizedBox(height: 2),
                    Text(_tabs[i], style: TextStyle(
                      fontSize: 10,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                      color: on ? Colors.white : t.textSec,
                      letterSpacing: 0.5,
                    )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildView() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04), end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: switch (_tabIndex) {
        0 => const CalcScreen(key: ValueKey(0)),
        1 => const GstScreen(key: ValueKey(1)),
        2 => const UnitConverterScreen(key: ValueKey(2)),
        3 => const CurrencyScreen(key: ValueKey(3)),
        _ => const CalcScreen(key: ValueKey(0)),
      },
    );
  }
}

// ─── HISTORY MODEL ────────────────────────────────────────────────────────────
class HistEntry {
  final String expr, result;
  HistEntry(this.expr, this.result);
}

// ─── BUTTON KIND ─────────────────────────────────────────────────────────────
enum BK { num, op, eq, clear, fn, sci }

class BtnDef {
  final String label;
  final BK kind;
  const BtnDef(this.label, {this.kind = BK.num});
}

// ─── CALCULATOR SCREEN ────────────────────────────────────────────────────────
class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});
  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> with TickerProviderStateMixin {
  String _input   = '';
  String _output  = '0';
  String _preview = '';
  String _lastOp  = '';
  double _ans     = 0;
  bool _isDeg     = true;
  bool _isInv     = false;
  bool _showHist  = false;
  bool _showSci   = true;
  bool _justCalc  = false;

  final List<HistEntry> _hist = [];
  final ScrollController _histScroll = ScrollController();

  late final AnimationController _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480));
  late final AnimationController _resultCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
  late final AnimationController _bgCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..repeat(reverse: true);

  late final Animation<double> _shakeAnim = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut));
  late final Animation<double> _resultScale =
  Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _resultCtrl, curve: Curves.elasticOut));
  late final Animation<double> _bgAnim =
  Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

  bool get _isDark => themeNotifier.value == ThemeMode.dark;
  AppTheme get th  => AppTheme(_isDark);

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _resultCtrl.dispose();
    _bgCtrl.dispose();
    _histScroll.dispose();
    super.dispose();
  }

  List<List<BtnDef>> get _sciRows => [
    [
      BtnDef(_isInv ? 'asin' : 'sin', kind: BK.sci),
      BtnDef(_isInv ? 'acos' : 'cos', kind: BK.sci),
      BtnDef(_isInv ? 'atan' : 'tan', kind: BK.sci),
      BtnDef('log', kind: BK.sci),
      BtnDef('ln',  kind: BK.sci),
    ],
    [
      BtnDef('π',  kind: BK.sci),
      BtnDef('e',  kind: BK.sci),
      BtnDef('√',  kind: BK.sci),
      BtnDef('^',  kind: BK.sci),
      BtnDef('!',  kind: BK.sci),
    ],
  ];

  final List<List<BtnDef>> _mainRows = [
    [BtnDef('AC', kind: BK.clear), BtnDef('+/-', kind: BK.fn),
      BtnDef('%', kind: BK.fn),    BtnDef('÷',   kind: BK.op)],
    [BtnDef('7'), BtnDef('8'), BtnDef('9'), BtnDef('×', kind: BK.op)],
    [BtnDef('4'), BtnDef('5'), BtnDef('6'), BtnDef('-', kind: BK.op)],
    [BtnDef('1'), BtnDef('2'), BtnDef('3'), BtnDef('+', kind: BK.op)],
    [BtnDef('0'), BtnDef('.'), BtnDef('⌫', kind: BK.fn),
      BtnDef('=', kind: BK.eq)],
  ];

  // ── Tap handler ───────────────────────────────────────────────────────────
  void _tap(String v) {
    HapticFeedback.lightImpact();
    setState(() {
      switch (v) {
        case 'AC':
          _input = ''; _output = '0'; _preview = '';
          _lastOp = ''; _justCalc = false;
          _resultCtrl.forward(from: 0);
          break;

        case '⌫':
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
            _updatePreview();
            if (_input.isEmpty) { _output = '0'; _preview = ''; }
          }
          break;

        case '=':
          _calculate();
          break;

        case 'Ans':
          if (_justCalc) _input = '';
          _input += _fmt(_ans); _justCalc = false; _updatePreview();
          break;

        case 'π':
          if (_justCalc) _input = '';
          _input += '3.14159265358979'; _justCalc = false; _updatePreview();
          break;

        case 'e':
          if (_justCalc) _input = '';
          _input += '2.71828182845904'; _justCalc = false; _updatePreview();
          break;

        case '+/-':
          if (_input.isNotEmpty) {
            _input = _input.startsWith('-')
                ? _input.substring(1) : '-$_input';
            _updatePreview();
          }
          break;

        case '%':
          if (_input.isNotEmpty) {
            try {
              final val = double.parse(_input);
              _input = _fmt(val / 100); _updatePreview();
            } catch (_) {}
          }
          break;

        default:
          const needsParen = [
            'sin','cos','tan','asin','acos','atan','log','ln','√'
          ];
          if (needsParen.contains(v)) {
            if (_justCalc) _input = '';
            _input += '$v('; _justCalc = false; _updatePreview();
          } else {
            final isOp = '+-×÷^'.contains(v);
            if (_justCalc && !isOp) _input = '';
            _justCalc = false;
            _input += v; _updatePreview();
          }
          break;
      }
    });
  }

  void _updatePreview() {
    try {
      final r = _eval(_input);
      final hasOp = RegExp(r'[+\-×÷*/^]').hasMatch(_input) ||
          RegExp(r'(sin|cos|tan|log|ln|√|sqrt)\(').hasMatch(_input);
      if (r != null && r.isFinite && hasOp) {
        _preview = '= ${_fmt(r)}';
      } else {
        _preview = '';
      }
    } catch (_) {
      _preview = '';
    }
  }

  void _calculate() {
    if (_input.isEmpty) return;
    try {
      final r = _eval(_input);
      if (r == null || !r.isFinite) { _error('Math Error'); return; }
      final fs = _fmt(r);
      _hist.add(HistEntry(_input, fs));
      _ans    = r;
      _output = fs;
      _preview = '';
      _lastOp = '$_input = $fs';
      _input  = fs;
      _justCalc = true;
      _resultCtrl.forward(from: 0);
      HapticFeedback.mediumImpact();
      if (_showHist) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_histScroll.hasClients) {
            _histScroll.animateTo(_histScroll.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        });
      }
    } catch (_) {
      _error('Syntax Error');
    }
  }

  void _error(String msg) {
    _output = msg; _preview = '';
    _shakeCtrl.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  String _autoClose(String expr) {
    int open = 0;
    for (final ch in expr.runes) {
      final c = String.fromCharCode(ch);
      if (c == '(') open++;
      else if (c == ')') open--;
    }
    if (open > 0) return expr + ')' * open;
    return expr;
  }

  double? _eval(String raw) {
    String e = _autoClose(raw);
    e = e
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√', 'sqrt');
    e = _doTrig(e);
    e = _doSqrt(e);
    e = _doLog(e);
    e = _doFact(e);
    return _ExprParser(e).parse();
  }

  String _doTrig(String e) {
    for (final fn in ['asin','acos','atan','sin','cos','tan']) {
      e = e.replaceAllMapped(RegExp('$fn\\(([^()]+)\\)'), (m) {
        final v   = double.tryParse(m.group(1)!) ?? 0;
        final rad = fn.startsWith('a') ? v
            : (_isDeg ? v * math.pi / 180 : v);
        double r;
        switch (fn) {
          case 'sin':  r = math.sin(rad); break;
          case 'cos':  r = math.cos(rad); break;
          case 'tan':  r = math.tan(rad); break;
          case 'asin': r = math.asin(v) * (_isDeg ? 180/math.pi : 1); break;
          case 'acos': r = math.acos(v) * (_isDeg ? 180/math.pi : 1); break;
          case 'atan': r = math.atan(v) * (_isDeg ? 180/math.pi : 1); break;
          default:     r = 0; break;
        }
        return r.toString();
      });
    }
    return e;
  }

  String _doSqrt(String e) => e.replaceAllMapped(
      RegExp(r'sqrt\(([^()]+)\)'),
          (m) => math.sqrt(double.tryParse(m.group(1)!) ?? 0).toString());

  String _doLog(String e) {
    e = e.replaceAllMapped(RegExp(r'ln\(([^()]+)\)'),
            (m) => math.log(double.tryParse(m.group(1)!) ?? 1).toString());
    e = e.replaceAllMapped(RegExp(r'log\(([^()]+)\)'),
            (m) => (math.log(double.tryParse(m.group(1)!) ?? 1) / math.ln10).toString());
    return e;
  }

  String _doFact(String e) => e.replaceAllMapped(RegExp(r'(\d+)!'), (m) {
    final n = int.tryParse(m.group(1)!);
    if (n == null || n < 0 || n > 20) return '0';
    int f = 1; for (int i = 2; i <= n; i++) f *= i;
    return f.toString();
  });

  String _fmt(double n) {
    if (n == n.truncateToDouble() && n.abs() < 1e15) return n.toInt().toString();
    String s = n.toStringAsPrecision(10);
    if (s.contains('.') && !s.contains('e')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, __, ___) {
        final t = th;
        return Stack(children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              painter: _OrbPainter(_bgAnim.value, t),
              size: MediaQuery.of(context).size,
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            final totalH = constraints.maxHeight;
            const topH  = 52.0;
            const dispH = 150.0;
            const histH = 160.0;
            final sciH  = _showSci ? 116.0 : 0.0;
            const pad   = 16.0;
            final usedH = topH + dispH +
                (_showHist ? histH : 0) + sciH + pad;
            final btnH  = (totalH - usedH).clamp(220.0, 520.0);
            final rowH  = btnH / _mainRows.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topH,  child: _buildTopBar(t)),
                SizedBox(height: dispH, child: _buildDisplay(t)),
                if (_showHist)
                  SizedBox(height: histH, child: _buildHistory(t)),
                if (_showSci)
                  SizedBox(height: sciH,  child: _buildSci(t)),
                const SizedBox(height: 8),
                SizedBox(
                  height: rowH * _mainRows.length,
                  child: _buildMain(rowH, t),
                ),
              ],
            );
          }),
        ]);
      },
    );
  }

  Widget _buildTopBar(AppTheme t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        _chip('DEG', _isDeg,  t, () => setState(() => _isDeg = true)),
        const SizedBox(width: 8),
        _chip('RAD', !_isDeg, t, () => setState(() => _isDeg = false)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            themeNotifier.value = _isDark ? ThemeMode.light : ThemeMode.dark;
            setState(() {});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 52, height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.accent.withOpacity(0.25)
                  : Colors.orange.withOpacity(0.20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDark ? AppTheme.accent : Colors.orange.shade300,
                width: 1.2,
              ),
            ),
            child: Stack(children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: _isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: _isDark ? AppTheme.accent : Colors.orange.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 12, color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        _topBtn(Icons.science_outlined,  _isInv,    t,
                () => setState(() => _isInv = !_isInv), 'INV'),
        const SizedBox(width: 6),
        _topBtn(Icons.history_rounded,   _showHist, t,
                () => setState(() => _showHist = !_showHist), null),
        const SizedBox(width: 6),
        _topBtn(Icons.grid_view_rounded, _showSci,  t,
                () => setState(() => _showSci = !_showSci), null),
      ]),
    );
  }

  Widget _chip(String label, bool on, AppTheme t, VoidCallback fn) {
    return GestureDetector(
      onTap: fn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: on ? AppTheme.accent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: on ? AppTheme.accent : t.border),
        ),
        child: Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
            color: on ? AppTheme.accent : t.textSec)),
      ),
    );
  }

  Widget _topBtn(IconData icon, bool on, AppTheme t,
      VoidCallback fn, String? lbl) {
    return GestureDetector(
      onTap: fn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: lbl != null ? 10 : 8, vertical: 6),
        decoration: BoxDecoration(
          color: on ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: on ? AppTheme.accent.withOpacity(0.5) : t.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15,
              color: on ? AppTheme.accent : t.textSec),
          if (lbl != null) ...[
            const SizedBox(width: 4),
            Text(lbl, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold,
                color: on ? AppTheme.accent : t.textSec)),
          ],
        ]),
      ),
    );
  }

  Widget _buildDisplay(AppTheme t) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnim, _resultScale]),
      builder: (_, child) {
        final dx = math.sin(_shakeAnim.value * math.pi * 8) * 10;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(scale: _resultScale.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(_isDark ? 0.10 : 0.06),
              blurRadius: 40, spreadRadius: 4,
            ),
            BoxShadow(
              color: t.shadow.withOpacity(0.15),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                _input.isEmpty ? '0' : _input,
                style: TextStyle(fontSize: 18, color: t.textSec),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25), end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                _output,
                key: ValueKey(_output),
                style: TextStyle(
                  fontSize: _output.length > 12 ? 28 : 42,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                  color: _output.contains('Error')
                      ? AppTheme.red : t.textPri,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _preview.isEmpty
                  ? const SizedBox(height: 18, key: ValueKey('empty'))
                  : SizedBox(
                key: const ValueKey('preview'),
                height: 18,
                child: Text(
                  _preview,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.accentAlt.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(AppTheme t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
          child: Row(children: [
            Icon(Icons.history_rounded, size: 13, color: t.textSec),
            const SizedBox(width: 6),
            Text('HISTORY', style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.4,
                color: t.textSec)),
            const Spacer(),
            if (_hist.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _hist.clear()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.red.withOpacity(0.3)),
                  ),
                  child: const Text('Clear',
                      style: TextStyle(fontSize: 10, color: AppTheme.red)),
                ),
              ),
          ]),
        ),
        Expanded(
          child: _hist.isEmpty
              ? Center(child: Text('No history yet',
              style: TextStyle(fontSize: 12,
                  color: t.textSec.withOpacity(0.4))))
              : ListView.builder(
              controller: _histScroll,
              padding: const EdgeInsets.all(10),
              itemCount: _hist.length,
              itemBuilder: (_, i) {
                final h = _hist[i];
                return GestureDetector(
                  onTap: () => setState(() {
                    _input = h.result; _output = h.result; _preview = '';
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                        color: t.glass,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(h.expr,
                            style: TextStyle(fontSize: 12, color: t.textSec),
                            overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('= ${h.result}',
                            style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent)),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ]),
    );
  }

  Widget _buildSci(AppTheme t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(children: _sciRows.map((row) {
        return Expanded(child: Row(
          children: row.map((btn) =>
              Expanded(child: _mkBtn(btn, 13.0, t))).toList(),
        ));
      }).toList()),
    );
  }

  Widget _buildMain(double rowH, AppTheme t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(children: _mainRows.map((row) {
        return SizedBox(
          height: rowH,
          child: Row(children: row.map((btn) =>
              Expanded(child: _mkBtn(btn, 19.0, t))).toList()),
        );
      }).toList()),
    );
  }

  Widget _mkBtn(BtnDef def, double fs, AppTheme t) =>
      CalcBtn(def: def, fontSize: fs, theme: t,
          onTap: () => _tap(def.label));
}

// ─── ANIMATED CALCULATOR BUTTON ───────────────────────────────────────────────
class CalcBtn extends StatefulWidget {
  final BtnDef def;
  final double fontSize;
  final AppTheme theme;
  final VoidCallback onTap;
  const CalcBtn({super.key, required this.def, required this.fontSize,
    required this.theme, required this.onTap});
  @override
  State<CalcBtn> createState() => _CalcBtnState();
}

class _CalcBtnState extends State<CalcBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 130));
  late final Animation<double> _scale =
  Tween<double>(begin: 1.0, end: 0.84).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  late final Animation<double> _glow =
  Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  bool _hover = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  AppTheme get t => widget.theme;

  Color get _bg => switch (widget.def.kind) {
    BK.eq    => AppTheme.accent,
    BK.clear => AppTheme.red.withOpacity(0.15),
    BK.op    => t.opBg,
    BK.fn    => t.opBg,
    BK.sci   => t.glass,
    _        => t.numBg,
  };

  Color get _fg => switch (widget.def.kind) {
    BK.eq    => Colors.white,
    BK.clear => AppTheme.red,
    BK.op    => AppTheme.accent,
    BK.fn    => AppTheme.accentAlt,
    BK.sci   => AppTheme.accentAlt,
    _        => t.textPri,
  };

  Color get _glowCol => switch (widget.def.kind) {
    BK.eq    => AppTheme.accent,
    BK.clear => AppTheme.red,
    BK.op    => AppTheme.accent,
    _        => AppTheme.accentAlt,
  };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown:   (_) => _ctrl.forward(),
        onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.all(4),
            child: Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: _hover ? Color.lerp(_bg, _glowCol, 0.09) : _bg,
                  borderRadius: BorderRadius.circular(
                      widget.def.kind == BK.sci ? 14 : 22),
                  border: Border.all(
                    color: _glow.value > 0.1
                        ? _glowCol.withOpacity(0.55)
                        : (_hover
                        ? _glowCol.withOpacity(0.28)
                        : t.border.withOpacity(0.6)),
                  ),
                  boxShadow: [
                    if (widget.def.kind == BK.eq)
                      BoxShadow(
                        color: AppTheme.accent
                            .withOpacity(0.30 + _glow.value * 0.35),
                        blurRadius: 18 + _glow.value * 18,
                        spreadRadius: _glow.value * 3,
                      ),
                    BoxShadow(
                      color: _glowCol.withOpacity(_glow.value * 0.15),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: t.shadow.withOpacity(0.25),
                      blurRadius: 6, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(child: _lbl()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lbl() {
    if (widget.def.label == '⌫') {
      return Icon(Icons.backspace_outlined, color: _fg,
          size: widget.def.kind == BK.sci ? 14 : 19);
    }
    return Text(widget.def.label, style: TextStyle(
      color: _fg,
      fontSize: widget.fontSize,
      fontWeight: (widget.def.kind == BK.eq || widget.def.kind == BK.clear)
          ? FontWeight.w700 : FontWeight.w400,
    ));
  }
}

// ─── BACKGROUND ORBS ─────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double t;
  final AppTheme theme;
  _OrbPainter(this.t, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset center, double r, Color col) {
      canvas.drawCircle(center, r, Paint()
        ..shader = RadialGradient(
          colors: [col.withOpacity(col.opacity * t), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: r)));
    }
    orb(Offset(size.width * 0.2,  size.height * 0.1),  220, theme.orbA);
    orb(Offset(size.width * 0.85, size.height * 0.82), 200, theme.orbB);
    orb(Offset(size.width * 0.5,  size.height * 0.5),  150,
        AppTheme.accent.withOpacity(theme.isDark ? 0.04 : 0.02));
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.t != t || old.theme.isDark != theme.isDark;
}

// ─── EXPRESSION PARSER ───────────────────────────────────────────────────────
class _ExprParser {
  final String src;
  int i = 0;
  _ExprParser(this.src);

  double parse() {
    final v = _addSub();
    if (i < src.length) throw Exception('Unexpected: ${src[i]}');
    return v;
  }

  double _addSub() {
    var v = _mulDiv();
    while (i < src.length) {
      if      (src[i] == '+') { i++; v += _mulDiv(); }
      else if (src[i] == '-') { i++; v -= _mulDiv(); }
      else break;
    }
    return v;
  }

  double _mulDiv() {
    var v = _pow();
    while (i < src.length) {
      if (src[i] == '*') { i++; v *= _pow(); }
      else if (src[i] == '/') {
        i++;
        final d = _pow();
        if (d == 0) throw Exception('Div/0');
        v /= d;
      } else break;
    }
    return v;
  }

  double _pow() {
    final b = _unary();
    if (i < src.length && src[i] == '^') {
      i++; return math.pow(b, _pow()).toDouble();
    }
    return b;
  }

  double _unary() {
    if (i < src.length && src[i] == '-') { i++; return -_atom(); }
    if (i < src.length && src[i] == '+') { i++; }
    return _atom();
  }

  double _atom() {
    if (i >= src.length) throw Exception('Unexpected end');
    if (src[i] == '(') {
      i++;
      final v = _addSub();
      if (i < src.length && src[i] == ')') i++;
      return v;
    }
    final start = i;
    if (i < src.length && src[i] == '-') i++;
    while (i < src.length &&
        (RegExp(r'[0-9.]').hasMatch(src[i]) ||
            (src[i] == 'e' && i + 1 < src.length &&
                RegExp(r'[0-9+\-]').hasMatch(src[i + 1])))) {
      i++;
    }
    if (i == start) throw Exception('Expected number at $i');
    return double.parse(src.substring(start, i));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── GST CALCULATOR SCREEN ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
class GstScreen extends StatefulWidget {
  const GstScreen({super.key});
  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  final _amtCtrl = TextEditingController();
  double _gstPct = 18;
  bool _inclusive = false; // false = exclusive (add GST), true = inclusive (extract GST)

  bool get _isDark => themeNotifier.value == ThemeMode.dark;
  AppTheme get th  => AppTheme(_isDark);

  // Preset GST slabs
  static const _slabs = [5.0, 12.0, 18.0, 28.0];

  double get _amount => double.tryParse(_amtCtrl.text) ?? 0;

  /// Exclusive: user enters pre-tax amount, we add GST on top.
  /// Inclusive: user enters total (GST included), we extract GST.
  double get _gstAmount {
    if (_amount <= 0) return 0;
    if (_inclusive) {
      // GST already included in amount
      return _amount - (_amount * 100 / (100 + _gstPct));
    } else {
      return (_amount * _gstPct) / 100;
    }
  }

  double get _totalAmount {
    if (_amount <= 0) return 0;
    if (_inclusive) {
      return _amount; // amount is already the total
    } else {
      return _amount + _gstAmount;
    }
  }

  double get _baseAmount {
    if (_amount <= 0) return 0;
    if (_inclusive) {
      return _amount * 100 / (100 + _gstPct);
    } else {
      return _amount;
    }
  }

  String _f(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  @override
  void dispose() { _amtCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, __, ___) {
        final t = th;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Mode toggle ──
            _modeToggle(t),
            const SizedBox(height: 16),
            // ── Amount input ──
            _sectionCard(t, 'Amount (₹)',
              child: _styledInput(t, _amtCtrl, 'Enter amount',
                  suffix: '₹', onChanged: (_) => setState(() {})),
            ),
            const SizedBox(height: 12),
            // ── GST slab selector ──
            _sectionCard(t, 'GST Rate',
              child: Column(children: [
                Row(children: _slabs.map((s) {
                  final on = s == _gstPct;
                  return Expanded(child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: GestureDetector(
                      onTap: () => setState(() => _gstPct = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: on
                              ? AppTheme.accent
                              : t.glass,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: on ? AppTheme.accent : t.border),
                          boxShadow: on ? [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.35),
                              blurRadius: 12, spreadRadius: 1,
                            )
                          ] : [],
                        ),
                        child: Center(child: Text('${s.toInt()}%',
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: on ? Colors.white : t.textSec,
                            ))),
                      ),
                    ),
                  ));
                }).toList()),
                const SizedBox(height: 10),
                // Custom GST slider
                Row(children: [
                  Text('Custom: ${_gstPct.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, color: t.textSec)),
                  Expanded(child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.accent,
                      inactiveTrackColor: t.border,
                      thumbColor: AppTheme.accent,
                      overlayColor: AppTheme.accent.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _gstPct,
                      min: 0, max: 50, divisions: 100,
                      onChanged: (v) => setState(() => _gstPct = v),
                    ),
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            // ── Results card ──
            _resultsCard(t),
          ]),
        );
      },
    );
  }

  Widget _modeToggle(AppTheme t) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(children: [
        Expanded(child: _modeBtn('Exclusive', !_inclusive, t,
                () => setState(() => _inclusive = false))),
        Expanded(child: _modeBtn('Inclusive', _inclusive, t,
                () => setState(() => _inclusive = true))),
      ]),
    );
  }

  Widget _modeBtn(String label, bool on, AppTheme t, VoidCallback fn) {
    return GestureDetector(
      onTap: fn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: on ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: on ? [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.35),
              blurRadius: 10, spreadRadius: 1,
            )
          ] : [],
        ),
        child: Column(children: [
          Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: on ? Colors.white : t.textSec,
          )),
          Text(
            on && !_inclusive ? '(Amount + GST)' : (on ? '(GST included)' : ''),
            style: TextStyle(
              fontSize: 9, color: on ? Colors.white70 : Colors.transparent,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionCard(AppTheme t, String title, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withOpacity(0.1),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.3, color: AppTheme.accent)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _resultsCard(AppTheme t) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(t.isDark ? 0.20 : 0.10),
            AppTheme.accentAlt.withOpacity(t.isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.15),
            blurRadius: 20, spreadRadius: 2,
          ),
        ],
      ),
      child: Column(children: [
        _resultRow(t, 'Base Amount', '₹${_f(_baseAmount)}', false),
        Divider(color: t.border, height: 20),
        _resultRow(t, 'GST (${_gstPct.toStringAsFixed(1)}%)',
            '₹${_f(_gstAmount)}', false),
        Divider(color: t.border, height: 20),
        _resultRow(t, 'Total Amount', '₹${_f(_totalAmount)}', true),
      ]),
    );
  }

  Widget _resultRow(AppTheme t, String label, String val, bool highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: highlight ? 15 : 13,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
          color: highlight ? t.textPri : t.textSec,
        )),
        Text(val, style: TextStyle(
          fontSize: highlight ? 22 : 15,
          fontWeight: FontWeight.w700,
          color: highlight ? AppTheme.accent : t.textPri,
        )),
      ],
    );
  }

  Widget _styledInput(AppTheme t, TextEditingController ctrl,
      String hint, {String? suffix, void Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(color: t.textPri, fontSize: 18, fontWeight: FontWeight.w300),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: t.textSec.withOpacity(0.5), fontSize: 16),
        suffixText: suffix,
        suffixStyle: TextStyle(color: t.textSec, fontSize: 16),
        filled: true,
        fillColor: t.glass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── UNIT CONVERTER SCREEN ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});
  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  // Categories and their units
  static const _categories = ['Length', 'Weight', 'Temperature'];
  static const _units = {
    'Length':      ['Meter', 'Kilometer', 'Centimeter', 'Inch', 'Feet', 'Mile'],
    'Weight':      ['Kilogram', 'Gram', 'Pound', 'Ounce'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  // Conversion factors TO base unit (Meter for length, Kilogram for weight)
  static const _toBase = {
    // Length → Meter
    'Meter': 1.0, 'Kilometer': 1000.0, 'Centimeter': 0.01,
    'Inch': 0.0254, 'Feet': 0.3048, 'Mile': 1609.344,
    // Weight → Kilogram
    'Kilogram': 1.0, 'Gram': 0.001, 'Pound': 0.453592, 'Ounce': 0.0283495,
  };

  int _catIndex = 0;
  String get _cat => _categories[_catIndex];
  List<String> get _unitList => _units[_cat]!;

  String _fromUnit = 'Meter';
  String _toUnit   = 'Centimeter';
  final _inputCtrl = TextEditingController();

  bool get _isDark => themeNotifier.value == ThemeMode.dark;
  AppTheme get th  => AppTheme(_isDark);

  double get _inputVal => double.tryParse(_inputCtrl.text) ?? 0;

  double _convert(double val, String from, String to) {
    if (_cat == 'Temperature') return _convertTemp(val, from, to);
    final base = val * (_toBase[from] ?? 1.0);
    return base / (_toBase[to] ?? 1.0);
  }

  double _convertTemp(double v, String from, String to) {
    // Convert to Celsius first
    double c;
    switch (from) {
      case 'Celsius':    c = v; break;
      case 'Fahrenheit': c = (v - 32) * 5 / 9; break;
      case 'Kelvin':     c = v - 273.15; break;
      default:           c = v; break;
    }
    switch (to) {
      case 'Celsius':    return c;
      case 'Fahrenheit': return c * 9 / 5 + 32;
      case 'Kelvin':     return c + 273.15;
      default:           return c;
    }
  }

  String _fmt(double v) {
    if (v.abs() > 1e9 || (v.abs() < 1e-4 && v != 0)) {
      return v.toStringAsExponential(4);
    }
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _onCatChange(int i) {
    setState(() {
      _catIndex = i;
      _fromUnit = _units[_categories[i]]!.first;
      _toUnit   = _units[_categories[i]]![1];
      _inputCtrl.clear();
    });
  }

  void _swap() {
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
    });
  }

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, __, ___) {
        final t = th;
        final result = _convert(_inputVal, _fromUnit, _toUnit);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Category selector ──
            _catSelector(t),
            const SizedBox(height: 16),
            // ── From unit + input ──
            _unitInputCard(t, 'From', _fromUnit, _inputCtrl,
                isResult: false,
                onUnitChanged: (u) => setState(() => _fromUnit = u!)),
            // ── Swap button ──
            Center(
              child: GestureDetector(
                onTap: _swap,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.4),
                        blurRadius: 12, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_vert_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            // ── To unit + result ──
            _unitResultCard(t, 'To', _toUnit, _fmt(result),
                onUnitChanged: (u) => setState(() => _toUnit = u!)),
            const SizedBox(height: 16),
            // ── Quick reference table ──
            _quickRefTable(t),
          ]),
        );
      },
    );
  }

  Widget _catSelector(AppTheme t) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(children: List.generate(_categories.length, (i) {
        final on = i == _catIndex;
        return Expanded(child: GestureDetector(
          onTap: () => _onCatChange(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: on ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: on ? [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.35),
                  blurRadius: 10,
                )
              ] : [],
            ),
            child: Center(child: Text(_categories[i], style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: on ? Colors.white : t.textSec,
            ))),
          ),
        ));
      })),
    );
  }

  Widget _unitInputCard(AppTheme t, String label, String currentUnit,
      TextEditingController ctrl,
      {required bool isResult,
        required void Function(String?) onUnitChanged}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(color: t.shadow.withOpacity(0.1),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.3, color: AppTheme.accent)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _unitDropdown(t, currentUnit, onUnitChanged)),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: t.textPri, fontSize: 18, fontWeight: FontWeight.w300),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: t.textSec.withOpacity(0.4)),
              filled: true, fillColor: t.glass,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: t.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: t.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _unitResultCard(AppTheme t, String label, String currentUnit,
      String result, {required void Function(String?) onUnitChanged}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(t.isDark ? 0.18 : 0.08),
            AppTheme.accentAlt.withOpacity(t.isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(color: AppTheme.accent.withOpacity(0.12),
              blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.3, color: AppTheme.accent)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _unitDropdown(t, currentUnit, onUnitChanged)),
          const SizedBox(width: 10),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent.withOpacity(0.30)),
            ),
            child: Text(result, style: TextStyle(
              color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.w600,
            )),
          )),
        ]),
      ]),
    );
  }

  Widget _unitDropdown(AppTheme t, String val, void Function(String?) fn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: DropdownButton<String>(
        value: val,
        items: _unitList.map((u) => DropdownMenuItem(
          value: u,
          child: Text(u, style: TextStyle(fontSize: 12, color: t.textPri)),
        )).toList(),
        onChanged: fn,
        dropdownColor: t.surface,
        underline: const SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.expand_more_rounded, color: t.textSec, size: 16),
        style: TextStyle(fontSize: 12, color: t.textPri),
      ),
    );
  }

  Widget _quickRefTable(AppTheme t) {
    // Show common conversions for the current category
    final entries = <Map<String, String>>[];
    final base = _unitList.first;
    for (final u in _unitList.skip(1)) {
      final v = _convert(1, base, u);
      entries.add({'from': '1 $base', 'to': '${_fmt(v)} $u'});
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUICK REFERENCE', style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.3,
            color: AppTheme.accent)),
        const SizedBox(height: 10),
        ...entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e['from']!, style: TextStyle(fontSize: 12, color: t.textSec)),
              Icon(Icons.arrow_forward_rounded, size: 12, color: t.border),
              Text(e['to']!, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: t.textPri)),
            ],
          ),
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── CURRENCY CONVERTER SCREEN ────────────────────────────────────════════════
// ═══════════════════════════════════════════════════════════════════════════════
/// Uses static rates by default. To add live API support, replace the
/// [_fetchRates] method with a real HTTP call that returns Map<String, double>.
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  // Static exchange rates relative to USD (1 USD = X of currency)
  // Easy to replace with API: just update this map from a response.
  static const Map<String, double> _ratesFromUSD = {
    'USD': 1.0,
    'INR': 93.73,
    'EUR': 0.85,
    'GBP': 0.74,
    'JPY': 156.4,
    'AUD': 1.48,
    'CAD': 1.37,
    'CHF': 0.79,
    'CNY': 7.20,
    'SGD': 1.35,
    'AED': 3.67,
    'SAR': 3.75,
  };

  static const Map<String, String> _flags = {
    'USD': '🇺🇸', 'INR': '🇮🇳', 'EUR': '🇪🇺', 'GBP': '🇬🇧',
    'JPY': '🇯🇵', 'AUD': '🇦🇺', 'CAD': '🇨🇦', 'CHF': '🇨🇭',
    'CNY': '🇨🇳', 'SGD': '🇸🇬', 'AED': '🇦🇪', 'SAR': '🇸🇦',
  };

  String _from  = 'USD';
  String _to    = 'INR';
  final _inputCtrl = TextEditingController();
  bool _useApi  = false; // Future: toggle for live rates

  bool get _isDark => themeNotifier.value == ThemeMode.dark;
  AppTheme get th  => AppTheme(_isDark);

  List<String> get _currencies => _ratesFromUSD.keys.toList();

  double get _inputVal => double.tryParse(_inputCtrl.text) ?? 0;

  /// Convert via USD as intermediate base.
  double _convert(double amount, String from, String to) {
    final inUSD = amount / (_ratesFromUSD[from] ?? 1.0);
    return inUSD * (_ratesFromUSD[to] ?? 1.0);
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _swap() => setState(() {
    final tmp = _from; _from = _to; _to = tmp;
  });

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, __, ___) {
        final t = th;
        final result = _convert(_inputVal, _from, _to);
        final rate   = _convert(1, _from, _to);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Header info ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: t.glass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.border),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 13, color: t.textSec),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  'Static rates · Last updated: Apr 2025',
                  style: TextStyle(fontSize: 11, color: t.textSec),
                )),
              ]),
            ),
            const SizedBox(height: 14),
            // ── From card ──
            _currencyCard(t, 'From', _from, _inputCtrl,
                isInput: true,
                onCurrencyChanged: (c) => setState(() => _from = c!)),
            // ── Swap + rate ──
            Center(child: Column(children: [
              GestureDetector(
                onTap: _swap,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.4),
                        blurRadius: 14, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_vert_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: t.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border),
                ),
                child: Text(
                  '1 $_from = ${_fmt(rate)} $_to',
                  style: TextStyle(fontSize: 12, color: t.textSec,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ])),
            // ── To card ──
            _currencyResultCard(t, 'To', _to, _fmt(result),
                onCurrencyChanged: (c) => setState(() => _to = c!)),
            const SizedBox(height: 16),
            // ── All currencies grid ──
            _allRatesGrid(t),
          ]),
        );
      },
    );
  }

  Widget _currencyCard(AppTheme t, String label, String currency,
      TextEditingController ctrl,
      {required bool isInput, required void Function(String?) onCurrencyChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(color: t.shadow.withOpacity(0.10),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.3, color: AppTheme.accent)),
        const SizedBox(height: 12),
        Row(children: [
          // Flag + currency picker
          Expanded(child: _currencyDropdown(t, currency, onCurrencyChanged)),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: t.textPri, fontSize: 20, fontWeight: FontWeight.w300),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(color: t.textSec.withOpacity(0.4), fontSize: 18),
              filled: true, fillColor: t.glass,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          )),
        ]),
      ]),
    );
  }

  Widget _currencyResultCard(AppTheme t, String label, String currency,
      String result, {required void Function(String?) onCurrencyChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(t.isDark ? 0.18 : 0.08),
            AppTheme.accentAlt.withOpacity(t.isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(color: AppTheme.accent.withOpacity(0.12),
              blurRadius: 14, spreadRadius: 1),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.3, color: AppTheme.accent)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _currencyDropdown(t, currency, onCurrencyChanged)),
          const SizedBox(width: 12),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent.withOpacity(0.30)),
            ),
            child: Text(result, style: const TextStyle(
              color: AppTheme.accent, fontSize: 20, fontWeight: FontWeight.w600,
            )),
          )),
        ]),
      ]),
    );
  }

  Widget _currencyDropdown(AppTheme t, String val, void Function(String?) fn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: DropdownButton<String>(
        value: val,
        items: _currencies.map((c) => DropdownMenuItem(
          value: c,
          child: Row(children: [
            Text(_flags[c] ?? '🏳️', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(c, style: TextStyle(fontSize: 12, color: t.textPri,
                fontWeight: FontWeight.w600)),
          ]),
        )).toList(),
        onChanged: fn,
        dropdownColor: t.surface,
        underline: const SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.expand_more_rounded, color: t.textSec, size: 16),
      ),
    );
  }

  Widget _allRatesGrid(AppTheme t) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ALL RATES vs $_from', style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.3,
            color: AppTheme.accent)),
        const SizedBox(height: 10),
        ..._currencies.where((c) => c != _from).map((c) {
          final rate = _convert(1, _from, c);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _to == c ? AppTheme.accent.withOpacity(0.10) : t.glass,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _to == c ? AppTheme.accent.withOpacity(0.40) : t.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(_flags[c] ?? '🏳️', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(c, style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: t.textPri)),
                ]),
                Text(_fmt(rate), style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: _to == c ? AppTheme.accent : t.textSec,
                )),
              ],
            ),
          );
        }),
      ]),
    );
  }
}