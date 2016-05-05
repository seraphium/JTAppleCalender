//
//  JTAppleCalendarView.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

let cellReuseIdentifier = "JTDayCell"

let NUMBER_OF_DAYS_IN_WEEK = 7

let MAX_NUMBER_OF_DAYS_IN_WEEK = 7                              // Should not be changed
let MIN_NUMBER_OF_DAYS_IN_WEEK = MAX_NUMBER_OF_DAYS_IN_WEEK     // Should not be changed
let MAX_NUMBER_OF_ROWS_PER_MONTH = 6                            // Should not be changed
let MIN_NUMBER_OF_ROWS_PER_MONTH = 1                            // Should not be changed

let FIRST_DAY_INDEX = 0
let OFFSET_CALC = 2
let NUMBER_OF_DAYS_INDEX = 1
let DATE_SELECTED_INDEX = 2
let TOTAL_DAYS_IN_MONTH = 3
let DATE_BOUNDRY = 4

/// Describes which month the cell belongs to
/// - ThisMonth: Cell belongs to the current month
/// - PreviousMonthWithinBoundary: Cell belongs to the previous month. Previous month is included in the date boundary you have set in your delegate
/// - PreviousMonthOutsideBoundary: Cell belongs to the previous month. Previous month is not included in the date boundary you have set in your delegate
/// - FollowingMonthWithinBoundary: Cell belongs to the following month. Following month is included in the date boundary you have set in your delegate
/// - FollowingMonthOutsideBoundary: Cell belongs to the following month. Following month is not included in the date boundary you have set in your delegate
///
/// You can use these cell states to configure how you want your date cells to look. Eg. you can have the colors belonging to the month be in color black, while the colors of previous months be in color gray.
public struct CellState {
    /// Describes which month owns the date
    public enum DateOwner: Int {
        /// Describes which month owns the date
        case ThisMonth = 0, PreviousMonthWithinBoundary, PreviousMonthOutsideBoundary, FollowingMonthWithinBoundary, FollowingMonthOutsideBoundary
    }
    /// returns true if a cell is selected
    public let isSelected: Bool
    /// returns the date as a string
    public let text: String
    /// returns the a description of which month owns the date
    public let dateBelongsTo: DateOwner
    /// returns the date
    public let date: NSDate
    /// returns the day
    public let day: DaysOfWeek
    
}

/// Days of the week. By setting you calandar's first day of week, you can change which day is the first for the week. Sunday is by default.
public enum DaysOfWeek: Int {
    /// Days of the week.
    case Sunday = 7, Monday = 6, Tuesday = 5, Wednesday = 4, Thursday = 10, Friday = 9, Saturday = 8
}

protocol JTAppleCalendarDelegateProtocol: class {
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfSections() -> Int
}

/// The JTAppleCalendarViewDataSource protocol is adopted by an object that mediates the application’s data model for a JTAppleCalendarViewDataSource object. The data source provides the calendar-view object with the information it needs to construct and modify it self
public protocol JTAppleCalendarViewDataSource {
    /// Asks the data source to return the start and end boundary dates as well as the calendar to use. You should properly configure your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - startDate: The *start* boundary date for your calendarView.
    ///     - endDate: The *end* boundary date for your calendarView.
    ///     - calendar: The *calendar* to be used by the calendarView.
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, calendar: NSCalendar)
}


/// The delegate of a JTAppleCalendarView object must adopt the JTAppleCalendarViewDelegate protocol.
/// Optional methods of the protocol allow the delegate to manage selections, and configure the cells.
public protocol JTAppleCalendarViewDelegate {
    /// Asks the delegate if selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(calendar : JTAppleCalendarView, canSelectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    
    /// Asks the delegate if de-selecting the date-cell with a specified date is allowed
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point.
    ///     - cellState: The month the date-cell belongs to.
    /// - returns: A Bool value indicating if the operation can be done.
    func calendar(calendar : JTAppleCalendarView, canDeselectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool
    
    /// Tells the delegate that a date-cell with a specified date was selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, didSelectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) -> Void
    
    /// Tells the delegate that a date-cell with a specified date was de-selected
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date attached to the date-cell.
    ///     - cell: The date-cell view. This can be customized at this point. This may be nil if the selected cell is off the screen
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, didDeselectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) -> Void
    
    /// Tells the delegate that the JTAppleCalendar view scrolled to a segment beginning and ending with a particular date
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - date: The date at the start of the segment.
    ///     - cell: The date at the end of the segment.
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) -> Void
    
    /// Tells the delegate that the JTAppleCalendar is about to display a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The date-cell that is about to be displayed.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) -> Void
}
/// Default delegate functions
public extension JTAppleCalendarViewDelegate {
    func calendar(calendar : JTAppleCalendarView, canSelectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, canDeselectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, didSelectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didDeselectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWith date: NSDate?, endingWithDate: NSDate?) {}
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) {}
}

