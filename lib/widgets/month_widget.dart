import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:kalendar/enums/highlight_painter_style.dart';
import 'package:kalendar/helpers/painter.dart';
import 'package:kalendar/constants.dart';
import 'focus_date_widget.dart';
import 'grid_layout_widget.dart';

const Duration _monthScrollDuration = Duration(milliseconds: 200);

/// Displays the days of a given month and allows choosing a date range.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class MonthItem extends StatefulWidget {
  /// Creates a month item.
  MonthItem({
    Key? key,
    required this.selectedDateStart,
    required this.selectedDateEnd,
    required this.currentDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.displayedMonth,
    this.dragStartBehavior = DragStartBehavior.start,
    this.highLightColor,
    this.selectedColor,
    this.selectedTextStyle,
    this.disabledTexStyle,
    this.showCurrentDay = true,
    this.currentDayStrokeColor,
    this.itemHeight,
    this.splashColor,
    this.spaceBetweenEachMonth,
    this.spaceBetweenRows,
    this.dayTextStyle,
    this.monthNameHeight,
    this.monthTextStyle,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            !selectedDateStart.isBefore(firstDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isBefore(firstDate)),
        assert(
            selectedDateStart == null || !selectedDateStart.isAfter(lastDate)),
        assert(selectedDateEnd == null || !selectedDateEnd.isAfter(lastDate)),
        assert(selectedDateStart == null ||
            selectedDateEnd == null ||
            !selectedDateStart.isAfter(selectedDateEnd)),
        super(key: key);

  /// The currently selected start date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateStart;

  /// The currently selected end date.
  ///
  /// This date is highlighted in the picker.
  final DateTime? selectedDateEnd;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to scroll a
  /// date picker wheel will begin at the position where the drag gesture won
  /// the arena. If set to [DragStartBehavior.down] it will begin at the position
  /// where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  final DragStartBehavior dragStartBehavior;

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
  final bool showCurrentDay;

  /// The current day gets a different text color and a circle stroke
  /// border. This prop only shows effect when [showCurrentDay] is true.
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

  @override
  _MonthItemState createState() => _MonthItemState();
}

class _MonthItemState extends State<MonthItem> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = FocusedDate.of(context)?.date;
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _highlightColor(BuildContext context) {
    return (widget.highLightColor ?? Theme.of(context).colorScheme.primary)
        .withOpacity(0.12);
  }

  void _dayFocusChanged(bool focused) {
    if (focused) {
      final TraversalDirection? focusDirection =
          FocusedDate.of(context)?.scrollDirection;
      if (focusDirection != null) {
        ScrollPositionAlignmentPolicy policy =
            ScrollPositionAlignmentPolicy.explicit;
        switch (focusDirection) {
          case TraversalDirection.up:
          case TraversalDirection.left:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
            break;
          case TraversalDirection.right:
          case TraversalDirection.down:
            policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
            break;
        }

        Scrollable.ensureVisible(
          primaryFocus!.context!,
          duration: _monthScrollDuration,
          alignmentPolicy: policy,
        );
      }
    }
  }

  // Create day item.
  Widget _buildDayItem(BuildContext context, DateTime dayToBuild,
      int firstDayOffset, int daysInMonth) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final TextDirection textDirection = Directionality.of(context);
    final Color highlightColor = _highlightColor(context);

    final int day = dayToBuild.day;

    final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
        dayToBuild.isBefore(widget.firstDate);
    BoxDecoration? decoration;

    TextStyle? itemStyle = widget.dayTextStyle ?? textTheme.bodyText2;
    final bool isRangeSelected =
        widget.selectedDateStart != null && widget.selectedDateEnd != null;

    final bool isSelectedDayStart = widget.selectedDateStart != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateStart!);

    final bool isSelectedDayEnd = widget.selectedDateEnd != null &&
        dayToBuild.isAtSameMomentAs(widget.selectedDateEnd!);

    final bool isInRange = isRangeSelected &&
        dayToBuild.isAfter(widget.selectedDateStart!) &&
        dayToBuild.isBefore(widget.selectedDateEnd!);

    HighlightPainter? highlightPainter;

    if (isSelectedDayStart || isSelectedDayEnd) {
      // The selected start and end dates gets a circle background
      // highlight, and a contrasting text color.
      itemStyle = widget.selectedTextStyle ??
          textTheme.bodyText2?.apply(color: colorScheme.onPrimary);
      decoration = BoxDecoration(
        color: widget.selectedColor ?? colorScheme.primary,
        shape: BoxShape.circle,
      );

      if (isRangeSelected &&
          widget.selectedDateStart != widget.selectedDateEnd) {
        final HighlightPainterStyle style = isSelectedDayStart
            ? HighlightPainterStyle.highlightTrailing
            : HighlightPainterStyle.highlightLeading;
        highlightPainter = HighlightPainter(
          color: highlightColor,
          style: style,
          textDirection: textDirection,
        );
      }
    } else if (isInRange) {
      // The days within the range get a light background highlight.
      highlightPainter = HighlightPainter(
        color: highlightColor,
        style: HighlightPainterStyle.highlightAll,
        textDirection: textDirection,
      );
    } else if (isDisabled) {
      itemStyle = widget.disabledTexStyle ??
          textTheme.bodyText2
              ?.apply(color: colorScheme.onSurface.withOpacity(0.38));
    } else if (DateUtils.isSameDay(widget.currentDate, dayToBuild) &&
        widget.showCurrentDay) {
      // The current day gets a different text color and a circle stroke
      // border.
      itemStyle = textTheme.bodyText2?.apply(color: colorScheme.primary);
      decoration = BoxDecoration(
        border: Border.all(color: widget.currentDayStrokeColor ?? colorScheme.primary),
        shape: BoxShape.circle,
      );
    }

    // We want the day of month to be spoken first irrespective of the
    // locale-specific preferences or TextDirection. This is because
    // an accessibility user is more likely to be interested in the
    // day of month before the rest of the date, as they are looking
    // for the day of month. To do that we prepend day of month to the
    // formatted full date.
    String semanticLabel =
        '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}';
    if (isSelectedDayStart) {
      semanticLabel =
          localizations.dateRangeStartDateSemanticLabel(semanticLabel);
    } else if (isSelectedDayEnd) {
      semanticLabel =
          localizations.dateRangeEndDateSemanticLabel(semanticLabel);
    }

    Widget dayWidget = Container(
      decoration: decoration,
      child: Center(
        child: Semantics(
          label: semanticLabel,
          selected: isSelectedDayStart || isSelectedDayEnd,
          child: ExcludeSemantics(
            child: Text(localizations.formatDecimal(day), style: itemStyle),
          ),
        ),
      ),
    );

    if (highlightPainter != null) {
      dayWidget = CustomPaint(
        painter: highlightPainter,
        child: dayWidget,
      );
    }

    if (!isDisabled) {
      dayWidget = InkResponse(
        focusNode: _dayFocusNodes[day - 1],
        onTap: () => widget.onChanged(dayToBuild),
        radius: (widget.itemHeight ?? monthItemRowHeight) / 2 + 4,
        splashColor:
            (widget.splashColor ?? colorScheme.primary).withOpacity(0.38),
        onFocusChange: _dayFocusChanged,
        child: dayWidget,
      );
    }

    return dayWidget;
  }

  Widget _buildEdgeContainer(BuildContext context, bool isHighlighted) {
    return Container(color: isHighlighted ? _highlightColor(context) : null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);
    final int weeks = ((daysInMonth + dayOffset) / DateTime.daysPerWeek).ceil();
    final double gridHeight =
        weeks * (widget.itemHeight ?? monthItemRowHeight) +
            (weeks - 1) *
                (widget.spaceBetweenEachMonth ?? monthItemSpaceBetweenRows);

    final List<Widget> dayItems = <Widget>[];
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - dayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final Widget dayItem = _buildDayItem(
          context,
          dayToBuild,
          dayOffset,
          daysInMonth,
        );
        dayItems.add(dayItem);
      }
    }

    // Add the leading/trailing edge containers to each week in order to
    // correctly extend the range highlight.
    final List<Widget> paddedDayItems = <Widget>[];
    for (int i = 0; i < weeks; i++) {
      final int start = i * DateTime.daysPerWeek;
      final int end = math.min(
        start + DateTime.daysPerWeek,
        dayItems.length,
      );

      final List<Widget> weekList = dayItems.sublist(start, end);
      final DateTime dateAfterLeadingPadding =
          DateTime(year, month, start - dayOffset + 1);

      // Only color the edge container if it is after the start date and
      // on/before the end date.
      final bool isLeadingInRange = !(dayOffset > 0 && i == 0) &&
          widget.selectedDateStart != null &&
          widget.selectedDateEnd != null &&
          dateAfterLeadingPadding.isAfter(widget.selectedDateStart!) &&
          !dateAfterLeadingPadding.isAfter(widget.selectedDateEnd!);
      weekList.insert(0, _buildEdgeContainer(context, isLeadingInRange));

      // Only add a trailing edge container if it is for a full week and not a
      // partial week.
      if (end < dayItems.length ||
          (end == dayItems.length &&
              dayItems.length % DateTime.daysPerWeek == 0)) {
        final DateTime dateBeforeTrailingPadding =
            DateTime(year, month, end - dayOffset);
        // Only color the edge container if it is on/after the start date and
        // before the end date.
        final bool isTrailingInRange = widget.selectedDateStart != null &&
            widget.selectedDateEnd != null &&
            !dateBeforeTrailingPadding.isBefore(widget.selectedDateStart!) &&
            dateBeforeTrailingPadding.isBefore(widget.selectedDateEnd!);
        weekList.add(_buildEdgeContainer(context, isTrailingInRange));
      }

      paddedDayItems.addAll(weekList);
    }

    final double maxWidth =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? maxCalendarWidthLandscape
            : maxCalendarWidthPortrait;

    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          height: monthItemHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: AlignmentDirectional.centerStart,
          child: ExcludeSemantics(
            child: Text(
              localizations.formatMonthYear(widget.displayedMonth),
              style: textTheme.bodyText2!
                  .apply(color: themeData.colorScheme.onSurface),
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: gridHeight,
          ),
          child: GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: monthItemGridDelegate,
            childrenDelegate: SliverChildListDelegate(
              paddedDayItems,
              addRepaintBoundaries: false,
            ),
          ),
        ),
        SizedBox(height: widget.spaceBetweenEachMonth ?? monthItemFooterHeight),
      ],
    );
  }
}
