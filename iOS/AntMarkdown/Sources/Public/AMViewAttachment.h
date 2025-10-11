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


@interface AMViewAttachment : NSTextAttachment <AMViewAttachment>

@property (nonatomic, readonly, nullable) __kindof UIView<AMAttachedView> *view;
@property (nonatomic) BOOL fullWidth;   // Default YES

- (void)setNeedsUpdate DEPRECATED_MSG_ATTRIBUTE("use setNeedsLayout instead");
- (void)setNeedsLayout;
- (void)setNeedsDisplay;

- (NSAttributedString *)attributedString;

- (CGSize)sizeThatFits:(CGSize)size;

- (BOOL)isEqualToAttachment:(AMViewAttachment *)attach;

- (void)updateAttachmentFromAttachment:(AMViewAttachment *)attach NS_REQUIRES_SUPER;

@end


typedef void(^ButtonAction)(void);

@interface AMButtonViewAttachment : AMViewAttachment
@property (nonatomic, strong) UIButton *button;

- (instancetype)initWithTitle:(NSString *)title action:(nullable ButtonAction)action NS_DESIGNATED_INITIALIZER;

@end

@interface UIView (AMAttachedView) <AMAttachedView>

@end

NS_ASSUME_NONNULL_END
