import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar_date_range_picker.dart';

const Duration _calendarSizeAnimationDuration = Duration(milliseconds: 200);

/// A Material-style date range picker.
class VerticalDateRangePicker extends StatefulWidget {
  /// A Material-style date range picker.
  const VerticalDateRangePicker({
    Key? key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.restorationId,
    required this.onEndDateChanged,
    required this.onStartDateChanged,
    this.highLightColor,
    this.selectedColor,
    this.selectedTextStyle,
    this.disabledTexStyle,
    this.showPresentDay,
    this.presentDayStrokeColor,
    this.itemHeight,
    this.splashColor,
    this.spaceBetweenEachMonth,
    this.dayTextStyle,
    this.spaceBetweenRows,
    this.monthNameHeight,
    this.monthTextStyle,
  }) : super(key: key);

  /// The date range that the date range picker starts with when it opens.
  ///
  /// If an initial date range is provided, `initialDateRange.start`
  /// and `initialDateRange.end` must both fall between or on [firstDate] and
  /// [lastDate]. For all of these [DateTime] values, only their dates are
  /// considered. Their time fields are ignored.
  ///
  /// If [initialDateRange] is non-null, then it will be used as the initially
  /// selected date range. If it is provided, `initialDateRange.start` must be
  /// before or on `initialDateRange.end`.
  final DateTimeRange? initialDateRange;

  /// The earliest allowable date on the date range.
  final DateTime firstDate;

  /// The latest allowable date on the date range.
  final DateTime lastDate;

  /// The [currentDate] represents the current day (i.e. today).
  ///
  /// This date will be highlighted in the day grid.
  ///
  /// If `null`, the date of `DateTime.now()` will be used.
  final DateTime? currentDate;

  /// Restoration ID to save and restore the state of the [VerticalDateRangePicker].
  ///
  /// If it is non-null, the date range picker will persist and restore the
  /// date range selected on the dialog.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime> onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?> onEndDateChanged;

  /// The highlight color for the the selected dates
  /// By default the color will be [colorScheme.primary].
  final Color? highLightColor;

  /// The color of the selected dates.
  final Color? selectedColor;

  /// Text style for the selected day items.
  final TextStyle? selectedTextStyle;

  /// Text style for the disabled day items.
  final TextStyle? disabledTexStyle;

  /// Boolean to hide or show the selection of current date.
  /// By default the value will be true.
  final bool? showPresentDay;

  /// The current day gets a different text color and a circle stroke
  /// border. This prop only shows effect when [showPresentDay] is true.
  final Color? presentDayStrokeColor;

  /// Item height of each day in month.
  final double? itemHeight;

  /// The splash color for each day of the month. By default the
  /// value will be [ColorScheme.primary].
  final Color? splashColor;

  /// Space between each month. By default the height between each month
  /// will be 12.
  final double? spaceBetweenEachMonth;

  /// The text style for all days. By default the text style
  /// is [textTheme.bodyText2].
  final TextStyle? dayTextStyle;

  /// Space between rows.
  final double? spaceBetweenRows;

  /// Height of the month name widget.
  final double? monthNameHeight;

  /// Text style for month names.
  final TextStyle? monthTextStyle;

  @override
  State<VerticalDateRangePicker> createState() =>
      _VerticalDateRangePickerState();
}

class _VerticalDateRangePickerState extends State<VerticalDateRangePicker>
    with RestorationMixin {
  late final RestorableDateTimeN _selectedStart =
      RestorableDateTimeN(widget.initialDateRange?.start);
  late final RestorableDateTimeN _selectedEnd =
      RestorableDateTimeN(widget.initialDateRange?.end);
  final RestorableBool _autoValidate = RestorableBool(false);
  final GlobalKey _calendarPickerKey = GlobalKey();

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedStart, 'selected_start');
    registerForRestoration(_selectedEnd, 'selected_end');
    registerForRestoration(_autoValidate, 'autovalidate');
  }

  void _handleStartDateChanged(DateTime? date) {
    if (date != null) {
      widget.onStartDateChanged(date);
    }
  }

  void _handleEndDateChanged(DateTime? date) {
    if (date != null) {
      widget.onEndDateChanged(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double textScaleFactor = math.min(mediaQuery.textScaleFactor, 1.3);
    final Widget contents;
    final Size size;

    contents = SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        body: CalendarDateRangePicker(
          key: _calendarPickerKey,
          initialStartDate: _selectedStart.value,
          initialEndDate: _selectedEnd.value,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onStartDateChanged: _handleStartDateChanged,
          onEndDateChanged: _handleEndDateChanged,
          highLightColor: widget.highLightColor,
          selectedColor: widget.selectedColor,
          selectedTextStyle: widget.selectedTextStyle,
          disabledTexStyle: widget.disabledTexStyle,
          showPresentDay: widget.showPresentDay ?? true,
          currentDayStrokeColor: widget.presentDayStrokeColor,
          dayTextStyle: widget.dayTextStyle,
          itemHeight: widget.itemHeight,
          spaceBetweenEachMonth: widget.spaceBetweenEachMonth,
          spaceBetweenRows: widget.spaceBetweenRows,
          splashColor: widget.splashColor,
          monthNameHeight: widget.monthNameHeight,
          monthTextStyle: widget.monthTextStyle,
        ),
      ),
    );

    size = mediaQuery.size;
    return Scaffold(
      body: AnimatedContainer(
        width: size.width,
        height: size.height,
        duration: _calendarSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: Builder(builder: (BuildContext context) {
            return contents;
          }),
        ),
      ),
    );
  }
}
