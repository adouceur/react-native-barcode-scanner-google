//
//  SwiftView.swift
//  RNBSG
//

import UIKit

class BarcodeScannerView: BarcodeScannerViewObjC {
    let childVC = UIStoryboard(name: "GMVBD", bundle: nil).instantiateInitialViewController() as! BarcodeScannerChildViewController
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
            rootVC.addChildViewController(childVC)
            childVC.swiftView = self
            addSubview(childVC.view)
            childVC.didMove(toParentViewController: rootVC)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        childVC.view.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init coder isn't supported")
    }
    
    var barcodeType: Int? {
        get {
            return self.barcodeType ?? nil
        }
    }
}