/// An instance of JTAppleCalendarView (or simply, a calendar view) is a means for displaying and interacting with a gridstyle layout of date-cells
public class JTAppleCalendarView: UIView {
    /// The amount of buffer space before the first row of date-cells
    public var bufferTop: CGFloat    = 0.0
    /// The amount of buffer space after the last row of date-cells
    public var bufferBottom: CGFloat = 0.0
    /// Enables and disables animations when scrolling to and from date-cells
    public var animationsEnabled = true
    /// The scroll direction of the sections in JTAppleCalendar.
    public var direction : UICollectionViewScrollDirection = .Horizontal {
        didSet {
            let layout = generateNewLayout()
            calendarView.collectionViewLayout = layout
            reloadData(false)
        }
    }
    /// Enables/Disables multiple selection on JTAppleCalendar
    public var allowsMultipleSelection: Bool = false {
        didSet {
            self.calendarView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    /// First day of the week value for JTApleCalendar. You can set this to anyday
    public var firstDayOfWeek = DaysOfWeek.Sunday
    
    private var layoutNeedsUpdating = false
    /// Number of rows to be displayed per month. Allowed values are 1, 2, 3 & 6.
    /// After changing this value, you should reload your calendarView to show your change
    public var numberOfRowsPerMonth = 6 {
        didSet {
            if numberOfRowsPerMonth == 4 || numberOfRowsPerMonth == 5 || numberOfRowsPerMonth > 6 || numberOfRowsPerMonth < 0 {numberOfRowsPerMonth = 6}
            if cachedConfiguration != nil {
                layoutNeedsUpdating = true
            }
        }
    }
    /// The object that acts as the data source of the calendar view.
    public var dataSource : JTAppleCalendarViewDataSource? {
        didSet {
            if monthInfo.count < 1 {
                monthInfo = setupMonthInfoDataForStartAndEndDate()
            }
            reloadData(false)
        }
    }
    /// The object that acts as the delegate of the calendar view.
    public var delegate : JTAppleCalendarViewDelegate?
    private var dateComponents = NSDateComponents()
    private var scrollToDatePathOnRowChange: NSDate?
    private var delayedExecutionClosure: (()->Void)?
    private var currentSectionPage: Int {
        let cvbounds = self.calendarView.bounds
        var page : Int = 0
        if self.direction == .Horizontal {
            page = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        } else {
            page = Int(floor(self.calendarView.contentOffset.y / cvbounds.size.height))
        }
        let totalSections = monthInfo.count * numberOfSectionsPerMonth
        if page >= totalSections {return totalSections - 1}
        return page > 0 ? page : 0
    }
    
    lazy private var startDateCache : NSDate? = {
        [weak self] in
        self!.cachedConfiguration?.startDate
        }()
    
    lazy private var endDateCache : NSDate? = {
        [weak self] in
        self!.cachedConfiguration?.startDate
        }()
    
    lazy private var calendar : NSCalendar? = {
        [weak self] in
        self!.cachedConfiguration?.calendar
        }()
    
    lazy private var cachedConfiguration : (startDate: NSDate, endDate: NSDate, calendar: NSCalendar)? = {
        [weak self] in
        print(self!.dataSource)
        if let  config = self!.dataSource?.configureCalendar(self!) {
            return (startDate: config.startDate, endDate: config.endDate, calendar: config.calendar)
        }
        return nil
        }()
    
    lazy private var startOfMonthCache : NSDate = {
        [weak self] in
        let currentDate = NSDate()
        guard let validCachedConfig = self!.cachedConfiguration else {
            
            print("Error: Date was not correctly generated for start of month. current date was used: \(currentDate)")
            return currentDate
        }
        let dayOneComponents = validCachedConfig.calendar.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: validCachedConfig.startDate)
        if let date = validCachedConfig.calendar.dateFromComponents(dayOneComponents) {
            return date
        }
        
        print("Error: Date was not correctly generated for start of month. current date was used: \(currentDate)")
        return currentDate
        }()
    
    lazy private var endOfMonthCache : NSDate = {
        [weak self] in
        // set last of month
        
        let currentDate = NSDate()
        guard let validCachedConfig = self!.cachedConfiguration else {
            
            print("Error: Date was not correctly generated for start of month. current date was used: \(currentDate)")
            return currentDate
        }
        
        
        let lastDayComponents = validCachedConfig.calendar.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: validCachedConfig.endDate)
        lastDayComponents.month = lastDayComponents.month + 1
        lastDayComponents.day = 0
        if let returnDate = validCachedConfig.calendar.dateFromComponents(lastDayComponents) {
            return returnDate
        }
        
        print("Error: Date was not correctly generated for end of month. current date was used: \(currentDate)")
        return currentDate
        }()
    
    
    private(set) var selectedIndexPaths : [NSIndexPath] = [NSIndexPath]()
    /// Returns all selected dates
    public var selectedDates : [NSDate] = [NSDate]()
    
