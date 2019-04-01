//
//  ViewController+BViewControllerCategory.m
//  RACDemo
//
//  Created by huangzhifei on 2019/4/1.
//  Copyright © 2019 eric. All rights reserved.
//

#import "ViewController+BViewControllerCategory.h"
#import "NSObject+InvokeOriginalMethod.h"

@implementation ViewController (BViewControllerCategory)

- (void)viewDidLoad {
    
    NSLog(@"BViewControllerCategory %@", NSStringFromSelector(_cmd));
    self.view.tag = 2;
    [NSObject invokeOriginalMethod:self selector:_cmd];
}

@end
