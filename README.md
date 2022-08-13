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

## License

[Mozilla Public License Version 2.0](/LICENSE)
