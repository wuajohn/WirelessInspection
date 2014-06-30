//
//  Photo+MKAnnotation.h
//  Photomania
//

#import "Photo.h"
#import <MapKit/MapKit.h>

@interface Photo (MKAnnotation) <MKAnnotation>

// this is not part of the MKAnnotation protocol
// but we implement it at the urging of MapViewController's header file

- (UIImage *)thumbnail;  // blocks!

@end
