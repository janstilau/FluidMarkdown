// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "CocoaMarkdown.h"
#import "AMViewAttachment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * AMIconAttachment 是 NSTextAttachment 的子类，用于在富文本中嵌入图标元素。
 * 支持自定义图标路径、文本内容、字体、颜色、尺寸、对齐方式和边距等属性。
 * 主要用于渲染带有图标的文本元素，提供丰富的视觉效果和布局控制。
 */
@interface AMIconAttachment : NSTextAttachment

@property (nonatomic, nullable) NSString *path;
@property (nonatomic, nullable) NSString *text;
@property (nonatomic) UIFont *baseFont;
@property (nonatomic) UIColor *textColor;
@property (nonatomic, assign) NSInteger textSize;
@property (nonatomic, assign)NSTextAlignment textAlignment;
@property (nonatomic) CGSize attachmentSize;
@property (nonatomic) CGFloat marginLeft;
@property (nonatomic) CGFloat marginRight;
@property (nonatomic) BOOL boldText;

- (instancetype)init;
- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(AMIconAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
