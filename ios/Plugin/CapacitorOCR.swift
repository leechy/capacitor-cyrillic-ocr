import Foundation
import Capacitor
import Vision

@objc public class CapacitorOCR: NSObject {

    var recognizedText: [String: Any] = [
      "text": "",
      "lines": []
    ]
    var imageWidth: Double = 0
    var imageHeight: Double = 0

    @objc public func recognize(call: CAPPluginCall, languages: Array<String>, cgImage: CGImage, orientation: CGImagePropertyOrientation) {
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

    ///  Transforms the VNRequest to the JS Array with the recognized text
    ///
    ///  - Parameters:
    ///    - request: pointer to the request to the Vision framework, to get the results
    ///    - error: error message if something is wrong
    ///
    ///  - Returns:
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
            let bbox = self.convertBbox(boundingBox: observation.boundingBox, width: self.imageWidth, height: self.imageHeight)
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

    /// Convert Vision coordinates to pixel coordinates within image.
    ///
    /// - Parameters:
    ///   - boundingBox: The bounding box returned by Vision framework.
    ///   - width: Image width in pixels.
    ///   - height: Image height in pixels.
    ///
    /// - Returns: The bounding box in pixel coordinates within the initial image.

    func convertBbox(boundingBox: CGRect, width imageWidth: Double, height imageHeight: Double) -> [String : CGFloat] {
      // Begin with input rect.
      var rect = boundingBox

      // Reposition origin.
      rect.origin.x *= imageWidth
      rect.origin.y = (1 - rect.maxY) * imageHeight

      // Rescale normalized coordinates.
      rect.size.width *= imageWidth
      rect.size.height *= imageHeight
    
      let bbox = [
        "x0": rect.origin.x,
        "y0": rect.origin.y,
        "x1": rect.origin.x + rect.size.width,
        "y1": rect.origin.y + rect.size.height
      ]
      return bbox
    }
}
