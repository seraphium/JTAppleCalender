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
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if pagingEnabled {
            (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).pointForFocusItem = targetContentOffset.memory
            return
        }
        
        var contentOffset: CGFloat = 0,
        theTargetContentOffset: CGFloat = 0,
        directionVelocity: CGFloat = 0,
        contentSize: CGFloat = 0,
        frameSize: CGFloat = 0

        if direction == .Horizontal {
            contentOffset = scrollView.contentOffset.x
            theTargetContentOffset = targetContentOffset.memory.x
            directionVelocity = velocity.x
            contentSize = scrollView.contentSize.width
            frameSize = scrollView.frame.size.width
        } else {
            contentOffset = scrollView.contentOffset.y
            theTargetContentOffset = targetContentOffset.memory.y
            directionVelocity = velocity.y
            contentSize = scrollView.contentSize.height
            frameSize = scrollView.frame.size.height
        }
        
        let diff = abs(theTargetContentOffset - contentOffset)
        
        let calcTestPoint = {(velocity: CGFloat) -> CGPoint in
            var recalcOffset: CGFloat
            if velocity == 0 || velocity > 0 {
                recalcOffset = theTargetContentOffset - (diff * self.scrollResistance)
            } else {
                recalcOffset = theTargetContentOffset + (diff * self.scrollResistance)
            }
            
            let retval: CGPoint
            if self.direction == .Vertical {
                retval = CGPoint(x: 0, y: recalcOffset)
            } else {
                if headerViewXibs.count < 1 {
                    retval = CGPoint(x: recalcOffset, y: 0)
                } else {
                    let targetSection =  Int(recalcOffset / self.calendarView.frame.size.width)
                    let headerHeigt = self.collectionView(self.calendarView, layout: self.calendarView.collectionViewLayout, referenceSizeForHeaderInSection: targetSection)
                    retval = CGPoint(x: recalcOffset, y: headerHeigt.height)
                }
            }
            
            return retval
        }
        
        let setTestPoint = {(testPoint: CGPoint) in
            if let indexPath = self.calendarView.indexPathForItemAtPoint(testPoint) {
                if let attributes = self.calendarView.layoutAttributesForItemAtIndexPath(indexPath) {
                    
                    if self.direction == .Vertical {
                        let targetOffset = attributes.frame.origin.y
                        targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                    } else {
                        let targetOffset = attributes.frame.origin.x
                        targetContentOffset.memory = CGPoint(x: targetOffset, y: 0)
                    }
                }
            } else {
                print("")
            }
        }
        
        
        
        if (directionVelocity == 0) {
            guard let
                    indexPath = calendarView.indexPathForItemAtPoint(calcTestPoint(directionVelocity)),
                    attributes = calendarView.layoutAttributesForItemAtIndexPath(indexPath) else {
                        return //                            print("Landed on a header")
            }
            
            if self.direction == .Vertical {
                if theTargetContentOffset <= attributes.frame.origin.y + (attributes.frame.height / 2)  {
                    let targetOffset = attributes.frame.origin.y
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                } else {
                    let targetOffset = attributes.frame.origin.y + attributes.frame.height
                    targetContentOffset.memory = CGPoint(x: 0, y: targetOffset)
                }
            } else {
                if theTargetContentOffset <= attributes.frame.origin.x + (attributes.frame.width / 2)  {
                    let targetOffset = attributes.frame.origin.x
                    targetContentOffset.memory = CGPoint(x: targetOffset, y: 0)
                } else {
                    let targetOffset = attributes.frame.origin.x + attributes.frame.width
                    targetContentOffset.memory = CGPoint(x: targetOffset, y: 0)
                }
            }
        } else if (directionVelocity > 0) { // scrolling down or left
            if contentOffset > (contentSize - frameSize) { return }
            setTestPoint(calcTestPoint(directionVelocity))
        } else { // Scrolling back up
            if contentOffset >= 1 {
                setTestPoint(calcTestPoint(directionVelocity))
            }
        }
        (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).pointForFocusItem = targetContentOffset.memory
    }
    
    /// Tells the delegate when a scrolling animation in the scroll view concludes.
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if triggerScrollToDateDelegate {
            scrollViewDidEndDecelerating(scrollView)
        }
        
        delayedExecutionClosure?()
        delayedExecutionClosure = nil
        
        // Update the focus item whenever scrolled
        (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).pointForFocusItem = scrollView.contentOffset
    }
    
    /// Tells the delegate that the scroll view has ended decelerating the scrolling movement.
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentSegmentDates = currentCalendarDateSegment()
        self.delegate?.calendar(self, didScrollToDateSegmentStartingWithdate: currentSegmentDates.startDate, endingWithDate: currentSegmentDates.endDate)
        
    }
}

