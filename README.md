# TouchVisualizer

[![Join the chat at https://gitter.im/morizotter/TouchVisualizer](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/morizotter/TouchVisualizer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Version](https://img.shields.io/cocoapods/v/TouchVisualizer.svg?style=flat)](http://cocoadocs.org/docsets/TouchVisualizer)
[![License](https://img.shields.io/cocoapods/l/TouchVisualizer.svg?style=flat)](http://cocoadocs.org/docsets/TouchVisualizer)
[![Platform](https://img.shields.io/cocoapods/p/TouchVisualizer.svg?style=flat)](http://cocoadocs.org/docsets/TouchVisualizer)
[![Circle CI](https://circleci.com/gh/morizotter/TouchVisualizer/tree/master.svg?style=shield&circle-token=b7eb2e179731634bcac95d1e4f8e90b837b092e3)](https://circleci.com/gh/morizotter/TouchVisualizer/tree/master)

Effective presentation with TouchVisualizer! Main features are below.

- Multiple fingers supported.
- Multiple UIWindows supported.
- Shows touch radius.
- Shows touch duration.
- You can change colors and images of finger points.

![top](https://raw.githubusercontent.com/morizotter/TouchVisualizer/master/misc/top.png)

Catch the image with GIF!

![gif](https://raw.githubusercontent.com/morizotter/TouchVisualizer/master/misc/presentation.gif)

Let's give a presentation effectively

## Installation

> Embedded frameworks require a minimum deployment target of iOS 8.1
> To use TouchVisualizer with a project targeting iOS 8.0 or lower, you must include the TouchVisualizer.swift source file directly in your project.

### CocoaPods

[CocoaPods](http://cocoapods.org) 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```
$ gem update
$ gem install cocoapods
$ pods --version
```

To install it, simply add the following lines to your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.1'

use_frameworks!

pod "TouchVisualizer", '~>1.1'
```

then, `pod install`

### Carthage

See [instruction here](https://github.com/Carthage/Carthage#installing-carthage).

Known Xcode 6.3.1 Problem: If you failed to install with errors. Try this command below on your risk. It seems Xcode bug - [SimVerifier returned error: Simulator verification failed. · Issue #424 · Carthage/Carthage](https://github.com/Carthage/Carthage/issues/424#issuecomment-95812898).

```
sudo chown :wheel /Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ *.simruntime/Contents/Resources/RuntimeRoot/usr/lib/dyld_sim
```

## Usage

`import TouchVisualizer` and just write the following line wherever you want to start visualization. 

```
TouchVisualizer.start()
```

Is it really simple, isn't it? And you can change settings:

```
var config = TouchVisualizerConfig()
config.color = UIColor.redColor()
config.image = UIImage(named: "YOUR-IMAGE")
config.showsTimer = true
config.showsTouchRadius = true
config.showsLog = true
TouchVisualizer.start(config)
```

You can stop presentation from the app like this.

```
TouchVisualizer.stop()
```

## Requirements

- iOS8.1 or later
- Xcode 6.3

## Document

- [How to take an iOS screen movie](misc/take_a_movie.md)

## Contribution

I'm waiting for your contribution:)

## License

TouchVisualizer is available under the MIT license. See the LICENSE file for more info.

## Alternative

There is similar *touch visualization* library: [COSTouchVisualizer](https://github.com/conopsys/COSTouchVisualizer). It seems support lower iOS versions and probably works neater. If TouchVisualizer doesn't fit for your project. Let's try this.
