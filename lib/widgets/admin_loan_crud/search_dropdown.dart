import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SearchDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final String hint;

  const SearchDropdown({
    super.key,
    required this.items,
    required this.label,
    required this.onSelected,
    this.hint = 'Select',
  });

  @override
  State<SearchDropdown<T>> createState() => _SearchDropdownState<T>();
}

class _SearchDropdownState<T> extends State<SearchDropdown<T>> {
  final TextEditingController _ctrl = TextEditingController();
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;

  List<T> _filtered = [];

  void _openOverlay() {
    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: MediaQuery.of(context).size.width * 0.78,
        child: CompositedTransformFollower(
          link: _link,
          offset: const Offset(0, 48),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  return ListTile(
                    title: Text(
                      widget.label(item),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    onTap: () {
                      widget.onSelected(item);
                      _ctrl.text = widget.label(item);
                      _closeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _onChanged(String v) {
    _filtered = widget.items
        .where((e) => widget.label(e).toLowerCase().contains(v.toLowerCase()))
        .toList();

    _closeOverlay();
    if (_filtered.isNotEmpty) _openOverlay();
  }

  @override
  void dispose() {
    _closeOverlay();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: TextField(
        controller: _ctrl,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
