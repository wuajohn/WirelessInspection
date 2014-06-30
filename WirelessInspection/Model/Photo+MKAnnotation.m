//
//  Photo+MKAnnotation.m
//  Photomania
//


#import "Photo+MKAnnotation.h"

@implementation Photo (MKAnnotation)

// Photo already implements two of the MKAnnotation methods
//   title and subtitle
// this is the implementation of the third (required) method

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

// MapViewController likes annotations to implement this

- (UIImage *)thumbnail
{
#warning 测试用
    //return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.thumbnailURLString]]];
    
    return [UIImage imageWithContentsOfFile:self.thumbnailURLString];
    
}

@end
