//
//  JTAppleCalendarFlowLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//
public class JTAppleCalendarBaseFlowLayout: UICollectionViewFlowLayout {
    var pathForFocusItem: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        let layoutAttrs = layoutAttributesForItemAtIndexPath(pathForFocusItem)
        return CGPointMake(layoutAttrs!.frame.origin.x - self.collectionView!.contentInset.left, layoutAttrs!.frame.origin.y-self.collectionView!.contentInset.top);
    }

}
public class JTAppleCalendarVerticalFlowLayout: JTAppleCalendarBaseFlowLayout {
}
/// The JTAppleCalendarFlowLayout class is a concrete layout object that organizes day-cells into a grid
public class JTAppleCalendarHorizontalFlowLayout: JTAppleCalendarBaseFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .Horizontal
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
    
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
    
    override  public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
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
            let stride = (self.scrollDirection == .Horizontal) ? collectionView.frame.size.width : collectionView.frame.size.height
            let offset = CGFloat(attributes.indexPath.section) * stride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            var yCellOffset : CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            if(self.scrollDirection == .Horizontal) {
                xCellOffset += offset;
            } else {
                yCellOffset += offset
            }
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }   
    }
}
