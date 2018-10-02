//
//  ViewController.swift
//  Cam
//
//  Created by amirshayegh on 09/21/2018.
//  Copyright (c) 2018 amirshayegh. All rights reserved.
//

import UIKit
import Cam
import CoreML
import Extended

enum Genders {
    case Male
    case Female
    case Unknown
}

enum LifeForms {
    case Animal
    case Plant
    case Human
    case Unknown
}

enum PlantTypes {
    case DalmatianToadflax
    case SpottedKnapweed
    case CowParsley
    case PonytailPalm
    case Unknown
}

enum AnimalTypes {
    case Cat
    case Cow
    case Dog
    case Unknown
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func action(_ sender: UIButton) {
        // Create a Cam object
        let cam = Cam()
        // Call display
        cam.display(on: self) { (photo) in
            if let photo = photo, let image = photo.image, let buffer = self.buffer(from: image) {
                let imageView = UIImageView(frame: self.view.frame)
                imageView.contentMode = .scaleAspectFit
                imageView.image = photo.image
                self.view.addSubview(imageView)

                var text = "I think this is"
                let kind = self.getLifeForm(image: buffer)
                switch kind {
                case .Animal:
                    let animal = self.getAnimalType(image: buffer)
                    text = "\(text) an Animal... \(animal) to be more precise."
                case .Plant:
                    let plant = self.getPlantType(image: buffer)
                    let plantString = "\(plant)"
                    text = "\(text) a \(plantString.convertFromCamelCase()) \(kind)"
                case .Human:
                    let gender = self.getGender(image: buffer)
                    text = "\(text) a \(gender) \(kind)."
                case .Unknown:
                    text = "\(text)... dunno."
                }

//                let h = self.getHighestProb(in: output.classLabelProbs)
//                let percent = h * 100
//                self.descLabel.text = "i'm \(percent.roundToDecimal(1))% sure this is a \(output.classLabel)"
                self.descLabel.text = text
                self.view.addSubview(self.descLabel)


                self.truggerTimer(from: 5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    imageView.removeFromSuperview()
                    self.descLabel.text = ""
                })
            }
        }
    }

    func truggerTimer(from seconds: Int) {
        if seconds < 1 {
             self.timerLabel.text = ""
            return
        }
        self.timerLabel.text = "\(seconds - 1)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.truggerTimer(from: (seconds - 1))
        })
    }

    func getLifeForm(image: CVPixelBuffer) -> LifeForms {
        let lifeForm = LifeForm()
        guard let output = try? lifeForm.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Animal":
            return .Animal
        case "Human":
            return .Human
        case "Plant":
            return .Plant
        default:
            return .Unknown
        }
    }

    func getPlantType(image: CVPixelBuffer) -> PlantTypes {
        let plants = Plant()
        guard let output = try? plants.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "DalmatianToadflax":
            return .DalmatianToadflax
        case "SpottedKnapweed":
            return .SpottedKnapweed
        case "CowParsley":
            return .CowParsley
        case "PonytailPalm":
            return .PonytailPalm
        default:
            return .Unknown
        }
    }

    func getGender(image: CVPixelBuffer) -> Genders {
        let genders = Gender()
        guard let output = try? genders.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Male":
            return .Male
        case "Female":
            return .Female
        default:
            return .Unknown
        }
    }

    func getAnimalType(image: CVPixelBuffer) -> AnimalTypes {
        let animals = Animal()
        guard let output = try? animals.prediction(image: image) else {
            print("ML Failed")
            return .Unknown
        }
        switch output.classLabel {
        case "Cow":
            return .Cow
        case "Cat":
            return .Cat
        case "Dog":
            return .Dog
        default:
            return .Unknown
        }
    }

    func getHighestProb(in probs: [String: Double]) -> Double {
        var highest: Double = 0.0
        for prob in probs where prob.value > highest {
            highest = prob.value
        }
        return highest
    }

    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
