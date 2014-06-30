//
//  PhotographerMapViewController.h
//  Photomania
//

#import "MapViewController.h"

@interface PhotoMVC : MapViewController

// displays all Photographers in the managedObjectContext
//   (with more than 2 photos) on the mapView

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *userName;
// requeries Core Data for the Photographers

- (void)reload;
- (void)saveContext;

@end
