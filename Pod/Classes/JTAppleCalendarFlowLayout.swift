//
//  JTAppleCalendarFlowLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

protocol JTAppleCalendarLayoutProtocol: class {
    var itemSize: CGSize {get set}
    var headerReferenceSize: CGSize {get set}
    var pathForFocusItem: NSIndexPath {get set}
    func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint
}
/// Base class for the Horizontal layout
public class JTAppleCalendarBaseFlowLayout: UICollectionViewLayout, JTAppleCalendarLayoutProtocol {
    var itemSize: CGSize = CGSizeZero
    var headerReferenceSize: CGSize = CGSizeZero
    var pathForFocusItem: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        let layoutAttrs = layoutAttributesForItemAtIndexPath(pathForFocusItem)
        return CGPointMake(layoutAttrs!.frame.origin.x - self.collectionView!.contentInset.left, layoutAttrs!.frame.origin.y-self.collectionView!.contentInset.top);
    }
}
/// Vertical flow layout for calendar view
public class JTAppleCalendarVerticalFlowLayout: UICollectionViewFlowLayout, JTAppleCalendarLayoutProtocol {
    var pathForFocusItem: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    /// Returns the content offset to use after an animation layout update or change.
    /// - Parameter proposedContentOffset: The proposed point for the upper-left corner of the visible content
    /// - returns: The content offset that you want to use instead
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        let layoutAttrs = layoutAttributesForItemAtIndexPath(pathForFocusItem)
        return CGPointMake(layoutAttrs!.frame.origin.x - self.collectionView!.contentInset.left, layoutAttrs!.frame.origin.y-self.collectionView!.contentInset.top);
    }
}
/// The JTAppleCalendarFlowLayout class is a concrete layout object that organizes day-cells into a grid
public class JTAppleCalendarHorizontalFlowLayout: JTAppleCalendarBaseFlowLayout {
    var numberOfRows = 0
    var numberOfColumns = 0
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 0
    var scrollDirection: UICollectionViewScrollDirection = .Horizontal
    
    weak var delegate: JTAppleCalendarDelegateProtocol?
    
    init(withDelegate delegate: JTAppleCalendarDelegateProtocol) {
        super.init()
        self.delegate = delegate
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
    /// Returns an object initialized from data in a given unarchiver. self, initialized using the data in decoder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// Tells the layout object to update the current layout.
    public override func prepareLayout() {
        numberOfRows = self.delegate!.numberOfRows()
        numberOfColumns = self.delegate!.numberOfColumns()
    }
    /// Returns the layout attributes for all of the cells and views in the specified rectangle.
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Determine how many columns needs to be displayed
        let requestedWidth = rect.width
        let requestedColumns = Int(requestedWidth / itemSize.width) + 2
        var startColumn = Int(rect.origin.x / itemSize.width)
        var endColumn = startColumn + requestedColumns
        
//        print("requestedWidth: \(requestedWidth) itemSize: \(itemSize) = \(requestedWidth / itemSize.width)")
//        print("requestedColumns: \(requestedColumns)")
//        print("range: \(endColumn - startColumn)")
//        print("startColumn: \(startColumn)")
//        print("endColumn: \(endColumn)")
        
        let maxColumns = delegate!.numberOfSections() * delegate!.numberOfsectionsPermonth() * 7
        if endColumn >= maxColumns {
            // range for this loop loads an extra column so that it will not flicker when a user scrolls.
            // however you will get outOfBounds error if reached the end. Do check here
            endColumn = maxColumns
        }
        
        if startColumn >= endColumn {
            startColumn = endColumn - 1
        }

        if startColumn < 0 { // If the user scrolls beyond the left end boundary
            startColumn = 0
        }

        var attributes: [UICollectionViewLayoutAttributes] = []
        
        for index in 0..<numberOfRows {
            for columnNumber in startColumn..<endColumn {
                let section = columnNumber / numberOfColumns
                let sectionIndex = (columnNumber % numberOfColumns) + (index * numberOfColumns)
                let indexPath = NSIndexPath(forItem: sectionIndex, inSection: section)
                if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                    attributes.append(attribute)
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
            let stride = collectionView.frame.size.width
            let offset = CGFloat(attributes.indexPath.section) * stride
            var xCellOffset : CGFloat = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
            let yCellOffset : CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            xCellOffset += offset
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }
    }
    /// Returns the width and height of the collection view’s contents. The width and height of the collection view’s contents.
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        size.width = self.collectionView!.bounds.size.width * CGFloat(delegate!.numberOfSections()) * CGFloat(delegate!.numberOfsectionsPermonth())
        return size
    }
    
    func adjustedIndex(index: Int, rows: Int, columns: Int) -> Int{
        let length = rows * columns
        let modval = index * rows
        let addFactor = (modval % length) + (modval / length)
        let retval = ((index + addFactor) % length) + ((index + addFactor) / length)
        
        return retval
    }
}


