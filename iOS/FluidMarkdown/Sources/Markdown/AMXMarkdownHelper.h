// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AMXMarkdownStyle.h"

@class AMTextStyles;
@protocol CMAttributedStringRendererDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 * ========================================
 * AMX 图片附件协议 (Image Attachment Protocol)
 * ========================================
 * 
 * 用于处理 Markdown 中图片的缓存管理和异步加载回调
 * 
 * 应用场景:
 * • 网络图片的缓存管理
 * • 图片异步加载完成后的UI更新
 * • 图片加载失败的降级处理
 * 
 * 实现要点:
 * • 缓存策略: 内存缓存 + 磁盘缓存
 * • 异步加载: 避免阻塞主线程
 * • 回调更新: 图片加载完成后刷新显示
 */

@protocol AMXImageAttachmentProtocol <NSObject>

/**
 * 从缓存中获取图片（如果存在）
 * 
 * 该方法用于快速获取已缓存的图片，避免重复网络请求
 * 
 * @param url 图片的URL地址
 * @return 如果缓存中存在则返回UIImage对象，否则返回nil
 * 
 * @note 实现建议:
 *       1. 优先检查内存缓存
 *       2. 其次检查磁盘缓存
 *       3. 返回nil时触发异步下载
 */
- (nullable UIImage *)getImageFromCacheIfExist:(NSString *)url;

/**
 * 图片加载完成回调
 * 
 * 当图片异步加载完成后，通过此回调通知UI更新
 * 
 * @param image 加载完成的图片对象
 * @param url 图片的URL地址
 * 
 * @note 回调时机:
 *       1. 网络下载完成
 *       2. 图片解码完成
 *       3. 缓存存储完成
 */
- (void)onImageLoadFinish:(UIImage *)image url:(NSString *)url;

@end

/**
 * ========================================
 * AMXMarkdownHelper - Markdown 渲染助手类
 * ========================================
 * 
 * 核心功能:
 * • Markdown 文本转换为 NSAttributedString
 * • 自定义样式配置和应用
 * • 图片附件管理和异步加载
 * • 各种 Markdown 元素的样式变换
 * 
 * 架构设计:
 * ┌─────────────────────────────────────────────────────────────┐
 * │                    AMXMarkdownHelper                        │
 * │                                                             │
 * │  ┌─────────────────┐    ┌─────────────────┐                │
 * │  │   文本转换模块   │    │   样式配置模块   │                │
 * │  │                 │    │                 │                │
 * │  │ • mdToAttrString │    │ • transformXXX  │                │
 * │  │ • 解析Markdown   │    │ • 应用自定义样式 │                │
 * │  └─────────────────┘    └─────────────────┘                │
 * │           │                       │                        │
 * │           └───────┬───────────────┘                        │
 * │                   │                                        │
 * │  ┌─────────────────▼─────────────────┐                     │
 * │  │         图片附件管理模块           │                     │
 * │  │                                   │                     │
 * │  │ • setImageAttachListener          │                     │
 * │  │ • 异步图片加载                     │                     │
 * │  │ • 缓存管理                         │                     │
 * │  └───────────────────────────────────┘                     │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * 使用流程:
 * 1. 调用 mdToAttrString 转换 Markdown 文本
 * 2. 使用 transformXXX 方法应用自定义样式
 * 3. 调用 setImageAttachListener 设置图片加载回调
 * 4. 将结果设置到 UITextView 或 UILabel 显示
 */
@interface AMXMarkdownHelper : NSObject

// MARK: - 核心转换方法

/**
 * 将 Markdown 文本转换为富文本字符串（基础版本）
 * 
 * 这是最基础的转换方法，使用默认或指定的样式配置
 * 
 * @param text Markdown 格式的文本字符串
 * @param defaultStyles 默认样式配置，传nil使用系统默认样式
 * @return 转换后的可变富文本字符串，转换失败返回nil
 * 
 * @note 适用场景:
 *       • 简单的 Markdown 文本显示
 *       • 不需要自定义渲染逻辑
 *       • 静态内容展示
 */
+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles;

/**
 * 将 Markdown 文本转换为富文本字符串（完整版本）
 * 
 * 提供完整的自定义能力，支持自定义渲染代理和关联文本视图
 * 
 * @param text Markdown 格式的文本字符串
 * @param defaultStyles 默认样式配置，传nil使用系统默认样式
 * @param delegate 自定义渲染代理，用于处理特殊元素的渲染逻辑
 * @param textView 关联的文本视图，用于处理交互和布局
 * @return 转换后的可变富文本字符串，转换失败返回nil
 * 
 * @note 适用场景:
 *       • 需要自定义渲染逻辑
 *       • 包含交互元素（链接、按钮等）
 *       • 复杂的布局需求
 */
+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles
                                              delegate:(id<CMAttributedStringRendererDelegate>)delegate
                                              textView:(UITextView*)textView;

// MARK: - 图片附件管理

/**
 * 为富文本字符串设置图片加载监听器
 * 
 * 遍历富文本中的所有图片附件，为每个附件设置异步加载回调
 * 
 * @param attrText 包含图片附件的富文本字符串
 * @param delegate 图片加载代理，处理缓存获取和加载完成回调
 * 
 * @note 工作流程:
 *       1. 遍历富文本中的 NSAttachmentAttributeName 属性
 *       2. 识别 AMXMarkdownImageTextAttachment 类型的附件
 *       3. 为每个图片附件设置代理和触发刷新
 */
+ (void)setImageAttachListener:(NSMutableAttributedString *)attrText
                      delegate:(id<AMXImageAttachmentProtocol>)delegate;

// MARK: - 样式变换方法
// 以下方法用于将自定义样式配置应用到默认样式对象中

/**
 * 应用段落样式配置
 * 
 * 配置普通段落文本的显示样式，包括字体、颜色、行高、段落间距等
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformParagraph:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用标题样式配置
 * 
 * 配置 H1-H6 标题的显示样式，包括字体大小、颜色、间距等
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformTitle:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用水平分割线样式配置
 * 
 * 配置 Markdown 水平分割线（---）的显示样式
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformHRule:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用表格样式配置
 * 
 * 配置 Markdown 表格的显示样式，包括边框、间距、标题行样式等
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformTable:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用有序列表样式配置
 * 
 * 配置有序列表（1. 2. 3.）的显示样式，包括缩进、符号、间距等
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformOrderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用无序列表样式配置
 * 
 * 配置无序列表（• - *）的显示样式，包括缩进、符号、间距等
 * 
 * @param defalutStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformUnorderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用脚注样式配置
 * 
 * 配置 Markdown 脚注的显示样式，包括标记大小、背景色等
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformFootNote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用链接样式配置
 * 
 * 配置 Markdown 链接的显示样式和交互行为
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 * @param textView 关联的文本视图，用于处理链接点击事件
 */
+ (void)transformLink:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config textView:(UITextView*)textView;

/**
 * 应用行内代码样式配置
 * 
 * 配置行内代码（`code`）的显示样式，包括背景色、字体等
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformInlineCode:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用代码块样式配置
 * 
 * 配置代码块（```code```）的显示样式，包括背景、边框、语法高亮等
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformCodeBlock:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用下划线样式配置
 * 
 * 配置下划线文本的显示样式
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformUnderLine:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;

/**
 * 应用引用块样式配置
 * 
 * 配置引用块（> 引用内容）的显示样式，包括左边框、缩进、背景等
 * 
 * @param defaultStyle 默认样式对象，将被修改
 * @param config 自定义样式配置
 */
+ (void)transformBlockQuote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
@end

NS_ASSUME_NONNULL_END
