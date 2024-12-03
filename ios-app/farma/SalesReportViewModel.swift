import Foundation
import PDFKit
import UIKit

class SalesReportViewModel: ObservableObject {
    @Published var salesData: [SalesData] = []
    @Published var errorMessage: String?

    // Fetch sales data for the selected range
    func fetchSalesData(for range: String) {
        let urlString = "http://localhost:3000/api/v1/reports/sales?range=\(range)&timestamp=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch sales data: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([String: [SalesData]].self, from: data)
                DispatchQueue.main.async {
                    self.salesData = decodedResponse["salesReport"] ?? []
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse sales data."
                }
            }
        }
        .resume()
    }

    // Function to download the report in CSV format
    func downloadCSV(completion: @escaping (URL) -> Void) {
        let csvHeader = "Date, Total Price\n"
        var csvString = csvHeader

        // Add sales data to CSV string
        for data in salesData {
            csvString += "\(data.date), \(data.total_price)\n"
        }

        let fileName = "sales_report.csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved at: \(fileURL)")
            completion(fileURL) // Call the completion handler with the URL
        } catch {
            print("Error saving CSV file: \(error.localizedDescription)")
        }
    }

    // Function to download the report in PDF format
    func downloadPDF(completion: @escaping (URL) -> Void) {
        let pdfDocument = createPDFDocument()

        let fileName = "sales_report.pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try pdfDocument.write(to: fileURL)
            print("PDF file saved at: \(fileURL)")
            completion(fileURL) // Call the completion handler with the URL
        } catch {
            print("Error saving PDF file: \(error.localizedDescription)")
        }
    }

    // Helper function to create a PDF document from sales data
    private func createPDFDocument() -> PDFDocument {
        let pdfDocument = PDFDocument()

        let pageSize = CGSize(width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let data = renderer.pdfData { context in
            context.beginPage()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]

            var yPosition: CGFloat = 30

            // Add title
            let title = "Sales Report"
            let titleAttributedString = NSAttributedString(string: title, attributes: titleAttributes)
            titleAttributedString.draw(at: CGPoint(x: 20, y: yPosition))
            yPosition += 40

            // Add sales data
            for data in salesData {
                let text = "Date: \(data.date)\nTotal Price: \(data.total_price)\n\n"
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                attributedString.draw(at: CGPoint(x: 20, y: yPosition))
                yPosition += 60
            }
        }

        if let pdfDoc = PDFDocument(data: data) {
            return pdfDoc
        } else {
            return PDFDocument()
        }
    }
}