    lazy private var monthInfo : [[Int]] = {
        [weak self] in
        let newMonthInfo = self!.setupMonthInfoDataForStartAndEndDate()
        return newMonthInfo
        }()
    
    
    private var numberOfMonthSections: Int = 0
    private var numberOfSectionsPerMonth: Int = 0
    private var numberOfItemsPerSection: Int {return MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth}
    
    /// Cell inset padding for the x and y axis of every date-cell on the calendar view.
    public var cellInset: CGPoint {
        get {return internalCellInset}
        set {internalCellInset = newValue}
    }
    
    /// Enable or disable paging when the calendar view is scrolled
    public var pagingEnabled: Bool = true {
        didSet {
            calendarView.pagingEnabled = pagingEnabled
        }
    }
    
    
    /// Enable or disable swipe scrolling of the calendar with this variable
    public var scrollEnabled: Bool = true {
        didSet {
            calendarView.scrollEnabled = scrollEnabled
        }
    }
    
    /// This is only applicable when calendar view paging is not enabled. Use this variable to decelerate the scroll movement to make it more 'sticky' or more fluid scrolling
    public var scrollResistance: CGFloat = 0.75
    
    lazy private var calendarView : UICollectionView = {
        let layout = JTAppleCalendarHorizontalFlowLayout(withDelegate: self)
        layout.scrollDirection = self.direction
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.pagingEnabled = true
        cv.backgroundColor = UIColor.clearColor()
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    private func updateLayoutItemSize (layout: JTAppleCalendarLayoutProtocol) {
        layout.itemSize = CGSizeMake(
            self.calendarView.frame.size.width / CGFloat(MAX_NUMBER_OF_DAYS_IN_WEEK),
            (self.calendarView.frame.size.height - layout.headerReferenceSize.height) / CGFloat(numberOfRowsPerMonth)
        )
        self.calendarView.collectionViewLayout = layout as! UICollectionViewLayout
    }
    
    /// The frame rectangle which defines the view's location and size in its superview coordinate system.
    override public var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x:0.0, y:bufferTop, width: self.frame.size.width, height:self.frame.size.height - bufferBottom)
            calendarView.collectionViewLayout.invalidateLayout()
            updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame : CGRectMake(0.0, 0.0, 200.0, 200.0))
        self.initialSetup()
    }
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override public func awakeFromNib() {
        self.initialSetup()
    }
    
    /// Lays out subviews.
    override public func layoutSubviews() {
        self.frame = super.frame
    }
    
    // MARK: Setup
    func initialSetup() {
        self.clipsToBounds = true
        self.calendarView.registerClass(JTAppleDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.calendarView)
    }
    
    /// Let's the calendar know which cell xib to use for the displaying of it's date-cells.
    /// - Parameter name: The name of the xib of your cell design
    public func registerCellViewXib(fileName name: String) {
        cellViewXibName = name
    }
    
    
    /// Reloads the data on the calendar view
    public func reloadData() {
        reloadData(true)
    }
    
    private func reloadData(checkDelegateDataSource: Bool) {
        
        if checkDelegateDataSource {
            self.checkDelegateDataSource() // Reload the datasource
        }
        
        // Delay on main thread. We want this to be called after the view is displayed ont he main run loop
        if self.layoutNeedsUpdating {
            delayRunOnMainThread(0.0, closure: {
                self.changeNumberOfRowsPerMonthTo(self.numberOfRowsPerMonth, withFocusDate: nil)
            })
        } else {
            self.calendarView.reloadData()
        }
        
    }
    
    private func checkDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self),
            oldDateBoundary = cachedConfiguration {
            // Jt101 do a check in each lazy var to see if user has bad star/end dates
            let newStartOfMonth = NSDate.startOfMonthForDate(newDateBoundary.startDate, usingCalendar: oldDateBoundary.calendar)
            let newEndOfMonth = NSDate.endOfMonthForDate(newDateBoundary.startDate, usingCalendar: oldDateBoundary.calendar)
            let oldStartOfMonth = NSDate.startOfMonthForDate(oldDateBoundary.startDate, usingCalendar: oldDateBoundary.calendar)
            let oldEndOfMonth = NSDate.endOfMonthForDate(oldDateBoundary.startDate, usingCalendar: oldDateBoundary.calendar)
            
            if
                newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != oldDateBoundary.calendar {
                    startDateCache = newDateBoundary.startDate
                    endDateCache = newDateBoundary.endDate
                    calendar = newDateBoundary.calendar
                    layoutNeedsUpdating = true
            }
        }
    }
    
    /// Change the number of rows per month on the calendar view. Once the row count is changed, the calendar view will auto-focus on the date provided. The calendarView will also reload its data.
    /// - Parameter number: The number of rows per month the calendar view should display. This is restricted to 1, 2, 3, & 6. 6 will be chosen as default.
    public func changeNumberOfRowsPerMonthTo(number: Int, withFocusDate date: NSDate?) {
        self.scrollToDatePathOnRowChange = date
        switch number {
        case 1, 2, 3:
            self.numberOfRowsPerMonth = number
        default:
            self.numberOfRowsPerMonth = 6
        }
        self.configureChangeOfRows()
    }
    
    private func configureChangeOfRows() {
        selectedDates.removeAll()
        selectedIndexPaths.removeAll()
        
        monthInfo = setupMonthInfoDataForStartAndEndDate()
        
        let layout = calendarView.collectionViewLayout
        updateLayoutItemSize(layout as! JTAppleCalendarLayoutProtocol)
        self.calendarView.setCollectionViewLayout(layout, animated: true)
        self.calendarView.reloadData()
        layoutNeedsUpdating = false
        
        
        guard let dateToScrollTo = scrollToDatePathOnRowChange else {
            // If the date is invalid just scroll to the the first item on the view
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: position, animated: animationsEnabled)
            return
        }
        
        delayRunOnMainThread(0.0, closure: { () -> () in
            self.scrollToDate(dateToScrollTo)
        })
    }
    
    func generateNewLayout() -> UICollectionViewLayout {
        if direction == .Horizontal {
            let layout = JTAppleCalendarHorizontalFlowLayout(withDelegate: self)
            layout.scrollDirection = direction
            return layout
        } else {
            let layout = JTAppleCalendarVerticalFlowLayout()
            layout.scrollDirection = direction
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            return layout
        }
    }
    private func setupMonthInfoDataForStartAndEndDate()-> [[Int]] {
        
        var retval: [[Int]] = []
        
        if let  validConfig = dataSource?.configureCalendar(self) {
            
            // check if the dates are in correct order
            if validConfig.calendar.compareDate(validConfig.startDate, toDate: validConfig.endDate, toUnitGranularity: NSCalendarUnit.Nanosecond) == NSComparisonResult.OrderedDescending {
                //                print("No dates can be generated because your start date is greater than your end date.")
                return retval
            }
            
            cachedConfiguration = validConfig
            
            if let
                startMonth = NSDate.startOfMonthForDate(validConfig.startDate, usingCalendar: validConfig.calendar),
                endMonth = NSDate.endOfMonthForDate(validConfig.endDate, usingCalendar: validConfig.calendar) {
                
                startOfMonthCache = startMonth
                endOfMonthCache = endMonth
                
                let differenceComponents = validConfig.calendar.components(
                    NSCalendarUnit.Month,
                    fromDate: startOfMonthCache,
                    toDate: endOfMonthCache,
                    options: []
                )
                
                // Create boundary date
                let leftDate = validConfig.calendar.dateByAddingUnit(.Weekday, value: -1, toDate: startOfMonthCache, options: [])!
                let leftDateInt = validConfig.calendar.component(.Day, fromDate: leftDate)
                
                // Number of months
                numberOfMonthSections = differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
                
                // Number of sections in each month
                numberOfSectionsPerMonth = Int(ceil(Float(MAX_NUMBER_OF_ROWS_PER_MONTH)  / Float(numberOfRowsPerMonth)))

                
                // Section represents # of months. section is used as an offset to determine which month to calculate
                for numberOfMonthsIndex in 0 ... numberOfMonthSections - 1 {
                    if let correctMonthForSectionDate = validConfig.calendar.dateByAddingUnit(.Month, value: numberOfMonthsIndex, toDate: startOfMonthCache, options: []) {
                        
                        let numberOfDaysInMonth = validConfig.calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: correctMonthForSectionDate).length
                        
                        var firstWeekdayOfMonthIndex = validConfig.calendar.component(.Weekday, fromDate: correctMonthForSectionDate)
                        firstWeekdayOfMonthIndex -= 1 // firstWeekdayOfMonthIndex should be 0-Indexed
                        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + firstDayOfWeek.rawValue) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
                        
                        
                        // We have number of days in month, now lets see how these days will be allotted into the number of sections in the month
                        // We will add the first segment manually to handle the fdIndex inset
                        let aFullSection = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK)
                        var numberOfDaysInFirstSection = aFullSection - firstWeekdayOfMonthIndex
                        
                        // If the number of days in first section is greater that the days of the month, then use days of month instead
                        if numberOfDaysInFirstSection > numberOfDaysInMonth {
                            numberOfDaysInFirstSection = numberOfDaysInMonth
                        }
                        
                        let firstSectionDetail: [Int] = [firstWeekdayOfMonthIndex, numberOfDaysInFirstSection, 0, numberOfDaysInMonth] //fdIndex, numberofDaysInMonth, offset
                        retval.append(firstSectionDetail)
                        let numberOfSectionsLeft = numberOfSectionsPerMonth - 1
                        
                        // Continue adding other segment details in loop
                        if numberOfSectionsLeft < 1 {continue} // Continue if there are no more sections
                        
                        var numberOfDaysLeft = numberOfDaysInMonth - numberOfDaysInFirstSection
                        for _ in 0 ... numberOfSectionsLeft - 1 {
                            switch numberOfDaysLeft {
                            case _ where numberOfDaysLeft <= aFullSection: // Partial rows
                                let midSectionDetail: [Int] = [0, numberOfDaysLeft, firstWeekdayOfMonthIndex]
                                retval.append(midSectionDetail)
                                numberOfDaysLeft = 0
                            case _ where numberOfDaysLeft > aFullSection: // Full Rows
                                let lastPopulatedSectionDetail: [Int] = [0, aFullSection, firstWeekdayOfMonthIndex]
                                retval.append(lastPopulatedSectionDetail)
                                numberOfDaysLeft -= aFullSection
                            default:
                                break
                            }
                        }
                    }
                }
                retval[0].append(leftDateInt)
            }
        }
        return retval
    }
    
    /// Scrolls the calendar view to the next section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToNextSegment(animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage
        if page + 1 < monthInfo.count {
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page + 1), atScrollPosition: position, animated: animateScroll)
        }
    }
    /// Scrolls the calendar view to the previous section view. It will execute a completion handler at the end of scroll animation if provided.
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToPreviousSegment(animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        let page = currentSectionPage
        if page - 1 > -1 {
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            calendarView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection:page - 1), atScrollPosition: position, animated: animateScroll)
        }
    }
    
    private func xibFileValid() -> Bool {
        guard let xibName =  cellViewXibName else {
            //            print("Did you remember to register your xib file to JTAppleCalendarView? call the registerCellViewXib method on it because xib filename is nil")
            return false
        }
        guard let viewObject = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: [:]) where viewObject.count > 0 else {
            //            print("your nib file name \(cellViewXibName) could not be loaded)")
            return false
        }
        
        guard let _ = viewObject[0] as? JTAppleDayCellView else {
            //            print("xib file class does not conform to the protocol<JTAppleDayCellViewProtocol>")
            return false
        }
        
        return true
    }
    /// Scrolls the calendar view to the start of a section view containing a specified date.
    /// - Paramater date: The calendar view will scroll to a date-cell containing this date if it exists
    /// - Paramater animateScroll: Bool indicating if animation should be enabled
    /// - Parameter completionHandler: A completion handler that will be executed at the end of the scroll animation
    public func scrollToDate(date: NSDate, animateScroll: Bool = true, completionHandler:(()->Void)? = nil) {
        guard let validCachedCalendar = calendar else {
            return
        }
        
        let components = validCachedCalendar.components([.Year, .Month, .Day],  fromDate: date)
        let firstDayOfDate = validCachedCalendar.dateFromComponents(components)!
        
        if !(firstDayOfDate >= startOfMonthCache && firstDayOfDate <= endOfMonthCache) {
            return
        }
        
        let retrievedPathsFromDates = pathsFromDates([date])
        
        if retrievedPathsFromDates.count > 0 {
            let sectionIndexPath =  pathsFromDates([date])[0]
            delayedExecutionClosure = completionHandler
            let segmentToScrollTo = pagingEnabled ? NSIndexPath(forItem: 0, inSection: sectionIndexPath.section) : sectionIndexPath
            
            let position: UICollectionViewScrollPosition = self.direction == .Horizontal ? .Left : .Top
            delayRunOnMainThread(0.0, closure: {
                self.calendarView.scrollToItemAtIndexPath(segmentToScrollTo, atScrollPosition: position, animated: animateScroll)
                if  !animateScroll {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                }
            })
        }
    }
    
    /// Select a date-cell if it is on screen
    /// - Parameter date: The date-cell with this date will be selected
    /// - Parameter triggerDidSelectDelegate: Triggers the delegate function only if the value is set to true. Sometimes it is necessary to setup some dates without triggereing the delegate e.g. For instance, when youre initally setting up data in your viewDidLoad
    public func selectDates(dates: [NSDate], triggerSelectionDelegate: Bool = true) {
        delayRunOnMainThread(0.0) {
            guard let validCachedCalendar = self.calendar else {
                return
            }
            
            var allIndexPathsToReload: [NSIndexPath] = []
            for date in dates {
                let components = validCachedCalendar.components([.Year, .Month, .Day],  fromDate: date)
                let firstDayOfDate = validCachedCalendar.dateFromComponents(components)!
                
                if !(firstDayOfDate >= self.startOfMonthCache && firstDayOfDate <= self.endOfMonthCache) {
                    // If the date is not within valid boundaries, then exit
                    continue
                }
                
                let pathFromDates = self.pathsFromDates([date])
                
                // If the date path youre searching for, doesnt exist, then return
                if pathFromDates.count < 0 {
                    continue
                }
                
                let sectionIndexPath = pathFromDates[0]
                allIndexPathsToReload.append(sectionIndexPath)
                let selectTheDate = {
                    if self.selectedIndexPaths.contains(sectionIndexPath) == false { // Can contain the value already if the user selected the same date twice.
                        self.selectedDates.append(date)
                        self.selectedIndexPaths.append(sectionIndexPath)
                    }
                    self.calendarView.selectItemAtIndexPath(sectionIndexPath, animated: false, scrollPosition: .None)
                    
                    // If triggereing is enabled, then let their delegate handle the reloading of view, else we will reload the data
                    if triggerSelectionDelegate {
                        self.collectionView(self.calendarView, didSelectItemAtIndexPath: sectionIndexPath)
                    }
                }
                
                let deSelectTheDate = { (indexPath: NSIndexPath) -> Void in
                    self.calendarView.deselectItemAtIndexPath(indexPath, animated: false)
                    if
                        self.selectedIndexPaths.contains(indexPath),
                        let index = self.selectedIndexPaths.indexOf(indexPath) {
                        
                        self.selectedIndexPaths.removeAtIndex(index)
                        self.selectedDates.removeAtIndex(index)
                    }
                    if triggerSelectionDelegate {
                        self.collectionView(self.calendarView, didDeselectItemAtIndexPath: indexPath)
                    }
                }
                
                // Remove old selections
                if self.calendarView.allowsMultipleSelection == false { // If single selection is ON
                    for indexPath in self.selectedIndexPaths {
                        if indexPath != sectionIndexPath {
                            deSelectTheDate(indexPath)
                        }
                    }
                    
                    // Add new selections
                    // Must be added here. If added in delegate didSelectItemAtIndexPath
                    selectTheDate()
                } else { // If multiple selection is on. Multiple selection behaves differently to singleselection. It behaves like a toggle.
                    
                    if self.selectedIndexPaths.contains(sectionIndexPath) { // If this cell is already selected, then deselect it
                        deSelectTheDate(sectionIndexPath)
                    } else {
                        // Add new selections
                        // Must be added here. If added in delegate didSelectItemAtIndexPath
                        selectTheDate()
                    }
                }
                
                
            }
            if triggerSelectionDelegate == false {
                self.calendarView.reloadItemsAtIndexPaths(allIndexPathsToReload)
                //                self.reloadData()
            }
        }
    }
    
    /// Reload the date of specified date-cells on the calendar-view
    /// - Parameter dates: Date-cells with these specified dates will be reloaded
    public func reloadDates(dates: [NSDate]) {
        let paths = pathsFromDates(dates)
        reloadPaths(paths)
    }
    
    func reloadPaths(indexPaths: [NSIndexPath]) {
        if indexPaths.count > 0 {
            calendarView.reloadItemsAtIndexPaths(indexPaths)
        }
    }
    
    private func pathsFromDates(dates:[NSDate])-> [NSIndexPath] {
        var returnPaths: [NSIndexPath] = []
        
        guard let validCachedCalendar = calendar else {
            return returnPaths
        }
        
        for date in dates {
            if date >= startOfMonthCache && date <= endOfMonthCache {
                let periodApart = validCachedCalendar.components(.Month, fromDate: startOfMonthCache, toDate: date, options: [])
                let monthSectionIndex = periodApart.month
                let startSectionIndex = monthSectionIndex * numberOfSectionsPerMonth
                let sectionIndex = startMonthSectionForSection(startSectionIndex) // Get the section within the month
                
                // Get the section Information
                let currentMonthInfo = monthInfo[sectionIndex]
                let dayIndex = validCachedCalendar.components(.Day, fromDate: date).day
                
                // Given the following, find the index Path
                let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
                let cellIndex = dayIndex + fdIndex - 1
                let updatedSection = cellIndex / numberOfItemsPerSection
                let adjustedSection = sectionIndex + updatedSection
                let adjustedCellIndex = cellIndex - (numberOfItemsPerSection * (cellIndex / numberOfItemsPerSection))
                returnPaths.append(NSIndexPath(forItem: adjustedCellIndex, inSection: adjustedSection))
            }
        }
        return returnPaths
    }
    
    /// Returns the calendar view's current section boundary dates.
    /// - returns:
    ///     - startDate: The start date of the current section
    ///     - endDate: The end date of the current section
    public func currentCalendarSegment() -> (startDate: NSDate, endDate: NSDate)? {
        if monthInfo.count < 1 {
            return nil
        }
        
        let section = currentSectionPage
        let monthData = monthInfo[section]
        let itemLength = monthData[NUMBER_OF_DAYS_INDEX]
        let fdIndex = monthData[FIRST_DAY_INDEX]
        let startIndex = NSIndexPath(forItem: fdIndex, inSection: section)
        let endIndex = NSIndexPath(forItem: fdIndex + itemLength - 1, inSection: section)
        
        if let theStartDate = dateFromPath(startIndex), theEndDate = dateFromPath(endIndex) {
            return (theStartDate, theEndDate)
        }
        return nil
    }
    
    // MARK: Helper functions
    func cellWasNotDisabledByTheUser(cell: JTAppleDayCell) -> Bool {
        return cell.cellView.hidden == false && cell.cellView.userInteractionEnabled == true
    }
    
}

