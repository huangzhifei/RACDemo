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
#import "UIView+WebCache.h"

@interface ViewController ()

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

    //    NSMutableArray *temp = [NSMutableArray arrayWithArray:nil];

    //    NSLog(@"temp: %@", temp);

    NSString *str1 = @"=xxxxx";
    str1 = [str1 stringByReplacingOccurrencesOfString:@"(null)=" withString:@""];
    NSLog(@"str1: %@", str1);

    self.labelxx = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 150, 40)];
    self.labelxx.backgroundColor = [UIColor orangeColor];
    self.labelxx.textColor = [UIColor whiteColor];
    [self.view addSubview:self.labelxx];

    [self setup];
    [self addListenEvent];
}

- (RACSignal *)createSignal {
    return [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"create signal");
        [subscriber sendNext:@"xxxx"];
        return nil;
    }];
}

- (void)setup {
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];

    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@", x);
    }];

    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@", x);
    }];

    // 3.发送信号
    [subject sendNext:@"1"];

    RACSignal *signal = [self createSignal];
    NSLog(@"call create signal");

    [self.view addSubview:self.delegateView];
    [self.delegateView.btnClickSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"button: %@", x);
    }];

    @weakify(self);
    [[self.delegateView rac_signalForSelector:@selector(buttonClick:)] subscribeNext:^(RACTuple *_Nullable x) {
        NSLog(@"button2: %@", x);
        UIButton *btn = (UIButton *) x[0];
        @strongify(self);
        self.delegateView.backgroundColor = [UIColor orangeColor];
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

    NSArray *numbers = @[
        @"1",
        @"2",
        @"3",
        @"4",
        @"5",
        @"6",
        @"7",
        @"8",
        @"9",
        @"10",
        @"11",
        @"12",
        @"13",
        @"14",
        @"15",
        @"16",
        @"17",
        @"18",
        @"19",
    ];

    [numbers.rac_sequence.signal subscribeNext:^(id _Nullable x) {

        NSLog(@"x: %@", x);
    }];

    NSLog(@"start call create signal");
    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"did subscribe");
    }];

    [self testRACSignal];

    [self testRACSubject];

    [self testRACRelaySubject];

    [self testRACCommand];

    [self testRACMulticastConnection];

    [[self.delegateView rac_valuesAndChangesForKeyPath:@"backgroundColor"
                                               options:NSKeyValueObservingOptionNew
                                              observer:nil]
        subscribeNext:^(id x) {
            NSLog(@"self.delegateView: %@", x);
        }];

    [self testLiftSignals];

    [self testAdvanced];
}

- (void)testLiftSignals {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [subscriber sendNext:@"A"];
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [subscriber sendNext:@"AA"];
            });
        });
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"B"];
        [subscriber sendNext:@"Another B"];
        [subscriber sendCompleted];
        return nil;
    }];

    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA, signalB, nil];
}

- (void)doA:(NSString *)A withB:(NSString *)B {
    NSLog(@"A:%@ and B:%@", A, B);
}

- (void)testAdvanced {
    [self testConcat];
    [self testBind];
    [self testThen];
    [self testMerge];
    [self testCombineLatest];
    [self testReduce];
    [self testDelay];
    [self testTake];
    [self testSkip];
    [self testTakeUntil];
    [self testTakeLast];
    [self testDistinctUntilChanged];
}

- (void)testBind {
    [[self.textField.rac_textSignal bind:^RACSignalBindBlock _Nonnull {
        return ^RACSignal *(id value, BOOL *stop) {
            // 做好处理，通过信号返回出去.
            return [RACSignal return:[NSString stringWithFormat:@"hello: %@", value]];
        };
    }] subscribeNext:^(id _Nullable x) {
        NSLog(@"bind content: %@", x); // hello: xxxxx
    }];
}

- (void)testConcat {
    // 创建两个信号 signalA 和 signalB
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"signalA sendNext");
        [subscriber sendNext:@"A"];
        [subscriber sendNext:@"AA"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"signalB sendNext");
        [subscriber sendNext:@"B"];
        [subscriber sendCompleted];
        return nil;
    }];

    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活
    [[signalA concat:signalB] subscribeNext:^(id _Nullable x) {
        NSLog(@"contact :%@", x);
    }];
}

- (void)testThen {
    [[[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"test1"];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *_Nonnull {
        return [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
            [subscriber sendNext:@"test2"];
            return nil;
        }];
    }] subscribeNext:^(id _Nullable x) {
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"then content: %@", x);
    }];
}

- (void)testMerge {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"merge signal 1"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"merge signal 2"];
        [subscriber sendCompleted];
        return nil;
    }];

    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    [mergeSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"merge content: %@", x);
    }];
}

