//
//  UIImage+Scale.m
//  WirelessInspection
//
//  Created by wuajohn on 14-6-25.
//  Copyright (c) 2014年 ajohn. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

+(UIImage *)scale:(UIImage *)image tosize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


@end
