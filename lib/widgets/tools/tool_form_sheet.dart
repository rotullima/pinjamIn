import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pinjamln/models/tools/tool_model.dart';
import '../../constants/app_colors.dart';
import '../../dummy/tools/category_dummy.dart';
import 'package:image_picker/image_picker.dart';

class ToolFormSheet extends StatefulWidget {
  final ToolModel? tool;

  const ToolFormSheet({super.key, this.tool});

  @override
  State<ToolFormSheet> createState() => _ToolFormSheetState();
}

final List<String> categoryNames = categoryDummies.map((c) => c.name).toList();

class _ToolFormSheetState extends State<ToolFormSheet> {
  late TextEditingController nameCtrl;
  late TextEditingController stockCtrl;
  String selectedCategory = categoryNames.first;
  String selectedCondition = 'good';
  Uint8List? pickedImageBytes;

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );

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
  text: widget.tool?.stockAvailable.toString() ?? '',
);

    selectedCategory = widget.tool?.category ?? categoryNames.first;
    selectedCondition = widget.tool?.statusItem ?? 'good';

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
              _dropdown(
                'Category',
                selectedCategory,
                categoryNames,
                (v) => setState(() => selectedCategory = v),
              ),
              _input('Stock', stockCtrl, number: true),
              _dropdown(
  'Condition',
  selectedCondition,
  ['good', 'in_repair'],
  (v) => setState(() => selectedCondition = v),
),


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
                        Navigator.pop(
                          context, true
                        );
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

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
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
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => onChanged(v!),
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
}
