import 'package:financial_ai_advisor/core/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  String espaces(String s) => s.replaceAll(' ', ' ');

  test('nombres au format français', () {
    expect(espaces(Format.nombre(12500)), '12 500');
    expect(Format.nombre(null), '—');
    expect(espaces(Format.nombre(2.5, decimales: 2)), '2,50');
  });

  test('pourcentages et écarts signés', () {
    expect(espaces(Format.pourcentage(1.234)), '+1,23 %');
    expect(espaces(Format.pourcentage(-0.5)), '−0,50 %');
    expect(Format.pourcentage(0), '0,00 %');
    expect(espaces(Format.signe(-1500)), '−1 500');
  });

  test('dates longues et courtes', () {
    expect(Format.date('2026-03-12'), '12 mars 2026');
    expect(Format.dateCourte('2026-03-12T00:00:00'), '12 mars');
    expect(Format.date(null), '—');
  });

  test('saisie souple des montants', () {
    expect(Format.lireNombre('1 500,5'), 1500.5);
    expect(Format.lireNombre('abc'), isNull);
  });
}
