import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> fetchCategories() async {
    final res = await _supabase
        .from('categories')
        .select('''
        category_id,
        name,
        items (
          item_id
        )
      ''')
        .eq('is_active', true)
        .order('created_at');

    return (res as List).map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<CategoryModel> createCategory(String name) async {
    final res = await _supabase
        .from('categories')
        .insert({'name': name})
        .select('''
          category_id,
          name,
          items ( item_id )
        ''')
        .single();

    return CategoryModel.fromMap(res);
  }

  Future<CategoryModel> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    final res = await _supabase
        .from('categories')
        .update({'name': name})
        .eq('category_id', categoryId)
        .select('''
          category_id,
          name,
          items ( item_id )
        ''')
        .single();

    return CategoryModel.fromMap(res);
  }

  Future<void> softDeleteCategory(int categoryId) async {
    await _supabase
        .from('categories')
        .update({'is_active': false})
        .eq('category_id', categoryId);
  }
}
