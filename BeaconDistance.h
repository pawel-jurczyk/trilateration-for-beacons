
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  BeaconDistance object tells the distance from a beacon and the coordinates of that beacon.
 */
@interface BeaconDistance : NSObject

@property (assign, nonatomic) CGFloat distance;
@property (assign, nonatomic) CGPoint beaconCoordinates;

+ (BeaconDistance *)beaconWithDistance:(double)distance coordinates:(CGPoint)beaconCoordinates;

@end
