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
 *  从 Markdown 文档渲染生成 NSAttributedString 富文本
 */
// 这个类没有真正的使用起来. 没有真正调用它的地方.
// 真正起到作用的, 还是 AMAttributedStringRenderer 这个类. 
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
 *  便利构造方法（指定初始化方法）。
 *
 *  @param document   Markdown 文档对象。
 *  @param attributes 用于渲染样式的属性集合（字体、颜色、段落等）。
 *
 *  @return 已初始化的渲染器实例。
 */
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
 *  指定初始化方法（带可点击元素信息回调）。
 *
 *  @param document   Markdown 文档对象。
 *  @param attributes 渲染样式属性集合。
 *  @param delegate   可点击元素信息回调代理，用于同步链接、脚注引用等位置与内容。
 *
 *  @return 已初始化的渲染器实例。
 */

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
 *  注册一个用于转换 HTML 元素的处理器（Transformer）。
 *
 *  同一个 HTML 标签仅允许注册一个转换器，如果重复注册会覆盖之前的转换器。
 *
 *  @param transformer 要注册的 HTML 元素转换器。
 */

/**
 *  Renders an attributed string from the Markdown document.
 *
 *  @return An attributed string containing the contents of the Markdown document,
 *  styled using the attributes set on the receiver.
 */
- (NSAttributedString *)render;
/**
 *  将当前 Markdown 文档渲染为 NSAttributedString。
 *
 *  @return 返回包含文档内容的富文本，按传入的样式属性进行着色与排版。
 */

/**
 *  Get the clickable object infos.
 *
 *  @return An array that has all clickable object.
 */
-(NSArray*)clickableObjs;
/**
 *  获取所有可点击元素的信息（如链接、脚注引用等）。
 *
 *  @return 包含可点击元素数据的数组。
 */

@end
