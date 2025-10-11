//
//  CMHTMLElementTransformer.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ONOXMLElement;

/**
 *  Interface for an object that can transform an HTML element to an attributed string.
 */
/**
 * CM HTML 元素转换器协议
 * 用于将 HTML 元素转换为属性字符串的转换器接口
 */
@protocol CMHTMLElementTransformer <NSObject>

/**
 * 获取此转换器处理的标签名称
 * @return 标签名称字符串
 */
+ (NSString *)tagName;

/**
 * 将 HTML 元素转换为属性字符串
 * @param element 要转换的 HTML 元素
 * @param attributes 应用到属性字符串的基础属性
 * @return 转换后的属性字符串
 */
- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes;

@optional
/**
 * 获取转换器参数（可选实现）
 * @return 参数字典
 */
-(NSDictionary*)getParams;

@end

/**
 *  Use this macro inside an implementation of `-attributedStringForElement:attributes:`
 *  to assert that the root element's tag matches the transformer's tag.
 */
#define CMAssertCorrectTag(element) \
    NSAssert([element.tag isEqualToString:self.class.tagName], @"Tag does not match");
