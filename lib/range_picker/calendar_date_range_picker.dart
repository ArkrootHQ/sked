import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sked/widgets/month_widget.dart';
import 'package:sked/widgets/day_header_widget.dart';
import 'package:sked/helpers/calender_keyboard_navigator.dart';

/// Displays a scrollable calendar grid that allows a user to select a range
/// of dates.
class CalendarDateRangePicker extends StatefulWidget {
  /// Creates a scrollable calendar grid for picking date ranges.
  CalendarDateRangePicker({
    Key? key,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.highLightColor,
    this.selectedColor,
    this.selectedTextStyle,
    this.disabledTexStyle,
    this.showPresentDay,
    this.currentDayStrokeColor,
    this.itemHeight,
    this.splashColor,
    this.spaceBetweenEachMonth,
    this.dayTextStyle,
    this.spaceBetweenRows,
    this.monthNameHeight,
    this.monthTextStyle,
    this.daysHeaderTexStyle,
  })  : initialStartDate = initialStartDate != null ? DateUtils.dateOnly(initialStartDate) : null,
        initialEndDate = initialEndDate != null ? DateUtils.dateOnly(initialEndDate) : null,
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        super(key: key) {
    assert(
        this.initialStartDate == null ||
            this.initialEndDate == null ||
            !this.initialStartDate!.isAfter(initialEndDate!),
        'initialStartDate must be on or before initialEndDate.');
    assert(!this.lastDate.isBefore(this.firstDate), 'firstDate must be on or before lastDate.');
  }

  /// The [DateTime] that represents the start of the initial date range selection.
  final DateTime? initialStartDate;

  /// The [DateTime] that represents the end of the initial date range selection.
  final DateTime? initialEndDate;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<DateTime>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<DateTime?>? onEndDateChanged;

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
  final Color? currentDayStrokeColor;

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

  /// Text style for days. By default
  /// the text style will be [themeData.textTheme.subtitle2].
  final TextStyle? daysHeaderTexStyle;

  @override
  _CalendarDateRangePickerState createState() => _CalendarDateRangePickerState();
}

class _CalendarDateRangePickerState extends State<CalendarDateRangePicker> {
  final GlobalKey _scrollViewKey = GlobalKey();
  DateTime? _startDate;
  DateTime? _endDate;
  int _initialMonthIndex = 0;
  late ScrollController _controller;
  late bool _showWeekBottomDivider;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    // Calculate the index for the initially displayed month. This is needed to
    // divide the list of months into two `SliverList`s.
    final DateTime initialDate = widget.initialStartDate ?? widget.currentDate;
    if (!initialDate.isBefore(widget.firstDate) && !initialDate.isAfter(widget.lastDate)) {
      _initialMonthIndex = DateUtils.monthDelta(widget.firstDate, initialDate);
    }

    _showWeekBottomDivider = _initialMonthIndex != 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent) {
      setState(() {
        _showWeekBottomDivider = false;
      });
    } else if (!_showWeekBottomDivider) {
      setState(() {
        _showWeekBottomDivider = true;
      });
    }
  }

  int get _numberOfMonths => DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1;

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  // This updates the selected date range using this logic:
  //
  // * From the unselected state, selecting one date creates the start date.
  //   * If the next selection is before the start date, reset date range and
  //     set the start date to that selection.
  //   * If the next selection is on or after the start date, set the end date
  //     to that selection.
  // * After both start and end dates are selected, any subsequent selection
  //   resets the date range and sets start date to that selection.
  void _updateSelection(DateTime date) {
    _vibrate();
    setState(() {
      if (_startDate != null && _endDate == null && !date.isBefore(_startDate!)) {
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate);
      } else {
        _startDate = date;
        widget.onStartDateChanged?.call(_startDate!);
        if (_endDate != null) {
          _endDate = null;
          widget.onEndDateChanged?.call(_endDate);
        }
      }
    });
  }

  Widget _buildMonthItem(BuildContext context, int index, bool beforeInitialMonth) {
    final int monthIndex = beforeInitialMonth ? _initialMonthIndex - index - 1 : _initialMonthIndex + index;
    final DateTime month = DateUtils.addMonthsToMonthDate(widget.firstDate, monthIndex);
    return MonthItem(
      selectedDateStart: _startDate,
      selectedDateEnd: _endDate,
      currentDate: widget.currentDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      onChanged: _updateSelection,
      highLightColor: widget.highLightColor,
      selectedColor: widget.selectedColor,
      selectedTextStyle: widget.selectedTextStyle,
      disabledTexStyle: widget.disabledTexStyle,
      showCurrentDay: widget.showPresentDay ?? true,
      currentDayStrokeColor: widget.currentDayStrokeColor,
      dayTextStyle: widget.dayTextStyle,
      itemHeight: widget.itemHeight,
      spaceBetweenEachMonth: widget.spaceBetweenEachMonth,
      spaceBetweenRows: widget.spaceBetweenRows,
      splashColor: widget.splashColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key sliverAfterKey = Key('sliverAfterKey');
    return Column(
      children: <Widget>[
        DayHeaders(daysHeaderTexStyle: widget.daysHeaderTexStyle),
        if (_showWeekBottomDivider) const Divider(height: 0),
        Expanded(
          child: CalendarKeyboardNavigator(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialFocusedDay: _startDate ?? widget.initialStartDate ?? widget.currentDate,
            // In order to prevent performance issues when displaying the
            // correct initial month, 2 `SliverList`s are used to split the
            // months. The first item in the second SliverList is the initial
            // month to be displayed.
            child: CustomScrollView(
              key: _scrollViewKey,
              controller: _controller,
              center: sliverAfterKey,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => _buildMonthItem(context, index, true),
                    childCount: _initialMonthIndex,
                  ),
                ),
                SliverList(
                  key: sliverAfterKey,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => _buildMonthItem(context, index, false),
                    childCount: _numberOfMonths - _initialMonthIndex,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