// MARK: CollectionView delegates
extension JTAppleCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    /// Asks your data source object to provide a supplementary view to display in the collection view.
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reuseIdentifier: String
        guard let date = dateFromSection(indexPath.section) else {
            assert(false, "Date could not be generated fro section. This is a bug. Contact the developer")
            return UICollectionReusableView()
        }
        
        if headerViewXibs.count == 1 {
            reuseIdentifier = headerViewXibs[0]
        } else {
            guard let identifier = delegate?.calendar(self, sectionHeaderIdentifierForDate: date) where headerViewXibs.contains(identifier) else {
                assert(false, "Identifier was not registered")
                return UICollectionReusableView()
            }
            reuseIdentifier = identifier
        }
        currentXib = reuseIdentifier
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                               withReuseIdentifier: reuseIdentifier,
                                                                               forIndexPath: indexPath) as! JTAppleCollectionReusableView

        delegate?.calendar(self, isAboutToDisplaySectionHeader: headerView.view, date: date, identifier: reuseIdentifier)
        return headerView
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        restoreSelectionStateForCellAtIndexPath(indexPath)
        
        let dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! JTAppleDayCell

        dayCell.bounds.origin.y = 0
        dayCell.bounds.origin.x = 0
        
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
        
        return monthInfo.count
    }

    /// Asks your data source object for the number of items in the specified section. The number of rows in section.
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  MAX_NUMBER_OF_DAYS_IN_WEEK * numberOfRowsPerMonth
    }
    /// Asks the delegate if the specified item should be selected. true if the item should be selected or false if it should not.
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if let
            delegate = self.delegate,
            dateUserSelected = dateFromPath(indexPath),
            cell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell {
            if cellWasNotDisabledOrHiddenByTheUser(cell) {
                let cellState = cellStateFromIndexPath(indexPath, withDate: dateUserSelected)
                return delegate.calendar(self, canSelectDate: dateUserSelected, cell: cell.cellView, cellState: cellState)
            }
        }
        return false
    }
    
    func cellWasNotDisabledOrHiddenByTheUser(cell: JTAppleDayCell) -> Bool {
        return cell.cellView.hidden == false && cell.cellView.userInteractionEnabled == true
    }
    /// Tells the delegate that the item at the specified path was deselected. The collection view calls this method when the user successfully deselects an item in the collection view. It does not call this method when you programmatically deselect items.
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let
            delegate = self.delegate,
            dateDeselectedByUser = dateFromPath(indexPath) {
            
            // Update model
            deleteCellFromSelectedSetIfSelected(indexPath)
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell // Cell may be nil if user switches month sections
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateDeselectedByUser) // Although the cell may be nil, we still want to return the cellstate
            
            if let anUnselectedCounterPartIndexPath = deselectCounterPartCellIndexPath(indexPath, date: dateDeselectedByUser, dateOwner: cellState.dateBelongsTo) {
                deleteCellFromSelectedSetIfSelected(anUnselectedCounterPartIndexPath)
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                refreshIndexPathIfVisible(anUnselectedCounterPartIndexPath)
            }
            
            delegate.calendar(self, didDeselectDate: dateDeselectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
    
    /// Asks the delegate if the specified item should be deselected. true if the item should be deselected or false if it should not.
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let
            delegate = self.delegate,
            dateDeSelectedByUser = dateFromPath(indexPath),
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
            addCellToSelectedSetIfUnselected(indexPath, date:dateSelectedByUser)
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? JTAppleDayCell
            let cellState = cellStateFromIndexPath(indexPath, withDate: dateSelectedByUser)
            
            // If cell has a counterpart cell, then select it as well
            if let aSelectedCounterPartIndexPath = selectCounterPartCellIndexPath(indexPath, date: dateSelectedByUser, dateOwner: cellState.dateBelongsTo) {
                // ONLY if the counterPart cell is visible, then we need to inform the delegate
                refreshIndexPathIfVisible(aSelectedCounterPartIndexPath)
            }
            delegate.calendar(self, didSelectDate: dateSelectedByUser, cell: selectedCell?.cellView, cellState: cellState)
        }
    }
}

extension JTAppleCalendarView:  UICollectionViewDelegateFlowLayout {
    /// Asks the delegate for the size of the header view in the specified section.
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerViewXibs.count < 1 { return CGSizeZero }
        let size = calendarViewHeaderSizeForSection(section)
        return size
    }
    
    /// Asks the delegate for the size of the specified item’s cell.
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let size = indexPathSectionItemSize where size.section == indexPath.section {
            return size.itemSize
        }
        
        let headerHeight = self.collectionView(self.calendarView, layout: self.calendarView.collectionViewLayout, referenceSizeForHeaderInSection: indexPath.section)
        let currentItemSize = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize
        let size = CGSize(width: currentItemSize.width, height: (calendarView.frame.height - headerHeight.height) / CGFloat(numberOfRows()))
        indexPathSectionItemSize = (section: indexPath.section, itemSize: size)
        return size
    }
}