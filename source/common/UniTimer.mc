using Toybox.Timer;

module UniTimer {

    class Timer {
        private const BASE_TIMER_FREQUENCY = 50;
        private var timer = new Timer.Timer();

        private var scheduledTimers = {};

        private var nextTick = null;

        function start(key as String, callback as Method(), delay as Number, repeat as Boolean) {
            if (!scheduledTimers.hasKey(key)) {
                // TODO: put weak reference
                scheduledTimers.put(key, new TimerEntry(callback, delay, repeat));
                if (scheduledTimers.size() == 1) {
                    startInternalTimer(delay);
                } else {
                    if (nextTick == null || nextTick > System.getTimer() + delay) {
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
                stop(expiredTimers[i]);
            }

            if (!scheduledTimers.isEmpty() && minDelay != null) {
                startInternalTimer(minDelay);
            }
        }

        private function stopInternalTimer() {
            timer.stop();
            nextTick = null;
        }

        private function startInternalTimer(delay) {
            timer.start(method(:onTick), delay, false);
            nextTick = System.getTimer() + delay;
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
                nextTick =  System.getTimer() + delay;
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
