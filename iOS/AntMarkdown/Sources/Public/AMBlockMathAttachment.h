// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CMBlockTextAttachment.h>
#import <AntMarkdown/AMInlineMathAttachment.h>

NS_ASSUME_NONNULL_BEGIN
@class MTMathListDisplay;
@class MTMathList;

/**
 * AMBlockMathAttachment 是 CMBlockTextAttachment 的子类，用于在富文本中嵌入块级数学公式。
 * 支持 LaTeX 数学表达式的渲染，能够显示复杂的数学公式和符号。
 * 主要用于 Markdown 块级数学语法的渲染和显示。
 * 
 * 对应的 Markdown 语法示例：
 * ```
 * $$
 * \int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
 * $$
 * 
 * $$
 * \sum_{i=1}^{n} x_i = x_1 + x_2 + \cdots + x_n
 * $$
 * ```
 */
@interface AMBlockMathAttachment : CMBlockTextAttachment

@property (nonatomic, nullable, strong) NSError *error;

- (instancetype)initWithText:(nullable NSString *)text
                       style:(nullable AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDisplayList:(nullable MTMathListDisplay *)displayList style:(nullable AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

+ (NSArray<AMBlockMathAttachment *> *)constructorBlockMathAttachmentWithText:(NSString *)text style:(AMMathStyle *)style;

@end

NS_ASSUME_NONNULL_END
