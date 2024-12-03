import SwiftUI
import Charts

struct SalesReportView: View {
    @ObservedObject var viewModel = SalesReportViewModel()
    @State private var selectedRange = "Daily"
    @State private var showShareSheet = false
    @State private var fileToShare: URL?
    @State private var showPDF = false

    let ranges = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        VStack {
            Text("Sales Reports")
                .font(.largeTitle)
                .padding()

            Picker("Select Range", selection: $selectedRange) {
                ForEach(ranges, id: \.self) { range in
                    Text(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button("Generate Report") {
                viewModel.fetchSalesData(for: selectedRange)
            }
            .buttonStyle(.borderedProminent)
            .padding()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            if !viewModel.salesData.isEmpty {
                Chart(viewModel.salesData) { data in
                    BarMark(
                        x: .value("Date", data.date),
                        y: .value("Revenue", data.total_price)
                    )
                }
                .chartYAxisLabel("Revenue ($)")
                .chartXAxisLabel("Date")
                .frame(height: 300)
                .padding()
            }

            if !viewModel.salesData.isEmpty {
                HStack {
                    Button("Download as PDF") {
                        viewModel.downloadPDF { url in
                            fileToShare = url
                            showPDF = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Download as CSV") {
                        viewModel.downloadCSV { url in
                            fileToShare = url
                            showShareSheet = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("Sales Reports")
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = fileToShare {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .sheet(isPresented: $showPDF) {
            if let fileURL = fileToShare {
                PDFKitView(url: fileURL)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

