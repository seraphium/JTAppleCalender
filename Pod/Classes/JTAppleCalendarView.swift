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
    /// returns the row in which the date cell appears visually
    public let row: Int
    /// returns the column in which the date cell appears visually
    public let column: Int
}

/// Days of the week. By setting you calandar's first day of week, you can change which day is the first for the week. Sunday is by default.
public enum DaysOfWeek: Int {
    /// Days of the week.
    case Sunday = 7, Monday = 6, Tuesday = 5, Wednesday = 4, Thursday = 10, Friday = 9, Saturday = 8
}

/// The JTAppleCalendarViewDataSource protocol is adopted by an object that mediates the application’s data model for a JTAppleCalendarViewDataSource object. The data source provides the calendar-view object with the information it needs to construct and modify it self
public protocol JTAppleCalendarViewDataSource {
    /// Asks the data source to return the start and end boundary dates as well as the calendar to use. You should properly configure your calendar at this point.
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view requesting this information.
    /// - returns:
    ///     - startDate: The *start* boundary date for your calendarView.
    ///     - endDate: The *end* boundary date for your calendarView.
    ///     - numberOfRows: The number of rows to be displayed per month
    ///     - calendar: The *calendar* to be used by the calendarView.
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar)
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
    ///     - startDate: The date at the start of the segment.
    ///     - endDate: The date at the end of the segment.
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) -> Void
    /// Tells the delegate that the JTAppleCalendar is about to display a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The date-cell that is about to be displayed.
    ///     - date: The date attached to the cell.
    ///     - cellState: The month the date-cell belongs to.
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) -> Void
    /// Implement this function to use headers in your project. Return your registered header for the date presented.
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   String: Provide the registered header you wish to show for this date
    func calendar(calendar : JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String?
    /// Implement this function to use headers in your project. Return the size for the header you wish to present
    /// - Parameters:
    ///     - date: Contains the startDate and endDate for the header that is about to be displayed
    /// - Returns:
    ///   CGSize: Provide the size for the header you wish to show for this date
    func calendar(calendar : JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize
    /// Tells the delegate that the JTAppleCalendar is about to display a header. This is the point of customization for your headers
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - header: The header view that is about to be displayed.
    ///     - date: The date attached to the header.
    ///     - identifier: The identifier you provided for the header
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) -> Void
}
/// Default delegate functions
public extension JTAppleCalendarViewDelegate {
    func calendar(calendar : JTAppleCalendarView, canSelectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, canDeselectDate date : NSDate, cell: JTAppleDayCellView, cellState: CellState)->Bool {return true}
    func calendar(calendar : JTAppleCalendarView, didSelectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didDeselectDate date : NSDate, cell: JTAppleDayCellView?, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {}
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date:NSDate, cellState: CellState) {}
    func calendar(calendar : JTAppleCalendarView, isAboutToDisplaySectionHeader header: JTAppleHeaderView, date: (startDate: NSDate, endDate: NSDate), identifier: String) {}
    func calendar(calendar : JTAppleCalendarView, sectionHeaderIdentifierForDate date: (startDate: NSDate, endDate: NSDate)) -> String? {return nil}
    func calendar(calendar : JTAppleCalendarView, sectionHeaderSizeForDate date: (startDate: NSDate, endDate: NSDate)) -> CGSize {return CGSizeZero}
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
            if oldValue == direction { return }
            let layout = generateNewLayout()
            calendarView.collectionViewLayout = layout
        }
    }
    /// Enables/Disables multiple selection on JTAppleCalendar
    public var allowsMultipleSelection: Bool = false {
        didSet {
            self.calendarView.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    /// First day of the week value for JTApleCalendar. You can set this to anyday. After changing this value you must reload your calendar view to show the change.
    public var firstDayOfWeek = DaysOfWeek.Sunday {
        didSet {
            if firstDayOfWeek != oldValue {
                layoutNeedsUpdating = true
            }
        }
    }
    
    var triggerScrollToDateDelegate: Bool? = true
    
    // Keeps track of item size for a section. This is an optimization
    var scrollInProgress = false
    private var layoutNeedsUpdating = false
    
    /// Number of rows to be displayed per month. Allowed values are 1, 2, 3 & 6.
    /// After changing this value, you should reload your calendarView to show your change
    public var numberOfRowsPerMonth: Int {
        set {
            if newValue != cachedConfiguration.numberOfRows {
                cachedConfiguration.numberOfRows = newValue
                if newValue == 4 || newValue == 5 || newValue > 6 || newValue < 0 { self.numberOfRowsPerMonth = 6 }
                layoutNeedsUpdating = true
            }
        }
        
        get { return cachedConfiguration.numberOfRows }
    }
    /// The object that acts as the data source of the calendar view.
    public var dataSource : JTAppleCalendarViewDataSource? {
        didSet {
            monthInfo = setupMonthInfoDataForStartAndEndDate()
            reloadData(checkDelegateDataSource: false)
        }
    }
    /// The object that acts as the delegate of the calendar view.
    public var delegate: JTAppleCalendarViewDelegate?

    var dateComponents = NSDateComponents()
    var delayedExecutionClosure: [(()->Void)] = []
    var lastOrientation: UIDeviceOrientation?
    
    var currentSectionPage: Int {
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
    
    var startDateCache: NSDate {
        get { return cachedConfiguration.startDate }
    }
    
    var endDateCache: NSDate {
        get { return cachedConfiguration.endDate }
    }
    
    var calendar: NSCalendar {
        get { return cachedConfiguration.calendar }
    }
    
    lazy var cachedConfiguration: (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) = {
        [weak self] in
        
        guard let  config = self!.dataSource?.configureCalendar(self!) else {
            assert(false, "DataSource is not set")
            return (startDate: NSDate(), endDate: NSDate(), 0, NSCalendar(calendarIdentifier: "nil")!)
        }
        
        return (startDate: config.startDate, endDate: config.endDate, numberOfRows: config.numberOfRows, calendar: config.calendar)
        }()
    
    // Set the start of the month
    lazy var startOfMonthCache: NSDate = {
        [weak self] in
        if let startDate = NSDate.startOfMonthForDate(self!.startDateCache, usingCalendar: self!.calendar) { return startDate }
        assert(false, "Error: StartDate was not correctly generated for start of month. current date was used: \(NSDate())")
        return NSDate()
        }()
    
    // Set the end of month
    lazy var endOfMonthCache: NSDate = {
        [weak self] in
        if let endDate = NSDate.endOfMonthForDate(self!.endDateCache, usingCalendar: self!.calendar) { return endDate }
        assert(false, "Error: Date was not correctly generated for end of month. current date was used: \(NSDate())")
        return NSDate()
        }()
    
    
    var theSelectedIndexPaths: [NSIndexPath] = []
    var theSelectedDates:      [NSDate]      = []
    
    /// Returns all selected dates
    public var selectedDates: [NSDate] {
        get {
            // Array may contain duplicate dates in case where out-dates are selected. So clean it up here
            return Array(Set(theSelectedDates))
        }
    }

    
    lazy var monthInfo : [[Int]] = {
        [weak self] in
        let newMonthInfo = self!.setupMonthInfoDataForStartAndEndDate()
        return newMonthInfo
        }()
    
    var numberOfMonths: Int = 0
    var numberOfSectionsPerMonth: Int = 0
    var numberOfItemsPerSection: Int {return MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth}
    
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
    
    lazy var calendarView : UICollectionView = {
        
        let layout = JTAppleCalendarLayout(withDelegate: self)
        layout.scrollDirection = self.direction
        
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
        if delegate == nil { // If the delegate is not set yet, then return
            return
        }
        
        layout.itemSize = CGSizeMake(
            self.calendarView.bounds.size.width / CGFloat(MAX_NUMBER_OF_DAYS_IN_WEEK),
            (self.calendarView.bounds.size.height - layout.headerReferenceSize.height) / CGFloat(numberOfRowsPerMonth)
        )

        self.calendarView.collectionViewLayout = layout as! UICollectionViewLayout
    }
    
    /// The frame rectangle which defines the view's location and size in its superview coordinate system.
    override public var frame: CGRect {
        didSet {
            calendarView.frame = CGRect(x:0.0, y:/*bufferTop*/0.0, width: self.frame.size.width, height:self.frame.size.height/* - bufferBottom*/)
            let orientation = UIDevice.currentDevice().orientation
            if orientation == .Unknown { return }
            if lastOrientation != orientation {
                lastOrientation = orientation
                calendarView.collectionViewLayout.invalidateLayout()
                let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
                layout.clearCache()
                calendarView.reloadData()
            }
            updateLayoutItemSize(self.calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.calendarView.registerClass(JTAppleDayCell.self,
                                        forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
        self.addSubview(self.calendarView)
    }
    
    func restoreSelectionStateForCellAtIndexPath(indexPath: NSIndexPath) {
        if theSelectedIndexPaths.contains(indexPath) {
            calendarView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func dateFromSection(section: Int) -> (startDate: NSDate, endDate: NSDate)? {
        if monthInfo.count < 1 {
            return nil
        }
        
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
    
    func scrollToHeaderInSection(section:Int, triggerScrollToDateDelegate: Bool = false, withAnimation animation: Bool = true, completionHandler: (()->Void)? = nil)  {
        if headerViewXibs.count < 1 { return }
        
        self.triggerScrollToDateDelegate = triggerScrollToDateDelegate
        
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        calendarView.layoutIfNeeded()
        if let attributes =  calendarView.layoutAttributesForSupplementaryElementOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
            if let validHandler = completionHandler {
                delayedExecutionClosure.append(validHandler)
            }
            
            let topOfHeader = CGPointMake(attributes.frame.origin.x, attributes.frame.origin.y)
            self.scrollInProgress = true
            delayRunOnMainThread(0.0, closure: {
                self.calendarView.setContentOffset(topOfHeader, animated:animation)
                if  !animation {
                    self.scrollViewDidEndScrollingAnimation(self.calendarView)
                    self.scrollInProgress = false
                } else {
                    // If the scroll is set to animate, and the target content offset is already on the screen, then the didFinishScrollingAnimation
                    // delegate will not get called. Once animation is on let's force a scroll so the delegate MUST get caalled
                    if let check = self.calendarOffsetIsAlreadyAtScrollPosition(forOffset: topOfHeader) where check == true {
                        self.scrollViewDidEndScrollingAnimation(self.calendarView)
                        self.scrollInProgress = false
                    }
                }
            })
        }
    }
    
    func reloadData(checkDelegateDataSource check: Bool, withAnchorDate anchorDate: NSDate? = nil, withAnimation animation: Bool = false, completionHandler:(()->Void)? = nil) {
        if check {
            reloadDelegateDataSource() // Reload the datasource
        }
        
        // Delay on main thread. We want this to be called after the view is displayed on the main run loop
        if layoutNeedsUpdating {
            delayRunOnMainThread(0.0, closure: {
                if !self.scrollInProgress { // Make sure this scroll only gets activated if no other scroll is in queue
                    self.configureChangeOfRows()
                    
                    guard let validAnchorDate = anchorDate else { // If the date is invalid just scroll to the the first item on the view or scroll to the start of a header (if header is enabled)
                        if headerViewXibs.count < 1 {
                            self.scrollToDate(self.startOfMonthCache, triggerScrollToDateDelegate: false, animateScroll: animation, completionHandler: completionHandler)
                        } else {
                            self.scrollToHeaderForDate(self.startOfMonthCache, triggerScrollToDateDelegate: false, withAnimation: animation, completionHandler: completionHandler)
                        }
                        return
                    }
                    
                    delayRunOnMainThread(0.0, closure: { () -> () in
                        self.scrollToDate(validAnchorDate, triggerScrollToDateDelegate: false, animateScroll: animation, completionHandler: completionHandler)
                    })
                } else {
                    if let validHandler = completionHandler {
                        self.delayedExecutionClosure.append(validHandler)
                    }
                }
                
                // Set layoutNeedsUpdating to false
                self.layoutNeedsUpdating = false
            })
        } else {
            (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).clearCache()
            calendarView.reloadData()
        }
    }
    
    private func reloadDelegateDataSource() {
        if let
            newDateBoundary = dataSource?.configureCalendar(self) {
            // Jt101 do a check in each var to see if user has bad star/end dates
            let newStartOfMonth = NSDate.startOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let newEndOfMonth = NSDate.endOfMonthForDate(newDateBoundary.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldStartOfMonth = NSDate.startOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)
            let oldEndOfMonth = NSDate.endOfMonthForDate(cachedConfiguration.startDate, usingCalendar: cachedConfiguration.calendar)

            
            if
                newStartOfMonth != oldStartOfMonth ||
                newEndOfMonth != oldEndOfMonth ||
                newDateBoundary.calendar != cachedConfiguration.calendar ||
                newDateBoundary.numberOfRows != cachedConfiguration.numberOfRows {
                    layoutNeedsUpdating = true
            }
        }
    }
    
    func configureChangeOfRows() {
        theSelectedDates.removeAll()
        theSelectedIndexPaths.removeAll()
        let layout = calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol
        layout.clearCache()
        monthInfo = setupMonthInfoDataForStartAndEndDate()
        self.calendarView.reloadData()
    }
    
    func calendarViewHeaderSizeForSection(section: Int) -> CGSize {
        var retval = CGSizeZero
        if headerViewXibs.count > 0 {
            if let date = dateFromSection(section), size = delegate?.calendar(self, sectionHeaderSizeForDate: date){ retval = size }
        }
        return retval
    }
    
    func indexPathOfdateCellCounterPart(date: NSDate, indexPath: NSIndexPath, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        var retval: NSIndexPath?
        if dateOwner != .ThisMonth { // If the cell is anything but this month, then the cell belongs to either a previous of following month
            // Get the indexPath of the counterpartCell
            let counterPathIndex = pathsFromDates([date])
            if counterPathIndex.count > 0 {
                retval = counterPathIndex[0]
            }
        } else { // If the date does belong to this month, then lets find out if it has a counterpart date
            if date >= startOfMonthCache && date <= endOfMonthCache {
                let dayIndex = calendar.components(.Day, fromDate: date).day
                if case 1...13 = dayIndex  { // then check the previous month
                    // get the index path of the last day of the previous month
                    
                    guard let prevMonth = calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: []) where prevMonth >= startOfMonthCache && prevMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let lastDayOfPrevMonth = NSDate.endOfMonthForDate(prevMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfLastDayOfPreviousMonth = pathsFromDates([lastDayOfPrevMonth])
                    if indexPathOfLastDayOfPreviousMonth.count > 0 {
                        let lastDayIndex = indexPathOfLastDayOfPreviousMonth[0].item
                        
                        let indexPathItemToBeFound = lastDayIndex + dayIndex
                        if indexPathItemToBeFound < 42 { // then it is valid
                            retval = NSIndexPath(forItem: indexPathItemToBeFound, inSection: indexPathOfLastDayOfPreviousMonth[0].section)
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() upper. This should not happen. Contact developer on github")
                    }
                } else if case 26...31 = dayIndex  { // check the following month
                    guard let followingMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: date, options: []) where followingMonth >= startOfMonthCache && followingMonth <= endOfMonthCache else {
                        return retval
                    }
                    
                    guard let firstDayOfFollowingMonth = NSDate.startOfMonthForDate(followingMonth, usingCalendar: calendar) else {
                        print("Error generating date in indexPathOfdateCellCounterPart(). Contact the developer on github")
                        return retval
                    }
                    let indexPathOfFirstDayOfFollowingMonth = pathsFromDates([firstDayOfFollowingMonth])
                    if indexPathOfFirstDayOfFollowingMonth.count > 0 {
                        let firstDayIndex = indexPathOfFirstDayOfFollowingMonth[0].item
                        
                        
                        let lastDay = NSDate.endOfMonthForDate(date, usingCalendar: calendar)!
                        let lastDayIndex = calendar.components(.Day, fromDate: lastDay).day
                        
                        let x = lastDayIndex - dayIndex
                        let y = firstDayIndex - x - 1
                        
                        if y > -1 {
                            return NSIndexPath(forItem: y, inSection: indexPathOfFirstDayOfFollowingMonth[0].section)
                        }
                    } else {
                        print("out of range error in indexPathOfdateCellCounterPart() lower. This should not happen. Contact developer on github")
                    }
                }
            }
            
        }
        return retval
    }
    
    func xibFileValid() -> Bool {
        //"Did you remember to register your xib file to JTAppleCalendarView? call the registerCellViewXib method on it because xib filename is nil"
        guard let xibName =  cellViewFromDeveloper else { return false }
        //"your nib file name \(cellViewXibName) could not be loaded)"
        guard let viewObject = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: [:]) where viewObject.count > 0 else { return false }
        //"xib file class does not conform to the protocol<JTAppleDayCellViewProtocol>"
        guard let _ = viewObject[0] as? JTAppleDayCellView else { return false }
        return true
    }
    
    func generateNewLayout() -> UICollectionViewLayout {
        let layout: UICollectionViewLayout = JTAppleCalendarLayout(withDelegate: self)
        let conformingProtocolLayout = layout as! JTAppleCalendarLayoutProtocol
        
        conformingProtocolLayout.scrollDirection = direction
        return layout
    }
    
    private func setupMonthInfoDataForStartAndEndDate()-> [[Int]] {
        var retval: [[Int]] = []
        if var validConfig = dataSource?.configureCalendar(self) {
            // check if the dates are in correct order
            if validConfig.calendar.compareDate(validConfig.startDate, toDate: validConfig.endDate, toUnitGranularity: NSCalendarUnit.Nanosecond) == NSComparisonResult.OrderedDescending {
                assert(false, "Error, your start date cannot be greater than your end date\n")
                return retval
            }
            
            // Check to see if we have a valid number of rows
            switch validConfig.numberOfRows {
            case 1, 2, 3:
                break
            default:
                validConfig.numberOfRows = 6
            }
            
            // Set the new cache
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
                numberOfMonths = differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
                
                // Number of sections in each month
                numberOfSectionsPerMonth = Int(ceil(Float(MAX_NUMBER_OF_ROWS_PER_MONTH)  / Float(numberOfRowsPerMonth)))

                // Section represents # of months. section is used as an offset to determine which month to calculate
                for numberOfMonthsIndex in 0 ... numberOfMonths - 1 {
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
    
    func pathsFromDates(dates:[NSDate])-> [NSIndexPath] {
        var returnPaths: [NSIndexPath] = []
        
        for date in dates {
            if date >= startOfMonthCache && date <= endOfMonthCache {
                let periodApart = calendar.components(.Month, fromDate: startOfMonthCache, toDate: date, options: [])
                let monthSectionIndex = periodApart.month
                let startSectionIndex = monthSectionIndex * numberOfSectionsPerMonth
                let sectionIndex = startMonthSectionForSection(startSectionIndex) // Get the section within the month
                
                // Get the section Information
                let currentMonthInfo = monthInfo[sectionIndex]
                let dayIndex = calendar.components(.Day, fromDate: date).day
                
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
}

extension JTAppleCalendarView {
    func cellStateFromIndexPath(indexPath: NSIndexPath, withDate date: NSDate)->CellState {
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let componentDay = calendar.component(.Day, fromDate: date)
        let componentWeekDay = calendar.component(.Weekday, fromDate: date)
        let cellText = String(componentDay)
        let dateBelongsTo: CellState.DateOwner
        
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
        
        let row = {()->Int in return (itemIndex / 7) }
        
        let column = {()->Int in return (itemIndex % 7) }
        
        let cellState = CellState(
            isSelected: theSelectedIndexPaths.contains(indexPath),
            text: cellText,
            dateBelongsTo: dateBelongsTo,
            date: date,
            day: dayOfWeek,
            row: row(),
            column: column()
        )
        
        return cellState
    }
    
    func startMonthSectionForSection(aSection: Int)->Int {
        let monthIndexWeAreOn = aSection / numberOfSectionsPerMonth
        let nextSection = numberOfSectionsPerMonth * monthIndexWeAreOn
        return nextSection
    }
    
    func reloadIndexPathsIfVisible(indexPath: [NSIndexPath]) {
        var visiblePaths: [NSIndexPath] = []
        for path in indexPath {
            if (calendarView.cellForItemAtIndexPath(path) as? JTAppleDayCell) != nil {
                visiblePaths.append(path)
                
            }
        }
        if visiblePaths.count > 0 {
            delayRunOnMainThread(0.0, closure: {
                self.calendarView.reloadItemsAtIndexPaths(visiblePaths)
            })
        }
    }
    
    func addCellToSelectedSetIfUnselected(indexPath: NSIndexPath, date: NSDate) {
        if self.theSelectedIndexPaths.contains(indexPath) == false {
            self.theSelectedIndexPaths.append(indexPath)
            self.theSelectedDates.append(date)
        }
    }
    func deleteCellFromSelectedSetIfSelected(indexPath: NSIndexPath) {
        if let index = self.theSelectedIndexPaths.indexOf(indexPath) {
            self.theSelectedIndexPaths.removeAtIndex(index)
            self.theSelectedDates.removeAtIndex(index)
        }
    }
    func deselectCounterPartCellIndexPath(indexPath: NSIndexPath, date: NSDate, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        if let
            counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            deleteCellFromSelectedSetIfSelected(counterPartCellIndexPath)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func selectCounterPartCellIndexPathIfExists(indexPath: NSIndexPath, date: NSDate, dateOwner: CellState.DateOwner) -> NSIndexPath? {
        if let counterPartCellIndexPath = indexPathOfdateCellCounterPart(date, indexPath: indexPath, dateOwner: dateOwner) {
            
            let dateComps = calendar.components([.Month, .Day, .Year], fromDate: date)
            guard let counterpartDate = calendar.dateFromComponents(dateComps) else {
                return nil
            }
            
            addCellToSelectedSetIfUnselected(counterPartCellIndexPath, date:counterpartDate)
            return counterPartCellIndexPath
        }
        return nil
    }
    
    func dateFromPath(indexPath: NSIndexPath)-> NSDate? { // Returns nil if date is out of scope
        let itemIndex = indexPath.item
        let itemSection = indexPath.section
        let monthIndexWeAreOn = itemSection / numberOfSectionsPerMonth
        let currentMonthInfo = monthInfo[itemSection]
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let offSet = currentMonthInfo[OFFSET_CALC]
        let cellDate = (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK * (itemSection % numberOfSectionsPerMonth)) + itemIndex - fdIndex - offSet + 1
        
        dateComponents.month = monthIndexWeAreOn
        dateComponents.weekday = cellDate - 1
        
        return calendar.dateByAddingComponents(dateComponents, toDate: startOfMonthCache, options: [])
    }
}



extension JTAppleCalendarView: JTAppleCalendarDelegateProtocol {
    func numberOfRows() -> Int {return numberOfRowsPerMonth}
    func numberOfColumns() -> Int { return MAX_NUMBER_OF_DAYS_IN_WEEK }
    func numberOfsectionsPermonth() -> Int { return numberOfSectionsPerMonth }
    func numberOfMonthsInCalendar() -> Int { return numberOfMonths }
    func numberOfDaysPerSection() -> Int { return numberOfItemsPerSection }
    
    func referenceSizeForHeaderInSection(section: Int) -> CGSize {
        if headerViewXibs.count < 1 { return CGSizeZero }
        return calendarViewHeaderSizeForSection(section)
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

func delayRunOnMainThread(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func delayRunOnGlobalThread(delay:Double, qos: qos_class_t,closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ), dispatch_get_global_queue(qos, 0), closure)
}

extension NSDate: Comparable { }

extension NSDate {

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
