// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@protocol AMViewAttachment;

NS_ASSUME_NONNULL_BEGIN

/**
 * 附加视图协议
 * 定义可以附加到文本附件的视图需要实现的接口
 */
@protocol AMAttachedView <NSObject>

@optional
/**
 * 关联的视图附件对象（弱引用）
 */
@property (nonatomic, weak) id<AMViewAttachment> attachment;

@end

/**
 * 附件可更新协议
 * 定义附件对象的更新接口
 */
@protocol AMAttachmentUpdatable <NSObject>

@optional
/**
 * 从另一个文本附件更新当前附件
 * @param attach 源文本附件对象
 */
//
- (void)updateAttachmentFromAttachment:(NSTextAttachment *)attach;

@end

/**
 * 视图附件协议
 * 继承自AMAttachmentUpdatable，定义视图附件的核心接口
 */
@protocol AMViewAttachment <AMAttachmentUpdatable>

/**
 * 获取附件视图（如果未加载会创建）
 * @return 实现了AMAttachedView协议的视图对象
 */
- (nullable __kindof UIView<AMAttachedView> *)view;

/**
 * 获取附件视图（仅在已加载时返回）
 * @return 已加载的视图对象，未加载时返回nil
 */
- (nullable __kindof UIView<AMAttachedView> *)viewIfLoaded;

@optional
/**
 * 获取附件的属性字符串表示（可选实现）
 * @return 属性字符串对象
 */
- (NSAttributedString *)attributedString;

/**
 * 标记需要重新布局（可选实现）
 */
- (void)setNeedsLayout;

/**
 * 标记需要重新绘制（可选实现）
 */
- (void)setNeedsDisplay;

/**
 * 强制标记需要重新布局（可选实现）
 */
- (void)setForceNeedsLayout;

@end

/**
 \c object is \c NSAttributedString itself, \c userInfo is:
 \code
 @{
 NSAttachmentAttributeName: attachment instance,
 }
 \endcode
 */
UIKIT_EXTERN NSString *const AMTextAttachmentSizeDidUpdateNotification;

/**
 * AMViewAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入 UIView 视图。
 * 支持全宽显示、布局更新、尺寸计算等功能，为在文本中嵌入复杂视图提供基础支持。
 * 这是一个基础类，通常通过其子类来实现具体的视图嵌入功能。
 */
// 对于 AMViewAttachment 的实现, 都在这个 AMViewAttachment 中, 所以, 所有的 View 相关的 Attachment, 都是这个类的子类
@interface AMViewAttachment : NSTextAttachment <AMViewAttachment>

@property (nonatomic, readonly, nullable) __kindof UIView<AMAttachedView> *view;
// 这个名非常失败.
@property (nonatomic) BOOL fullWidth;   // Default YES

- (void)setNeedsLayout;
- (void)setNeedsDisplay;

- (NSAttributedString *)attributedString;

- (CGSize)sizeThatFits:(CGSize)size;

- (BOOL)isEqualToAttachment:(AMViewAttachment *)attach;

- (void)updateAttachmentFromAttachment:(AMViewAttachment *)attach NS_REQUIRES_SUPER;

@end


typedef void(^ButtonAction)(void);

/**
 * AMButtonViewAttachment 是 AMViewAttachment 的子类，用于在富文本中嵌入按钮视图。
 * 支持自定义按钮样式和交互行为，主要用于创建可交互的按钮元素。
 * 提供点击回调功能，可以实现各种自定义交互逻辑。
 * 
 * 使用示例：
 * ```objective-c
 * // 创建带回调的按钮附件
 * AMButtonViewAttachment *buttonAttachment = [[AMButtonViewAttachment alloc] 
 *     initWithTitle:@"点击我" 
 *     action:^{
 *         NSLog(@"按钮被点击了！");
 *         // 执行自定义逻辑
 *     }];
 * 
 * // 创建简单按钮
 * AMButtonViewAttachment *simpleButton = [[AMButtonViewAttachment alloc] 
 *     initWithTitle:@"确认" 
 *     action:nil];
 * ```
 * 
 * 注意：此类不对应标准 Markdown 语法，主要用于程序化创建交互式按钮元素。
 */
// 没有地方用到这个, 这可以认为是自定义的一个场所. 
@interface AMButtonViewAttachment : AMViewAttachment

@property (nonatomic, strong) UIButton *button;

- (instancetype)initWithTitle:(NSString *)title action:(nullable ButtonAction)action NS_DESIGNATED_INITIALIZER;

@end

@interface UIView (AMAttachedView) <AMAttachedView>

@end

NS_ASSUME_NONNULL_END
