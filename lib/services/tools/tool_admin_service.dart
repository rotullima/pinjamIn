import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/tool_model.dart';
import '../admin/activity_log_service.dart';
import '../../models/activity_log_model.dart';
import '../auth/user_session.dart';

class ToolAdminService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logService = ActivityLogService();

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
  }) async {
    final insertRes = await _supabase
        .from('items')
        .insert({
          'name': name,
          'category_id': categoryId,
          'description': description,
          'image_item': imagePath,
          'stock_total': stock,
          'stock_available': stock,
          'is_active': true,
        })
        .select('item_id')
        .single();
    final int itemId = insertRes['item_id'];
    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.create,
      entity: EntityEnum.item,
      entityId: itemId,
      newValue: name,
    );
  }

  Future<void> updateTool({
    required int itemId,
    required String name,
    required int categoryId,
    String? description,
    String? imagePath,
    required int stockTotal,
  }) async {
    final old = await _supabase
        .from('items')
        .select('stock_total, stock_available, name')
        .eq('item_id', itemId)
        .single();

    final int oldTotal = old['stock_total'];
    final int oldAvailable = old['stock_available'];
    final String oldName = old['name'];

    final int delta = stockTotal - oldTotal;
    final int newAvailable = oldAvailable + delta;

    if (newAvailable < 0) {
      throw Exception('Stock available tidak boleh kurang dari 0');
    }

    if (newAvailable > stockTotal) {
      throw Exception('Stock available tidak boleh melebihi stock total');
    }

    await _supabase
        .from('items')
        .update({
          'name': name,
          'category_id': categoryId,
          'description': description,
          'image_item': imagePath,
          'stock_total': stockTotal,
          'stock_available': newAvailable,
        })
        .eq('item_id', itemId);

    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.edit,
      entity: EntityEnum.item,
      entityId: itemId,
      fieldName: 'name',
      oldValue: oldName,
      newValue: name,
    );
  }

  Future<void> addAvailableStock({
  required int itemId,
  required int amount,
}) async {
  if (amount <= 0) return;

  final item = await _supabase
      .from('items')
      .select('stock_total, stock_available')
      .eq('item_id', itemId)
      .single();

  final int total = item['stock_total'];
  final int available = item['stock_available'];

  final int newAvailable = available + amount;

  if (newAvailable > total) {
    throw Exception('Stock available tidak boleh melebihi stock total');
  }

  await _supabase
      .from('items')
      .update({'stock_available': newAvailable})
      .eq('item_id', itemId);

  await _logService.createActivityLog(
    userId: UserSession.id,
    action: ActionEnum.edit,
    entity: EntityEnum.item,
    entityId: itemId,
    fieldName: 'stock_available',
    oldValue: available.toString(),
    newValue: newAvailable.toString(),
  );
}


  Future<void> softDeleteTool(int itemId) async {
    await _supabase
        .from('items')
        .update({'is_active': false})
        .eq('item_id', itemId);
    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.delete,
      entity: EntityEnum.item,
      entityId: itemId,
      newValue: 'Item deleted',
    );
  }
}
