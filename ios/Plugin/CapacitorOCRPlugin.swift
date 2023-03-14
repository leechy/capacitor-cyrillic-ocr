import Foundation
import Capacitor
import Vision

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorOCRPlugin)
public class CapacitorOCRPlugin: CAPPlugin {
  private let implementation = CapacitorOCR()

  @objc func recognize(_ call: CAPPluginCall) {
    // process parameters
    let languages = call.getArray("languages", ["en"]) as! Array<String>
    let orientation = self.getOrientation(orientation: call.getString("orientation"))

    // decode image
    guard let base64Image = call.getString("base64Image") else {
      call.reject("Image not found!")
      return
    }
    let imageDecoded : Data = Data(base64Encoded: base64Image, options: .ignoreUnknownCharacters)!
    guard let image = UIImage(data: imageDecoded) else {
      call.reject("Image format not rercognized!")
      return
    }
    guard let cgImage = image.cgImage else {
      call.reject("Image was not properly converted!")
      return
    }
    
    implementation.recognize(call: call, languages: languages, cgImage: cgImage, orientation: orientation) 
  }


  /// Converts the orientation from string to CGImagePropertyOrientation value
  ///
  /// Defaults to "up"
  ///
  /// - Parameters
  ///   - orientation:  Image orientation as a string: "up" | "right" | "down" | "left"
  ///
  /// - Returns: CGImagePropertyOrientation with the requested direction

  func getOrientation(orientation: String?) -> CGImagePropertyOrientation {
    switch orientation {
      case "down": return CGImagePropertyOrientation.down
      case "left": return CGImagePropertyOrientation.left
      case "right": return CGImagePropertyOrientation.right
      default: return CGImagePropertyOrientation.up
    }
  }

}
