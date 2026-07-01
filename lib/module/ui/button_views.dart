import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class AddFloatingActionButton extends StatelessWidget {
  final void Function() onTap;
  const AddFloatingActionButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      onPressed: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              const Color(0xff278BBC)
            ])),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(
            Icons.add,
            size: 30.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// class DropDownWithOptions extends StatelessWidget {
//   final List<String> options;
//   final String hint;
//   final void Function(String?)? valChanged;

//   final String? selectedVal;
//   final bool enabled;
//   final Future<bool?> Function(String?)? onBeforePopupopen;

//   const DropDownWithOptions(
//       {super.key,
//       required this.options,
//       required this.hint,
//       required this.valChanged,
//       this.selectedVal,
//       required this.enabled,
//       this.onBeforePopupopen});

//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch<String>(
//       enabled: enabled,
//       popupProps:
//           const PopupProps.menu(
//             showSelectedItems: true,
//              showSearchBox: true,
             
//     searchFieldProps: TextFieldProps(
//       autofocus: true, // 💡 This opens the keyboard immediately
//     ),
//              ),
//       items: options,
//       selectedItem: selectedVal,
//       onChanged: valChanged,
//       onBeforePopupOpening: onBeforePopupopen,
//       dropdownDecoratorProps: DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           hintText: hint,
//           border: const OutlineInputBorder(),
//         ),
//       ),
//     );
//   }
// }


class DropDownSearchWidget<T> extends StatefulWidget {
  final List<T> options;
  final String hint;
  final bool enabled;
  final void Function(T?) valChanged;
  final bool Function(T?, String)? filterFn;
  final T? selectedVal;
  final Widget selectedWidget;
  final Widget Function(T?) listItemWidget;
  final Future<bool?> Function(T?)? onBeforePopupopen;
  final bool Function(T, T)? compareFn;

  const DropDownSearchWidget(
      {super.key,
       required this.enabled,
      required this.options,
      required this.hint,
      required this.valChanged,
      this.selectedVal,
      required this.selectedWidget,
      required this.listItemWidget,
      this.filterFn,
      this.onBeforePopupopen,
      this.compareFn});

  @override
  State<DropDownSearchWidget<T>> createState() =>
      _DropDownSearchWidgetState<T>();
}

class _DropDownSearchWidgetState<T> extends State<DropDownSearchWidget<T>> {
  late final FocusNode _searchFocusNode;

  void _forceKeyboard() {
    // Only request focus when the node is attached (popup search field built).
    if (!mounted || _searchFocusNode.context == null) return;
    _searchFocusNode.requestFocus();
    // Some Android devices ignore autofocus inside popup overlays.
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(debugLabel: 'dropdown_search');
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      key: widget.key,
      enabled: widget.enabled,
      dropdownBuilder: (context, selectedItem) =>
          Container(padding: const EdgeInsets.all(2), child: widget.selectedWidget),
      onBeforePopupOpening: (selected) async {
        // Popup overlay mounts after this returns; schedule a few focus attempts.
        Future.microtask(_forceKeyboard);
        Future.delayed(const Duration(milliseconds: 80), _forceKeyboard);
        Future.delayed(const Duration(milliseconds: 200), _forceKeyboard);
        return widget.onBeforePopupopen?.call(selected);
      },
      popupProps: PopupProps.menu(
        showSelectedItems: false,
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          focusNode: _searchFocusNode,
        ),
        itemBuilder: (context, item,isDisabled, isSelected) =>Container(
            padding: const EdgeInsets.all(10), child: widget.listItemWidget(item)),
      ),
      items:  (f, cs) =>  widget.options,
      selectedItem: widget.selectedVal,
      onChanged: widget.valChanged,
      compareFn: widget.compareFn ?? (item1, item2) => item1 == item2,
      filterFn: (item, filter) => widget.filterFn!(item, filter),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}



class DropDownSearchWidgetMultiSelect<T> extends StatefulWidget {
  final List<T> options;
  final String hint;
  final void Function(List<T>) valChanged;
  final bool Function(T, String)? filterFn;
  final List<T> selectedVals;
  final Widget Function(List<T>) selectedWidget;
  final Widget Function(T) listItemWidget;
 // final String selectAllLabel;
  final bool Function(T, T) isSame;
  final bool enabled;
  final Future<bool?> Function(List<T>)? onBeforePopupopen;

  const DropDownSearchWidgetMultiSelect({
    super.key,
    required this.options,
    required this.hint,
    required this.valChanged,
    required this.selectedVals,
    required this.selectedWidget,
    required this.listItemWidget,
    required this.isSame,
    required this.enabled,
   // this.selectAllLabel = 'Select All',
    this.filterFn,
    this.onBeforePopupopen,
  });

  @override
  State<DropDownSearchWidgetMultiSelect<T>> createState() =>
      _DropDownSearchWidgetMultiSelectState<T>();
}

class _DropDownSearchWidgetMultiSelectState<T>
    extends State<DropDownSearchWidgetMultiSelect<T>> {
  late final FocusNode _searchFocusNode;

  void _forceKeyboard() {
    if (!mounted || _searchFocusNode.context == null) return;
    _searchFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode(debugLabel: 'dropdown_search_multi');
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<SelectableItem<T>> wrappedOptions = [
      //SelectableItem<T>.selectAll(label: selectAllLabel),
      ...widget.options.map((e) => SelectableItem<T>.data(e)),
    ];

    final selectedWrapped = widget.selectedVals
        .map((val) => wrappedOptions.firstWhere(
              (e) => !e.isSelectAll && widget.isSame(e.value as T, val),
              orElse: () => SelectableItem<T>.data(val),
            ))
        .toList();

    return DropdownSearch<SelectableItem<T>>.multiSelection(
      key: widget.key,
      enabled: widget.enabled,
      items:  (f, cs) =>  wrappedOptions,
      selectedItems: selectedWrapped,
      dropdownBuilder: (context, selectedItems) => Padding(
        padding: const EdgeInsets.all(2),
        child: widget.selectedWidget(
          selectedItems
              .where((e) => !e.isSelectAll)
              .map((e) => e.value as T)
              .toList(),
        ),
      ),
      popupProps: PopupPropsMultiSelection.menu(
        showSelectedItems: true,
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          autofocus: true,
          focusNode: _searchFocusNode,
        ),
        itemBuilder: (context, item, isDisabled,isSelected) {
          if (item.isSelectAll) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.label ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.listItemWidget(item.value as T),
          );
        },
      ),
      onChanged: (selectedWrappedItems) {
       final hasSelectAll = selectedWrappedItems.any((e) => e.isSelectAll);

        if (hasSelectAll) {
          // If "Select All" is selected → select all actual items
          widget.valChanged(widget.options);
        } else {
          // If "Select All" is deselected manually → unselect everything
          final selectedItems = selectedWrappedItems
              .where((e) => !e.isSelectAll)
              .map((e) => e.value as T)
              .toList();

          if (selectedItems.length < widget.options.length) {
            widget.valChanged(selectedItems);
          } else {
            // If all items manually selected (but Select All not clicked), avoid feedback loop
            widget.valChanged(selectedItems);
          }
        }
      },
      compareFn: (a, b) {
        if (a.isSelectAll && b.isSelectAll) return true;
        if (!a.isSelectAll && !b.isSelectAll) {
          return widget.isSame(a.value as T, b.value as T);
        }
        return false;
      },
      onBeforePopupOpening: (selectedWrappedItems) async {
        Future.microtask(_forceKeyboard);
        Future.delayed(const Duration(milliseconds: 80), _forceKeyboard);
        Future.delayed(const Duration(milliseconds: 200), _forceKeyboard);
        final selected = selectedWrappedItems
            .where((e) => !e.isSelectAll)
            .map((e) => e.value as T)
            .toList();
        return widget.onBeforePopupopen?.call(selected);
      },
      filterFn: widget.filterFn != null
          ? (item, filter) {
              if (item.isSelectAll) return true;
              return widget.filterFn!(item.value as T, filter);
            }
          : null,
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          contentPadding:EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class SelectableItem<T> {
  final T? value;
  final bool isSelectAll;
  final String? label;

  SelectableItem.selectAll({this.label = 'Select All'})
      : value = null,
        isSelectAll = true;

  SelectableItem.data(this.value)
      : isSelectAll = false,
        label = null;
}
