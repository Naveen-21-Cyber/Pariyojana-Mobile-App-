import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';

// ────────────────────────────────────────────────────────────────────────────
// Country tax calculation engine — Real-World Financial Rules & Slabs
// ────────────────────────────────────────────────────────────────────────────

enum CountryCode { india, usa, uk, singapore, uae, canada, germany, australia }

class BreakdownLine {
  final String label;
  final double amount;
  final bool isNegative;
  final bool isSection;
  final bool isHighlight;
  const BreakdownLine(
    this.label,
    this.amount, {
    this.isNegative = false,
    this.isSection = false,
    this.isHighlight = false,
  });
}

class TaxResult {
  final double grossAnnual;
  final double netAnnual;
  final double netMonthly;
  final double totalTax;
  final double totalPf;
  final double effectiveTaxRate;
  final String currency;
  final List<BreakdownLine> lines;

  const TaxResult({
    required this.grossAnnual,
    required this.netAnnual,
    required this.netMonthly,
    required this.totalTax,
    required this.totalPf,
    required this.effectiveTaxRate,
    required this.currency,
    required this.lines,
  });
}

class TaxEngine {
  static TaxResult calculate(
    CountryCode country,
    double input, {
    double basicPct = 0.40,
    double hraPct = 0.50,
    bool includeFoodAllowance = true,
    double taxModifierPct = 0.0,
    double customPfRatePct = 0.0,
  }) {
    TaxResult res;
    switch (country) {
      case CountryCode.india:
        res = _india(
          input,
          basicPct: basicPct,
          hraPct: hraPct,
          includeFoodAllowance: includeFoodAllowance,
        );
        break;
      case CountryCode.usa:
        res = _usa(input);
        break;
      case CountryCode.uk:
        res = _uk(input);
        break;
      case CountryCode.singapore:
        res = _singapore(input);
        break;
      case CountryCode.uae:
        res = _uae(input);
        break;
      case CountryCode.canada:
        res = _canada(input);
        break;
      case CountryCode.germany:
        res = _germany(input);
        break;
      case CountryCode.australia:
        res = _australia(input);
        break;
    }

    if (taxModifierPct == 0.0 && customPfRatePct == 0.0) {
      return res;
    }

    final taxShift = res.grossAnnual * (taxModifierPct / 100);
    final pfShift = res.grossAnnual * (customPfRatePct / 100);
    final newNet = (res.netAnnual - taxShift - pfShift).clamp(0.0, double.infinity);
    final newTax = (res.totalTax + taxShift).clamp(0.0, double.infinity);
    final newEffectiveRate = res.grossAnnual > 0 ? (newTax / res.grossAnnual) * 100 : 0.0;

    final modifiedLines = List<BreakdownLine>.from(res.lines);
    if (taxModifierPct != 0.0) {
      modifiedLines.add(BreakdownLine(
        'Custom Tax Shift (${taxModifierPct >= 0 ? "+" : ""}${taxModifierPct.toStringAsFixed(1)}%)',
        -taxShift,
        isNegative: taxShift > 0,
      ));
    }
    if (customPfRatePct > 0.0) {
      modifiedLines.add(BreakdownLine(
        'Custom Savings Shift (${customPfRatePct.toStringAsFixed(1)}%)',
        -pfShift,
        isNegative: true,
      ));
    }
    modifiedLines.add(BreakdownLine('Adjusted Net In-Hand', newNet, isHighlight: true));

    return TaxResult(
      grossAnnual: res.grossAnnual,
      netAnnual: newNet,
      netMonthly: newNet / 12,
      totalTax: newTax,
      totalPf: res.totalPf + pfShift,
      effectiveTaxRate: newEffectiveRate,
      currency: res.currency,
      lines: modifiedLines,
    );
  }

