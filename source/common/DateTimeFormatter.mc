using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DateTimerFormatter {
    function formatDateTimeNumeric(time as Moment) as String {
        var timeFormat = Gregorian.info(time, Time.FORMAT_SHORT);
        return Lang.format(
            "$1$-$2$-$3$ $4$:$5$:$6$",
            [
                timeFormat.year,
                timeFormat.month,
                timeFormat.day,
                timeFormat.hour,
                timeFormat.min.format("%02d"),
                timeFormat.sec.format("%02d")
            ]
        );
    }
}
