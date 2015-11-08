
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BeaconDistance.h"

/**
 *	http://stackoverflow.com/questions/20332856/triangulate-example-for-ibeacons
 */
@interface Trilateration : NSObject

+ (CGPoint)pointForBeaconsAndDistances:(NSArray *)beaconDistances withCorrection:(BOOL)correction;

@end
