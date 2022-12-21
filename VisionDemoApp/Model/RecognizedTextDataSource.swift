//
//  RecognizedTextDataSource.swift
//  VisionDemoApp
//
//  Created by Samuel Wahome on 21/12/2022.
//

import UIKit
import Vision

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}
