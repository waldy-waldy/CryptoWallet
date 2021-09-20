//
//  PriceHistoryViewController.swift
//  CryptoWallet
//
//  Created by neoviso on 9/16/21.
//

import UIKit
import Alamofire
import Charts
import TinyConstraints

extension PriceHistoryViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dt = pricesHistory[Int(value)].historyDate
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df.string(from: dt)
    }
}

class History {
    var historyDate: Date = Date()
    var historyPrice: Double = 0.0
    
    init(date: Date, price: Double) {
        historyDate = date
        historyPrice = price
    }
}

class PriceHistoryViewController: UIViewController, ChartViewDelegate {

    weak var axisFormatDelegate: IAxisValueFormatter?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var pricesHistory = [History]()
    
    @IBOutlet weak var changeType: UISegmentedControl!
    @IBOutlet weak var barChart: UIView!
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var minPriceLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    var coinName = ""
    var coinCode = ""
    let startUrl = "https://min-api.cryptocompare.com/data/v2/histominute?fsym="
    let endUrl = "&tsym=USD&api_key=YOURKEYHERE"
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = UIColor(named: "BackgroundColor")
        
        chartView.rightAxis.enabled = false
        chartView.doubleTapToZoomEnabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 10)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = UIColor(named: "AdditionalCOlor")!
        yAxis.labelPosition = .outsideChart
        yAxis.axisLineColor = UIColor(named: "AdditionalCOlor")!
        
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.xAxis.labelTextColor = UIColor(named: "AdditionalCOlor")!
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = UIColor(named: "AdditionalCOlor")!
        
        chartView.animate(xAxisDuration: 2.0)
        
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        
        barChart.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: barChart)
        lineChartView.heightToWidth(of: barChart)
        axisFormatDelegate = self
        
        getCoinInfo()
        
        //
        let datef = DateFormatter()
        datef.dateFormat = "dd/MM/yyyy"
        
        pricesHistory.append(History(date: datef.date(from: "12/01/2021")!, price: 2354.00))
        pricesHistory.append(History(date: datef.date(from: "12/02/2021")!, price: 23524.00))
        pricesHistory.append(History(date: datef.date(from: "12/03/2021")!, price: 8354.00))
        pricesHistory.append(History(date: datef.date(from: "12/04/2021")!, price: 12354.00))
        pricesHistory.append(History(date: datef.date(from: "12/05/2021")!, price: 12454.00))
        pricesHistory.append(History(date: datef.date(from: "12/06/2021")!, price: 21354.00))
        pricesHistory.append(History(date: datef.date(from: "12/07/2021")!, price: 23534.00))
        pricesHistory.append(History(date: datef.date(from: "12/08/2021")!, price: 25554.00))
        pricesHistory.append(History(date: datef.date(from: "12/09/2021")!, price: 32504.00))
        pricesHistory.append(History(date: datef.date(from: "12/10/2021")!, price: 22354.00))
        pricesHistory.append(History(date: datef.date(from: "12/11/2021")!, price: 28354.00))
        pricesHistory.append(History(date: datef.date(from: "12/12/2021")!, price: 23254.00))
        
 
        setData()
        
        var prices = [Double]()
        for item in pricesHistory {
            prices.append(item.historyPrice)
        }
        
        let max = Double(prices.max()!)
        let min = Double(prices.min()!)
        
        maxPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: max))!
        minPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: min))!
        var sum = 0.0
        for item in prices {
            sum += item
        }
        avgPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: sum/Double(prices.count)))!
        currentPriceLabel.text = "$ " + formatter.string(from:  NSNumber(value: getCurrentPrice(name: coinName)))!
        
        
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.navigationItem.leftBarButtonItem?.title = "Back"
        self.navigationItem.title = coinName
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BackgroundColor")]
        navigationController?.navigationBar.tintColor = UIColor(named: "BackgroundColor")
        // Do any additional setup after loading the view.
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //
    }
    
    func setData() {
        lineChartView.noDataText = "No information"
        var yValues:[ChartDataEntry] = []
        var i = 0
        for item in pricesHistory {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(item.historyPrice), data: item.historyDate as AnyObject?)
            yValues.append(dataEntry)
            i += 1
        }
        
        let set1 = LineChartDataSet(entries: yValues, label: "Price")
        
        //let chartMarker: ChartMaker = (ChartMaker.viewFromXib() as? ChartMaker)!
        //chartMarker.chartView = lineChartView
        //lineChartView.marker = chartMarker
        
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 3
        set1.setColor(UIColor(named: "PrimaryColor")!)
        set1.fill = Fill(color: UIColor(named: "PrimaryColor")!)
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor = UIColor(named: "ValueDown")!
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
        let xAxisValue = lineChartView.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
    }

    func getCurrentPrice(name: String) -> Double {
        var pr = 0.00
        do {
            let items = try context.fetch(CoinsEntity.fetchRequest()) as! [CoinsEntity]
            pr = items.first(where: { $0.name == name})!.price
        }
        catch {
            context.rollback()
        }
        return pr
    }
    
    /*
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0, data: "1 Jan 2020" as AnyObject?),
        ChartDataEntry(x: 1.0, y: 67.0, data: "1 Feb 2020" as AnyObject?),
        ChartDataEntry(x: 2.0, y: 90.0, data: "1 Mar 2020" as AnyObject?),
        ChartDataEntry(x: 3.0, y: 35.0, data: "1 Apr 2020" as AnyObject?),
        ChartDataEntry(x: 4.0, y: 13.0, data: "1 May 2020" as AnyObject?),
        ChartDataEntry(x: 5.0, y: 35.0, data: "1 Jun 2020" as AnyObject?),
        ChartDataEntry(x: 6.0, y: 63.0, data: "1 Jul 2020" as AnyObject?),
        ChartDataEntry(x: 7.0, y: 23.0, data: "1 Aug 2020" as AnyObject?),
        ChartDataEntry(x: 8.0, y: 53.0, data: "1 Sep 2020" as AnyObject?),
        ChartDataEntry(x: 9.0, y: 42.0, data: "1 Oct 2020" as AnyObject?),
        ChartDataEntry(x: 10.0, y: 72.0, data: "1 Nov 2020" as AnyObject?),
        ChartDataEntry(x: 11.0, y: 52.0, data: "1 Dec 2020" as AnyObject?),
        ChartDataEntry(x: 12.0, y: 66.0, data: "1 Jan 2021" as AnyObject?),
        ChartDataEntry(x: 13.0, y: 52.0, data: "1 Feb 2021" as AnyObject?),
        ChartDataEntry(x: 14.0, y: 63.0, data: "1 Mar 2021" as AnyObject?),
        ChartDataEntry(x: 15.0, y: 16.0, data: "1 Apr 2021" as AnyObject?),
        ChartDataEntry(x: 16.0, y: 24.0, data: "1 May 2021" as AnyObject?),
        ChartDataEntry(x: 17.0, y: 25.0, data: "1 Jun 2021" as AnyObject?),
        ChartDataEntry(x: 18.0, y: 36.0, data: "1 Jul 2021" as AnyObject?),
        ChartDataEntry(x: 19.0, y: 74.0, data: "1 Aug 2021" as AnyObject?),
        ChartDataEntry(x: 20.0, y: 21.0, data: "1 Sep 2021" as AnyObject?),
        ChartDataEntry(x: 21.0, y: 12.0, data: "1 Oct 2021" as AnyObject?)
    ]
    */
    
    
    func getCoinInfo() {
        DispatchQueue.main.async { [self] in
            var stringUrl = URL(string: startUrl + coinCode.uppercased() + endUrl)!
            AF.request(stringUrl).responseJSON { [weak self] response in
                switch response.result {
                case .success(let value):
                    print(value)
                    if let resp = value as? [String: Any] {
                        /*
                        let data = (resp["data"] as? [Any])!
                        for item in data {
                            let str = item as? [String: Any]
                            let stringprice = str!["priceUsd"] as! Double
                            let stringdate = str!["date"] as! Date
                            print(stringdate)
                            print(stringprice)
                        }
                        */
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
