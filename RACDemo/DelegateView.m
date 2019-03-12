//
//  DelegateView.m
//  RACDemo
//
//  Created by huangzhifei on 2018/11/2.
//  Copyright © 2018 eric. All rights reserved.
//

#import "DelegateView.h"
#import "RACEXTScope.h"

@interface DelegateView ()

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UILabel *label;

@end

@implementation DelegateView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        [self addSubview:self.btn];
        [self addSubview:self.label];
        [self addListenEvent];
    }
    return self;
}

- (void)addListenEvent {
    @weakify(self);
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self);
        [self buttonClick:self.btn];
//        [self.btnClickSignal sendNext:@"我在代理"];
//        CGFloat r = random() % 255;
//        CGFloat g = random() % 255;
//        CGFloat b = random() % 255;
//        self.backgroundColor = [UIColor colorWithRed:r / 255 green:g / 255 blue:b / 255 alpha:1.0];
    }];
    //[self.btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.label addGestureRecognizer:tap];

    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer *_Nullable x) {
        @strongify(self);
        [self.labelClickSignal sendNext:@""];
        CGFloat r = random() % 255;
        CGFloat g = random() % 255;
        CGFloat b = random() % 255;
        self.label.backgroundColor = [UIColor colorWithRed:r / 255 green:g / 255 blue:b / 255 alpha:1.0];
    }];
}

- (void)buttonClick:(UIButton *)sender {
    NSLog(@"xxxxxx");
}

#pragma mark - Setter & Getter

- (RACSubject *)btnClickSignal {
    if (!_btnClickSignal) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btn setTitle:@"代理测试" forState:UIControlStateNormal];
        _btn.frame = CGRectMake(0, 5, 100, 40);
    }
    return _btn;
}

- (RACSubject *)labelClickSignal {
    if (!_labelClickSignal) {
        _labelClickSignal = [RACSubject subject];
    }
    return _labelClickSignal;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.text = @"我是个label，点击我就变颜色";
        _label.frame = CGRectMake(0, 50, 300, 40);
        _label.backgroundColor = [UIColor whiteColor];
        _label.userInteractionEnabled = YES;
    }
    return _label;
}

@end
