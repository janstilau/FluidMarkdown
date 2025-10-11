// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AMXMarkdownStyle.h"

@class AMTextStyles;
@protocol CMAttributedStringRendererDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * AMX 图片附件协议
 * 用于处理 Markdown 中图片的缓存管理和加载回调
 */
@protocol AMXImageAttachmentProtocol <NSObject>

/**
 * 从缓存中获取图片（如果存在）
 * @param url 图片的URL地址
 * @return 如果缓存中存在则返回UIImage对象，否则返回nil
 */
- (nullable UIImage *)getImageFromCacheIfExist:(NSString *)url;

/**
 * 图片加载完成回调
 * @param image 加载完成的图片对象
 * @param url 图片的URL地址
 */
- (void)onImageLoadFinish:(UIImage *)image url:(NSString *)url;

@end

@interface AMXMarkdownHelper : NSObject


+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles;
+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles
                                              delegate:(id<CMAttributedStringRendererDelegate>)delegate
                                              textView:(UITextView*)textView;
+ (void)setImageAttachListener:(NSMutableAttributedString *)attrText
                      delegate:(id<AMXImageAttachmentProtocol>)delegate;
+ (void)transformParagraph:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformTitle:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformHRule:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformTable:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformOrderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformUnorderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformFootNote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformLink:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config textView:(UITextView*)textView;
+ (void)transformInlineCode:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformCodeBlock:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformUnderLine:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformBlockQuote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
@end

NS_ASSUME_NONNULL_END
