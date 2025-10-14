// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CocoaMarkdown.h>
#import <AntMarkdown/AMViewAttachment.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMSimpleImageCache : NSObject

+ (instancetype)sharedCache;

- (nullable NSData *)imageDataForURL:(NSURL *)url;
- (void)setImageData:(NSData *)data forURL:(NSURL *)url;

@end

/**
 * AMImageTextAttachment 是 CMImageTextAttachment 的子类，用于在富文本中嵌入图片。
 * 支持本地图片和网络图片的加载显示，提供图片缓存和异步加载功能。
 *
 * 主要用于 Markdown 图片语法的渲染，支持图片的自适应尺寸和样式设置。
 *
 * 对应的 Markdown 语法示例：
 * ```
 * ![图片描述](https://example.com/image.jpg)
 *
 * ![本地图片](./assets/logo.png)
 *
 * ![带标题的图片](https://example.com/photo.jpg "这是图片标题")
 *
 * ![指定尺寸的图片](image.png =300x200)
 * ```
 */
@interface AMImageTextAttachment : CMImageTextAttachment <AMAttachmentUpdatable>
@property (nonatomic) BOOL enableImageCache;

- (void)setNeedsLayout;
- (void)setNeedsDisplay;

- (BOOL)isEqualToAttachment:(AMImageTextAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
