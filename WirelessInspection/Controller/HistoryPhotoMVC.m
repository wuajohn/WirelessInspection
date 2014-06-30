//
//  PhotographerMapViewController.m
//  Photomania
//

#import "HistoryPhotoMVC.h"
#import "Photo+MKAnnotation.h"
#import "WIAppDelegate.h"
#import "UCDatePicker.h"
#import "NSDate+String.h"

@interface HistoryPhotoMVC()
@property (strong, nonatomic) IBOutlet UCDatePicker *startDatePicker;
@property (strong, nonatomic) IBOutlet UCDatePicker *endDatePicker;

@end


@implementation HistoryPhotoMVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.startDatePicker.dateFormat=DF;    
    self.endDatePicker.dateFormat=DF;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setHour:-[components hour]-24];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *sDate = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
    
    [components setHour:24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *eDate = [cal dateByAddingComponents:components toDate: sDate options:0];
    self.startDatePicker.date=sDate;
    self.endDatePicker.date=eDate;
    
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//	[format setDateFormat:DF];
//    
//    NSString *dateString = [format stringFromDate:sDate];
//    [self.startDatePicker setText:dateString];
//    dateString = [format stringFromDate:eDate];
//    [self.endDatePicker setText:dateString];
}

- (IBAction)queryHistory:(id)sender {
    [self reload];
    [self updateRegion];
}



- (void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSDate *sDate = [NSDate dateFromString:self.startDatePicker.text];
    NSDate *eDate = [NSDate dateFromString:self.endDatePicker.text];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setHour:24];
    eDate = [cal dateByAddingComponents:components toDate: eDate options:0];
    
    
    request.predicate = [NSPredicate predicateWithFormat: @"whoTook.name = %@ AND photoDate >= %@ AND photoDate < %@", self.userName,sDate,eDate];
    
    NSArray *photos = [self.managedObjectContext executeFetchRequest:request error:NULL];
#warning 测试输出
    NSLog(@"context=%@,photos.count=%d",self.managedObjectContext.description, photos.count);
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:photos];
}
@end


