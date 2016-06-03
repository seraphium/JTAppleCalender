//
//  JTAppleDayCell.swift
//  JTAppleCalendar
//
//  Created by Jay Thomas on 2016-03-01.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

var cellViewFromDeveloper: String?
var cellViewIsClass: Bool?

var internalCellInset: CGPoint = CGPoint(x: 3.0, y: 3.0)

/// The JTAppleDayCell class defines the attributes and behavior of the cells that appear in JTAppleCalendarView objects.
public class JTAppleDayCell: UICollectionViewCell {
    
    var cellView: JTAppleDayCellView!

    func setupCellView() {
        
        guard let validCell = cellViewFromDeveloper else {
            print("Did you remember to register your xib file to JTAppleCalendarView? call the registerCellViewXib method on it because xib filename is nil")
            return
        }
        
        var theView: JTAppleDayCellView
        
        if !(cellViewIsClass!) {
            let viewObject = NSBundle.mainBundle().loadNibNamed(validCell, owner: self, options: [:])
            assert(viewObject.count > 0, "your nib file name \(validCell) could not be loaded)")
            
            guard let view = viewObject[0] as? JTAppleDayCellView else {
                print("xib file class does not conform to the protocol<JTAppleDayCellViewProtocol>")
                assert(false )
                return
            }
            theView = view
        } else {
            guard let theCellClass = NSBundle.mainBundle().classNamed(validCell) as? JTAppleDayCellView.Type else {
                print("Error loading registered class: '\(validCell)'")
                print("Make sure that: \n\n(1) It is a subclass of: 'JTAppleDayCellView' \n(2) You registered your class using the fully qualified name like so -->  'theNameOfYourProject.theNameOfYourClass'\n")
                assert(false)
                return
            }
            theView = theCellClass.init()
        }
    
        updateCellView(theView)
    }
    
    func updateCellView(view: JTAppleDayCellView) {
        let vFrame = CGRectInset(self.frame, internalCellInset.x, internalCellInset.y)
        view.frame = vFrame
        view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        cellView = view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCellView()
        self.addSubview(cellView)
    }
    
    /// Returns an object initialized from data in a given unarchiver.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
