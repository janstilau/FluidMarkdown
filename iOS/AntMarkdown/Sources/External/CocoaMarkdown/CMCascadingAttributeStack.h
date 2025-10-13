//
//  CMCascadingAttributeStack.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

/**
 * 级联属性栈类，用于管理 Markdown 渲染过程中的文本属性层次结构
 * Cascading attribute stack class for managing text attribute hierarchy during Markdown rendering
 *
 * 该类实现了一个栈结构，用于处理嵌套的 Markdown 元素（如列表、引用等）的属性继承和覆盖。
 * 当遇到嵌套元素时，新的属性会被推入栈中，并与现有属性进行级联合并。
 * This class implements a stack structure for handling attribute inheritance and overriding 
 * of nested Markdown elements (such as lists, quotes, etc.). When nested elements are encountered,
 * new attributes are pushed onto the stack and cascaded with existing attributes.
 */

#import <Foundation/Foundation.h>
#import "CMPlatformDefines.h"
#import "CMTextAttributes.h"

@class CMStyleAttributes;
@class CMAttributeRun;

/**
 * 级联属性栈类
 * Cascading attribute stack class
 */
@interface CMCascadingAttributeStack : NSObject

/**
 * 级联合并后的属性字典（只读）
 * Read-only dictionary of cascaded attributes
 *
 * 该属性返回当前栈中所有属性层级合并后的最终属性字典
 * This property returns the final attribute dictionary after merging all attribute levels in the current stack
 */
@property (nonatomic, readonly) NSDictionary *cascadedAttributes;

/**
 * 将样式属性推入栈顶
 * Push style attributes to the top of the stack
 *
 * @param attributes 要推入的样式属性 / The style attributes to push
 */
- (void) pushAttributes:(CMStyleAttributes*)attributes;

/**
 * 将有序列表的样式属性推入栈顶
 * Push ordered list style attributes to the top of the stack
 *
 * @param attributes 要推入的样式属性 / The style attributes to push
 * @param startingNumber 列表的起始编号 / The starting number for the list
 */
- (void) pushOrderedListAttributes:(CMStyleAttributes*)attributes withStartingNumber:(NSInteger)startingNumber;

/**
 * 弹出栈顶的属性
 * Pop the top attributes from the stack
 */
- (void)pop;

/**
 * 查看栈顶的属性运行对象（不弹出）
 * Peek at the top attribute run object (without popping)
 *
 * @return 栈顶的属性运行对象 / The attribute run object at the top of the stack
 */
- (CMAttributeRun *)peek;

/**
 * 获取指定深度的样式属性
 * Get style attributes at the specified depth
 *
 * @param depth 栈的深度，0表示栈顶 / The depth of the stack, 0 means stack top
 * @return 指定深度的样式属性 / The style attributes at the specified depth
 */
- (CMStyleAttributes*) attributesWithDepth:(NSUInteger)depth; // depth=0 means stack top
@end

/**
 * CMFont 扩展类别，提供字体属性处理功能
 * CMFont extension category providing font attribute processing functionality
 */
@interface CMFont (CMAdditions)

/**
 * 通过添加 CM 字体属性创建新的字体对象
 * Create a new font object by adding CM font attributes
 *
 * @param addedFontAttributes 要添加的字体属性字典 / The font attributes dictionary to add
 * @return 应用了新属性的字体对象 / The font object with applied new attributes
 */
- (CMFont*) fontByAddingCMAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)addedFontAttributes;

@end

/**
 * NSParagraphStyle 扩展类别，提供段落样式属性处理功能
 * NSParagraphStyle extension category providing paragraph style attribute processing functionality
 */
@interface NSParagraphStyle (CMAdditions)

/**
 * 使用 CM 段落样式属性创建段落样式对象
 * Create a paragraph style object using CM paragraph style attributes
 *
 * @param paragraphStyleAttributes CM 段落样式属性字典 / The CM paragraph style attributes dictionary
 * @return 创建的段落样式对象 / The created paragraph style object
 */
+ (NSParagraphStyle*) paragraphStyleWithCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes;

/**
 * 通过添加 CM 段落样式属性创建新的段落样式对象
 * Create a new paragraph style object by adding CM paragraph style attributes
 *
 * @param paragraphStyleAttributes 要添加的 CM 段落样式属性字典 / The CM paragraph style attributes dictionary to add
 * @return 应用了新属性的段落样式对象 / The paragraph style object with applied new attributes
 */
- (NSParagraphStyle*) paragraphStyleByAddingCMAttributes:(NSDictionary<CMParagraphStyleAttributeName, id> *)paragraphStyleAttributes;

@end
