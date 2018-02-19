@import AVFoundation;
#import "GoogleMobileVision.h"
#import "BarcodeScannerView.h"
#import <React/RCTComponent.h>

@interface BarcodeScannerView()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onBarcodeRead;
@property (nonatomic, copy) RCTBubblingEventBlock onException;
@property (nonatomic) NSInteger barcodeTypes;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) GMVDetector *barcodeDetector;

@end

@implementation BarcodeScannerView


- (id)init {
    self = [super init];
    if (self) {
        _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue",
                                                      DISPATCH_QUEUE_SERIAL);
        // Set up default camera settings.
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
        [self updateCameraSelection];
        
        // Set up video processing pipeline.
        [self setUpVideoProcessing];
        
        // Set up camera preview.
        [self setUpCameraPreview];
        
        // Initialize barcode detector.
        self.barcodeDetector = [GMVDetector detectorOfType:GMVDetectorTypeBarcode options:@{GMVDetectorBarcodeFormats: @(self.barcodeTypes)}];
    }
    return self;
}


- (void)layoutSubviews {
    self.previewLayer.frame = self.layer.bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.previewLayer.frame),
                                             CGRectGetMidY(self.previewLayer.frame));
}

- (void)dealloc {
    [self cleanupCaptureSession];
}

- (void)didMoveToWindow {
    if (self.window) {
        [self.session startRunning];
    } else {
        [self.session stopRunning];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    UIImage *image = [GMVUtility sampleBufferTo32RGBA:sampleBuffer];
    AVCaptureDevicePosition devicePosition = AVCaptureDevicePositionBack;
    
    // Establish the image orientation and detect features using GMVDetector.
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    GMVImageOrientation orientation = [GMVUtility
                                       imageOrientationFromOrientation:deviceOrientation
                                       withCaptureDevicePosition:devicePosition
                                       defaultDeviceOrientation:UIDeviceOrientationPortrait];
    NSDictionary *options = @{
                              GMVDetectorImageOrientation : @(orientation)
                              };
    
    NSArray<GMVBarcodeFeature *> *barcodes = [self.barcodeDetector featuresInImage:image
                                                                           options:options];
    NSLog(@"Detected %lu barcodes.", (unsigned long)barcodes.count);
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Display detected features in overlay.
        for (GMVBarcodeFeature *barcode in barcodes) {
            self.onBarcodeRead(@{@"data" : barcode.rawValue});
        }
    });
}

#pragma mark - Camera setup

- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.session removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
}

- (void)cleanupCaptureSession {
    [self.session stopRunning];
    [self cleanupVideoProcessing];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
}

- (void)setUpVideoProcessing {
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *rgbOutputSettings = @{
                                        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
                                        };
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    
    if (![self.session canAddOutput:self.videoDataOutput]) {
        [self cleanupVideoProcessing];
        NSLog(@"Failed to setup video output");
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.session addOutput:self.videoDataOutput];
}

- (void)setUpCameraPreview {
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[UIColor blackColor].CGColor];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = self.layer;
    rootLayer.masksToBounds = YES;
    [self.previewLayer setFrame:rootLayer.bounds];
    [rootLayer addSublayer:self.previewLayer];
}

- (void)updateCameraSelection {
    [self.session beginConfiguration];
    
    // Remove old inputs
    NSArray *oldInputs = [self.session inputs];
    for (AVCaptureInput *oldInput in oldInputs) {
        [self.session removeInput:oldInput];
    }
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionBack;
    AVCaptureDeviceInput *input = [self captureDeviceInputForPosition:desiredPosition];
    if (!input) {
        // Failed, restore old inputs
        for (AVCaptureInput *oldInput in oldInputs) {
            [self.session addInput:oldInput];
        }
    } else {
        // Succeeded, set input and update connection states
        [self.session addInput:input];
    }
    [self.session commitConfiguration];
}

- (AVCaptureDeviceInput *)captureDeviceInputForPosition:(AVCaptureDevicePosition)desiredPosition {
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == desiredPosition) {
            NSError *error = nil;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                                error:&error];
            if (error) {
                NSLog(@"Could not initialize for AVMediaTypeVideo for device %@", device);
            } else if ([self.session canAddInput:input]) {
                return input;
            }
        }
    }
    return nil;
}

@end


