import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/category_model.dart';
import '../admin/activity_log_service.dart';
import '../../models/activity_log_model.dart';
import '../auth/user_session.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logService = ActivityLogService();

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

    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.create,
      entity: EntityEnum.category,
      entityId: res['category_id'],
      newValue: name,
    );

    return CategoryModel.fromMap(res);
  }

  Future<CategoryModel> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    final oldRes = await _supabase
        .from('categories')
        .select('name')
        .eq('category_id', categoryId)
        .single();
    final oldName = oldRes['name'] as String;

    final res = await _supabase
        .from('categories')
        .update({'name': name})
        .eq('category_id', categoryId)
        .select('category_id, name, items(item_id)')
        .single();

    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.edit,
      entity: EntityEnum.category,
      entityId: res['category_id'],
      fieldName: 'name',
      oldValue: oldName,
      newValue: name,
    );

    return CategoryModel.fromMap(res);
  }

  Future<void> softDeleteCategory(int categoryId) async {
    await _supabase
        .from('categories')
        .update({'is_active': false})
        .eq('category_id', categoryId);

    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.delete,
      entity: EntityEnum.category,
      entityId: categoryId,
      newValue: 'Category deleted',
    );
  }
}
