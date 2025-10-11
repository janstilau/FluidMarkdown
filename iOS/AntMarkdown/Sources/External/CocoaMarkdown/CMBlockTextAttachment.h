// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * CMBlockTextAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入块级文本元素。
 * 这是一个基础类，通常不直接使用，而是通过其子类来实现具体的块级元素渲染。
 * 支持文本内容设置和属性字符串生成，为块级元素提供基础功能。
 */
// 这个没有真正的使用到, 直接使用的是它的子类. 
@interface CMBlockTextAttachment : NSTextAttachment
@property (nonatomic, nullable) NSString *text;

- (void)setNeedsUpdate;
- (NSAttributedString *)attributedString;

- (BOOL)isEqualToAttachment:(CMBlockTextAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
