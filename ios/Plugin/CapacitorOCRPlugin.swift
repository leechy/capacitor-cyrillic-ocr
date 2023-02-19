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

  var recognizedText: [String: Any] = [
    "text": "",
    "lines": []
  ]
  var languages = ["en"]
  var imageWidth: Double = 0
  var imageHeight: Double = 0
  
  @objc func recognize(_ call: CAPPluginCall) {
    self.languages = call.getArray("languages", ["en"]) as! Array<String>
    
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
    
    // caching image size to convert the bboxes later
    self.imageWidth = Double(cgImage.width)
    self.imageHeight = Double(cgImage.height)

    // create the request
    let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
    request.recognitionLevel = .accurate
    request.recognitionLanguages = languages
    
    // create the rerquest handler
    let imageRequestHandler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: orientation,
      options: [:]
    )
    
    // add to the global queue
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try imageRequestHandler.perform([request])
        call.resolve(self.recognizedText)
      } catch let error as NSError {
        print("Failed to perform image request: \(error)")
        call.reject(error.description)
      }
    }
  }
  
  func handleDetectedText(request: VNRequest?, error: Error?) {
    if let error = error {
      NSLog("Error detecting text: \(error)")
      return
    }
    
    guard let results = request?.results, results.count > 0 else {
      NSLog("No text found")
      return
    }
    
    var fullText = ""
    var lines: [[String: Any]] = []
    for result in results {
      if let observation = result as? VNRecognizedTextObservation {
        for text in observation.topCandidates(1) {
          
          let rect = self.convertBbox(boundingBox: observation.boundingBox, width: self.imageWidth, height: self.imageHeight)
          let bbox = [
            "x0": rect.origin.x,
            "y0": rect.origin.y,
            "x1": rect.origin.x + rect.size.width,
            "y1": rect.origin.y + rect.size.height
          ]
          
          fullText += text.string + "\n"
          lines.append([
            "text": text.string,
            "confidence": text.confidence,
            "bbox": bbox,
            "words": [
              "text": text.string,
              "confidence": text.confidence,
              "bbox": bbox,
            ]
          ])
        }
      }
    }
    
    // return the tesseract-like results
    self.recognizedText = [
      "text": fullText,
      "lines": lines
    ]
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
  
  /// Convert Vision coordinates to pixel coordinates within image.
  ///
  /// Adapted from `boundingBox` method from
  /// [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
  /// This flips the y-axis.
  ///
  /// - Parameters:
  ///   - boundingBox: The bounding box returned by Vision framework.
  ///   - bounds: The bounds within the image (in pixels, not points).
  ///
  /// - Returns: The bounding box in pixel coordinates, flipped vertically so 0,0 is in the upper left corner

  func convertBbox(boundingBox: CGRect, width imageWidth: Double, height imageHeight: Double) -> CGRect {
    // Begin with input rect.
    var rect = boundingBox

    // Reposition origin.
    rect.origin.x *= imageWidth
    rect.origin.y = (1 - rect.maxY) * imageHeight

    // Rescale normalized coordinates.
    rect.size.width *= imageWidth
    rect.size.height *= imageHeight
  
    return rect
  }
}
