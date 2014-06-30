//
//  Photo+Flickr.h
//  Photomania
//


#import "Photo.h"

@interface Photo (Flickr)

// Creates a Photo in the database for the given Flickr photo (if necessary).

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
