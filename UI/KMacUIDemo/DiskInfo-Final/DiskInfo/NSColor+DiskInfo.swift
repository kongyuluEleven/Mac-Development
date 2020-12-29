/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

extension NSColor {

  static var othersFillColor: NSColor {
    return NSColor(hue: 0.138, saturation: 1, brightness: 1, alpha: 1)
  }

  static var othersStrokeColor: NSColor {
    return NSColor(hue: 0.136, saturation: 1, brightness: 0.924, alpha: 1)
  }

  static var moviesFillColor: NSColor {
    return NSColor(hue: 0.285, saturation: 0.68, brightness: 0.865, alpha: 1)
  }

  static var moviesStrokeColor: NSColor {
    return NSColor(hue: 0.284, saturation: 0.712, brightness: 0.731, alpha: 1)
  }

  static var photosFillColor: NSColor {
    return NSColor(hue: 0.952, saturation: 0.721, brightness: 1, alpha: 1)
  }

  static var photosStrokeColor: NSColor {
    return NSColor(hue: 0.954, saturation: 0.733, brightness: 0.889, alpha: 1)
  }

  static var audioFillColor: NSColor {
    return NSColor(hue: 0.106, saturation: 1, brightness: 1, alpha: 1)
  }

  static var audioStrokeColor: NSColor {
    return NSColor(hue: 0.105, saturation: 1, brightness: 0.927, alpha: 1)
  }

  static var appsFillColor: NSColor {
    return NSColor(hue: 0.545, saturation: 0.926, brightness: 0.979, alpha: 1)
  }

  static var appsStrokeColor: NSColor {
    return NSColor(hue: 0.544, saturation: 0.971, brightness: 0.931, alpha: 1)
  }

  static var availableFillColor: NSColor {
    return NSColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
  }

  static var availableStrokeColor: NSColor {
    return NSColor(hue: 0, saturation: 0, brightness: 0.853, alpha: 1)
  }

  static var pieChartAvailableStrokeColor: NSColor {
    return NSColor(hue: 0, saturation: 0, brightness: 0.853, alpha: 1)
  }

  static var pieChartAvailableFillColor: NSColor {
    return NSColor(hue: 0, saturation: 0, brightness: 1, alpha: 1)
  }

  static var pieChartUsedStrokeColor: NSColor {
    return NSColor(hue: 0.581, saturation: 0.882, brightness: 0.982, alpha: 1)
  }

  static var pieChartGradientStartColor: NSColor {
    return NSColor(hue: 0.581, saturation: 0.888, brightness: 0.982, alpha: 1)
  }

  static var pieChartGradientEndColor: NSColor {
    return NSColor(hue: 0.572, saturation: 0.515, brightness: 0.979, alpha: 1)
  }

  static var pieChartUsedSpaceTextColor: NSColor {
    return NSColor.white
  }

  static var pieChartAvailableSpaceTextColor: NSColor {
    return NSColor(white: 0.1, alpha: 1.0)
  }
}
