// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AMViewAttachment.h>

@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

/**
 * 代码视图协议
 * 定义代码块显示组件需要实现的基本接口
 */
@protocol AMCodeView <NSObject>

/**
 * 设置纯文本代码内容
 * @param codeText 代码文本字符串
 */
- (void)setPlainCodeText:(NSString *)codeText;

/**
 * 设置代码语言类型
 * @param lang 编程语言标识（如 "swift", "objc", "javascript" 等）
 */
- (void)setLanguage:(nullable NSString *)lang;

/**
 * 设置带属性的代码文本（支持语法高亮）
 * @param codeText 带格式的属性字符串
 */
- (void)setAttributedCodeText:(NSAttributedString *)codeText;

@optional
/**
 * 代码复制完成回调（可选实现）
 * @param code 被复制的代码内容
 */
- (void)didCopyCode:(NSString *)code;

/**
 * 使用样式初始化代码视图（可选实现）
 * @param styles 文本样式配置
 * @return 初始化的代码视图实例
 */
- (instancetype)initWithStyles:(AMTextStyles *)styles;

/**
 * 计算代码视图所需尺寸（可选实现）
 * @param size 限制尺寸
 * @param code 代码内容
 * @param lang 编程语言
 * @param styles 样式配置
 * @return 计算得出的尺寸
 */
+ (CGSize)sizeThatFits:(CGSize)size
                  code:(NSString *)code
              language:(nullable NSString *)lang
                styles:(AMTextStyles *)styles;

@end

@interface AMCodeViewAttachment : AMViewAttachment
@property (nonatomic, readonly, nullable) UIView<AMCodeView> *view;
@property (nonatomic) BOOL partialUpdate;
@property (nonatomic, nullable) NSString *language;
@property (nonatomic) NSString *code;

+ (Class<AMCodeView>)codeViewClass;    // Default is AMMarkdownCodeView

+ (instancetype)attachmentWithCode:(NSString *)code
                          language:(nullable NSString *)hint
                            styles:(nullable AMTextStyles *)styles;

@end

NS_ASSUME_NONNULL_END
