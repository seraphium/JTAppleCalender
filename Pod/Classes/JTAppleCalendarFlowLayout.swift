//
//  JTAppleCalendarFlowLayout.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//


protocol JTAppleCalendarLayoutProtocol: class {
    func numberOfRows() -> Int
    func numberOfColumns() -> Int
    func numberOfsectionsPermonth() -> Int
    func numberOfSections() -> Int
}

public class JTAppleCalendarBaseFlowLayout: UICollectionViewLayout {
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
public class JTAppleCalendarVerticalFlowLayout: UICollectionViewFlowLayout {
}
/// The JTAppleCalendarFlowLayout class is a concrete layout object that organizes day-cells into a grid
public class JTAppleCalendarHorizontalFlowLayout: JTAppleCalendarBaseFlowLayout {
    var numberOfRows = 0
    var numberOfColumns = 0
    var minimumInteritemSpacing: CGFloat = 0
    var minimumLineSpacing: CGFloat = 0
    var scrollDirection: UICollectionViewScrollDirection = .Horizontal
    
    weak var delegate: JTAppleCalendarLayoutProtocol?
    
    init(withDelegate delegate: JTAppleCalendarLayoutProtocol) {
        super.init()
        self.delegate = delegate
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prepareLayout() {
        numberOfRows = self.delegate!.numberOfRows()
        numberOfColumns = self.delegate!.numberOfColumns()
    }
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Determine how many columns needs to be displayed
        let requestedWidth = rect.width
        let visibleWidth = self.collectionView!.bounds.width
        let requestedColumns = Int(requestedWidth / itemSize.width) + 2
        let startColumn = Int(rect.origin.x / itemSize.width)
        var endColumn = startColumn + requestedColumns
        
        
        print("")
        print("requestedWidth: \(requestedWidth) itemSize: \(itemSize) = \(requestedWidth / itemSize.width)")
        print("requestedColumns: \(requestedColumns)")
        print("range: \(endColumn - startColumn)")
        print("startColumn: \(startColumn)")
        print("endColumn: \(endColumn)")
        print("")
        
        let maxColumns = delegate!.numberOfSections() * delegate!.numberOfsectionsPermonth() * 7
        if endColumn >= maxColumns{
            // range for this loop loads an extra column so that it will not flicker when a user scrolls.
            // however you will get outOfBounds error if reached the end. Do check here
            endColumn = maxColumns
        }
        


        if startColumn < 0 { // If the user scrolls beyond the left end boundary
            return nil
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
        
        let x = attributes.sort { (firstVal: UICollectionViewLayoutAttributes, secondVal: UICollectionViewLayoutAttributes) -> Bool in
            if firstVal.indexPath.section < secondVal.indexPath.section {
                return true
            }
            
            if firstVal.indexPath.section == secondVal.indexPath.section {
                if firstVal.indexPath.item < secondVal.indexPath.item {
                    return true
                }
            }
            
            return false
        }
        
        return attributes
    }
    
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
            var yCellOffset : CGFloat = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
            xCellOffset += offset
            attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height)
        }
    }
    
    public override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        // make sure it's wide enough to cover all the objects
        size.width = self.collectionView!.bounds.size.width * CGFloat(collectionView!.numberOfSections())
        return size;
    }
    
    func adjustedIndex(index: Int, rows: Int, columns: Int) -> Int{
        let length = rows * columns
        let modval = index * rows
        let addFactor = (modval % length) + (modval / length)
        let retval = ((index + addFactor) % length) + ((index + addFactor) / length)
        
        return retval
    }
}


