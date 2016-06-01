//
//  JTVerticalFlowLayout.swift
//  Pods
//
//  Created by Jeron Thomas on 2016-05-31.
//
//

import UIKit


/// Vertical flow layout for calendar view
public class JTAppleCalendarVerticalFlowLayout: UICollectionViewFlowLayout, JTAppleCalendarLayoutProtocol {
    var pointForFocusItem: CGPoint = CGPointZero
    var cellCache: [Int:[UICollectionViewLayoutAttributes]] = [:]
    var headerCache: [UICollectionViewLayoutAttributes] = []
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    var indexPathSectionItemSize: (section: Int, itemSize: CGSize)? // Keeps track of item size for a section. This is an optimization
    
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
    

    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
    }
    
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return super.layoutAttributesForElementsInRect(rect)?.map {
            attrs in
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
        
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let attrs = super.layoutAttributesForItemAtIndexPath(indexPath) {
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
        return nil
        
    }
    
    
    func applyLayoutAttributes(attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil {
            return
        }
        
        if let collectionView = self.collectionView {
            let stride = collectionView.frame.size.height
            let offset = CGFloat(attributes.indexPath.section) * stride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            
            // First get the header size
            var headerSize = CGSizeZero
            if headerViewXibs.count > 0 {
                headerSize = delegate!.referenceSizeForHeaderInSection(attributes.indexPath.section)
            }
            
//            var theItemSize =
//            
//            {
//                print(indexPath)
//                if let size = indexPathSectionItemSize where size.section == indexPath.section {
//                    return size.itemSize
//                }
//                
//                let headerHeight = self.collectionView(self.calendarView, layout: self.calendarView.collectionViewLayout, referenceSizeForHeaderInSection: indexPath.section)
//                let currentItemSize = (calendarView.collectionViewLayout as! JTAppleCalendarLayoutProtocol).itemSize
//                let size = CGSize(width: currentItemSize.width, height: (calendarView.frame.height - headerHeight.height) / CGFloat(numberOfRows()))
//                indexPathSectionItemSize = (section: indexPath.section, itemSize: size)
//            }
            
            
            
            
            if headerViewXibs.count > 0 {
                if let sizeOfItem = delegate?.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: attributes.indexPath) {
                    itemSize.height = sizeOfItem.height
                }
            }
            
            var yCellOffset : CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            
            if headerViewXibs.count > 0 {
                let headerHeight = delegate!.referenceSizeForHeaderInSection(attributes.indexPath.section)
                yCellOffset += headerHeight.height
            }
            yCellOffset += offset
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }
        
    }
    
    func clearCache() {
        cellCache.removeAll()
        headerCache.removeAll()
    }
}
