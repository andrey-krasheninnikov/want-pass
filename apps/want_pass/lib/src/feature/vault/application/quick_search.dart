import 'package:want_pass_core/want_pass_core.dart';

List<CardSummaryV1> rankQuickCards(
  Iterable<CardSummaryV1> matches,
  String query,
  Map<Object?, Object?> usage,
) {
  final needle = query.trim().toLowerCase();
  int relevance(String name) {
    if (needle.isEmpty) return 0;
    final lower = name.toLowerCase();
    if (lower == needle) return 0;
    if (lower.startsWith(needle)) return 1;
    if (lower.contains(needle)) return 2;
    return 3;
  }

  (int, int) score(String id) {
    final value = usage[id];
    return value is List &&
            value.length == 2 &&
            value[0] is int &&
            value[1] is int
        ? (value[0] as int, value[1] as int)
        : (0, 0);
  }

  final cards = matches.toList()
    ..sort((a, b) {
      int comparison = relevance(a.name).compareTo(relevance(b.name));
      if (comparison != 0) return comparison;
      final first = score(a.id), second = score(b.id);
      comparison = second.$1.compareTo(first.$1);
      if (comparison != 0) return comparison;
      comparison = second.$2.compareTo(first.$2);
      if (comparison != 0) return comparison;
      comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return comparison != 0 ? comparison : a.id.compareTo(b.id);
    });
  return List.unmodifiable(cards.take(5));
}
