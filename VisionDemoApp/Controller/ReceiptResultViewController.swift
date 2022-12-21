//
//  ReceiptResultViewController.swift
//  VisionDemoApp
//
//  Created by Samuel Wahome on 21/12/2022.
//

import UIKit
import Vision

//MARK: - UITableViewController Extension
class ReceiptResultViewController: UITableViewController {

    static let tableCellIdentifier = "receiptCell"

    static let textHeightThreshold: CGFloat = 0.025
    
    typealias ReceiptContentField = (name: String, value: String)

    // The information to fetch from a scanned receipt.
    struct ReceiptContents {

        var name: String?
        var items = [ReceiptContentField]()
    }
    
    var contents = ReceiptContents()
}

// MARK: UITableViewDataSource Extension
extension ReceiptResultViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = contents.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptResultViewController.tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = field.name
        cell.detailTextLabel?.text = field.value
        return cell
    }
}
    
    // MARK: RecognizedTextDataSource Extension
extension ReceiptResultViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        var currLabel: String?
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            let isLarge = (observation.boundingBox.height > ReceiptResultViewController.textHeightThreshold)
            var text = candidate.string
            var valueQualifier: VNRecognizedTextObservation?
            
            if isLarge {
                if let label = currLabel {
                    if let qualifier = valueQualifier {
                        if abs(qualifier.boundingBox.minY - observation.boundingBox.minY) < 0.01 {
                            
                            let qualifierCandidate = qualifier.topCandidates(1)[0]
                            text = qualifierCandidate.string + " " + text
                        }
                        valueQualifier = nil
                    }
                    contents.items.append((label, text))
                    currLabel = nil
                } else if contents.name == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    contents.name = text
                }
            } else {
                if text.starts(with: "#") {
                    contents.items.append(("Order", text))
                } else if currLabel == nil {
                    currLabel = text
                } else {
                    do {
                        let types: NSTextCheckingResult.CheckingType = [.date]
                        let detector = try NSDataDetector(types: types.rawValue)
                        let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                        if !matches.isEmpty {
                            contents.items.append(("Date", text))
                        } else {
                            // This observation is potentially a qualifier.
                            valueQualifier = observation
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
        }
        tableView.reloadData()
        navigationItem.title = contents.name != nil ? contents.name : "Scanned Receipt"
    }
}
