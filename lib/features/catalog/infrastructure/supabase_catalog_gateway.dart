import 'package:supabase_flutter/supabase_flutter.dart';

import 'catalog_gateway.dart';

class SupabaseCatalogGateway implements CatalogGateway {
  const SupabaseCatalogGateway(this._client);

  static const String gameSelection =
      'id,slug,name_ar,name_fr,reward_unit_code,reward_unit_name_ar,'
      'reward_unit_name_fr,is_active,sort_order';
  static const String offerSelection =
      'id,game_id,name_ar,name_fr,reward_quantity,sale_price_dzd,'
      'is_published,sort_order';

  final SupabaseClient _client;

  @override
  Future<List<Map<String, Object?>>> fetchActiveGames() async {
    final rows = await _client
        .from('games')
        .select(gameSelection)
        .eq('is_active', true)
        .order('sort_order')
        .order('id');
    return _normalizeRows(rows);
  }

  @override
  Future<List<Map<String, Object?>>> fetchPublishedOffers(
    String gameId,
  ) async {
    final rows = await _client
        .from('public_offers')
        .select(offerSelection)
        .eq('game_id', gameId)
        .eq('is_published', true)
        .order('sort_order')
        .order('id');
    return _normalizeRows(rows);
  }
}

List<Map<String, Object?>> _normalizeRows(Object? response) {
  if (response is! List) {
    throw const FormatException('Catalog response must be a list.');
  }
  return List<Map<String, Object?>>.unmodifiable(
    response.map((row) {
      if (row is! Map) {
        throw const FormatException('Catalog row must be an object.');
      }
      final normalized = <String, Object?>{};
      for (final entry in row.entries) {
        if (entry.key is! String) {
          throw const FormatException('Catalog field names must be strings.');
        }
        normalized[entry.key as String] = entry.value;
      }
      return Map<String, Object?>.unmodifiable(normalized);
    }),
  );
}