- (void)testCombineLatest {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"combineLatest signal 1"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"combineLatest signal 2"];
        [subscriber sendCompleted];
        return nil;
    }];

    // 把两个信号组合成一个信号,跟zip一样，没什么区别
    RACSignal *combineSignal = [signalA combineLatestWith:signalB];

    [combineSignal subscribeNext:^(id x) {
        NSLog(@"combineLatest content: %@", x); // (combineLatest signal 1, combineLatest signal 2)
    }];
}

- (void)testReduce {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"reduce signalA"];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"reduce signalB"];
        return nil;
    }];

    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"reduce signalC"];
        return nil;
    }];

    // reduceblock的返回值：聚合信号之后的内容。
    RACSignal *reduceSignal = [RACSignal combineLatest:@[ signalA, signalB, signalC ]
                                                reduce:^id(NSNumber *num1, NSNumber *num2, NSNumber *num3) {
                                                    return [NSString stringWithFormat:@"%@ %@ %@", num1, num2, num3];
                                                }];

    [reduceSignal subscribeNext:^(id x) {
        NSLog(@"reduce content: %@", x); // (reduce signalA, reduce signalB, reduce signalC)
    }];
}

- (void)testDelay {
    [[[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSLog(@"delay signal start send");
        [subscriber sendNext:@"delay signal"];
        return nil;
    }] delay:2.0] subscribeNext:^(id _Nullable x) {
        NSLog(@"delay 2 second receive signal");
    }];

    NSLog(@"eric 1111");
    dispatch_main_async_safe(^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"eric 2222");
        });
        NSLog(@"eric 33333");
    });
}

- (void)testTake {
    // 取前 N 个
    [[[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"signal 1"];
        [subscriber sendNext:@"signal 2"];
        [subscriber sendNext:@"signal 3"];
        [subscriber sendCompleted];
        return nil;
    }] take:2] subscribeNext:^(id _Nullable x) {
        NSLog(@"take content: %@", x); // only 1 and 2 will be print
    }];
}

- (void)testSkip {
    // 跳过前 N 个
    [[[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"signal 1"];
        [subscriber sendNext:@"signal 2"];
        [subscriber sendNext:@"signal 3"];
        [subscriber sendCompleted];
        return nil;
    }] skip:2] subscribeNext:^(id _Nullable x) {
        NSLog(@"skip : %@", x); // only 3 will be print
    }];
}

- (void)testTakeUntil {
    // RAC 这个消息是2秒后完成, 所以 signal1 signal2 这两个消息是可以发送到 而3秒后的 signal3 signal4 就不会发送.
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"signal1"];
        [subscriber sendNext:@"signal2"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"signal3"];
            [subscriber sendNext:@"signal4"];
            [subscriber sendCompleted];
        });
        [subscriber sendCompleted];
        return nil;
    }] takeUntil:[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [subscriber sendNext:@"RAC"];
               [subscriber sendCompleted];
           });
           return nil;
       }]];

    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"takeUntil: %@", x); // only signal1 & signal2 will be print
    }];
}

- (void)testTakeLast {
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"signal1"];
        [subscriber sendNext:@"signal2"];
        [subscriber sendNext:@"signal3"];
        [subscriber sendNext:@"signal4"];
        [subscriber sendCompleted];
        // 上面调用 sendCompleted 之后，会直接进入下面的订阅回调，打印最后 3 条信号，然后在打印下面的 "send completed"
        NSLog(@"send completed");
        return nil;

    }] takeLast:3];

    [signal subscribeNext:^(id x) {
        NSLog(@"testTakeLast : %@",x);
    }];
}

- (void)testDistinctUntilChanged {
    RACSubject *signal = [RACSubject subject];
    [[signal distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"distinctUntilChanged : %@", x); // will only print "eric", "eric hzf", "eric"
    }];
    
    // 发送一次信号，内容为 eric
    [signal sendNext:@"eric"];
    
    // 发送二次信号，内容依然为 eric，但是使用 distinctUntilChanged 后不会在接收与上一次重复的内容
    [signal sendNext:@"eric"];
    
    // 发送三次信号，内容为 eric hzf
    [signal sendNext:@"eric hzf"];
    
    // 发送四次信号，内容为 eric hzf
    [signal sendNext:@"eric"];
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

- (void)addListenEvent {
    // 测试 UIButton 点击事件
    @weakify(self);
    [[self.button1 rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self);
        [self btn1Click:x];
    }];

    // 测试 通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"Btn1Click" object:nil] subscribeNext:^(NSNotification *_Nullable x) {
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
