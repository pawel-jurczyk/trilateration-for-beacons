
#import "Trilateration.h"

@implementation Trilateration

+ (CGPoint)pointForBeaconsAndDistances:(NSArray *)beaconDistances withCorrection:(BOOL)correction
{
	int bCount = (int)beaconDistances.count;
	NSMutableArray *pointsArray = [[NSMutableArray alloc] initWithCapacity:bCount];
	for (int i = 0 ; i < bCount - 2 ; i++ ) {
		NSArray *subArray = [beaconDistances subarrayWithRange:NSMakeRange(i, 3)];
		[pointsArray addObject:[self getCoordinateWithWithBeaconDiscances:subArray
														   withCorrection:correction]];
	}
	// Take the average of the calculated points. If 3 beacons, only one point will be calculated.
	CGFloat sumX = 0, sumY = 0;
	for (NSValue *pointValue in pointsArray) {
		CGPoint point = pointValue.CGPointValue;
		sumX += point.x;
		sumY += point.y;
	}
	CGFloat x = sumX / pointsArray.count,
			y = sumY / pointsArray.count;
	return CGPointMake(x, y);
}

/**
 *  Based on the 3rd point of this article http://everything2.com/title/Triangulate .
 
 *  Calculates the coordinate using trilateration having location of 3 beacons and distances from the receiver.
 
 *  Three circles around the beacons:
 
 *  A: (x - x1)^2 + (y - y1)^2 = r1^2
 
 *  B: (x - x2)^2 + (y - y2)^2 = r2^2
 
 *  C: (x - x3)^2 + (y - y3)^2 = r3^2
 
 *  Retrieve lines crossing two mutual points of any two circles

 *  A-B, B-C
 
 *  Intersection of any two of the three lines gives us the location.
 *  Extrapolate x from both equations:
 
 *  A-B:x=...
 
 *  B-C:x=...
 
 *  Compare both and get the value of x
 
 *  A-B = B-C -> x
 
 *  Get the value of y from value of x
 *
 *  @param beaconDistances An array of BeaconDistance objects.
 *
 *  @return The calculated point.
 */
+ (NSValue *)getCoordinateWithWithBeaconDiscances:(NSArray *)beaconDistances withCorrection:(BOOL)correction
{
	BeaconDistance *beacon1 = beaconDistances[0];
	BeaconDistance *beacon2 = beaconDistances[1];
	BeaconDistance *beacon3 = beaconDistances[2];
	
	CGFloat x1 = beacon1.beaconCoordinates.x,
			x2 = beacon2.beaconCoordinates.x,
			x3 = beacon3.beaconCoordinates.x;
	
	CGFloat y1 = beacon1.beaconCoordinates.y,
			y2 = beacon2.beaconCoordinates.y,
			y3 = beacon3.beaconCoordinates.y;
	
	CGFloat r1 = beacon1.distance,
			r2 = beacon2.distance,
			r3 = beacon3.distance;
	
	CGFloat W, Z, x, y;
	
	W = s(r1) - s(r2) - s(x1) - s(y1) + s(x2) + s(y2);
	Z = s(r2) - s(r3) - s(x2) - s(y2) + s(x3) + s(y3);
	
	x = (W * (y3 - y2) - Z * (y2 - y1)) / (2 * ((x2 - x1) * (y3 - y2) - (x3 - x2) * (y2 - y1)));
	
	if (y2 == y1) {
		y = 0;
	} else {
		y = (W - 2 * x * (x2 - x1)) / (2 * (y2 - y1));
	}
	CGPoint calculatedCoordinate = CGPointMake(x, y);
	if (correction) {
		calculatedCoordinate = [self applyCorrectionForPoint:calculatedCoordinate
										  forBeaconDiscances:beaconDistances];
	}
	
	return [NSValue valueWithCGPoint:calculatedCoordinate];
}

+ (CGPoint)applyCorrectionForPoint:(CGPoint)calculatedCoordinate
				forBeaconDiscances:(NSArray *)beaconDistances
{
	// Take in consideration that the signal is the most precise when closest to a beacon.
	// find the vector for each beacon:
	CGPoint totalVector = CGPointZero;
	CGFloat weight = 0;
	for (BeaconDistance *beDi in beaconDistances) {
		CGFloat
		dX = beDi.beaconCoordinates.x - calculatedCoordinate.x,
		dY = beDi.beaconCoordinates.y - calculatedCoordinate.y;
		
		CGFloat c1 = sqrt(s(dX) + s(dY));
		CGFloat d1 = c1 - beDi.distance;
		CGFloat ratio = d1 / c1;
		CGFloat multiplier = [self multipierForDistance:beDi.distance];

		totalVector.x += dX * ratio * multiplier;
		totalVector.y += dY * ratio * multiplier;
		weight += multiplier;
	}
	CGPoint coordinateWithCorrection = calculatedCoordinate;
	coordinateWithCorrection.x += totalVector.x / weight;
	coordinateWithCorrection.y += totalVector.y / weight;
	
	return coordinateWithCorrection;
}

// Squares the argument and returns the result
static inline CGFloat s(CGFloat value)
{
	return value * value;
}

+ (CGFloat)multipierForDistance:(CGFloat)distance
{
	return 1 / (distance);
}

@end
