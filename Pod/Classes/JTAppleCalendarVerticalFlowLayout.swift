//
//  JTAppleCalendarVerticalFlowLayout.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-05-31.
//
//

import UIKit


/// Vertical flow layout for calendar view
public class JTAppleCalendarVerticalFlowLayout: JTAppleCalendarBaseFlowLayout {    
    var maxSections: Int = 0
    var daysPerSection: Int = 0
    
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
    
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
    
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        let requestedRows = Int(ceil(rect.height / itemSize.height))
        let requestSections = requestedRows / numberOfRows
        var startRow = Int(floor(rect.origin.y / itemSize.height))
        var endRow = startRow + requestedRows + 1
        let maxRows = maxSections * numberOfRows
        
        if endRow > maxRows {
            endRow = maxRows
        } // range for this loop loads an extra column so that it will not flicker when a user scrolls. // however you will get outOfBounds error if reached the end. Do check here
        
        if endRow < 0 { endRow = 0 }
        if startRow >= endRow { startRow = endRow - 1 }
        if startRow < 0 { startRow = 0 } // If the user scrolls beyond the left end boundary
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        var startSection = startRow / numberOfRows
        var endSection = startSection + requestSections + 1
        
        if endSection >= maxSections { endSection = maxSections - 1 }
        if endSection < 0 { endSection = 0 }
        
        if startSection >= endSection { startSection = endSection - 1 }
        if startSection < 0 { startSection = 0 }
        
        for row in startRow..<endRow {
            let section = row / numberOfRows
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
        if attributes.representedElementKind != nil {
            return
        }
        
        if let collectionView = self.collectionView {
            let sectionStride = collectionView.frame.size.height
            let sectionOffset = CGFloat(attributes.indexPath.section) * sectionStride
            let xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            
            if headerViewXibs.count > 0 {
                if let sizeOfItem = delegate?.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: attributes.indexPath) {
                    itemSize.height = sizeOfItem.height
                }
            }
            
            var yCellOffset :CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            yCellOffset += sectionOffset
            
            if headerViewXibs.count > 0 {
                let headerHeight = delegate!.referenceSizeForHeaderInSection(attributes.indexPath.section)
                yCellOffset += headerHeight.height
            }
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }
    }
    
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        size.height = self.collectionView!.bounds.size.height * CGFloat(numberOfMonthsInCalendar * numberOfSectionsPerMonth)
        size.width = self.collectionView!.bounds.size.width
        return size
    }
    
    /// Returns the layout attributes for the specified supplementary view.
    public override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        let size = delegate!.referenceSizeForHeaderInSection(indexPath.section)
        let modifiedSize = CGSize(width: collectionView!.frame.size.width, height: size.height) // Modify the width. It will always stretch to width of collectionview
        let stride = collectionView!.frame.size.height
        let offset = CGFloat(attributes.indexPath.section) * stride
        attributes.frame = CGRect(x: 0, y: offset, width: modifiedSize.width, height: modifiedSize.height)
        if attributes.frame == CGRectZero {
            return nil
        }
        
        return attributes
    }
}
