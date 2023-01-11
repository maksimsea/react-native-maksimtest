#import <AVFoundation/AVFoundation.h>

#ifdef RCT_NEW_ARCH_ENABLED

#import "RNMaksimtestSpec.h"

@interface Maksimtest : NSObject <NativeMaksimtestSpec>
#else
#import <React/RCTBridgeModule.h>

@interface Maksimtest : NSObject <RCTBridgeModule>
#endif


@property(nonatomic) NSMutableData * mdata;
@property(nonatomic) NSString *soundPath;
@property(nonatomic) AVURLAsset *asset;


@end
