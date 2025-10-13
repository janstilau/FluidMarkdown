// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMImageTextAttachment.h"
#import "AMViewAttachment.h"
#import "AMUtils.h"

@implementation AMImageTextAttachment
{
    // 这套机制没有用上, 可能原来还想进行 Image 的显示控制, 但是现在来说, 还是 MD 的默认实现.
    CGRect _usedRect;
}

- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title
{
    self = [super initWithImageURL:imageURL title:title];
    if (self) {
        _usedRect = CGRectNull;
    }
    return self;
}

- (void)setImageWithData:(NSData *)imageData
{
    // setImageWithData 也重写了, 会有缓存的存入.
    [super setImageWithData:imageData];
    if ([self enableImageCache]) {
        [[AMSimpleImageCache sharedCache] setImageData:imageData forURL:self.imageURL];
    }
    [self setNeedsLayout];
}

- (void)setNeedsLayout
{
    NSLayoutManager *mgr = self.textContainer.layoutManager;
    if (mgr) {
        [mgr setNeedsLayoutForAttachment:self];
        
        NSNotification *noti = [[NSNotification alloc] initWithName:AMTextAttachmentSizeDidUpdateNotification
                                                             object:mgr.textStorage
                                                           userInfo:@{
            NSAttachmentAttributeName: self,
        }];
        [[NSNotificationQueue defaultQueue] enqueueNotification:noti
                                                   postingStyle:NSPostWhenIdle
                                                   coalesceMask:NSNotificationCoalescingOnSender
                                                       forModes:nil];
    }
}

- (void)setNeedsDisplay
{
    [self.textContainer.layoutManager setNeedsDisplayForAttachment:self];
}

- (BOOL)isEqualToAttachment:(AMImageTextAttachment *)attach
{
    return [self.imageURL isEqual:attach.imageURL];
}

- (void)updateAttachmentFromAttachment:(AMImageTextAttachment *)attach
{
    if (![self isEqualToAttachment:attach]) {
        _imageURL = attach.imageURL;
        self.isImageLoaded = NO;
    }
}

// 完全重写了, 父类的实现.
- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex
{
    // 会有一个缓存机制的检查.
    if (self.enableImageCache && !self.isImageLoaded) {
        NSData *data = [[AMSimpleImageCache sharedCache] imageDataForURL:self.imageURL];
        if (data) {
            [self setImageWithData:data];
            self.isImageLoaded = YES;
        }
    }
    UIImage *image = [super imageForBounds:imageBounds textContainer:textContainer characterIndex:charIndex];
    return image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex
{
    CGSize attachmentImageSize = self.image.size;
    
    CGFloat maxWidth = lineFrag.size.width - textContainer.lineFragmentPadding * 2;
    
    if (attachmentImageSize.width > maxWidth) {
        attachmentImageSize = CGSizeMake(maxWidth, attachmentImageSize.height * maxWidth / attachmentImageSize.width);
    }
    
    CGRect attachmentBounds;
    attachmentBounds.origin = CGPointZero;
    attachmentBounds.size = attachmentImageSize;
    return attachmentBounds;
}

@end

@implementation AMSimpleImageCache
{
    NSLock      * _lock;
    NSURLCache  * _cache;
}

+ (instancetype)sharedCache
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ImageAttachmentCache"];
        _cache = [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                               diskCapacity:50 * 1024 * 1024
                                                   diskPath:cachePath];
    }
    return self;
}

- (NSData *)imageDataForURL:(NSURL *)url
{
    [_lock lock];
    NSCachedURLResponse *res = [_cache cachedResponseForRequest:[NSURLRequest requestWithURL:url]];
    [_lock unlock];
    return res.data;
}

- (void)setImageData:(NSData *)data forURL:(NSURL *)url
{
    [_lock lock];
    [_cache storeCachedResponse:[[NSCachedURLResponse alloc] initWithResponse:[[NSURLResponse alloc] initWithURL:url
                                                                                                        MIMEType:@"application/image"
                                                                                           expectedContentLength:data.length
                                                                                                textEncodingName:nil]
                                                                         data:data]
                     forRequest:[NSURLRequest requestWithURL:url]];
    [_lock unlock];
}

@end
