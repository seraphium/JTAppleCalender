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
    let testCalendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    
    @IBAction func reloadView(sender: UIButton) {
        calendarView.reloadData()
    }
    
    @IBAction func changeToThreeRows(sender: UIButton) {
        let date = formatter.dateFromString("2016 04 11")
        calendarView.changeNumberOfRowsPerMonthTo(3, withFocusDate: date)
    }
    
    @IBAction func changeToSixRows(sender: UIButton) {
        let date = formatter.dateFromString("2016 04 11")
        calendarView.changeNumberOfRowsPerMonthTo(6, withFocusDate: date)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy MM dd"
        testCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!

        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.registerCellViewXib(fileName: "CellView") // manditory
        calendarView.registerHeaderViewXibs(fileNames: ["PinkSectionHeaderView", "WhiteSectionHeaderView"]) // Optional
        
        // The following default code can be removed since they are already the default.
        // They are only included here so that you can know what properties can be configured
//        calendarView.direction = .Vertical                         // default is horizontal
        calendarView.numberOfRowsPerMonth = 6                      // default is 6
        calendarView.cellInset = CGPoint(x: 0, y: 0)               // default is (3,3)
        calendarView.allowsMultipleSelection = false               // default is false
        calendarView.bufferTop = 0                                 // default is 0. - still work in progress
        calendarView.bufferBottom = 0                              // default is 0. - still work in progress
        calendarView.firstDayOfWeek = .Sunday                      // default is Sunday
        calendarView.scrollEnabled = true                          // default is true
        calendarView.pagingEnabled = false                         // default is true
        calendarView.scrollResistance = 0.75                       // default is 0.75 - this is only applicable when paging is not enabled
        calendarView.reloadData()
        
        let currentDate = calendarView.currentCalendarDateSegment()
        setupViewsOfCalendar(currentDate.startDate, endDate: currentDate.endDate)
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
        calendarView.allowsMultipleSelection = false
        let date = formatter.dateFromString("2016 02 11")
        self.calendarView.selectDates([date!], triggerSelectionDelegate: false)
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
    
    func setupViewsOfCalendar(startDate: NSDate, endDate: NSDate) {
        let month = testCalendar.component(NSCalendarUnit.Month, fromDate: startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: startDate)
        monthLabel.text = monthName + " " + String(year)
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
        
        let firstDate = formatter.dateFromString("2016 01 05")
        let secondDate = NSDate()
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here

        return (startDate: firstDate!, endDate: secondDate, calendar: aCalendar)
    }

    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as! CellView).setupCellBeforeDisplay(cellState, date: date)
    }

    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
//        printSelectedDates()
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
//        printSelectedDates()
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) {
        if let startDate = date, endDate = endingWithDate {
            setupViewsOfCalendar(startDate, endDate: endDate)
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {
        let comp = testCalendar.component(.Month, fromDate: date.startDate)
        if comp % 2 > 0{
            return "WhiteSectionHeaderView"
        }
        return "PinkSectionHeaderView"
    }
   
    func calendar(calendar: JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {
        if formatter.stringFromDate(date.startDate) == "2016 01 01" {
            return CGSize(width: 200, height: 100)
        } else {
//            return CGSizeZero
            return CGSize(width: 200, height: 200) // Yes you can have different size headers
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {
        switch identifier {
        case "WhiteSectionHeaderView":
            let headerCell = (header as? WhiteSectionHeaderView)
            headerCell?.title.text = "Design your own header"
        default:
            let headerCell = (header as? PinkSectionHeaderView)
            headerCell?.title.text = "However you want"
        }
    }
}
