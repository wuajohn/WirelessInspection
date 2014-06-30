//
//  PhotoViewController.m
//  Photomania
//

#import "PhotoViewController.h"
#import "MapViewController.h"
#import "Photo+MKAnnotation.h"

@interface PhotoViewController ()<UIScrollViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subTitleTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation PhotoViewController


#warning 测试版
- (void)setImagePath:(NSString *)imagePath
{    
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            self.scrollView.zoomScale = 1.0;
            self.scrollView.contentSize = image.size;
            self.imageView.image = image;
            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        }
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
#warning 测试版
    self.title=self.photo.title;
    self.titleTextField.text=self.photo.title;    
    [self setImagePath:self.photo.thumbnailURLString];
  
}

- (IBAction)savePhoto:(UIBarButtonItem *)sender
{
    self.photo.title=self.titleTextField.text;
    self.photo.subtitle=self.subTitleTextField.text;
    self.saveHandler(self, NO);
    [self.navigationController popViewControllerAnimated:YES];
}



@end
