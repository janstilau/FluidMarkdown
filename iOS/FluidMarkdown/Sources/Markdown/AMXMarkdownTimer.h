// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
 * AMXMarkdownTimer 定时器代理协议
 * 用于处理定时器触发事件
 */
@protocol AMXMarkdownTimerDelegate <NSObject>

@required
/**
 * 定时器触发回调
 * 当定时器达到设定的时间间隔时调用此方法
 */
- (void)onTimer;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AMXMarkdownTimer : NSObject
- (instancetype)initWithConfig:(NSInteger)intervalTime queue:(dispatch_queue_t)queue;

- (void)startTimer;

- (void)stopTimer;

- (BOOL)isRuning;

@property(nonatomic,weak)id<AMXMarkdownTimerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
