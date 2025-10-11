// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 可绘制对象协议
 * 定义可在指定矩形区域内绘制的对象接口
 */
@protocol AMDrawable <NSObject>

/**
 * 在指定矩形区域内绘制内容
 * @param rect 绘制区域
 * @param edges 需要裁剪的边缘
 */
- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges;

@optional
/**
 * 是否为内联绘制（可选实现）
 * @return YES表示内联绘制，NO表示块级绘制
 */
- (BOOL)isInline;

@end

/**
 * 下划线可绘制对象协议
 * 定义下划线样式绘制的接口
 */
@protocol AMUnderlineDrawable <NSObject>

/**
 * 绘制下划线
 * @param rect 绘制区域
 * @param type 下划线样式类型
 * @param offset 基线偏移量
 */
- (void)drawInRect:(CGRect)rect underlineStyle:(NSUnderlineStyle)type baselineOffset:(CGFloat)offset;

@end

/**
 * value is any AMDrawable
 */
UIKIT_EXTERN NSAttributedStringKey const AMBackgroundDrawableAttributeName;
UIKIT_EXTERN NSAttributedStringKey const AMUnderlineDrawableAttributeName;

@interface UIImage (AMDrawable) <AMDrawable>

@end

@interface UIColor (AMDrawable) <AMDrawable>

@end

@interface CALayer (AMDrawable) <AMDrawable>

@end

NS_ASSUME_NONNULL_END
