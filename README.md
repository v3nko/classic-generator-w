# Classic Generator W

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

```text
MIT License

Copyright (c) 2022 Victor K.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
