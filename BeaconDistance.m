
#import "BeaconDistance.h"

@implementation BeaconDistance

+ (BeaconDistance *)beaconWithDistance:(double)distance coordinates:(CGPoint)beaconCoordinates
{
	BeaconDistance *beaconDistance = [BeaconDistance new];
	beaconDistance.distance = distance;
	beaconDistance.beaconCoordinates = beaconCoordinates;
	return beaconDistance;
}

@end
