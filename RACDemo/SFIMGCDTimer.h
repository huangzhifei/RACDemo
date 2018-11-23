//
//  SFIMGCDTimer.h
//  NIM
//
//  Created by huangzhifei on 2018/11/5.
//  Copyright © 2018 YzChina. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SFIMGCDTimer : NSObject

// block 回调在指定线程
- (instancetype)initScheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                           repeats:(BOOL)repeats
                                             queue:(dispatch_queue_t)queue
                                             block:(dispatch_block_t)block;

// block 回调在指定线程
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                       repeats:(BOOL)repeats
                                         queue:(dispatch_queue_t)queue
                                         block:(dispatch_block_t)block;

// block 回调在主线程
- (instancetype)initScheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                           repeats:(BOOL)repeats
                                             block:(dispatch_block_t)block;

// block 回调在主线程
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                       repeats:(BOOL)repeats
                                         block:(dispatch_block_t)block;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
