//
//  ViewController.swift
//  testApplicationCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import JTAppleCalendar

class ViewController: UIViewController {

    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    let formatter = NSDateFormatter()
    
    @IBAction func reloadCalendarView(sender: UIButton) {
        let date = formatter.dateFromString("2016 04 11")
        calendarView.changeNumberOfRowsPerMonthTo(3, withFocusDate: date)
    }
    
    @IBAction func reloadCalendarViewTo6(sender: UIButton) {
        let date = formatter.dateFromString("2016 04 11")
        calendarView.changeNumberOfRowsPerMonthTo(6, withFocusDate: date)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy MM dd"

        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(fileName: "CellView")     // manditory
        
        // The following default code can be removed since they are already the default.
        // They are only included here so that you can know what properties can be configured
        calendarView.direction = .Horizontal                       // default is horizontal
        calendarView.numberOfRowsPerMonth = 6                      // default is 6
        calendarView.cellInset = CGPoint(x: 0, y: 0)               // default is (3,3)
        calendarView.allowsMultipleSelection = false               // default is false
        calendarView.bufferTop = 0                                 // default is 0. - still work in progress
        calendarView.bufferBottom = 0                              // default is 0. - still work in progress
        calendarView.firstDayOfWeek = .Sunday                      // default is Sunday
        calendarView.reloadData()
    }
    
    @IBAction func select10(sender: AnyObject?) {
        calendarView.allowsMultipleSelection = true
        var dates: [NSDate] = []
        
        dates.append(formatter.dateFromString("2016 02 03")!)
        dates.append(formatter.dateFromString("2016 02 05")!)
        dates.append(formatter.dateFromString("2016 02 07")!)
        dates.append(formatter.dateFromString("2020 02 16")!) // --> This date will never be selected as it is outsde bounds
                                                              // --> This is what happens when you select an invalid date
                                                              // --> It is simply not selected
        calendarView.selectDates(dates, triggerSelectionDelegate: false)
    }
    
    @IBAction func select11(sender: AnyObject?) {
//        calendarView.allowsMultipleSelection = false
        let date = formatter.dateFromString("2016 02 11")
        self.calendarView.selectDates([date!])
    }
    
    @IBAction func scrollToDate(sender: AnyObject?) {
        let date = formatter.dateFromString("2016 03 11")
        calendarView.scrollToDate(date!)
    }
    
    @IBAction func printSelectedDates() {
        print("Selected dates --->")
        for date in calendarView.selectedDates {
            print(formatter.stringFromDate(date))
        }
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
        calendarView.frame = calendarView.frame
    }
}

// MARK : JTAppleCalendarDelegate
extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, calendar: NSCalendar) {
        let startDateComponents = NSDateComponents()
        startDateComponents.month = -2
        let today = formatter.dateFromString("2016 04 05")!
        let firstDate = NSCalendar.currentCalendar().dateByAddingComponents(startDateComponents, toDate: today, options: NSCalendarOptions())
        
        let endDateComponents = NSDateComponents()
        endDateComponents.month = 1
        let secondDate = NSCalendar.currentCalendar().dateByAddingComponents(endDateComponents, toDate: today, options: NSCalendarOptions())

        let calendar = NSCalendar.currentCalendar()

        return (startDate: firstDate!, endDate: secondDate!, calendar: calendar)
    }

    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as! CellView).setupCellBeforeDisplay(cellState, date: date)
    }

    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        printSelectedDates()
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        printSelectedDates()
        
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) {
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




