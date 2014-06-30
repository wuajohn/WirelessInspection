//
//  PhotographerCDTVC.m
//  Photomania
//

#import "PhotoCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "WIAppDelegate.h"
#import "NSDate+String.h"
#import "UIImage+Scale.h"
#import "PhotoViewController.h"

@implementation PhotoCDTVC

#pragma mark - Properties

// The Model for this class.
//
// When it gets set, we create an NSFetchRequest to get all Photographers in the database associated with it.
// Then we hook that NSFetchRequest up to the table view using an NSFetchedResultsController.

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self reload];
}

#pragma mark - 数据相关
- (void)reload
{
    if (_managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"photoDate" ascending:YES ]];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
        [components setHour:-[components hour]];
        [components setMinute:-[components minute]];
        [components setSecond:-[components second]];
        NSDate *sDate = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
        
        [components setHour:24];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *eDate = [cal dateByAddingComponents:components toDate: sDate options:0];
        
        request.predicate = [NSPredicate predicateWithFormat: @"whoTook.name = %@ AND photoDate >= %@ AND photoDate < %@", self.userName,sDate,eDate];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    #warning 测试输出
        NSLog(@"context=%@,photos.count=%d",self.managedObjectContext.description, [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    }
    else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

// Uses NSFetchedResultsController's objectAtIndexPath: to find the Photographer for this row in the table.
// Then uses that Photographer to set the cell up.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@",photo.subtitle,[NSString stringFromLongDate:photo.photoDate]];
    cell.imageView.image=[UIImage scale:[UIImage imageWithContentsOfFile:photo.thumbnailURLString]tosize:CGSizeMake(40.0f, 40.0f)];
    
    return cell;
}

#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Photographer in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setPhotographer:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath)
    {
        if ([segue.identifier isEqualToString:@"setPhoto:"]) {
                Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                
                if ([segue.destinationViewController isKindOfClass:[PhotoViewController class]])
                {
                        PhotoViewController *photoViewController=(PhotoViewController*)segue.destinationViewController;
                        photoViewController.photo=photo;
                        photoViewController.saveHandler=^(PhotoViewController *sender, BOOL canceled)
                        {
                            if (!canceled)
                            {                        
                                NSError *error = nil;
                                if (self.managedObjectContext != nil) {                                    
                                    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
                                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                        abort();
                                    }
                                    
                                    NSLog(@"PhotoMVC call saveContext");
                                }
                                [self.tableView reloadData];
                            }
                        };
                }
        }
    }
}

    
#pragma mark - View Controller Lifecycle

// Just sets the Refresh Control's target/action since it can't be set in Xcode (bug?).

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    self.userName= ((WIAppDelegate*)[[UIApplication sharedApplication] delegate]).userName;
    [self reload];   
}

// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
        [self useDocument];
    [self reload];
}

// Either creates, opens or just uses the demo document
//   (actually, it will never "just use" it since it just creates the UIManagedDocument instance here;
//    the "just uses" case is just shown that if someone hands you a UIManagedDocument, it might already
//    be open and so you can just use it if it's documentState is UIDocumentStateNormal).
//
// Creating and opening are asynchronous, so in the completion handler we set our Model (managedObjectContext).

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"database"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

#pragma mark - Refreshing

// Fires off a block on a queue to fetch data from Flickr.
// When the data comes back, it is loaded into Core Data by posting a block to do so on
//   self.managedObjectContext's proper queue (using performBlock:).
// Data is loaded into Core Data by calling photoWithFlickrInfo:inManagedObjectContext: category method.

- (IBAction)refresh
{
#warning 测试用
    return;
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}


@end
