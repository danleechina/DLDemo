//
//  ContextMaker.m
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/26.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

#import "ContextMaker.h"

@implementation ContextMaker
+ (CIContext*) makeMeAContext {
    return [CIContext contextWithOptions:nil];
}

+ (void)renderForMe:(UIView *)view {
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ref, 1.1, 1.1);
    CGContextTranslateCTM(ref, -5, -view.frame.size.height/2 + 22);
    [view.layer renderInContext:ref];
    
}
@end
