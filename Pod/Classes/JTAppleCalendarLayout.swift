//
//  JTAppleCalendarLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


/// Base class for the Horizontal layout
public class JTAppleCalendarLayout: UICollectionViewLayout, JTAppleCalendarLayoutProtocol {
    var itemSize: CGSize = CGSizeZero
    var headerReferenceSize: CGSize = CGSizeZero
    var scrollDirection: UICollectionViewScrollDirection = .Horizontal
    var maxSections: Int = 0
    var daysPerSection: Int = 0
    
    var numberOfColumns: Int { get { return delegate!.numberOfColumns() } }
    var numberOfMonthsInCalendar: Int { get { return delegate!.numberOfMonthsInCalendar() } }
    var numberOfSectionsPerMonth: Int { get { return delegate!.numberOfsectionsPermonth() } }
    var numberOfDaysPerSection: Int { get { return delegate!.numberOfDaysPerSection() } }
    var numberOfRows: Int { get { return delegate!.numberOfRows() } }
    
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] = [:]
    var headerCache: [UICollectionViewLayoutAttributes] = []
    
    
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    /// Tells the layout object to update the current layout.
    public override func prepareLayout() {
        if !cellCache.isEmpty {
            return
        }
        
        maxSections = numberOfMonthsInCalendar * numberOfSectionsPerMonth
        daysPerSection = numberOfDaysPerSection
        
        // // Generate and cache the headers
        for section in 0..<maxSections {
            // generate header views
            let sectionIndexPath = NSIndexPath(forItem: 0, inSection: section)
            if let aHeaderAttr = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: sectionIndexPath) {
                headerCache.append(aHeaderAttr)
            }
            
            // Generate and cache the cells
            for item in 0..<daysPerSection {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                    if cellCache[section] == nil {
                        cellCache[section] = []
                    }
                    cellCache[section]!.append(attribute)
                } else {
                    print("error.")
                }
            }
        }
    }
    
    /// Returns the layout attributes for the specified supplementary view.
    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        let size = delegate!.referenceSizeForHeaderInSection(indexPath.section)
        let modifiedSize = CGSize(width: collectionView!.frame.size.width, height: size.height)
        let stride = scrollDirection == .Horizontal ? collectionView!.frame.size.width : collectionView!.frame.size.height
        let offset = CGFloat(attributes.indexPath.section) * stride
        
        attributes.frame = scrollDirection == .Horizontal ? CGRect(x: offset, y: 0, width: modifiedSize.width, height: modifiedSize.height) : CGRect(x: 0, y: offset, width: modifiedSize.width, height: modifiedSize.height)
        if attributes.frame == CGRectZero { return nil }
        
        return attributes
    }
    
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        if scrollDirection == .Horizontal {
            size.width = self.collectionView!.bounds.size.width * CGFloat(numberOfMonthsInCalendar * numberOfSectionsPerMonth)
        } else {
            size.height = self.collectionView!.bounds.size.height * CGFloat(numberOfMonthsInCalendar * numberOfSectionsPerMonth)
            size.width = self.collectionView!.bounds.size.width
        }
        return size
    }
    
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let requestedSet = scrollDirection == .Horizontal ? Int(ceil(rect.width / itemSize.width)) : Int(ceil(rect.height / itemSize.height))
        let requestedSections = scrollDirection == .Horizontal ? requestedSet / numberOfColumns : requestedSet / numberOfRows
        var startSet = scrollDirection == .Horizontal ? Int(floor(rect.origin.x / itemSize.width)) : Int(floor(rect.origin.y / itemSize.height))
        var endSet = scrollDirection == .Horizontal ? startSet + requestedSet : startSet + requestedSet + 1
        let maxSet = scrollDirection == .Horizontal ? maxSections * numberOfColumns : maxSections * numberOfRows
        
        if endSet > maxSet { endSet = maxSet } // range for this loop loads an extra column so that it will not flicker when a user scrolls. // however you will get outOfBounds error if reached the end. Do check here
        if endSet < 0 { endSet = 0 }
        if startSet >= endSet { startSet = endSet - 1 }
        if startSet < 0 { startSet = 0 } // If the user scrolls beyond the left end boundary
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        var startSection = scrollDirection == .Horizontal ? (startSet + 1) / 7 : startSet / numberOfRows
        var endSection = scrollDirection == .Horizontal ? startSection + requestedSections : startSection + requestedSections + 1
        
        if endSection >= maxSections { endSection = maxSections - 1 }
        if endSection < 0 { endSection = 0 }
        if startSection >= endSection { startSection = endSection - 1 }
        if startSection < 0 { startSection = 0 }
        
        let divValue = scrollDirection == .Horizontal ? numberOfColumns : numberOfRows
        for set in startSet..<endSet {
            let section = set / divValue
            if let sectData = cellCache[section] {
                for val in sectData {
                    if CGRectIntersectsRect(val.frame, rect) {
                        attributes.append(val)
                    }
                }
            }
        }
        
        if headerViewXibs.count > 0 {
            for index in startSection...endSection {
                if CGRectIntersectsRect(headerCache[index].frame, rect) {
                    attributes.append(headerCache[index])
                }
            }
        }
        
        return attributes
    }
    
    /// Returns the layout attributes for the item at the specified index path. A layout attributes object containing the information to apply to the item’s cell.
    override  public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        applyLayoutAttributes(attr)
        return attr
    }
    
    func applyLayoutAttributes(attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil { return }
        
        if let collectionView = self.collectionView {
            let sectionStride: CGFloat = scrollDirection == .Horizontal ? collectionView.frame.size.width : collectionView.frame.size.height
            let sectionOffset = CGFloat(attributes.indexPath.section) * sectionStride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            var yCellOffset :CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            
            if headerViewXibs.count > 0 {
                if let sizeOfItem = delegate?.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: attributes.indexPath) {
                    itemSize.height = sizeOfItem.height
                }
            }
            
            if scrollDirection == .Horizontal {
                xCellOffset += sectionOffset
            } else {
                yCellOffset += sectionOffset
            }
            
            if headerViewXibs.count > 0 {
                let headerHeight = delegate!.referenceSizeForHeaderInSection(attributes.indexPath.section)
                yCellOffset += headerHeight.height
            }
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
    
    func clearCache() {
        headerCache.removeAll()
        cellCache.removeAll()
    }
}