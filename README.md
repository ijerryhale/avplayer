## avplayer

Mac OS AVPlayer using AVPlayerLayer (Swift 5/Objective-C)

As of October 9 avplayer implements:

•   Opening of files thru Drag & Drop on the PlayerView
•   Opening remote Movie files with OpenURL...
•   Examples of both Key Value Observing and Key Value Coding
•   Using Objective-C Custom UI objects from Swift code
•   Full Screen Window support

So, maybe not as simple as it started out to be.

QuickTime Player Pro 7 stops working with Mac OS Catalina so we thought we'd have some fun.


## Requirements

- XCode 11+
- Mac OS 10.14+
- Swift 5+

## September 12, 2019

•   Initial commit

## September 13, 2019

•   Add code to handle Full Screen Window and Window size and position persistence

## September 25, 2019

•   Delete repository and recreate

•   Convert some Objective-C code to Swift, and add full WindowController

## September 30, 2019

•   Delete repository and recreate (again)
•   Add Drag and Drop on PlayerView, Open File, and Open URL

## October 7, 2019

•   Fix a lot of bugs

•   Add Objective-C Slider code. This implementation adds a custom UI object that is written in Objective-C code and because Swift cannot bridge Objective-C optional types the Slider is created programatically

## October 9, 2019

•   Move AVAsset to PlayerWindowController

•   Fix bug in PlayerView Drag & Drop

•   Add support for creating Trimmed Movies

![marquee](https://cormya.com/avplayer-3.png "AVPlayer")
## Contact

- [Linkedin][2]
- [Twitter][3] (@ijerryhale)

[2]: https://es.linkedin.com/in/ijerryhale
[3]: http://twitter.com/ijerryhale "Jerry Hale"

## License

Copyright 2019 Jerry Hale
<br>
Licensed under GNU GENERAL PUBLIC LICENSE v3.0

