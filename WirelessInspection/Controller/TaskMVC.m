//
//  TaskMVCViewController.m
//  WirelessInspection
//
//  Created by wuajohn on 14-6-23.
//  Copyright (c) 2014年 ajohn. All rights reserved.
//

#import "TaskMVC.h"
#import "Photographer+Create.h"
#import "Photo+Create.h"
#define centerLatitude 31.4091386259
#define centerLongitude 121.4737493443

@interface TaskMVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>

@property (strong,nonatomic)UIImagePickerController *imagePicker;
@property (strong,nonatomic)MKUserLocation *userLocation;
@property (nonatomic)int photoIndex;
@property (strong,nonatomic)CLLocationManager *locationManager;
@property (nonatomic)int locationIndex;

@end

@implementation TaskMVC

#pragma mark - 界面相关
- (IBAction)startTask:(UIBarButtonItem *)sender {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = centerLatitude;
    zoomLocation.longitude= centerLongitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 300, 300);
    [self.mapView setRegion:viewRegion animated:YES];
    
    if ( [sender.title isEqualToString:@"巡检"])
    {
        
        if (self.locationManager==nil) {
            self.locationManager=[[CLLocationManager alloc]init];
            self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            self.locationManager.distanceFilter=10;//10meter;
            self.locationManager.activityType=CLActivityTypeOther;
            self.locationManager.delegate=self;
        }
        [self.locationManager startUpdatingLocation];
        sender.title=@"停止";
    
    }
    else
    {
        [self.locationManager stopUpdatingLocation];
        sender.title=@"巡检";
    }
}



//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    if ([CLLocationManager locationServicesEnabled])
//    {
//        self.mapView.showsUserLocation = YES;
//        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //定位到当前位置
    if ([CLLocationManager locationServicesEnabled])
    {
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES]; 
    }   

}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLocation=userLocation;
}


#pragma mark - 异常拍照

- (IBAction)takePhoto:(UIBarButtonItem *)sender {  
    
    if (self.imagePicker==nil) {
        self.imagePicker=[[UIImagePickerController alloc]init];
        self.imagePicker.delegate=self;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==YES) 
            self.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        else
            self.imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    Photographer *photographer=[Photographer photographerWithName:self.userName inManagedObjectContext:self.managedObjectContext];//插入用户或查询用户
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        NSString *fileName=[self getFileName];        
        NSString *filePath =[self saveImage:image fileName:fileName];
#warning 用中心位置加随机量代替当前位置
        
        double shift= ((int)arc4random() % 100-50) /100000.0;   NSLog(@"shift:%.5f",shift);
        [Photo photoWithTitle:[NSString stringWithFormat:@"%d",++self.photoIndex]
                     subtitle:nil imageURL:filePath thumbnailURL:filePath
                     latitude:[NSNumber numberWithDouble:(centerLatitude+shift)]//用中心位置加随机量代替当前位置
                    longitude:[NSNumber numberWithDouble:(centerLongitude+shift/50.0)] photoDate:[NSDate date]
                       unique:filePath photographer:photographer inManagedObjectContext:self.managedObjectContext];
    }
    
    //保存数据
    [self saveContext];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self reload];
}

-(NSString *)getFileName
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];        
    
    return [NSString stringWithFormat:@"%@_%@_%4f_%4f.png",self.userName,currentDateStr,
            self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];    
}

- (NSString *)saveImage:(UIImage *)image fileName:(NSString *)fileName
{
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filePath =[filePath stringByAppendingPathComponent:@"images"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {//创建路径
        NSError *error;
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"create Directory images error.%@",error);
        }
    }
    
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = [UIImagePNGRepresentation(image)writeToFile:filePath atomically:YES];
    if (result) {
        return filePath;
    } else {
        return nil;
    }
}

#pragma mark - 位置变化时纪录位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation=[locations lastObject]; 
    NSTimeInterval eventInterval=[lastLocation.timestamp timeIntervalSinceNow];
    if (abs(eventInterval) < 30.0) {
        if (lastLocation.horizontalAccuracy >=0 && lastLocation.horizontalAccuracy<20) {
            
            Photographer *photographer=[Photographer photographerWithName:self.userName inManagedObjectContext:self.managedObjectContext];//插入用户或查询用户
            NSString *helloImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"hello.png"];
            
            //实例化一个NSDateFormatter对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
            //用[NSDate date]可以获取系统当前时间
            NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
            
            NSString *unique = [NSString stringWithFormat:@"hello_%@_%@_%4f_%4f",self.userName,currentDateStr, self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
            [Photo photoWithTitle:[NSString stringWithFormat:@"%d",++self.locationIndex]
                         subtitle:nil imageURL:nil thumbnailURL:helloImagePath
                         latitude:[NSNumber numberWithDouble:lastLocation.coordinate.latitude]//用中心位置加随机量代替当前位置
                        longitude:[NSNumber numberWithDouble:lastLocation.coordinate.longitude] photoDate:[NSDate date]
                           unique:unique photographer:photographer inManagedObjectContext:self.managedObjectContext];
        }
    }


}

#pragma mark - 数据相关
- (void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
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
    
    NSArray *photos = [self.managedObjectContext executeFetchRequest:request error:NULL];
#warning 测试输出
    NSLog(@"context=%@,photos.count=%d",self.managedObjectContext.description, photos.count);
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:photos];
}

@end
