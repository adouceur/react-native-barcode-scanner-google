//
//  SwiftViewManager.m
//  RNSwift
//

#import "BarcodeScannerViewManager.h"
//#import "CameraViewController.h"
#import "BarcodeScannerView.h"

//@interface BarcodeScannerViewManager()
//@property(strong) CameraViewController* cameraViewController;
//@end

@implementation BarcodeScannerViewManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onBarcodeRead, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(barcodeTypes, NSInteger)


- (UIView *) view
{
//    self.cameraViewController = [[CameraViewController alloc] init];
//    return self.cameraViewController.view;
    return [BarcodeScannerView new];
}

@end
