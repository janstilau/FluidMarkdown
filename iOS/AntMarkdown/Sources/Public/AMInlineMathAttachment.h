// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CMInlineTextAttachment.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMMathStyle : NSObject
@property (nonatomic) UIFont *font;
@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIControlContentVerticalAlignment verticalAlignment;
@property (nonatomic) UIControlContentHorizontalAlignment horizontalAlignment;
@property (nonatomic) CGFloat height;   // Default 0. Auto
@property (nonatomic,copy) NSParagraphStyle* paragraphStyle;

@property (nonatomic,copy) NSParagraphStyle* paragraphStyleBreakLine;

+ (instancetype)defaultStyle;

+ (instancetype)defaultBlockStyle;

@end

/**
 * AMInlineMathAttachment 是 CMInlineTextAttachment 的子类，用于在富文本中嵌入行内数学公式。
 * 支持 LaTeX 数学表达式的渲染，能够在文本行内显示数学公式和符号。
 * 主要用于 Markdown 行内数学语法的渲染，适用于在段落中插入数学表达式。
 * 
 * 对应的 Markdown 语法示例：
 * ```
 * 这是一个行内数学公式 $E = mc^2$ 的示例。
 * 
 * 计算圆的面积：$A = \pi r^2$，其中 $r$ 是半径。
 * 
 * 二次方程的解：$x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}$
 * ```
 */
@interface AMInlineMathAttachment : CMInlineTextAttachment

@property (nonatomic, nullable, strong) NSError *error;

- (instancetype)initWithText:(nullable NSString *)text
                       style:(AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

- (NSAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
