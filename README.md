# CycleImageScrollView
It is a highly customizable scroll view for display images which can be scrolled infinitely and automatically in swift.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Features

- [x] Adjusted auto scroll time interval
- [x] Changeable page control indicator tint color and current page control indicator tint color

## Requirements

- iOS 8.0+ / macOS 10.11+
- Xcode 8.0+
- Swift 3.0+

## Installation
- Add the CycleImageScrollView.swift to your project.

## Usage

```swift
let cycleImageScrollView = CycleImageScrollView()

cycleImageScrollView.autoScrollTimeInterval = 2.0
cycleImageScrollView.pageControlIndicatorTintColor = UIColor.red
cycleImageScrollView.currentPageControlIndicatorTintColor = UIColor.black

cycleImageScrollView.imageURLStrings = ['Add your url here!']

view.addSubview(cycleImageScrollView)

```