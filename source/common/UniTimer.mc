using Toybox.Timer;

class UniTimer {
    private const BASE_TIMER_FREQUENCY = 50;
    private var timer = new Timer.Timer();

    private var scheduledTimers = {};

    function startTimer(key as String, callback as Method(), delay as Number, repeat as Boolean) {
        if (!scheduledTimers.hasKey(key)) {
            // TODO: put weak reference
            scheduledTimers.put(key, new TimerEntry(callback, delay, repeat));
            if (scheduledTimers.size() == 1) {
                timer.start(method(:onTick), delay, false);
            } else {
                // TODO: align next timer tick if new t`imer delay is less than next scheduled timer
            }
        }
    }

    function stopTimer(key as String) {
        scheduledTimers.remove(key);
        if (scheduledTimers.isEmpty()) {
            timer.stop();
        }
    }

    function onTick() {
        var expiredTimers = [];
        var minDelay = null;
        for (var i = 0; i < scheduledTimers.size(); i++) {
            var entry = scheduledTimers.values()[i];
            var currentTick = System.getTimer();
            var expired = false;
            if (entry.getNextTick() <= currentTick) {
                entry.getCallback().invoke();
                if (entry.getRepeat()) {
                    entry.incrementNextTick();
                } else {
                    expiredTimers.add(scheduledTimers.keys()[i]);
                    expired = true;
                }
            }

            if (!expired) {
                var nextTickDelta = entry.getNextTick() - currentTick;
                if (minDelay == null || nextTickDelta < minDelay) {
                    minDelay = nextTickDelta;
                }
            }
        }
        for (var i = 0; i < expiredTimers.size(); i++) {
            stopTimer(expiredTimers[i]);
        }

        if (!scheduledTimers.isEmpty() && minDelay != null) {
            timer.start(method(:onTick), minDelay, false);
        }
    }

    class TimerEntry {
        private var callback as Method();
        private var delay as Number;
        private var repeat as Boolean;

        private var nextTick as Long;

        function initialize(callback as Method(), delay as Number, repeat as Boolean) {
            me.callback = callback;
            me.delay = delay;
            me.repeat = repeat;
            nextTick = System.getTimer() + delay;
        }

        function getCallback() {
            return callback;
        }

        function getRepeat() {
            return repeat;
        }

        function getNextTick() {
            return nextTick;
        }

        function incrementNextTick() {
            nextTick += delay;
            return nextTick;
        }

    }
}
