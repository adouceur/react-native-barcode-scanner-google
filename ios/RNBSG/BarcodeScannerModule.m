//
//  BarcodeScannerModule.m
//  RNBSG
//
//  Created by Arnaud Douceur on 3/23/18.
//

#import "BarcodeScannerModule.h"
#import <AVFoundation/AVFoundation.h>

@implementation BarcodeScannerModule

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

RCT_EXPORT_METHOD(toggleFlashOn)
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        NSError *error = nil;
        [device setTorchModeOnWithLevel:1 error:&error];
        [device unlockForConfiguration];
    }
}

RCT_EXPORT_METHOD(toggleFlashOff)
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

@end

