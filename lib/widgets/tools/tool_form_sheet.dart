import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pinjamln/models/tools/tool_model.dart';
import '../../constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tools/category_model.dart';
import '../../services/tools/category_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/tools/tool_admin_service.dart';

class ToolFormSheet extends StatefulWidget {
  final ToolModel? tool;

  const ToolFormSheet({super.key, this.tool});

  @override
  State<ToolFormSheet> createState() => _ToolFormSheetState();
}

class _ToolFormSheetState extends State<ToolFormSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController addAvailableCtrl;
  Uint8List? pickedImageBytes;
  CategoryModel? selectedCategory;
  List<CategoryModel> categories = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      pickedImageBytes = bytes;
    });
  }

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.tool?.name ?? '');
    stockCtrl = TextEditingController(
      text: widget.tool?.stockTotal.toString() ?? '',
    );
    addAvailableCtrl = TextEditingController(text: '0');

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await CategoryService().fetchCategories();

    setState(() {
      categories = data;

      selectedCategory = widget.tool != null
          ? categories.firstWhere((c) => c.id == widget.tool!.categoryId)
          : (categories.isNotEmpty ? categories.first : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.tool == null ? 'Add New Tools' : 'Update Tools',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 20),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: pickedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            pickedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image_outlined, size: 36),
                            SizedBox(height: 6),
                            Text('Tap to upload image'),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              _input('Name', nameCtrl),
              _dropdownCategory(
                'Category',
                selectedCategory,
                categories,
                (v) => setState(() => selectedCategory = v),
              ),

              _input('Stock', stockCtrl, number: true),
              _input('Available Stock', addAvailableCtrl, number: true),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Back',
                      icon: Icons.close,
                      outlined: true,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      label: 'Done',
                      icon: Icons.check,
                      onTap: () {
                        _submit();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),

          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownCategory(
    String label,
    CategoryModel? value,
    List<CategoryModel> items,
    ValueChanged<CategoryModel?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryModel>(
                value: value,
                isExpanded: true,
                items: items.map((c) {
                  return DropdownMenuItem<CategoryModel>(
                    value: c,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.background),
        label: Text(
          label,
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          elevation: 12,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (selectedCategory == null) return;

    String? imageUrl;

    if (pickedImageBytes != null) {
      final fileName = 'tools/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('items')
          .uploadBinary(
            fileName,
            pickedImageBytes!,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      imageUrl = Supabase.instance.client.storage
          .from('items')
          .getPublicUrl(fileName);
    }

    if (widget.tool != null) {
      final addAvailable = int.parse(addAvailableCtrl.text);

      await ToolAdminService().updateTool(
        itemId: widget.tool!.itemId,
        name: nameCtrl.text,
        categoryId: selectedCategory!.id,
        description: null,
        imagePath: imageUrl ?? widget.tool!.imagePath,
        stockTotal: int.parse(stockCtrl.text),
      );

      if (addAvailable > 0) {
        await ToolAdminService().addAvailableStock(
          itemId: widget.tool!.itemId,
          amount: addAvailable,
        );
      }
    }

    Navigator.pop(context, true);
  }
}
