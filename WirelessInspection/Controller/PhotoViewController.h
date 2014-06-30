//
//  PhotoViewController.h
//  Photomania
//


#import "Photo.h"

@class PhotoViewController;

typedef void (^PhotoViewControllerSaveHandler)(PhotoViewController *sender, BOOL canceled);

@interface PhotoViewController : UIViewController

// a simple subclass of ImageViewController whose Model is a Photo
//  (instead of just an NSURL for the photo's image data)

@property (nonatomic, weak) Photo *photo;
@property (strong,nonatomic)PhotoViewControllerSaveHandler saveHandler;

@end
