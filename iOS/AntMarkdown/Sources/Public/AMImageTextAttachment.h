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
 * 支持图片缓存、布局更新和显示更新功能。
 * 主要用于 Markdown 图片语法的渲染，如 ![alt](url)。
 */
@interface AMImageTextAttachment : CMImageTextAttachment <AMAttachmentUpdatable>
@property (nonatomic) BOOL enableImageCache;

- (void)setNeedsLayout;
- (void)setNeedsDisplay;

- (BOOL)isEqualToAttachment:(AMImageTextAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