// MARK: scrollViewDelegates

extension JTAppleCalendarView: UIScrollViewDelegate {
    /// Tells the delegate when the user finishes scrolling the content.
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if pagingEnabled {
            return
        }

        var contentOffset: CGFloat = 0,
            theTargetContentOffset: CGFloat = 0,
            directionVelocity: CGFloat = 0,
            contentInset: CGFloat = 0,
            cellDragInterval: CGFloat = 0
        
        if direction == .Horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.memory.x
            directionVelocity = velocity.x
            contentInset = calendarView.contentInset.left
            cellDragInterval = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.memory.y
            directionVelocity = velocity.y
            contentInset = calendarView.contentInset.top
            cellDragInterval = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height
        }
        
        var nextIndex: CGFloat = 0
        var diff = abs(theTargetContentOffset - contentOffset)

        
        if (directionVelocity == 0) {
            nextIndex = round(theTargetContentOffset / cellDragInterval)
            targetContentOffset.memory = CGPointMake(0, nextIndex * cellDragInterval)
        } else if (directionVelocity > 0) {
            nextIndex = ceil((theTargetContentOffset - (diff * scrollResistance)) / cellDragInterval)
        } else {
            nextIndex = floor((theTargetContentOffset + (diff * scrollResistance)) / cellDragInterval)
        }
        
        if direction == .Horizontal {
            targetContentOffset.memory = CGPointMake(max(nextIndex * cellDragInterval, contentInset), 0)
        } else {
            targetContentOffset.memory = CGPointMake(0, max(nextIndex * cellDragInterval, contentInset))
        }
    }
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
        delayedExecutionClosure?()
        delayedExecutionClosure = nil
    }
    
    /// Tells the delegate that the scroll view has ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // Determing the section from the scrollView direction
        let section = currentSectionPage
        
        // When ever the month/section is switched, let the flowlayout know which page it is on. This is needed in the event user switches orientatoin, we can use the index to snap back to correct position
        
        (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).pathForFocusItem = NSIndexPath(forItem: 0, inSection: section)
        
        if let currentSegmentDates = currentCalendarSegment() {
            self.delegate?.calendar(self, didScrollToDateSegmentStartingWith: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
        }
    }
}

