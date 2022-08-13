# Classic Generator W

[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

This repository contains a port of an Android App [Classic Generator](https://play.google.com/store/apps/details?id=me.venko.cg) for Garmin Watch devices. "W" stands for "Watch" or "Wearable" (on your choice).

This app is developed as a playground for applying various interesting technologies and development concepts and getting familiar with [Connect IQ SDK](https://developer.garmin.com/connect-iq/overview/). The app is still in an active development phase, so please expect some bugs, incompleteness, and general jank.

## Screenshots

![Alphanumeric generator](screenshots/cg-alphanum.png)

## Features

There are 5 generator modes available:

* numeric (from 0 to your value)
* range (supports negative values)
* numeric fixed (non-normalized numeric with fixed length)
* alphanumeric (supports custom symbols)
* hexadecimal

The generator mode can be switched by the "up"/"down" buttons. The "Start" button generates a new value. The last used generator mode is preserved between app launches.

App contains custom `SlidableView` view with a couple animation modes:

* slide (up/down) animation
* shake animation

Slide animation is used for generator mode switching and generated result reveal. Shake animation is used for mode switching and generation errors indication.

## Concepts

The project introduces multiple concepts that may be useful for Connect IQ app development.

### [UniTimer](source/common/UniTimer.mc)

Unified Timer. Performs multiple timers orchestration to make timer usage unified across the app without the need to worry about the OS limit for 3 timers. The timer instance is intended to be used as a singleton. UniTimer allows launching repeatable as well as non-repeatable timers. Each timer should be identified with a unique key. Uses single `Toybox.Timer` instance. Behavior is the same as the `Toybox.Timer`.

#### Start timer

```monkey-c
timer.start(
    "timer-key", // Unique timer identifier
    method(:onTimerTick), // Timer tick callback
    750, // Timer tick delay, ms
    true // Repeat (true | false)
);
```

#### Stop timer

```monkey-c
timer.stop("timer-key"); // Unique timer identifier
```

#### Check if timer is active

```monkey-c
timer.isActive("timer-key"); // Unique timer identifier
```

#### Limitations

UniTimer minimum delay is limited by the same value as the system timer (50 ms in most cases). This limitation may decrease precision if multiple timers use a minimum or close to minimum delay values and/or the timer ticks fall into this time window.

### [Alert](source/view/common/Alert.mc)

Simple alert dialog for displaying information, warning, or error messages. Supports multiline text that exceeds screen viewport. Can be scrolled manually or/and automatically. Alert view wraps the text with consideration of device shape. On the round device screen, the alert view will wrap text to fit into a visible viewport. Supports configurable displaying timeout.

Example:

Short text | Long text |
------- | ------- |
![Short text](screenshots/cg-alert-text-short.png) | ![Long text](screenshots/cg-alert-text-long.png)

## License

[Mozilla Public License Version 2.0](/LICENSE)
