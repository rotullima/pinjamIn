import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/tool_model.dart';

class ToolBorrowService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ToolModel>> fetchAvailableTools() async {
  final res = await _supabase
      .from('items')
      .select('''
        item_id,
        name,
        image_item,
        stock_available,
        status_item,
        is_active,
        categories (
          category_id,
          name,
          is_active
        )
      ''')
      .eq('is_active', true)
      .gte('stock_available', 1);

  print("Raw response dari Supabase:");
  print(res);   // ← lihat bentuk data aslinya

  // atau lebih detail:
  for (var row in res) {
    print("Row: $row");
    print("stock_available: ${row['stock_available']} (${row['stock_available'].runtimeType})");
    print("item_id: ${row['item_id']} (${row['item_id'].runtimeType})");
  }

  return (res as List)
      .where((e) =>
          e['categories'] != null &&
          e['categories']['is_active'] == true)
      .map((e) => ToolModel.fromMap(e))
      .toList();
}

}
