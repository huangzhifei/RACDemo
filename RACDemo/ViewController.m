//
//  ViewController.m
//  RACDemo
//
//  Created by huangzhifei on 2018/11/2.
//  Copyright © 2018 eric. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "DelegateView.h"
#import "SFIMGCDTimer.h"

@interface ViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) DelegateView *delegateView;
@property (weak, nonatomic) IBOutlet UIButton *countDownBtn;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, strong) UILabel *labelxx;
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, assign) NSInteger dex;
@property (nonatomic, strong) RACCommand *command;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)setup {
    [self.view addSubview:self.delegateView];
    [self.delegateView.btnClickSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"button: %@", x);
    }];
    [self.delegateView.labelClickSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"label: %@", x);
    }];

    self.arr = [NSMutableArray array];
    for (NSInteger index = 0; index < 10000; index++) {
        NSString *value = [NSString stringWithFormat:@"我是Label %ld", index];
        [self.arr addObject:value];
    }
    self.dex = 0;
    [SFIMGCDTimer scheduledTimerWithTimeInterval:0.01
                                         repeats:NO
                                           block:^{
                                               self.labelxx.text = self.arr[self.dex];
                                               self.dex++;
                                           }];

    [self testRACSignal];

    [self testRACSubject];

    [self testRACRelaySubject];

    [self testRACCommand];

    [self testRACMulticastConnection];

    [self testRACTupleAndRACSequence];

    [self testRACScheduler];

    [self testListenEvent];
}

/*
 * RACSignal使用注意
 * 一、创建信号，首先把didSubscribe保存到信号中，还不会触发。
 
 * 二、当信号被订阅，也就是调用signal的subscribeNext:nextBlock
    * 1. subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
    * 2. subscribeNext内部会调用siganl的didSubscribe
 
 * 三、signal的didSubscribe中调用[subscriber sendNext:@1];
    * 1. sendNext底层其实就是执行subscriber的nextBlock
 **/
- (void)testRACSignal {
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id subscriber) {

        // block调用时刻：每当有订阅者订阅信号，就会调用block。

        // 2.发送信号
        [subscriber sendNext:@1];

        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];

        // 执行完信号后进行的清理工作，如果不需要就返回 nil
        return [RACDisposable disposableWithBlock:^{

            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。

            // 执行完Block后，当前信号就不在被订阅了。

            NSLog(@"信号被销毁");
        }];
    }];

    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@", x);
    }];
}

/*
 * RACSubject:底层实现和RACSignal不一样。
 * 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
 * 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 **/
- (void)testRACSubject {
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];

    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"testRACSubject 第一个订阅者%@", x);
    }];

    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"testRACSubject 第二个订阅者%@", x);
    }];

    // 3.发送信号
    [subject sendNext:@"1"];
}

/*
 * 继承自RACSubject，特点是 订阅信号 和 发送信号 没有先后顺序，而RACSubject就必须先订阅后发送
 * 1.调用sendNext发送信号，把值保存起来
 * 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
 * 3.如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号
 * 4.也就是先保存值，在订阅值
 **/
- (void)testRACRelaySubject {
    // 1.创建信号
    RACReplaySubject *subject = [RACReplaySubject subject];

    // 2.发送信号
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];

    // 3.订阅信号
    [subject subscribeNext:^(id _Nullable x) {
        NSLog(@"testRACRelaySubject1: %@", x);
    }];

    // 4.订阅信号
    [subject subscribeNext:^(id _Nullable x) {
        NSLog(@"testRACRelaySubject2: %@", x);
    }];
}

/*
 * 一、RACCommand使用注意
    * 1.signalBlock必须要返回一个信号，不能传nil.
    * 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    * 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    * 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。

 * 二、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    * 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    * 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。

 * 三、如何拿到RACCommand中返回信号发出的数据。
    * 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    * 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。

 * 四、监听当前命令是否正在执行executing

 * 五、使用场景,监听按钮点击，网络请求
 **/
- (void)testRACCommand {
    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *_Nonnull(id _Nullable input) {
        NSLog(@"testRACCommand 执行命令");

        // 创建空信号,必须返回信号
        // return [RACSignal empty];

        RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
            [subscriber sendNext:@"请求数据"];
            [subscriber sendCompleted];
            return nil;
        }];
        return signal;
    }];
    // 订阅 RACCommand 中的信号
    [self.command.executionSignals subscribeNext:^(id _Nullable x) {
        NSLog(@"testRACCommand1 command-x: %@", x);
        [x subscribeNext:^(id x) {
            NSLog(@"testRACCommand2 command-x: %@", x);
        }];
    }];

    // 监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[self.command.executing skip:1] subscribeNext:^(NSNumber *_Nullable x) {
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"testRACCommand 正在执行");
        } else {
            // 执行完成
            NSLog(@"testRACCommand 执行完成");
        }
    }];

    // 执行命令
    [self.command execute:@"eric"];
}

/*
 * RACMulticastConnection底层原理:
 * 1.创建connect，connect.sourceSignal -> RACSignal(原始信号) connect.signal -> RACSubject
 * 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
 * 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
 * 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
 * 3.2.didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
 * 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
 * 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
 **/
- (void)testRACMulticastConnection {
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@1];

        return nil;
    }];

    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];

    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接，当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者一信号");
    }];

    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者二信号");
    }];

    // 4.连接,激活信号
    [connect connect];
}

