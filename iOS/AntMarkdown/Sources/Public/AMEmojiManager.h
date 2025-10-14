// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 这个机制, 各个不同的渲染器支持的不太一致.
// 不过简单来说, 是有这个机制. 
@interface AMEmojiManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)emojiWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
