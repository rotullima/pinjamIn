import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/tool_model.dart';

class ToolService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ToolModel>> fetchTools() async {
    final res = await _supabase
        .from('items')
        .select('''
      item_id,
      name,
      description,
      image_item,
      stock_total,
      stock_available,
      status_item,
      is_active,
      categories (
        category_id,
        name
      )
    ''')
        .eq('is_active', true);

    return (res as List).map((e) => ToolModel.fromMap(e)).toList();
  }

  Future<void> createTool({
    required String name,
    required int categoryId,
    String? description,
    String? imagePath,
    required int stock,
    required String statusItem,
  }) async {
    await _supabase.from('items').insert({
      'name': name,
      'category_id': categoryId,
      'description': description,
      'image_item': imagePath,
      'stock_total': stock,
      'stock_available': stock,
      'status_item': statusItem,
      'is_active': true,
    });
  }

  Future<void> updateTool({
    required int itemId,
    required String name,
    required int categoryId,
    String? description,
    String? imagePath,
    required int stockAvailable,
    required String statusItem,
  }) async {
    await _supabase
        .from('items')
        .update({
          'name': name,
          'category_id': categoryId,
          'description': description,
          'image_item': imagePath,
          'stock_available': stockAvailable,
          'status_item': statusItem,
        })
        .eq('item_id', itemId);
  }

  Future<void> softDeleteTool(int itemId) async {
    await _supabase
        .from('items')
        .update({'is_active': false})
        .eq('item_id', itemId);
  }
}