extension JTAppleCalendarView {
    private func cellStateFromIndexPath(indexPath: NSIndexPath, withDate date: NSDate)->CellState {
        
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        
        let currentMonthInfo = monthInfo[itemSection]
        
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        
        
        var dateBelongsTo: CellState.DateOwner  = .ThisMonth
        
        let componentDay = calendar!.component(.Day, fromDate: date)
        let componentWeekDay = calendar!.component(.Weekday, fromDate: date)
        let cellText = String(componentDay)
        
        if itemIndex >= fdIndex && itemIndex < fdIndex + nDays {
            dateBelongsTo = .ThisMonth
        } else if itemIndex < fdIndex  && itemSection - 1 > -1  { // Prior month is available
            dateBelongsTo = .PreviousMonthWithinBoundary
        } else if itemIndex >= fdIndex + nDays && itemSection + 1 < monthInfo.count { // Following months
            dateBelongsTo = .FollowingMonthWithinBoundary
        } else if itemIndex < fdIndex { // Pre from the start
            dateBelongsTo = .PreviousMonthOutsideBoundary
        } else { // Post from the end
            dateBelongsTo = .FollowingMonthOutsideBoundary
        }
        
        let dayOfWeek: DaysOfWeek
        switch componentWeekDay {
        case 1:
            dayOfWeek = .Sunday
        case 2:
            dayOfWeek = .Monday
        case 3:
            dayOfWeek = .Tuesday
        case 4:
            dayOfWeek = .Wednesday
        case 5:
            dayOfWeek = .Thursday
        case 6:
            dayOfWeek = .Friday
        default:
            dayOfWeek = .Saturday
        }
        
        let cellState = CellState(
            isSelected: selectedIndexPaths.contains(indexPath),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek   
        )
        
        return cellState
    }
    
