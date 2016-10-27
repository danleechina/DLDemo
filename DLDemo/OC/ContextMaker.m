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
@end
