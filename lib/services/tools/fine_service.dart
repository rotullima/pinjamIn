import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/fine_model.dart';
import '../admin/activity_log_service.dart';
import '../../models/activity_log_model.dart';
import '../auth/user_session.dart';

class FineService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _logService = ActivityLogService();

  Future<List<FineModel>> fetchFines() async {
    final res = await _supabase
        .from('damage_fines')
        .select()
        .eq('is_active', true)
        .order('created_at');
    return (res as List).map((e) => FineModel.fromJson(e)).toList();
  }

  Future<FineModel> createFine(String condition, double fineAmount) async {
    final res = await _supabase
        .from('damage_fines')
        .insert({'condition': condition, 'fine_amount': fineAmount})
        .select()
        .single();
    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.create,
      entity: EntityEnum.fine,
      entityId: res['fine_id'],
      newValue: '$condition - $fineAmount',
    );
    return FineModel.fromJson(res);
  }

  Future<FineModel> updateFine({
    required int fineId,
    required String condition,
    required double fineAmount,
  }) async {
    final oldRes = await _supabase
        .from('damage_fines')
        .select('condition, fine_amount')
        .eq('fine_id', fineId)
        .single();
    final oldAmount = (oldRes['fine_amount'] as num).toDouble();

    final res = await _supabase
        .from('damage_fines')
        .update({'condition': condition, 'fine_amount': fineAmount})
        .eq('fine_id', fineId)
        .select()
        .single();

    // log
    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.edit,
      entity: EntityEnum.fine,
      entityId: fineId,
      fieldName: 'fine_amount',
      oldValue: '$oldAmount',
      newValue: '$fineAmount',
    );

    return FineModel.fromJson(res);
  }

  Future<void> deleteFine(int fineId) async {
    await _supabase
        .from('damage_fines')
        .update({'is_active': false})
        .eq('fine_id', fineId);
    await _logService.createActivityLog(
      userId: UserSession.id,
      action: ActionEnum.delete,
      entity: EntityEnum.category,
      entityId: fineId,
      newValue: 'Fine deleted',
    );
  }
}
