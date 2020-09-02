

import UIKit

class DrawingSegmentationView: UIView {
    
    static private var colors: [Int32: UIColor] = [:]
    
    private var blackWhiteColor: [Int32 : UIColor] = [7: UIColor(red: 0, green: 0, blue: 0, alpha: 1), 0: UIColor(red: 0, green: 0, blue: 0, alpha: 1), 15: UIColor(white: 0, alpha: 0)]
    
    func segmentationColor(with index: Int32) -> UIColor {
        if let color = blackWhiteColor[index] {
            return color
        } else {
           let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            blackWhiteColor[index] = color
            return color
        }
    }
    
    var segmentationmap: SegmentationResultMLMultiArray? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            ctx.clear(rect);
            
            guard let segmentationmap = self.segmentationmap else { return }
            
            let size = self.bounds.size
            let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
            let segmentationmapHeightSize = segmentationmap.segmentationmapHeightSize
            let w = size.width / CGFloat(segmentationmapWidthSize)
            let h = size.height / CGFloat(segmentationmapHeightSize)
            
            print("W:", w)
            
            for j in 0..<segmentationmapHeightSize {
                for i in 0..<segmentationmapWidthSize {
                    let value = segmentationmap[j, i].int32Value

                    let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                    
                    print(value)
                    let color: UIColor = segmentationColor(with: value)
                    
                    color.setFill()
                    UIRectFill(rect)
                }
            }
        }
    } 

}
