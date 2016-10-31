//
//  ContextMaker.h
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/26.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface ContextMaker : NSObject

+ (CIContext*) makeMeAContext;
+ (void)renderForMe:(UIView *)view;
@end
