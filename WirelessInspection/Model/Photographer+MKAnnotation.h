//
//  Photographer+MKAnnotation.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photographer.h"
#import <MapKit/MapKit.h>

@interface Photographer (MKAnnotation) <MKAnnotation>

// this is not part of the MKAnnotation protocol
// but we implement it at the urging of MapViewController's header file
// it just picks a random thumbnail from this photographer's photos

- (UIImage *)thumbnail;  // blocks!

@end
