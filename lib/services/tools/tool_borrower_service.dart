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

  return (res as List)
      // filter category aktif DI SINI, bukan di JOIN
      .where((e) =>
          e['categories'] != null &&
          e['categories']['is_active'] == true)
      .map((e) => ToolModel.fromMap(e))
      .toList();
}

}
