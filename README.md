# MZRPresentationKit

[![CI Status](http://img.shields.io/travis/Naoki Morita/MZRPresentationKit.svg?style=flat)](https://travis-ci.org/Naoki Morita/MZRPresentationKit)
[![Version](https://img.shields.io/cocoapods/v/MZRPresentationKit.svg?style=flat)](http://cocoadocs.org/docsets/MZRPresentationKit)
[![License](https://img.shields.io/cocoapods/l/MZRPresentationKit.svg?style=flat)](http://cocoadocs.org/docsets/MZRPresentationKit)
[![Platform](https://img.shields.io/cocoapods/p/MZRPresentationKit.svg?style=flat)](http://cocoadocs.org/docsets/MZRPresentationKit)

## Let's give a presentation with finger points easily

![Gif](https://github.com/morizotter/MZRPresentationKit/blob/master/presentation.gif)

## Installation

> Embedded frameworks require a minimum deployment target of iOS 8
> To use MZRPresentationKit with a project targeting iOS 7, you must include the MZRPresentationKit.swift source file directly in your project.

[CocoaPods](http://cocoapods.org) 0.36 beta adds supports for Swift and embedded frameworks. You can install it with the following command:

```
$ gem install cocoapods --pre
```

To install it, simply add the following lines to your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod "MZRPresentationKit", '~>1.0.0'
```

## Usage

Just write the following line in the `application(application:didFinishLaunchingWithOptions:)` in `AppDelegate`.

```
MZRPresentationView.start()
```

You can change colors and images like this. You can set only color or image.

```
MZRPresentationView.start(UIColor.redColor(), image: UIImage(named: "YOUR-IMAGE"))
```

## Requirements

- iOS8 or later
- Xcode 6.1

## Author

Naoki Morita, namorit@gmail.com

## License

MZRPresentationKit is available under the MIT license. See the LICENSE file for more info.

