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

class PriceHistoryViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter {

    //OUTLETS
    
    @IBOutlet weak var changeType: UISegmentedControl!
    @IBOutlet weak var barChart: UIView!
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var minPriceLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    //VARIABLES
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    var pricesHistory = [History]()
    var type = "h"
    var coinName = ""
    var coinCode = ""
    let df = DateFormatter()

    
    //hour
    let startUrlHour = "https://min-api.cryptocompare.com/data/v2/histominute?limit=60&fsym="
    //day
    let startUrlDay = "https://min-api.cryptocompare.com/data/v2/histominute?fsym="
    //week
    let startUrlWeek = "https://min-api.cryptocompare.com/data/v2/histohour?fsym="
    //month
    let startUrlMonth = "https://min-api.cryptocompare.com/data/v2/histoday?fsym="
    //end
    let endUrl = "&tsym=USD&api_key=YOURKEYHERE"
    
    //CHART
    
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
        
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 8)
        chartView.xAxis.setLabelCount(4, force: false)
        chartView.xAxis.labelTextColor = UIColor(named: "AdditionalCOlor")!
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = UIColor(named: "AdditionalCOlor")!
        
        chartView.animate(xAxisDuration: 2.0)
        
        return chartView
    }()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dt = pricesHistory[Int(value)].historyDate
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        if (type == "h") {
            df.dateFormat = "HH:mm"
        }
        else if (type == "d") {
            df.dateFormat = "HH:mm"
        }
        else if (type == "w") {
            df.dateFormat = "E"
        }
        else if (type == "m") {
            df.dateFormat = "MMM d"
        }
        return df.string(from: dt)
    }

    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        df.timeZone = TimeZone.current
        
        barChart.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: barChart)
        lineChartView.heightToWidth(of: barChart)
        axisFormatDelegate = self

        getCoinInfo(type: "h")
        
        let datef = DateFormatter()
        datef.dateFormat = "dd/MM/yyyy"
    
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.navigationItem.leftBarButtonItem?.title = "Back"
        self.navigationItem.title = coinName
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "BackgroundColor")!]
        navigationController?.navigationBar.tintColor = UIColor(named: "BackgroundColor")
    }
    
    //SELECTOR CHANGING
    
    @IBAction func onChanging(_ sender: Any) {
        if (changeType.selectedSegmentIndex == 0) {
            type = "h"
        }
        else if (changeType.selectedSegmentIndex == 1) {
            type = "d"
        }
        else if (changeType.selectedSegmentIndex == 2) {
            type = "w"
        }
        else if (changeType.selectedSegmentIndex == 3) {
            type = "m"
        }
        getCoinInfo(type: type)
    }
    
    //SET DATA TO CHART AND LABELS
    
    func setData() {
        lineChartView.noDataText = NSLocalizedString("No data", comment: "")
                
        pricesHistory.sort(by: {$0.historyDate < $1.historyDate})
        var yValues:[ChartDataEntry] = []
        var i = 0
        for item in pricesHistory {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(item.historyPrice), data: item.historyDate as AnyObject?)
            yValues.append(dataEntry)
            i += 1
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        
        var prices = [Double]()
        for item in pricesHistory {
            prices.append(item.historyPrice)
        }
        
        let max = Double(prices.max() ?? 0.00)
        let min = Double(prices.min() ?? 0.00)
        
        maxPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: max))!
        minPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: min))!
        var sum = 0.0
        for item in prices {
            sum += item
        }
        avgPriceLabel.text = "$ " + formatter.string(from: NSNumber(value: sum/Double(prices.count)))!
        currentPriceLabel.text = "$ " + formatter.string(from:  NSNumber(value: Database().getCurrentPrice(name: coinName)))!
        
        let set1 = LineChartDataSet(entries: yValues, label: "Price")
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
    
    //CORE DATA

    /*
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
    */
 
    //API
    
    func getCoinInfo(type: String) {
        DispatchQueue.main.async { [self] in
            pricesHistory.removeAll()
            var startUrl = ""
            if type == "h" {
                startUrl = startUrlHour
                df.dateFormat = "HH:mm"
             }
            else if type == "d" {
                startUrl = startUrlDay
                df.dateFormat = "MMM d, HH:mm"
            }
            else if type == "w" {
                startUrl = startUrlWeek
                df.dateFormat = "E, dd MMM"
            }
            else if type == "m" {
                startUrl = startUrlMonth
                df.dateFormat = "dd MMM"
            }
            let stringUrl = URL(string: startUrl + coinCode.uppercased() + endUrl)!
            AF.request(stringUrl).responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let resp = value as? [String: Any] {
                        let tmpdata = (resp["Data"] as! [String: Any])
                        let data = tmpdata["Data"] as? [[String: Any]]
                        for item in data! {
                            let str = item as [String: Any]
                            let stringtime = str["time"] as! Int
                            let stringprice = str["close"] as! Double
                            
                            let epocTime = TimeInterval(stringtime)
                            let myDate = Date(timeIntervalSince1970: epocTime)
                                       
                            df.string(from: myDate)
                            
                            pricesHistory.append(History(date: myDate, price: stringprice))
                        }
                        setData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
