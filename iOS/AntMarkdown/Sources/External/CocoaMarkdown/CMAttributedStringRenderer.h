//
//  CMAttributedStringRenderer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMNode.h"

@class CMDocument;
@class CMTextAttributes;
@protocol CMHTMLElementTransformer;

/**
 * CM 属性字符串渲染器代理协议
 * 用于处理 Markdown 渲染过程中的可点击元素通知
 */
@protocol CMAttributedStringRendererDelegate <NSObject>

/**
 * 通知所有可点击元素的信息
 * @param dataArray 可见的可点击元素内容数组
 */
-(void)notifyNodeUpdate:( NSArray* _Nonnull )dataArray;

/**
 * 通知所有可点击元素基于父文本视图的位置信息
 * @param locArray 可见的可点击元素位置数组
 */
-(void)notifyNodeLocation:(NSArray* _Nonnull )locArray;

@end
/**
 *  Renders an attributed string from a Markdown document
 */
@interface CMAttributedStringRenderer : NSObject

/**
 *  Designated initializer.
 *
 *  @param document   A Markdown document.
 *  @param attributes Attributes used to style the string.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes;
/**
 *  Designated initializer.
 *
 *  @param document   A Markdown document.
 *  @param attributes Attributes used to style the string.
 *  @param delegate Clickable elements info delegate.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes delegate:(nullable id<CMAttributedStringRendererDelegate>)delegate;

/**
 *  Registers a handler to transform HTML elements.
 *
 *  Only a single transformer can be registered for an element. If a transformer
 *  is already registered for an element, it will be replaced.
 *
 *  @param transformer The transformer to register.
 */
- (void)registerHTMLElementTransformer:(id<CMHTMLElementTransformer>)transformer;

/**
 *  Renders an attributed string from the Markdown document.
 *
 *  @return An attributed string containing the contents of the Markdown document,
 *  styled using the attributes set on the receiver.
 */
- (NSAttributedString *)render;

/**
 *  Get the clickable object infos.
 *
 *  @return An array that has all clickable object.
 */
-(NSArray*)clickableObjs;

@end
