//
//  PhotographerMapViewController.m
//  Photomania
//

#import "PhotoMVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "WIAppDelegate.h"


@implementation PhotoMVC

@synthesize managedObjectContext=_managedObjectContext;

// if we are visible and our Model is (re)set, refetch from Core Data

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (self.view.window) [self reload];
}

// always fetch from Core Data after our outlets (mapView) are set
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userName= ((WIAppDelegate*)[[UIApplication sharedApplication] delegate]).userName;
    [self reload];
    
    // Polygon overlay  //绘制巡视区域
    CLLocationCoordinate2D polyCoords[7] = {
        CLLocationCoordinate2DMake(31.4103147765,121.4740188774),
        CLLocationCoordinate2DMake(31.4082296259,121.4750703443),
        CLLocationCoordinate2DMake(31.4080336259,121.4742683443),
        CLLocationCoordinate2DMake(31.4091386259,121.4737493443),
        CLLocationCoordinate2DMake(31.4090806259,121.4734003443),
        CLLocationCoordinate2DMake(31.4100407765,121.4729378774),
        CLLocationCoordinate2DMake(31.4104147765,121.4740188774)
    };
    MKPolygon *polygonOverlay = [MKPolygon polygonWithCoordinates:polyCoords count:7];
    [self.mapView addOverlays:[NSArray arrayWithObjects: polygonOverlay, nil]];
}

- (void)reload//abtract
{
}


//绘制巡检路线
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
    if([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
        
        //Display settings
        view.lineWidth=2;
        view.strokeColor=[UIColor blueColor];
        //view.fillColor=[[UIColor blueColor] colorWithAlphaComponent:0.5];
        return view;
    }
    return nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
        [self useDocument];
}

// 场景切换
// sent to the mapView's delegate (us) when any {left,right}CalloutAccessoryView
//   that is a UIControl is tapped on
// in this case, we manually segue using the setPhoto: segue

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setPhoto:" sender:view];
}

// prepares a view controller segued to via the setPhoto: segue
//   by calling setPhoto: with the photo associated with sender
//   (sender must be an MKAnnotationView whose annotation is a Photo)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhoto:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[Photo class]]) {
                Photo *photo = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
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
#warning 测试屏蔽掉Flickr
    return;
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
        // put the photos in Core Data
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reload];
            });
        }];
    });
}

//及时保存数据
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSLog(@"PhotoMVC call saveContext");
    }
    
}
@end


