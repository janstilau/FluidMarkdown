// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * AMIconLinkAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入带图标的链接。
 * 支持自定义文本内容、背景色、文字颜色和字体样式。
 * 主要用于渲染具有特殊样式的链接，提供比普通链接更丰富的视觉效果。
 */
@interface AMIconLinkAttachment : NSTextAttachment
@property (nonatomic, nullable) NSAttributedString *text;

- (instancetype)initWithText:(nullable NSAttributedString *)text url:(NSString*)url bgColor:(UIColor*)bgColor textColor:(UIColor*)textColor subFont:(UIFont*)subFont baseFont:(UIFont*)baseFont;
- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(AMIconLinkAttachment *)attach;
@end

NS_ASSUME_NONNULL_END
