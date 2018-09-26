# Cam

[![CI Status](https://img.shields.io/travis/amirshayegh/Cam.svg?style=flat)](https://travis-ci.org/amirshayegh/Cam)
[![Version](https://img.shields.io/cocoapods/v/Cam.svg?style=flat)](https://cocoapods.org/pods/Cam)
[![License](https://img.shields.io/cocoapods/l/Cam.svg?style=flat)](https://cocoapods.org/pods/Cam)
[![Platform](https://img.shields.io/cocoapods/p/Cam.svg?style=flat)](https://cocoapods.org/pods/Cam)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation
![Alt Text](https://github.com/FreshworksStudio/Cam/blob/master/ReadmeFiles/capture.PNG)
Cam is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Cam', '1.0.0'
```
## Quick Usage

1) Import the library

```Swift
import UIKit
import Cam
```

2) Create a Cam object

```Swift
let camera = Cam()
```

3) Call Display
```Swift
cam.display(on: self) { (photo) in
		
}
```

4) Process Photo 
```Swift
cam.display(on: self) { (photo) in
	if let photo = photo {
		// Example: displaying image on an imageview for 2 seconds
		let imageView = UIImageView(frame: self.view.frame)
		imageView.contentMode = .scaleAspectFit
		imageView.image = photo.image
		self.view.addSubview(imageView)
		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
			imageView.removeFromSuperview()
		})
	}
}
```
![Alt Text](https://github.com/FreshworksStudio/Cam/blob/master/ReadmeFiles/captured.PNG)

## Author

amirshayegh, shayegh@me.com

## License

Cam is available under the MIT license. See the LICENSE file for more info.