  // ── INDIA — FY 2024-25 / FY 2025-26 (Budget 2024 Revised - Section 115BAC) ──
  // New Regime: Standard Deduction ₹75,000, 100% Tax Rebate u/s 87A up to ₹7,00,000 (Tax = 0)
  static TaxResult _india(
    double lpa, {
    double basicPct = 0.40,
    double hraPct = 0.50,
    bool includeFoodAllowance = true,
  }) {
    final ctc = lpa * 100000;
    final basic = ctc * basicPct.clamp(0.30, 0.60);
    final hra = basic * hraPct.clamp(0.0, 0.50);
    final food = includeFoodAllowance ? 26400.0 : 0.0; // ₹2,200/mo tax-exempt
    final employerPf = basic * 0.12;
    final employeePf = basic * 0.12;
    final special = (ctc - basic - hra - food - employerPf).clamp(0.0, double.infinity);
    const pt = 2400.0; // Professional Tax ~₹200/mo

    // Gross In-Hand (excluding Employer PF which is in EPFO corpus)
    final grossInHand = basic + hra + special + food;

    const standardDeduction = 75000.0; // Union Budget revised standard deduction
    final taxableIncome = (grossInHand - standardDeduction).clamp(0.0, double.infinity);
    final incomeTax = _indiaNewRegimeTax(taxableIncome);

    final cess = incomeTax * 0.04;
    final totalTax = incomeTax + cess;
    final totalDeductions = employeePf + totalTax + pt;
    final netAnnual = (grossInHand - totalDeductions).clamp(0.0, double.infinity);

    final effectiveTaxRate = ctc > 0 ? (totalTax / ctc) * 100 : 0.0;

    final lines = <BreakdownLine>[
      BreakdownLine('CTC (Cost to Company)', ctc),
      BreakdownLine('Employer PF (12% of Basic)', -employerPf, isNegative: true),
      const BreakdownLine('─── Gross Earnings ───', 0, isSection: true),
      BreakdownLine('Basic Salary (${(basicPct * 100).toInt()}%)', basic),
      BreakdownLine('HRA (${(hraPct * 100).toInt()}% of Basic)', hra),
      BreakdownLine('Special Allowance', special),
      if (includeFoodAllowance) const BreakdownLine('Food Allowance (Tax-Exempt ₹2.2k/mo)', 26400.0),
      const BreakdownLine('─── Deductions & Tax ───', 0, isSection: true),
      const BreakdownLine('Standard Deduction (Sec 115BAC)', -standardDeduction, isNegative: true),
      BreakdownLine('Taxable Income', taxableIncome),
      BreakdownLine('Income Tax (New Slabs)', -incomeTax, isNegative: true),
      BreakdownLine('Health & Education Cess (4%)', -cess, isNegative: true),
      BreakdownLine('Employee PF (12% of Basic)', -employeePf, isNegative: true),
      const BreakdownLine('Professional Tax (PT)', -pt, isNegative: true),
      const BreakdownLine('─── In-Hand Take-Home ───', 0, isSection: true),
      BreakdownLine('Annual Net Take-Home', netAnnual, isHighlight: true),
      BreakdownLine('Monthly In-Hand Salary', netAnnual / 12, isHighlight: true),
    ];

    return TaxResult(
      grossAnnual: ctc,
      netAnnual: netAnnual,
      netMonthly: netAnnual / 12,
      totalTax: totalTax,
      totalPf: employeePf + employerPf,
      effectiveTaxRate: effectiveTaxRate,
      currency: '₹',
      lines: lines,
    );
  }

  /// New Tax Regime Slabs (Section 115BAC)
  static double _indiaNewRegimeTax(double taxable) {
    if (taxable <= 700000) return 0.0; // Section 87A 100% Rebate up to ₹7 Lakhs
    return _applySlabs(taxable, [
      (300000, 0.0),   // 0 to 3L: 0%
      (400000, 0.05),  // 3L to 7L: 5%
      (300000, 0.10),  // 7L to 10L: 10%
      (200000, 0.15),  // 10L to 12L: 15%
      (300000, 0.20),  // 12L to 15L: 20%
      (double.infinity, 0.30), // Above 15L: 30%
    ]);
  }

