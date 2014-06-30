//
//  LoginViewController.m
//  WirelessInspection
//
//  Created by wuajohn on 14-6-23.
//  Copyright (c) 2014年 ajohn. All rights reserved.
//

#import "LoginViewController.h"
#import "WIAppDelegate.h"

@interface LoginViewController ()

@property (nonatomic,strong)IBOutlet UITextField *userNameField;
@property (nonatomic,strong)IBOutlet UITextField *passwordField;


@end

@implementation LoginViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)login:(id)sender {
//    if ([@"ajohn" isEqualToString:self.userNameField.text] &&
//        [@"12345" isEqualToString:self.passwordField.text]){
//        
//        WIAppDelegate* appDelegate = (WIAppDelegate*)[[UIApplication sharedApplication] delegate];
//        appDelegate.userName=self.userNameField.text;
//        [self performSegueWithIdentifier:@"login" sender:nil];
//    }
    if (![@"" isEqualToString:self.userNameField.text] &&
        ![@"" isEqualToString:self.passwordField.text]){
        WIAppDelegate* appDelegate = (WIAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.userName=self.userNameField.text;
        [self performSegueWithIdentifier:@"login" sender:nil];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"警告" message:@"用户名或密码错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"login"]) {
//        if ([segue.destinationViewController isKindOfClass:[UIViewController class]]) {
//            
//        }
//    }
//}

@end
