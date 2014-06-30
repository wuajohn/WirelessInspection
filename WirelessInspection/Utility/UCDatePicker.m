//
//  UCDatePicker.m
//  Ch040802
//
//  Created by wuajohn on 14-5-17.
//  Copyright (c) 2014年 wuajohn. All rights reserved.
//

#import "UCDatePicker.h"

@implementation UCDatePicker


-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)becomeFirstResponder{
    if (action==nil) 
        [self initComponets];
    if (action!=nil) {
        UIWindow *appWindow=[self window];
        [action showInView:appWindow];
        [action setBounds:CGRectMake(0, 0, 320, 500)];
    }
    return YES;
}

-(void)dealloc{
    self.datePickerDelegate=nil;
    if (action !=nil) {
        [action dismissWithClickedButtonIndex:1 animated:YES];
        action = nil;
    }
    if(self.dateFormat!=nil)
        self.dateFormat=nil;
}

-(void)didMoveToSuperview
{
    action=nil;
    _dateFormat=@"yyyy-MM-dd HH:mm:ss";
//    CGRect bounds=self.bounds;
//    UIImage *image=[UIImage imageNamed:@"downArrow.png"];
//    CGSize imageSize=image.size;
//	// create our indicator imageview and add it as a subview of our textview.
//	CGRect imageViewRect = CGRectMake((bounds.origin.x + bounds.size.width) - imageSize.width,
//									  (bounds.size.height/2) - (imageSize.height/2),
//									  imageSize.width, imageSize.height);
//    UIImageView *indicator=[[UIImageView alloc]initWithFrame:imageViewRect];
//    indicator.image=image;
//    [self addSubview:indicator];
    
}

-(void)didMoveToWindow{
    UIWindow *appWindow=[self window];
    if (appWindow != nil) {
        [self initComponets];
    }

}

-(void)doCancelClick:(id)sender{
    [action dismissWithClickedButtonIndex:0 animated:YES];
    [self.datePickerDelegate buttonClicked:0];
}

-(void)doDoneClick:(id)sender{
    [action dismissWithClickedButtonIndex:1 animated:YES];
    [self.datePickerDelegate buttonClicked:1];
}

-(void)initComponets{
    if (action!= nil)
        return;
    
    action=[[UIActionSheet alloc]initWithTitle:@"" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    //datePicker
    UIDatePicker *datePicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0.0, 44.4, 0.0, 0.0)];
    datePicker.datePickerMode=UIDatePickerModeDate;
    datePicker.maximumDate=[NSDate date];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    //datePickerToolBar
    UIToolbar *datePickerToolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    datePickerToolBar.barStyle=UIBarStyleBlackOpaque;
    [datePickerToolBar sizeToFit];
    
    NSMutableArray *barItems=[[NSMutableArray alloc]init];
    UIBarButtonItem *btnFlexibleSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:btnFlexibleSpace];
    
    UIBarButtonItem *btnCancel=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doCancelClick:)];
    [barItems addObject:btnCancel];
    
    UIBarButtonItem *btnDone=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDoneClick:)];
    [barItems addObject:btnDone];
    
    [datePickerToolBar setItems:barItems animated:YES];
    
    [datePicker setDate:self.date animated:NO];
    
    [action addSubview:datePickerToolBar];
    [action addSubview:datePicker];
}

- (void)dateChanged:(id)sender{
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:self.dateFormat];
	self.date= ((UIDatePicker*)sender).date;
	NSString *dateString = [format stringFromDate:self.date];
    [self setText:dateString];
	[self.datePickerDelegate dateChanged:self.date];
}












@end
