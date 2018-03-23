//
//  BarcodeScannerModule.h
//  RNBSG
//
//  Created by Arnaud Douceur on 3/23/18.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTAssert.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@interface BarcodeScannerModule : NSObject <RCTBridgeModule>

@end
