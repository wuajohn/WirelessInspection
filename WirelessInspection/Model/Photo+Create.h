//
//  Photographer+Create.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photo.h"
@class Photographer;

@interface Photo (Create)

+ (Photo *)photoWithTitle:(NSString *) title
                subtitle: (NSString *) subtitle
                imageURL: (NSString *) imageURL
            thumbnailURL: (NSString *) thumbnailURLString
                latitude: (NSNumber *) latitude
               longitude: (NSNumber *) longitude
               photoDate: (NSDate *) photoDate
                  unique: (NSString *) unique
            photographer: (Photographer *) whoTook
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
