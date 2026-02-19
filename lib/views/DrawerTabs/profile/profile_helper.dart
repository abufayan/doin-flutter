import 'package:intl/intl.dart';

String mapIncomeRangeToBackend(String value) {
  switch (value) {
    case 'UNDER_20K':
      return '\$0 - \$20,000';
    case '20K_50K':
      return '\$20,000 - \$50,000';
    case '50K_100K':
      return '\$50,000 - \$100,000';
    case '100K_200K':
      return '\$100,000 - \$200,000';
    case 'MORE_THAN_200K':
      return 'More than \$200,000';
    default:
      return value;
  }
}

String formatReferral(String? value) {
  if (value == null || value.isEmpty) return '';
  return value.padLeft(3, '0');
}

String? cleanDropdownValue(String? value) {
  if (value == null) return null;

  return value
      .replaceAll('"', '') // remove quotes
      .replaceAll(',', '') // remove commas
      .trim()
      .isEmpty
      ? null
      : value
      .replaceAll('"', '')
      .replaceAll(',', '')
      .trim();
}


const tradingExperienceOptions = [
  'Yes, I have less than 1 year of trading experience',
  'Yes, I have 1+ years of trading experience',
  'Yes, I have 2+ years of trading experience',
  'Yes, I have 4+ years of trading experience',
  'No, I have no trading experience',
];

String? normalizeTradingExperience(String? value) {
  if (value == null) return null;

  final cleaned = value
      .replaceAll('"', '')
      .replaceAll(RegExp(r',+'), ',')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return tradingExperienceOptions.contains(cleaned) ? cleaned : null;
}


const incomeRanges = {
  'UNDER_20K': '\$0 - \$20,000',
  '20K_50K': '\$20,000 - \$50,000',
  '50K_100K': '\$50,000 - \$100,000',
  '100K_200K': '\$100,000 - \$200,000',
  'MORE_THAN_200K': 'More than \$200,000',
};

String? normalizeIncomeRangeForUI(String? value) {
  if (value == null) return null;

  final v = value.replaceAll(',', '').replaceAll(' ', '');

  if (v.contains('Morethan\$200000')) return 'More than \$200,000';
  if (v.contains('\$100000-\$200000')) return '\$100,000 - \$200,000';
  if (v.contains('\$50000-\$100000')) return '\$50,000 - \$100,000';
  if (v.contains('\$20000-\$50000')) return '\$20,000 - \$50,000';
  if (v.contains('\$0-\$20000')) return '\$0 - \$20,000';

  return null;
}


String? mapIncomeRangeFromBackend(String? value) {
  if (value == null) return null;

  final v = value.replaceAll(',', '').toLowerCase();

  if (v.contains('more than') && v.contains('200')) return 'MORE_THAN_200K';
  if (v.contains('100000') && v.contains('200000')) return '100K_200K';
  if (v.contains('50000') && v.contains('100000')) return '50K_100K';
  if (v.contains('20000') && v.contains('50000')) return '20K_50K';
  if (v.contains('0') && v.contains('20000')) return 'UNDER_20K';

  return null;
}

DateTime? parseDateOfBirth(String? dob) {
  if (dob == null || dob.isEmpty) return null;

  // Try ISO first: yyyy-MM-dd
  try {
    return DateFormat('yyyy-MM-dd').parseStrict(dob);
  } catch (_) {}

  // Fallback: dd/MM/yyyy
  try {
    return DateFormat('dd/MM/yyyy').parseStrict(dob);
  } catch (_) {}

  return null; // unknown format
}