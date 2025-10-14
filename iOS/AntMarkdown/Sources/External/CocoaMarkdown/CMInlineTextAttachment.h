// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CMInlineTextAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入行内文本元素。
 * 支持自定义文本内容和尺寸，主要用于渲染需要特殊样式或布局的行内文本元素。
 */
// 目前来说, 只有 inlineMath 这样的一个字类, 也就是行内 Code 展示.

@interface CMInlineTextAttachment : NSTextAttachment
@property (nonatomic, nullable) NSString *text;

- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithText:(nullable NSString *)text size:(CGSize)size;

- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(CMInlineTextAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
