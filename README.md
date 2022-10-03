![kalender](https://raw.githubusercontent.com/Arkroot-Innovations/kalender/main/images/kalender.png)

<p align="center">Simple and easy to use calendar utility package 🌈. </p>

---

<br><br>

### Calender utilities currently available

- 🚧 Vertical Calender.
- 🚧 Horizontal Calender.

# Usage

We can utilize the public props available for `VerticalDateRangePicker` to style the looks of calender.

<table border="0">
 <tr>
    <td><pre>
    VerticalDateRangePicker(
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 10),
          highLightColor: Colors.redAccent,
          onEndDateChanged: (date) {},
          selectedColor: Colors.redAccent,
          onStartDateChanged: (date) {},
          splashColor: Colors.redAccent,
          presentDayStrokeColor: Colors.black,
          selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          dayTextStyle: const TextStyle(
            color: Colors.black,
          ),
          initialDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(
              const Duration(days: 3),
            ),
          ),

        )

</pre>
</td>
    <td><image src="./images/screenshot.png" width="200"></td>
 </tr>
</table>