/*
 * RACTuple: 元组类，类似NSArray，在解构对象中经常使用
 * RACSequence: 集合类，使用它来快速遍历数组和字典
 **/
- (void)testRACTupleAndRACSequence {
    NSArray *numbers = @[ @1, @2, @3, @4 ];

    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    // 注意：这是异步的。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 会发现先打印了下面这行log，然后地打印上面的遍历
    NSLog(@"------");

    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{ @"name" : @"xmg",
                            @"age" : @18 };
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString * key, NSString * value) = x;

        // 相当于以下写法
        // NSString *key = x[0];
        // NSString *value = x[1];
        NSLog(@"%@ %@", key, value);
    }];

    NSLog(@"=======");
}

/*
 * RACScheduler: RAC中的队列，用GCD封装的
 * RACUnit: 表⽰stream不包含有意义的值,也就是看到这个，可以直接理解为nil
 * RACEvent: 把数据包装成信号事件(signal event)。它主要通过RACSignal的 -materialize 来使用，然并卵
 **/
- (void)testRACScheduler {
    self.countDownBtn.enabled = false;
    self.time = 10;

    // 这个就是RAC中的GCD
    self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate *_Nullable x) {
        self.time--;
        NSString *title = self.time > 0 ? [NSString stringWithFormat:@"请等待 %ld 秒后重试", self.time] : @"发送验证码";
        [self.countDownBtn setTitle:title forState:UIControlStateNormal];
        self.countDownBtn.enabled = (self.time == 0) ? YES : NO;
        if (self.time == 0) {
            // 取消这个订阅
            [self.disposable dispose];
        }
    }];

    NSLog(@"RACScheduler start");
    // 延迟 2 秒后触发
    [[RACScheduler mainThreadScheduler] afterDelay:2.0
                                          schedule:^{
                                              NSLog(@"RACScheduler delay 2");
                                          }];
}

/*
 * 事件监听
 * 1.代替代理: rac_signalForSelector
 *
 * 2.代替KVO: rac_valuesAndChangesForKeyPath
 *
 * 3.监听事件: rac_signalForControlEvents
 *
 * 4.代替通知：rac_addObserverForName
 *
 * 5.监听文本框文字改变：rac_textSignal
 *
 * 6.同步信号：rac_liftSelector:withSignalsFromArray:Signals
 *
 **/

- (void)testListenEvent {
    // 之前需要遵守代理协议、赋值delegate、实现代理方法等都不需要，只用rac_signalForSelector就可以实现
    @weakify(self);
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:)]
        subscribeNext:^(RACTuple *_Nullable x) {
            NSLog(@"x: %@", x);
        }];

    // 监听 UIButton 点击事件
    [[self.button1 rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            @strongify(self);
            [self btn1Click:x];
        }];

    // 代替KVO
    [[self.delegateView rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:self]
        subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];

    // 测试 通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"Btn1Click" object:nil]
        subscribeNext:^(NSNotification *_Nullable x) {
            NSLog(@"receive notification");
        }];

    // 测试 UITextField 内容改变事件
    //    [[self.textField rac_textSignal] subscribeNext:^(NSString *_Nullable value) {
    //        @strongify(self);
    //        self.label.text = value;
    //    }];
    // 简写
    //    RAC(self.label, text) = self.textField.rac_textSignal;
    //    [[[[self.textField rac_textSignal]
    //        map:^id _Nullable(NSString *_Nullable value) {
    //            return @(value.length);
    //        }] filter:^BOOL(id _Nullable value) {
    //        return [value integerValue] > 4;
    //    }] subscribeNext:^(id _Nullable x) {
    //        // 转换成数字，使用 map 后，信号会被转换
    //        NSLog(@"x: %@", x);
    //    }];
    [[[[[self.textField rac_textSignal] filter:^BOOL(NSString *_Nullable value) {
        if (value.length) {
            return YES;
        } else {
            return NO;
        }
    }] map:^id _Nullable(NSString *_Nullable value) {
        NSLog(@"map1: %@", value);
        return @(value.length);
    }] map:^id _Nullable(id _Nullable value) {
        NSLog(@"map2: %@", value);
        return value;
    }] subscribeNext:^(id _Nullable x) {
        NSLog(@"x: %@", x);
    }];

    // 按钮倒计时
    [[self.countDownBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self);
        self.countDownBtn.enabled = false;
        self.time = 10;

        // 这个就是RAC中的GCD
        self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate *_Nullable x) {
            self.time--;
            NSString *title = self.time > 0 ? [NSString stringWithFormat:@"请等待 %ld 秒后重试", self.time] : @"发送验证码";
            [self.countDownBtn setTitle:title forState:UIControlStateNormal];
            self.countDownBtn.enabled = (self.time == 0) ? YES : NO;
            if (self.time == 0) {
                // 取消这个订阅
                [self.disposable dispose];
            }
        }];
    }];
    
    // 同步信号：rac_liftSelector:withSignalsFromArray:Signals
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}

// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1 {
    NSLog(@"更新UI%@ %@",data,data1);
}

- (void)btn1Click:(UIButton *)sender {
    NSLog(@" ---------- ");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Btn1Click" object:nil];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RAC" message:@"RAC TEST" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *_Nullable x) {
        NSLog(@"%@", x);
    }];
    [alertView show];
}

- (DelegateView *)delegateView {
    if (!_delegateView) {
        _delegateView = [[DelegateView alloc] init];
        _delegateView.frame = CGRectMake(30, 200, 300, 100);
    }
    return _delegateView;
}

@end
