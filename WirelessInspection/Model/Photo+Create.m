//
//  Photographer+Create.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photo+Create.h"
#import "Photographer.h"

@implementation Photo (Create)

+ (Photo *)photoWithTitle:(NSString *) title
                 subtitle: (NSString *) subtitle
                 imageURL: (NSString *) imageURL
             thumbnailURL: (NSString *) thumbnailURLString
                 latitude: (NSNumber *) latitude
                longitude: (NSNumber *) longitude
                photoDate: (NSDate *) photoDate
                   unique: (NSString *) unique
             photographer: (Photographer *) whoTook
   inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    // This is just like Photo(Flickr)'s method.  Look there for commentary.
    
    if (unique.length) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {            
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title=title;
            photo.subtitle=subtitle;
            photo.imageURL=imageURL;
            photo.thumbnailURLString=thumbnailURLString;
            photo.latitude=latitude;
            photo.longitude=longitude;
            photo.photoDate=photoDate;
            photo.unique=unique;
            photo.whoTook=whoTook;
        } else {
            photo = [matches lastObject];
        }
    }
    
    return photo;
}

@end
