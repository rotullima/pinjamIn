import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/tools/fine_model.dart';

class FineService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FineModel>> fetchFines() async {
    final res = await _supabase
        .from('damage_fines')
        .select()
        .order('created_at');
    return (res as List).map((e) => FineModel.fromJson(e)).toList();
  }

  Future<FineModel> createFine(String condition, double fineAmount) async {
    final res = await _supabase
        .from('damage_fines')
        .insert({'condition': condition, 'fine_amount': fineAmount})
        .select()
        .single();
    return FineModel.fromJson(res);
  }

  Future<FineModel> updateFine({
    required int fineId,
    required String condition,
    required double fineAmount,
  }) async {
    final res = await _supabase
        .from('damage_fines')
        .update({'condition': condition, 'fine_amount': fineAmount})
        .eq('fine_id', fineId)
        .select()
        .single();
    return FineModel.fromJson(res);
  }

  Future<void> deleteFine(int fineId) async {
    await _supabase.from('damage_fines').delete().eq('fine_id', fineId);
  }
}
