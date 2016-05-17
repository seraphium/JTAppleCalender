//
//  JTAppleCalendarDelegates.swift
//  Pods
//
//  Created by Jay Thomas on 2016-05-12.
//
//


// MARK: scrollViewDelegates
extension JTAppleCalendarView: UIScrollViewDelegate {
    /// Tells the delegate when the user finishes scrolling the content.
//    public func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
//        print(maxOffset)
//        print(scrollView.contentOffset.y)
//    }
    
    func roundThis(number: CGFloat, toNearest: CGFloat) -> CGFloat {
        return round(number / toNearest) * toNearest
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if pagingEnabled {
            return
        }
        
        var contentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0,
        cellDragInterval: CGFloat = 0
        
        if direction == .Horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.memory.x
            directionVelocity = velocity.x
            cellDragInterval = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.memory.y
            directionVelocity = velocity.y
            cellDragInterval = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height
        }
        
        var nextIndex: CGFloat = 0
        let diff = abs(theTargetContentOffset - contentOffset)
        
        if (directionVelocity == 0) {
            if headerViewXibs.count < 1 {  // If there are no headers
                nextIndex = round(theTargetContentOffset / cellDragInterval)
                targetContentOffset.memory = CGPointMake(0, nextIndex * cellDragInterval)
                return
            } else { // If there are headers
                let testPoint = CGPoint(x: 0, y: theTargetContentOffset - (diff * scrollResistance))
                
                guard let
                        indexPath = calendarView.indexPathForItemAtPoint(testPoint),
                        attributes = calendarView.layoutAttributesForItemAtIndexPath(indexPath) else {
                            print("Landed on a header")
                            return
                }
                
                if theTargetContentOffset <= attributes.frame.origin.y + (attributes.frame.height / 2)  {
                    let targetOffset = attributes.frame.origin.y
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                } else {
                    let targetOffset = attributes.frame.origin.y + attributes.frame.height
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                }

            }
        } else if (directionVelocity > 0) { // scrolling down
            if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) {
                print("While scrolling down: RETURN ON: \(scrollView.contentSize.height - scrollView.frame.size.height)")
                return
            }

            let testPoint = CGPoint(x: 0, y: theTargetContentOffset - (diff * scrollResistance))
            if let indexPath = calendarView.indexPathForItemAtPoint(testPoint) {
                if let attributes = calendarView.layoutAttributesForItemAtIndexPath(indexPath) {
                    let targetOffset = attributes.frame.origin.y
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                }
            } else {
                print("\nOffset landed on a header. Complete code here")
            }
            return
        } else { // Scrolling back up
            if scrollView.contentOffset.y < 1 {
                print("while scrolling up: RETURNING ON \(scrollView.contentOffset.y)")
                return
            }

            let testPoint = CGPoint(x: 0, y: theTargetContentOffset + (diff * scrollResistance))
            if let indexPath = calendarView.indexPathForItemAtPoint(testPoint) {
                if let attributes = calendarView.layoutAttributesForItemAtIndexPath(indexPath) { //Crash
                    let targetOffsetx = attributes.frame.origin.y
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffsetx)
                }
            } else {
                print("\nOffset landed on a header. Complete code here")
            }
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
        let itemIndex: Int
        
        // Calculate the index to be used in focus path
        if direction == .Horizontal {
            itemIndex = Int(round(calendarView.contentOffset.x / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.width)) % MAX_NUMBER_OF_DAYS_IN_WEEK
        } else {
            itemIndex = (Int(round(calendarView.contentOffset.y / (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize.height)) * MAX_NUMBER_OF_DAYS_IN_WEEK) % (numberOfRowsPerMonth * MAX_NUMBER_OF_DAYS_IN_WEEK)
        }
        
        // When ever the month/section is switched, let the flowlayout know which page it is on. This is needed in the event user switches orientatoin, we can use the index to snap back to correct position
        (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).pathForFocusItem = NSIndexPath(forItem: itemIndex, inSection: section)
        
        if let currentSegmentDates = currentCalendarSegment() {
            self.delegate?.calendar(self, didScrollToDateSegmentStartingWith: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
        }
    }
    
    func calendarViewHeaderSizeForsection(section: Int) -> CGSize {
        
        if let date = dateFromSection(section) {
            if let size = delegate?.calendar(self, sectionHeaderSizeForDate: date) {
                return size
            }
        }
        
        return CGSizeZero
    }
}

// MARK: CollectionView delegates
extension JTAppleCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerViewXibs.count < 1 { return CGSizeZero }
        return calendarViewHeaderSizeForsection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reuseIdentifier: String
        guard let date = dateFromSection(indexPath.section) else {
            assert(false, "Date could not be generated fro section. This is a bug. Contact the developer")
        }
        
        if headerViewXibs.count == 1 {
            reuseIdentifier = headerViewXibs[0]
        } else {
            
            guard let identifier = delegate?.calendar(self, sectionHeaderIdentifierForDate: date) where headerViewXibs.contains(identifier) else {
                assert(false, "Identifier was not registered")
            }
            
            reuseIdentifier = identifier
        }
        
        currentXib = reuseIdentifier
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: reuseIdentifier,
                                                                               forIndexPath: indexPath) as! JTAppleCollectionReusableView

        delegate?.calendar(self, isAboutToDisplaySectionHeader: headerView.view, date: date)
    
        return headerView
    }
    
    
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
    
    func cellWasNotDisabledByTheUser(cell: JTAppleDayCell) -> Bool {
        return cell.cellView.hidden == false && cell.cellView.userInteractionEnabled == true
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