    private func startMonthSectionForSection(aSection: Int)->Int {
        let monthIndexWeAreOn = aSection / numberOfSectionsPerMonth
        let nextSection = numberOfSectionsPerMonth * monthIndexWeAreOn
        return nextSection
    }
    
    private func dateFromPath(indexPath: NSIndexPath)-> NSDate? { // Returns nil if date is out of scope
        guard let validCachedCalendar = calendar else {
            return nil
        }
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let monthIndexWeAreOn = itemSection / numberOfSectionsPerMonth
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
//        let offsetComponents = NSDateComponents()
        
        dateComponents.month = monthIndexWeAreOn
        dateComponents.weekday = cellDate - 1
        
        return validCachedCalendar.dateByAddingComponents(dateComponents, toDate: startOfMonthCache, options: [])
    }
    
    private func delayRunOnMainThread(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    private func delayRunOnGlobalThread(delay:Double, qos: qos_class_t,closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ), dispatch_get_global_queue(qos, 0), closure)
    }
}

// MARK: CollectionView delegates
extension JTAppleCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if selectedIndexPaths.contains(indexPath) {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        } else {
            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        }
        
        let dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! JTAppleDayCell
        let date = dateFromPath(indexPath)!
        let cellState = cellStateFromIndexPath(indexPath, withDate: date)
        
        delegate?.calendar(self, isAboutToDisplayCell: dayCell.cellView, date: date, cellState: cellState)
        
        return dayCell
    }
    /// Asks your data source object for the number of sections in the collection view. The number of sections in collectionView.
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if !xibFileValid() {
            return 0
        }
        
        if monthInfo.count > 0 {
            self.scrollViewDidEndDecelerating(self.calendarView)
        }
        return monthInfo.count
    }
    
    /// Asks your data source object for the number of items in the specified section. The number of rows in section.
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth
    }
    /// Asks the delegate if the specified item should be selected. true if the item should be selected or false if it should not.
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let
            dateUserSelected = dateFromPath(indexPath),
            delegate = self.delegate,
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell {
            if cellWasNotDisabledByTheUser(cell) {
                let cellState = cellStateFromIndexPath(indexPath, withDate: dateUserSelected)
                delegate.calendar(self, canSelectDate: dateUserSelected, cell: cell.cellView, cellState: cellState)
                return true
            }
        }
        
        return false // if date is out of scope
    }
    /// Tells the delegate that the item at the specified path was deselected. The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let
            delegate = self.delegate,
            dateDeSelectedByUser = dateFromPath(indexPath) {
            
            // Update model
            if let index = selectedIndexPaths.indexOf(indexPath) {
                selectedIndexPaths.removeAtIndex(index)
                selectedDates.removeAtIndex(index)
            }
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell // Cell may be nil if user switches month sections
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeSelectedByUser) // Although the cell may be nil, we still want to return the cellstate
            delegate.calendar(self, didDeselectDate: dateDeSelectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
    /// Asks the delegate if the specified item should be deselected. true if the item should be deselected or false if it should not.
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let
            dateDeSelectedByUser = dateFromPath(indexPath),
            delegate = self.delegate,
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell {
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeSelectedByUser)
            delegate.calendar(self, canDeselectDate: dateDeSelectedByUser, cell: cell.cellView, cellState:  cellState)
            return true
        }
        return false
    }
    /// Tells the delegate that the item at the specified index path was selected. The collection view calls this method when the user successfully selects an item in the collection view. It does not call this method when you programmatically set the selection.
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let
            delegate = self.delegate,
            dateSelectedByUser = dateFromPath(indexPath) {
            
            // Update model
            if selectedIndexPaths.contains(indexPath) == false { // wrapping in IF statement handles both multiple select scenarios AND singleselection scenarios
                selectedIndexPaths.append(indexPath)
                selectedDates.append(dateSelectedByUser)
            }
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateSelectedByUser)
            delegate.calendar(self, didSelectDate: dateSelectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
}

extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol {
    func numberOfRows() -> Int {
        return numberOfRowsPerMonth
    }
    
    func numberOfColumns() -> Int {
        return MAX_NUMBER_OF_DAYS_IN_WEEK
        
    }
    
    func numberOfsectionsPermonth() -> Int {
        return numberOfSectionsPerMonth
    }
    
    func numberOfSections() -> Int {
        return numberOfMonthSections
    }
}

/// NSDates can be compared with the == and != operators
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}
/// NSDates can be compared with the > and < operators
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

private extension NSDate {

    class func numberOfDaysDifferenceBetweenFirstDate(firstDate: NSDate, secondDate: NSDate, usingCalendar calendar: NSCalendar)->Int {
        let date1 = calendar.startOfDayForDate(firstDate)
        let date2 = calendar.startOfDayForDate(secondDate)
        
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: .WrapComponents)
        return abs(components.day)
    }
    
    class func startOfMonthForDate(date: NSDate, usingCalendar calendar:NSCalendar) -> NSDate? {
        let dayOneComponents = calendar.components([.Era, .Year, .Month], fromDate: date)
        return calendar.dateFromComponents(dayOneComponents)
    }
    
    class func endOfMonthForDate(date: NSDate, usingCalendar calendar:NSCalendar) -> NSDate? {
        let lastDayComponents = calendar.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: date)
        lastDayComponents.month = lastDayComponents.month + 1
        lastDayComponents.day = 0
        return calendar.dateFromComponents(lastDayComponents)
    }
}
