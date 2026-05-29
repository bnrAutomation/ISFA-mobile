import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/button_views.dart';

class AppPopup {
  static Future<T?> showAppBottomSheet<T>(
      {required BuildContext context,
      required Widget child,
      isDismis,
      enableDrag}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      isDismissible: isDismis ?? true,
      enableDrag: enableDrag ?? true,
      constraints: BoxConstraints(maxHeight: 1.sh - 20),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 50,
                height: 3,
                color: Colors.grey,
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  static Widget dropDownMenu(
      {Key? key,
      required List<String> options,
      required String placeholder,
      String? value,
      required void Function(String?) onChanged,
      required enabled,
      final Future<bool?> Function(String?)? onBeforePopupopen,
      Widget suffixIcon = const Icon(Icons.keyboard_arrow_down)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropDownSearchWidget(
        key: key,
        enabled: enabled,
          filterFn: (items, value) => items?.trim().toLowerCase().contains(value.trim().toLowerCase()) ?? false,
          listItemWidget: (userItems) => Text(
                userItems ?? "NA",
               // style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
          selectedWidget: Text(
           value ?? "Choose Option",
            //style: Theme.of(context).textTheme.titleSmall,
           overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          options: options,
          hint: placeholder,
          selectedVal: value,
          onBeforePopupopen: onBeforePopupopen,
          valChanged: onChanged),
      // ),
    );
  }

  static Widget dropDownMenuMutiselect(
      {
      required List<String> options,
      required String placeholder,
      String? value,
      required void Function(String?) onChanged,
      required enabled,
      final Future<bool?> Function(String?)? onBeforePopupopen,
      Key? key,
      Widget suffixIcon = const Icon(Icons.keyboard_arrow_down)}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropDownSearchWidgetMultiSelect<String>(
         filterFn: (items, value) => items.trim().toLowerCase().contains(value.trim().toLowerCase()),
        key: key,
          options: options,
          hint: placeholder,
          selectedVals: (value == null || value.trim().isEmpty)
              ? const <String>[]
              : value
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          selectedWidget: (selected) => Text(
            selected.isEmpty ? placeholder : selected.join(', '),
             maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          listItemWidget: (item) => Text(
            item,
             maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isSame: (a, b) => a == b,
          enabled: enabled,
          onBeforePopupopen: (selected) async {
            if (onBeforePopupopen == null) return null;
            final joined = selected.join(',');
            return onBeforePopupopen.call(joined.isEmpty ? null : joined);
          },
          // onBeforePopupopen: (selected) {
          //   if (onBeforePopupopen == null) {
          //     return Future<bool?>.value(null);
          //   }
          //   final joined = selected.join(',');
          //   return onBeforePopupopen.call(joined.isEmpty ? null : joined);
          // },
          valChanged: (selected) {
            final joined = selected.join(',');
            onChanged.call(joined.isEmpty ? null : joined);
          }),
      // ),
    );
  }
}
