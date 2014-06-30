//
//  UCDataPicker.h
//  Ch040802
//
//  Created by wuajohn on 14-5-17.
//  Copyright (c) 2014年 wuajohn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UCDatePickerDelegate;

@interface UCDatePicker : UITextField<UITextFieldDelegate>
{
@private
    UIActionSheet *action;
}

@property(nonatomic,strong)NSString *dateFormat;
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,weak) IBOutlet id<UCDatePickerDelegate>datePickerDelegate;
-(void)initComponets;

@end


@protocol UCDatePickerDelegate
@required
-(void)dateChanged:(NSDate *)date;
-(void)buttonClicked:(NSInteger)button;
@end
