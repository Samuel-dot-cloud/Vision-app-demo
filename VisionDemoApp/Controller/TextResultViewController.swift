//
//  TextResultViewController.swift
//  VisionDemoApp
//
//  Created by Samuel Wahome on 21/12/2022.
//

import UIKit
import Vision

class TextResultViewController: UIViewController {

    @IBOutlet weak var textResult: UITextView!
    
    var transcript = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        textResult?.text = transcript
    }
}
// MARK: RecognizedTextDataSource Extension
extension TextResultViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            transcript += candidate.string
            transcript += "\n"
        }
        textResult?.text = transcript
    }
}
