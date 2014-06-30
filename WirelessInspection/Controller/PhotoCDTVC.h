//
//  PhotographerCDTVC.h
//  Photomania
//
//  Can do "setPhotographer:" segue and will call said method in destination VC.

#import "CoreDataTableViewController.h"

@interface PhotoCDTVC : CoreDataTableViewController

// The Model for this class.
// Essentially specifies the database to look in to find all Photographers to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *userName;

- (void)reload;

@end
