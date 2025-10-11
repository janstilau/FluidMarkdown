//
//  CMImageTextAttachment.h
//  CocoaMarkdown
//
//  Created by Jean-Luc on 10/05/2019.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//
@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import Cocoa;
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * CMImageTextAttachment 是 NSTextAttachment 的子类，专门用于在富文本中嵌入图片。
 * 它支持从 URL 加载图片，并可以设置图片的尺寸和替代文本。
 * 主要用于 Markdown 图片语法的渲染，如 ![alt text](image_url)。
 */
@interface CMImageTextAttachment : NSTextAttachment
{
    @protected
    NSURL       * _imageURL;
    CGSize      _imageSize;
}
- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title size:(CGSize)size;
- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title;

- (instancetype) initWithImageURL:(NSURL*)imageURL;

@property (nonatomic, copy) NSString* altText;

@property (nonatomic, readonly) NSURL* imageURL;

@property (nonatomic, readonly, weak) NSTextContainer *textContainer;

@property (nonatomic, assign) BOOL isImageLoaded;

- (void)setImageWithData:(NSData *)imageData;

- (void)downloadImage:(NSURL *)imageURL
           completion:(void(^)(NSError * _Nullable error, NSData * _Nullable data))block;

- (BOOL)isEqualToAttachment:(CMImageTextAttachment *)attach;

- (NSString*)imageCaption;

@end

@interface NSLayoutManager (CMImageTextAttachment)

- (void) setNeedsDisplayForAttachment:(NSTextAttachment*)textAttachment;
- (void) setNeedsLayoutForAttachment:(NSTextAttachment*)textAttachment;

@end

NS_ASSUME_NONNULL_END
