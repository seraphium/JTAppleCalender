//
//  ViewController.swift
//  testApplicationCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    
    @IBOutlet weak var calendarView: JTCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBAction func reloadCalendarView(sender: UIButton) {
        calendarView.changeNumberOfRowsPerMonthTo(3, withFocusDate: NSDate())
    }
    
    @IBAction func reloadCalendarViewTo6(sender: UIButton) {
        calendarView.changeNumberOfRowsPerMonthTo(6, withFocusDate: NSDate())
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        
        calendarView.dataSource = self
        calendarView.delegate = self

        calendarView.cellInset = CGPoint(x: 0.0, y: 0.0)
        calendarView.registerCellViewXib(fileName: "cellView")
        calendarView.direction = .Horizontal
        
        

        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var date = formatter.dateFromString("2016-01-01")!
        
        

        date = formatter.dateFromString("2016-03-01")!

        calendarView.numberOfRowsPerMonth = 6
        
        self.calendarView.scrollToDate(date, animateScroll: false, completionHandler: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func delayRunOnMainThread(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calendarView.frame = self.calendarView.frame
    }

}

// MARK : KDCalendarDelegate
extension ViewController: JTCalendarViewDataSource, JTCalendarViewDelegate {
    
    func configureCalendar() -> (startDate: NSDate, endDate: NSDate, calendar: NSCalendar) {
        let startDateComponents = NSDateComponents()
        startDateComponents.month = -2
        let today = NSDate()
        let firstDate = NSCalendar.currentCalendar().dateByAddingComponents(startDateComponents, toDate: today, options: NSCalendarOptions())
        
        let endDateComponents = NSDateComponents()
        endDateComponents.month = 1
        let secondDate = NSCalendar.currentCalendar().dateByAddingComponents(endDateComponents, toDate: today, options: NSCalendarOptions())

//        let  calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!

        let calendar = NSCalendar.currentCalendar()

        return (startDate: firstDate!, endDate: secondDate!, calendar: calendar)
    }

    func calendar<cell : UIView where cell : protocol<JTDayCellViewProtocol>>(
        calendar: JTCalendarView,
        isAboutToDisplayCell cell: cell,
        date: NSDate,
        cellState: CellState)
    {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, userCellState: nil, date: date)
    }

    func calendar(calendar: JTCalendarView, didDeselectDate date: NSDate, cell: JTDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
    }
    
    func calendar(calendar: JTCalendarView, didSelectDate date: NSDate, cell: JTDayCellView, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        print( date)
    }
    
    func calendar(calendar: JTCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) {
        if let _ = date, _ = endingWithDate {
            let  gmtCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            gmtCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
            
            let month = gmtCalendar.component(NSCalendarUnit.Month, fromDate: date!)
            let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
            let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: date!)
            monthLabel.text = monthName + " " + String(year)
        }
        
    }
}




