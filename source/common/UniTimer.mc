using Toybox.Timer;

module UniTimer {

    class UptimeClock {
        private var baseTimer = 0l;
        private var prevTimer;

        function initialize() {
            prevTimer = System.getTimer();
        }

        function getUptime() {
            var currentTimer = System.getTimer();
            if (currentTimer < prevTimer) {
                baseTimer += prevTimer;
            }
            prevTimer = currentTimer;
            return baseTimer + currentTimer;
        }
    }

    class Timer {
        private const DELAY_MIN = 1;
        // Allowed delay delta tolerance value; if delta between requested delay and scheduled  
        // current delay falls into this value, rescheduling will be skipped. Preventing 
        // rescheduling leads to increase of performance by omitting overhead recreation of system 
        // timer and reducing potential offset relative to actual scheduled delay.
        private const DELTA_TOLERANCE = 15;
        private var timer = new Timer.Timer();
        private var clock = new UptimeClock();

        private var scheduledTimers = {};

        private var nextTick = null;
        private var currentDelay = null;

        function start(key as String, callback as Method(), delay as Number, repeat as Boolean) {
            if (!scheduledTimers.hasKey(key)) {
                scheduledTimers.put(
                    key,
                    new TimerEntry(callback, clock.getUptime(), delay, repeat)
                );
                if (scheduledTimers.size() == 1) {
                    startInternalTimer(delay);
                } else {
                    if (nextTick == null || nextTick > clock.getUptime() + delay) {
                        stopInternalTimer();
                        startInternalTimer(delay);
                    }
                }
            }
        }

        function stop(key as String) {
            scheduledTimers.remove(key);
            if (scheduledTimers.isEmpty()) {
                stopInternalTimer();
            }
        }

        function isActive(key as String) {
            return scheduledTimers.hasKey(key);
        }

        function onTick() {
            var expiredTimers = [];
            // Copy timer keys array to avoid possible concurrent moification of scheduledTimers 
            // dictionary in case of timer stop by the consumer in callback while permofming tick 
            // handling.
            var ongoingTimerKeys = scheduledTimers.keys().slice(0, scheduledTimers.size());
            for (var i = 0; i < ongoingTimerKeys.size(); i++) {
                var currentTick = clock.getUptime();
                var entry = scheduledTimers.get(ongoingTimerKeys[i]);
                var expired = entry == null;
                if (entry != null && entry.getNextTick() <= currentTick) {
                    entry.getCallback().invoke();
                    if (entry.getRepeat()) {
                        entry.incrementNextTick();
                    } else {
                        expired = true;
                    }
                }

                if (expired) {
                    expiredTimers.add(ongoingTimerKeys[i]);
                }
            }
            for (var i = 0; i < expiredTimers.size(); i++) {
                stop(expiredTimers[i]);
            }

            // Run scheduling round separately to handle possible added timers during callbacks
            var minDelay = null;
            for (var i = 0; i < scheduledTimers.size(); i++) {
                var currentTick = clock.getUptime();
                var nextTickDelta = scheduledTimers.values()[i].getNextTick() - currentTick;
                if (minDelay == null || nextTickDelta < minDelay) {
                    minDelay = nextTickDelta;
                }
            }

            if (!scheduledTimers.isEmpty() && minDelay != null) {
                startInternalTimer(Mathx.max(minDelay, DELAY_MIN));
            }
        }

        private function stopInternalTimer() {
            timer.stop();
            nextTick = null;
            currentDelay = null;
        }

        private function startInternalTimer(delay) {
            var delayDelta = 0;
            if (currentDelay != null) {
                delayDelta = currentDelay - delay;
            }
            if (
                currentDelay == null || 
                    delayDelta > DELTA_TOLERANCE || 
                    (delayDelta < 0 && delay > DELTA_TOLERANCE)
            ) {
                currentDelay = delay;
                timer.start(method(:onTick), delay, true);
            }
            nextTick = clock.getUptime() + currentDelay;
        }

        class TimerEntry {
            private var callback as Method();
            private var delay as Number;
            private var repeat as Boolean;

            private var nextTick as Long;

            function initialize(callback as Method(), uptime, delay as Number, repeat as Boolean) {
                me.callback = callback;
                me.delay = delay;
                me.repeat = repeat;
                nextTick = uptime + delay;
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

    var timerInstance;

    function getTimer() {
        if (timerInstance == null) {
            timerInstance = new UniTimer.Timer();
        }
        return timerInstance;
    }

}
