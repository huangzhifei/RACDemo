//
//  DelegateView.h
//  RACDemo
//
//  Created by huangzhifei on 2018/11/2.
//  Copyright © 2018 eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface DelegateView : UIView

@property (nonatomic, strong) RACSubject *btnClickSignal;
@property (nonatomic, strong) RACSubject *labelClickSignal;

@end

NS_ASSUME_NONNULL_END