  /// Generic slab calculator: list of (bandWidth, rate) pairs
  static double _applySlabs(double taxable, List<(double, double)> slabs) {
    double tax = 0, rem = taxable;
    for (final (band, rate) in slabs) {
      if (rem <= 0) break;
      final chunk = rem > band ? band : rem;
      tax += chunk * rate;
      rem -= chunk;
    }
    return tax;
  }

  // ── USA — Federal 2024 (Single) + FICA ────────────────────────────────────
  static TaxResult _usa(double kSalary) {
    final gross = kSalary * 1000;
    const standardDed = 14600.0;
    final taxable = (gross - standardDed).clamp(0.0, double.infinity).toDouble();
    final fedTax = _usaFedSlab(taxable);
    final socialSecurity = (gross * 0.062).clamp(0.0, 10453.0);
    final medicare = gross * 0.0145 + (gross > 200000 ? (gross - 200000) * 0.009 : 0.0);
    final stateTax = gross * 0.055; // ~5.5% avg
    final totalTax = fedTax + stateTax;
    final totalDed = fedTax + socialSecurity + medicare + stateTax;
    final net = (gross - totalDed).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (totalTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: totalTax,
      totalPf: socialSecurity + medicare,
      effectiveTaxRate: effectiveRate,
      currency: '\$',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        const BreakdownLine('Standard Deduction (Single)', -standardDed, isNegative: true),
        BreakdownLine('Federal Taxable Income', taxable),
        const BreakdownLine('─── Deductions ───', 0.0, isSection: true),
        BreakdownLine('Federal Income Tax', -fedTax, isNegative: true),
        BreakdownLine('Social Security (6.2%)', -socialSecurity.toDouble(), isNegative: true),
        BreakdownLine('Medicare (1.45%)', -medicare, isNegative: true),
        BreakdownLine('Est. State Tax (~5.5% avg)', -stateTax, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _usaFedSlab(double taxable) {
    return _applySlabs(taxable, [
      (11600, 0.10),
      (35550, 0.12),
      (53550, 0.22),
      (76500, 0.24),
      (43050, 0.32),
      (289950, 0.35),
      (double.infinity, 0.37),
    ]);
  }

  // ── UK — PAYE 2024-25 ─────────────────────────────────────────────────────
  static TaxResult _uk(double kSalary) {
    final gross = kSalary * 1000;
    final personalAllowance = gross > 125140 ? 0.0 : 12570.0;
    final taxable = (gross - personalAllowance).clamp(0.0, double.infinity).toDouble();
    final incomeTax = _ukSlab(taxable);
    final ni = _ukNationalInsurance(gross);
    final totalDed = incomeTax + ni;
    final net = (gross - totalDed).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (incomeTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: incomeTax,
      totalPf: ni,
      effectiveTaxRate: effectiveRate,
      currency: '£',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        BreakdownLine('Personal Allowance', -personalAllowance, isNegative: true),
        BreakdownLine('Taxable Income', taxable),
        const BreakdownLine('─── Deductions ───', 0.0, isSection: true),
        BreakdownLine('Income Tax (PAYE)', -incomeTax, isNegative: true),
        BreakdownLine('National Insurance (Class 1)', -ni, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _ukSlab(double taxable) {
    return _applySlabs(taxable, [
      (37700, 0.20),
      (87440, 0.40),
      (double.infinity, 0.45),
    ]);
  }

  static double _ukNationalInsurance(double gross) {
    if (gross <= 12570) return 0.0;
    final rem = gross - 12570;
    if (rem <= 37700) return rem * 0.08;
    return (37700 * 0.08) + ((rem - 37700) * 0.02);
  }

  // ── SINGAPORE ─────────────────────────────────────────────────────────────
  static TaxResult _singapore(double kSalary) {
    final gross = kSalary * 1000;
    final incomeTax = _singaporeSlab(gross);
    final cpf = (gross * 0.20).clamp(0.0, 14400.0);
    final totalDed = incomeTax + cpf;
    final net = (gross - totalDed).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (incomeTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: incomeTax,
      totalPf: cpf,
      effectiveTaxRate: effectiveRate,
      currency: 'S\$',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        const BreakdownLine('─── Deductions ───', 0, isSection: true),
        BreakdownLine('Income Tax (IRAS)', -incomeTax, isNegative: true),
        BreakdownLine('Employee CPF (20% capped)', -cpf, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _singaporeSlab(double taxable) {
    return _applySlabs(taxable, [
      (20000, 0.0),
      (10000, 0.02),
      (10000, 0.035),
      (40000, 0.07),
      (40000, 0.115),
      (40000, 0.15),
      (40000, 0.18),
      (40000, 0.19),
      (40000, 0.195),
      (40000, 0.20),
      (80000, 0.22),
      (500000, 0.23),
      (double.infinity, 0.24),
    ]);
  }

  // ── UAE — 0% Personal Income Tax ──────────────────────────────────────────
  static TaxResult _uae(double kSalary) {
    final gross = kSalary * 1000;
    return TaxResult(
      grossAnnual: gross,
      netAnnual: gross,
      netMonthly: gross / 12,
      totalTax: 0.0,
      totalPf: 0.0,
      effectiveTaxRate: 0.0,
      currency: 'AED',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        const BreakdownLine('Personal Income Tax (0% UAE Rate)', 0.0),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home (100% Tax-Free)', gross, isHighlight: true),
      ],
    );
  }

  // ── CANADA — Federal + Ontario Combined ───────────────────────────────────
  static TaxResult _canada(double kSalary) {
    final gross = kSalary * 1000;
    final bpa = gross > 173205 ? 14156.0 : 15705.0;
    final taxable = (gross - bpa).clamp(0.0, double.infinity).toDouble();
    final fedTax = _canadaFedSlab(taxable);
    final provTax = _canadaOntarioSlab(taxable);
    final cpp = (gross * 0.0595).clamp(0.0, 3867.50);
    final ei = (gross * 0.0166).clamp(0.0, 1049.12);
    final totalTax = fedTax + provTax;
    final totalDed = totalTax + cpp + ei;
    final net = (gross - totalDed).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (totalTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: totalTax,
      totalPf: cpp + ei,
      effectiveTaxRate: effectiveRate,
      currency: 'CA\$',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        BreakdownLine('Basic Personal Amount (BPA)', -bpa, isNegative: true),
        BreakdownLine('Taxable Income', taxable),
        const BreakdownLine('─── Deductions ───', 0, isSection: true),
        BreakdownLine('Federal Income Tax', -fedTax, isNegative: true),
        BreakdownLine('Ontario Provincial Tax', -provTax, isNegative: true),
        BreakdownLine('CPP (Pension Plan)', -cpp, isNegative: true),
        BreakdownLine('EI (Employment Insurance)', -ei, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _canadaFedSlab(double taxable) {
    return _applySlabs(taxable, [
      (55867, 0.15),
      (55866, 0.205),
      (61472, 0.26),
      (73547, 0.29),
      (double.infinity, 0.33),
    ]);
  }

  static double _canadaOntarioSlab(double taxable) {
    return _applySlabs(taxable, [
      (51446, 0.0505),
      (51446, 0.0915),
      (47108, 0.1116),
      (70000, 0.1216),
      (double.infinity, 0.1316),
    ]);
  }

  // ── GERMANY ───────────────────────────────────────────────────────────────
  static TaxResult _germany(double kSalary) {
    final gross = kSalary * 1000;
    const basicAllowance = 11784.0;
    final taxable = (gross - basicAllowance).clamp(0.0, double.infinity).toDouble();
    final incomeTax = _germanyIncomeTax(gross);
    final pension = gross * 0.093;
    final health = gross * 0.073;
    final care = gross * 0.022;
    final unemployment = gross * 0.013;
    final totalSocial = pension + health + care + unemployment;
    final totalDed = incomeTax + totalSocial;
    final net = (gross - totalDed).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (incomeTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: incomeTax,
      totalPf: totalSocial,
      effectiveTaxRate: effectiveRate,
      currency: '€',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        const BreakdownLine('Grundfreibetrag (Basic Allowance)', -basicAllowance, isNegative: true),
        BreakdownLine('Taxable Income', taxable),
        const BreakdownLine('─── Deductions ───', 0, isSection: true),
        BreakdownLine('Lohnsteuer (Income Tax)', -incomeTax, isNegative: true),
        BreakdownLine('Rentenversicherung (Pension 9.3%)', -pension, isNegative: true),
        BreakdownLine('Krankenversicherung (Health 7.3%)', -health, isNegative: true),
        BreakdownLine('Pflegeversicherung (Care 2.2%)', -care, isNegative: true),
        BreakdownLine('Arbeitslosenversicherung (Unemployment 1.3%)', -unemployment, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _germanyIncomeTax(double gross) {
    if (gross <= 11784) return 0.0;
    final taxable = gross - 11784;
    if (taxable <= 50000) return taxable * 0.28;
    if (taxable <= 200000) return (50000 * 0.28) + ((taxable - 50000) * 0.42);
    return (50000 * 0.28) + (150000 * 0.42) + ((taxable - 200000) * 0.45);
  }

  // ── AUSTRALIA ─────────────────────────────────────────────────────────────
  static TaxResult _australia(double kSalary) {
    final gross = kSalary * 1000;
    final incomeTax = _australiaSlab(gross);
    final medicare = gross * 0.02;
    final totalTax = incomeTax + medicare;
    final net = (gross - totalTax).clamp(0.0, double.infinity);
    final effectiveRate = gross > 0 ? (totalTax / gross) * 100 : 0.0;

    return TaxResult(
      grossAnnual: gross,
      netAnnual: net,
      netMonthly: net / 12,
      totalTax: totalTax,
      totalPf: 0.0,
      effectiveTaxRate: effectiveRate,
      currency: 'A\$',
      lines: [
        BreakdownLine('Gross Annual Salary', gross),
        const BreakdownLine('─── Deductions ───', 0, isSection: true),
        BreakdownLine('Income Tax (ATO)', -incomeTax, isNegative: true),
        BreakdownLine('Medicare Levy (2%)', -medicare, isNegative: true),
        const BreakdownLine('─── Take-Home ───', 0, isSection: true),
        BreakdownLine('Annual Net Take-Home', net, isHighlight: true),
      ],
    );
  }

  static double _australiaSlab(double taxable) {
    return _applySlabs(taxable, [
      (18200, 0.0),
      (26800, 0.16),
      (90000, 0.30),
      (55000, 0.37),
      (double.infinity, 0.45),
    ]);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Modal Presentation
// ────────────────────────────────────────────────────────────────────────────

class LpaTaxCalculatorModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LpaTaxCalculatorSheet(),
    );
  }
}

class LpaTaxCalculatorSheet extends StatefulWidget {
  const LpaTaxCalculatorSheet({super.key});

  @override
  State<LpaTaxCalculatorSheet> createState() => _LpaTaxCalculatorSheetState();
}

class _LpaTaxCalculatorSheetState extends State<LpaTaxCalculatorSheet> {
  CountryCode _country = CountryCode.india;

  late TextEditingController _ctrl;
  TaxResult? _result;

  bool _showCustomEdit = false;
  bool _showFullBreakdown = false;

  // India Modifiers (New Regime - Sec 115BAC)
  double _basicPct = 0.40;
  double _hraPct = 0.50;
  bool _includeFoodAllowance = true;

  // Global modifiers
  double _taxModifierPct = 0.0;
  double _customPfRatePct = 0.0;

  static const Map<CountryCode, (String, String, String)> _countryMeta = {
    CountryCode.india: ('🇮🇳 India (New Regime)', '₹', 'LPA (e.g. 18.5)'),
    CountryCode.usa: ('🇺🇸 USA', '\$', '\$k (e.g. 120)'),
    CountryCode.uk: ('🇬🇧 UK', '£', '£k (e.g. 60)'),
    CountryCode.singapore: ('🇸🇬 Singapore', 'S\$', 'S\$k (e.g. 80)'),
    CountryCode.uae: ('🇦🇪 UAE', 'AED', 'AED k (e.g. 200)'),
    CountryCode.canada: ('🇨🇦 Canada', 'CA\$', 'CA\$k (e.g. 90)'),
    CountryCode.germany: ('🇩🇪 Germany', '€', '€k (e.g. 70)'),
    CountryCode.australia: ('🇦🇺 Australia', 'A\$', 'A\$k (e.g. 85)'),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '18.5');
    _calculate();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _resetToDefaults() {
    HapticFeedback.mediumImpact();
    setState(() {
      _basicPct = 0.40;
      _hraPct = 0.50;
      _includeFoodAllowance = true;
      _taxModifierPct = 0.0;
      _customPfRatePct = 0.0;
      _ctrl.text = _country == CountryCode.india ? '18.5' : '120';
    });
    _calculate();
  }

  void _calculate() {
    final raw = double.tryParse(_ctrl.text.trim()) ?? 0;
    setState(() => _result = TaxEngine.calculate(
      _country,
      raw,
      basicPct: _basicPct,
      hraPct: _hraPct,
      includeFoodAllowance: _includeFoodAllowance,
      taxModifierPct: _taxModifierPct,
      customPfRatePct: _customPfRatePct,
    ));
  }

  void _switchCountry(CountryCode c) {
    final defaults = {
      CountryCode.india: '18.5',
      CountryCode.usa: '120',
      CountryCode.uk: '60',
      CountryCode.singapore: '80',
      CountryCode.uae: '200',
      CountryCode.canada: '90',
      CountryCode.germany: '70',
      CountryCode.australia: '85',
    };
    setState(() {
      _country = c;
      _ctrl.text = defaults[c] ?? '50';
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _countryMeta[_country]!;
    final fmt = _country == CountryCode.india
        ? NumberFormat('#,##,###')
        : NumberFormat('#,###');

    String fmt_(double v) => '${meta.$2} ${fmt.format(v.abs().round())}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VelvetColors.surface(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: VelvetColors.border(context), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header drag handle & close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: VelvetColors.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: VelvetColors.iconColor(context), size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Title & Reset Button Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: VelvetColors.coralPeach, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Salary & Tax Calculator 🧮',
                        style: TextStyle(
                          fontFamily: GoogleFonts.outfit().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: VelvetColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        foregroundColor: VelvetColors.coralPeach,
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Reset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      onPressed: _resetToDefaults,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Text(
                  'Accurate country tax regimes, social contributions, and take-home breakdown.',
                  style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CountryCode.values.map((c) {
                      final m = _countryMeta[c]!;
                      final sel = c == _country;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            m.$1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: sel ? Colors.white : VelvetColors.textPrimary(context),
                            ),
                          ),
                          selected: sel,
                          selectedColor: VelvetColors.coralPeach,
                          backgroundColor: VelvetColors.cardSurface(context),
                          side: BorderSide(color: sel ? VelvetColors.coralPeach : VelvetColors.border(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onSelected: (_) => _switchCountry(c),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: VelvetColors.textPrimary(context)),
                        decoration: InputDecoration(
                          labelText: 'Gross Salary — ${meta.$3}',
                          labelStyle: TextStyle(color: VelvetColors.textSecondary(context), fontSize: 12),
                          prefixIcon: SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                meta.$2,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VelvetColors.coralPeach),
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: VelvetColors.cardSurface(context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: VelvetColors.border(context))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: VelvetColors.border(context))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: VelvetColors.coralPeach, width: 2)),
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_country == CountryCode.india) ...[
                      IconButton(
                        tooltip: 'Reset to Defaults 🔄',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: VelvetColors.coralPeach.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.refresh_rounded, size: 18, color: VelvetColors.coralPeach),
                        ),
                        onPressed: _resetToDefaults,
                      ),
                    ],
                    IconButton(
                      tooltip: 'Salary & Tax Modifiers ⚙️',
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _showCustomEdit
                              ? VelvetColors.coralPeach
                              : VelvetColors.cardSurface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showCustomEdit
                                ? VelvetColors.coralPeach
                                : VelvetColors.border(context),
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _showCustomEdit
                              ? Colors.white
                              : VelvetColors.iconColor(context),
                        ),
                      ),
                      onPressed: () => setState(() => _showCustomEdit = !_showCustomEdit),
                    ),
                  ],
                ),
              ),
              if (_showCustomEdit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⚙️ Salary Modifiers & Allowances',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: VelvetColors.textPrimary(context),
                              ),
                            ),
                            TextButton(
                              onPressed: _resetToDefaults,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Reset', style: TextStyle(fontSize: 11, color: VelvetColors.coralPeach, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Basic Salary:', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context))),
                            Text('${(_basicPct * 100).toInt()}% of CTC', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: VelvetColors.coralPeach)),
                          ],
                        ),
                        Slider(
                          value: _basicPct,
                          min: 0.30,
                          max: 0.60,
                          divisions: 6,
                          activeColor: VelvetColors.coralPeach,
                          inactiveColor: VelvetColors.border(context),
                          onChanged: (v) {
                            setState(() => _basicPct = v);
                            _calculate();
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('HRA Allowance:', style: TextStyle(fontSize: 11, color: VelvetColors.textSecondary(context))),
                            Text('${(_hraPct * 100).toInt()}% of Basic', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: VelvetColors.coralPeach)),
                          ],
                        ),
                        Slider(
                          value: _hraPct,
                          min: 0.0,
                          max: 0.50,
                          divisions: 5,
                          activeColor: VelvetColors.coralPeach,
                          inactiveColor: VelvetColors.border(context),
                          onChanged: (v) {
                            setState(() => _hraPct = v);
                            _calculate();
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            'Tax-Exempt Food Allowance',
                            style: TextStyle(fontSize: 11, color: VelvetColors.textPrimary(context)),
                          ),
                          activeTrackColor: VelvetColors.coralPeach,
                          activeThumbColor: Colors.white,
                          value: _includeFoodAllowance,
                          onChanged: (v) {
                            setState(() => _includeFoodAllowance = v);
                            _calculate();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              if (_result != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VelvetColors.coralPeach.withValues(alpha: 0.22),
                          VelvetColors.periwinkle.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: VelvetColors.coralPeach.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ESTIMATED MONTHLY IN-HAND',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: VelvetColors.textSecondary(context),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: VelvetColors.mint.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: VelvetColors.mint.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                'Tax: ${_result!.effectiveTaxRate.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: VelvetColors.mint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt_(_result!.netMonthly),
                          style: TextStyle(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: VelvetColors.coralPeach,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Annual Take-Home: ${fmt_(_result!.netAnnual)} / year',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VelvetColors.textPrimary(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Salary & Tax Breakdown',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: VelvetColors.textPrimary(context)),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: VelvetColors.coralPeach),
                        icon: Icon(_showFullBreakdown ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 16),
                        label: Text(_showFullBreakdown ? 'Hide Details' : 'View Slabs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => setState(() => _showFullBreakdown = !_showFullBreakdown),
                      ),
                    ],
                  ),
                ),
                if (_showFullBreakdown)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: ClayCard(
                      color: VelvetColors.cardSurface(context),
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        children: _result!.lines.map((l) {
                          if (l.isSection) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                l.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: VelvetColors.textSecondary(context),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    l.label,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: l.isHighlight ? FontWeight.bold : FontWeight.normal,
                                      color: l.isHighlight
                                          ? VelvetColors.coralPeach
                                          : VelvetColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${l.isNegative ? "-" : ""}${fmt_(l.amount)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: l.isHighlight ? FontWeight.bold : FontWeight.w600,
                                    color: l.isHighlight
                                        ? VelvetColors.coralPeach
                                        : l.isNegative
                                            ? Colors.redAccent
                                            : VelvetColors.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
