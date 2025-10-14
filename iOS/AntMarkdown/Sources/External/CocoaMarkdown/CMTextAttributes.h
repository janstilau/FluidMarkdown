//
//  CMTextAttributes.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/15/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

/**
 * 文本属性配置类，用于定义 Markdown 元素的样式
 * Text attributes configuration class for defining styles of Markdown elements
 */

#import <Foundation/Foundation.h>

#import "CMPlatformDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Markdown 元素类型枚举
 * Enumeration of Markdown element types
 */
typedef NS_OPTIONS(NSUInteger, CMElementKind) {
    CMElementKindText = 1 << 0,                     // 普通文本 / Plain text
    
    CMElementKindHeader1 = 1 << 1,                  // 一级标题 / Level 1 header
    CMElementKindHeader2 = 1 << 2,                  // 二级标题 / Level 2 header
    CMElementKindHeader3 = 1 << 3,                  // 三级标题 / Level 3 header
    CMElementKindHeader4 = 1 << 4,                  // 四级标题 / Level 4 header
    CMElementKindHeader5 = 1 << 5,                  // 五级标题 / Level 5 header
    CMElementKindHeader6 = 1 << 6,                  // 六级标题 / Level 6 header
    CMElementKindAnyHeader = CMElementKindHeader1 | CMElementKindHeader2 | CMElementKindHeader3 | CMElementKindHeader4 | CMElementKindHeader5 | CMElementKindHeader6,  // 任意级别标题 / Any level header
    
    CMElementKindParagraph = 1 << 7,                // 段落 / Paragraph
    CMElementKindLink = 1 << 8,                     // 链接 / Link
    CMElementKindImageParagraph = 1 << 9,           // 图片段落 / Image paragraph
    CMElementKindCodeBlock = 1 << 10,               // 代码块 / Code block
    CMElementKindInlineCode = 1 << 11,              // 行内代码 / Inline code
    CMElementKindBlockQuote = 1 << 12,              // 引用块 / Block quote
    
    CMElementKindOrderedList = 1 << 13,             // 有序列表 / Ordered list
    CMElementKindOrderedSublist = 1 << 14,          // 有序子列表 / Ordered sublist
    CMElementKindOrderedListItem = 1 << 15,         // 有序列表项 / Ordered list item
    CMElementKindUnorderedList = 1 << 16,           // 无序列表 / Unordered list
    CMElementKindUnorderedSublist = 1 << 17,        // 无序子列表 / Unordered sublist
    CMElementKindUnorderedListItem = 1 << 18,       // 无序列表项 / Unordered list item
};

@class CMStyleAttributes;

typedef NSString * CMParagraphStyleAttributeName NS_EXTENSIBLE_STRING_ENUM;

typedef NSString * CMCustomStyleAttributeName NS_EXTENSIBLE_STRING_ENUM;

/**
 * 用于样式化属性字符串的文本属性集合容器
 * Container for sets of text attributes used to style 
 * attributed strings.
 */
@interface CMTextAttributes : NSObject

/**
 * 使用默认属性初始化接收器
 * Initializes the receiver with the default attributes.
 *
 * @return 接收器的初始化实例 / An initialized instance of the receiver.
 */
- (instancetype)init;

/// 为一个或多个元素类型设置额外的字符串属性
/// Set additional attributes for one or more element-kind
/// 
/// @param attributes 将添加到指定元素类型现有属性的字符串属性字典 / A dictionary of string attributes that will be added to existing attributes for every specified element kind
/// @param elementKinds 目标元素类型的掩码 / The mask of target element kinds
///
- (void) addStringAttributes:(NSDictionary<NSAttributedStringKey, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds;

/// 为一个或多个元素类型设置额外的字体属性
/// Set additional font attributes for one or more element-kind
/// 
/// @param fontAttributes 将添加到指定元素类型现有属性的字体描述符属性字典 / A dictionary of font-descriptor attributes that will be added to existing attributes for every specified element kind
/// @param elementKinds 目标元素类型的掩码 / The mask of target element kinds
///
- (void) addFontAttributes:(NSDictionary<CMFontDescriptorAttributeName, id>*)fontAttributes forElementWithKinds:(CMElementKind)elementKinds;

/// 为一个或多个元素类型设置字体特征
/// Set font traits for one or more element-kind
/// 
/// @param fontTraits 将为指定元素类型设置的字体特征属性字典 / A dictionary of font-trait attributes that will be set for every specified element kind
/// @param elementKinds 目标元素类型的掩码 / The mask of target element kinds
/// @description 这是专门用于字体特征属性的 `addFontAttributes:forElementWithKinds:` 的特化版本 / This is a specialized version of `addFontAttributes:forElementWithKinds:` dedicated to the font-trait attribute
///
- (void) setFontTraits:(NSDictionary<CMFontDescriptorTraitKey, id>*)fontTraits forElementWithKinds:(CMElementKind)elementKinds;

/// 为一个或多个元素类型设置额外的段落属性
/// Set additional paragraph attributes for one or more element-kind
/// 
/// @param attributes 将添加到指定元素类型现有属性的字符串属性字典 / A dictionary of string attributes that will be added to existing attributes for every specified element kind
/// @param elementKinds 目标元素类型的掩码 / The mask of target element kinds
///
- (void) addParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName, id>*)attributes forElementWithKinds:(CMElementKind)elementKinds;

/**
 * 获取指定标题级别的属性
 * Get attributes for the specified header level
 * @param level 标题级别 / The header level.
 *
 * @return 指定标题级别的属性 / The attributes for the specified header level.
 */
- (CMStyleAttributes *)attributesForHeaderLevel:(NSInteger)level;

/**
 * 用于样式化文本的属性
 * Attributes used to style text.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleBody` 样式的动态类型字体
 * 在 OS X 上，默认使用 12pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleBody`
 * On OS X, defaults to using the user font with size 12pt.
 */
@property (nonatomic) CMStyleAttributes *baseTextAttributes;

/**
 * 用于样式化一级标题的属性
 * Attributes used to style level 1 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleHeadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 24pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 * On OS X, defaults to using the user font with size 24pt.
 */
@property (nonatomic) CMStyleAttributes *h1Attributes;

/**
 * 用于样式化二级标题的属性
 * Attributes used to style level 2 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleHeadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 18pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 * On OS X, defaults to using the user font with size 18pt.
 */
@property (nonatomic) CMStyleAttributes *h2Attributes;

/**
 * 用于样式化三级标题的属性
 * Attributes used to style level 3 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleHeadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 14pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleHeadline`
 * On OS X, defaults to using the user font with size 14pt.
 */
@property (nonatomic) CMStyleAttributes *h3Attributes;

/**
 * 用于样式化四级标题的属性
 * Attributes used to style level 4 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleSubheadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 12pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 * On OS X, defaults to using the user font with size 12pt.
 */
@property (nonatomic) CMStyleAttributes *h4Attributes;

/**
 * 用于样式化五级标题的属性
 * Attributes used to style level 5 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleSubheadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 10pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 * On OS X, defaults to using the user font with size 10pt.
 */
@property (nonatomic) CMStyleAttributes *h5Attributes;

/**
 * 用于样式化六级标题的属性
 * Attributes used to style level 6 headers.
 *
 * 在 iOS 上，默认使用 `UIFontTextStyleSubheadline` 样式的动态类型字体
 * 在 OS X 上，默认使用 8pt 的用户字体
 * On iOS, defaults to using the Dynamic Type font with style `UIFontTextStyleSubheadline`
 * On OS X, defaults to using the user font with size 8pt.
 */
@property (nonatomic) CMStyleAttributes *h6Attributes;

/**
 * 用于样式化段落的属性
 * Attributes used to style paragraphs.
 *
 * 默认使用 12pt 的段落间距
 * Defaults to using a 12pt paragraph spacing
 */
@property (nonatomic) CMStyleAttributes *paragraphAttributes;

/**
 * 用于样式化强调文本的属性
 * Attributes used to style emphasized text.
 *
 * 如果未设置，渲染器将尝试从常规文本字体推断强调字体
 * If not set, the renderer will attempt to infer the emphasized font from the
 * regular text font.
 */
@property (nonatomic) CMStyleAttributes *emphasisAttributes;

/**
 * 用于样式化粗体文本的属性
 * Attributes used to style strong text.
 *
 * 如果未设置，渲染器将尝试从常规文本字体推断粗体字体
 * If not set, the renderer will attempt to infer the strong font from the
 * regular text font.
 */
@property (nonatomic) CMStyleAttributes *strongAttributes;

/**
 * 用于样式化链接文本的属性
 * Attributes used to style linked text.
 *
 * 默认使用蓝色前景色和单线下划线样式
 * Defaults to using a blue foreground color and a single line underline style.
 */
@property (nonatomic) CMStyleAttributes *linkAttributes;


/**
 * 用于样式化图片段落的属性
 * Attributes used to style images paragraphs.
 *
 * 默认将图片居中显示
 * Defaults to centering the image.
 */
@property (nonatomic) CMStyleAttributes *imageParagraphAttributes;

/**
 * 用于样式化代码块的属性
 * Attributes used to style code blocks.
 *
 * 在 iOS 上，默认使用 Menlo 字体（如果可用），否则使用 Courier 作为备选
 * 在 OS X 上，默认使用用户等宽字体
 * On iOS, defaults to the Menlo font when available, or Courier as a fallback.
 * On OS X, defaults to the user monospaced font.
 */
@property (nonatomic) CMStyleAttributes *codeBlockAttributes;

/**
 * 用于样式化行内代码的属性
 * Attributes used to style inline code.
 *
 * 在 iOS 上，默认使用 Menlo 字体（如果可用），否则使用 Courier 作为备选
 * 在 OS X 上，默认使用用户等宽字体
 * On iOS, defaults to the Menlo font when available, or Courier as a fallback.
 * On OS X, defaults to the user monospaced font.
 */
@property (nonatomic) CMStyleAttributes *inlineCodeAttributes;

/**
 * 用于样式化引用块的属性
 * Attributes used to style block quotes.
 *
 * 默认使用带有 30px 首行缩进的段落样式
 * Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *blockQuoteAttributes;

/**
 * 用于样式化有序列表的属性
 * Attributes used to style ordered lists.
 *
 * 这些属性将应用于整个列表（除非被列表项的属性覆盖），包括数字
 * These attributes will apply to the entire list (unless overriden by attributes
 * for the list items), including the numbers.
 *
 * 默认使用带有 30px 首行缩进的段落样式
 * Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *orderedListAttributes;

/**
 * 用于样式化无序列表的属性
 * Attributes used to style unordered lists.
 *
 * 这些属性将应用于整个列表（除非被列表项的属性覆盖），包括项目符号
 * These attributes will apply to the entire list (unless overriden by attributes
 * for the list items), including the bullets.
 *
 * 默认使用带有 30px 首行缩进的段落样式
 * Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *unorderedListAttributes;

/**
 * 用于样式化有序子列表的属性
 * Attributes used to style ordered sublists.
 *
 * 这些属性将应用于整个列表（除非被列表项的属性覆盖），包括数字
 * These attributes will apply to the entire list (unless overriden by attributes
 * for the list items), including the numbers.
 *
 * 默认使用带有 30px 首行缩进的段落样式
 * Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *orderedSublistAttributes;

/**
 * 用于样式化无序子列表的属性
 * Attributes used to style unordered sublists.
 *
 * 这些属性将应用于整个列表（除非被列表项的属性覆盖），包括项目符号
 * These attributes will apply to the entire list (unless overriden by attributes
 * for the list items), including the bullets.
 *
 * 默认使用带有 30px 首行缩进的段落样式
 * Defaults to using a paragraph style with a head indent of 30px.
 */
@property (nonatomic) CMStyleAttributes *unorderedSublistAttributes;

/**
 * 用于样式化有序列表项的属性
 * Attributes used to style ordered list items.
 *
 * 这些属性不适用于数字
 * These attribtues do _not_ apply to the numbers.
 */
@property (nonatomic) CMStyleAttributes *orderedListItemAttributes;

/**
 * 用于样式化无序列表项的属性
 * Attributes used to style unordered list items.
 *
 * 这些属性不适用于项目符号
 * These attribtues do _not_ apply to the bullets.
 */
@property (nonatomic) CMStyleAttributes *unorderedListItemAttributes;

/**
 * 用于样式化水平分割线的属性
 * Attributes used to style horizontal rules.
 *
 * 默认使用居中对齐和浅灰色
 * Defaults to using a centered alignment with light gray color.
 */
@property (nonatomic) CMStyleAttributes *horizontalRuleAttributes;

/**
 * 用于样式化复选框的属性
 * Attributes used to style Checkbox.
 *
 * 默认使用居中对齐和浅蓝色
 * Defaults to using a centered alignment with light blue color.
 */
@property (nonatomic) CMStyleAttributes *checkboxAttributes;

/**
 * 设置水平分割线的属性
 * Set properties for horizontal rule.
 *
 * @param color 水平分割线的颜色 / The color of the horizontal rule.
 * @param thickness 水平分割线的厚度 / The thickness of the horizontal rule line.
 */
- (void)setHorizontalRuleColor:(CMColor *)color thickness:(CGFloat)thickness;

/**
 * 设置复选框的属性
 * Set properties for horizontal rule.
 *
 * @param bgColor 复选框的背景颜色 / The backgroundColor of checkbox
 * @param borderColor 边框的颜色 / The color of the border.
 * @param borderWidth 边框的宽度 / The width of the border.
 */
- (void)setCheckBoxCheckedBackgroundColor:(CMColor *)bgColor
                              borderColor:(CMColor *)borderColor
                              borderWidth:(CGFloat)borderWidth;

@end


/**
 * 样式属性类，用于管理字符串、字体和段落样式属性
 * Style attributes class for managing string, font, and paragraph style attributes
 */
// 这其实就是一个盒子. 
@interface CMStyleAttributes: NSObject <NSCopying>

@property (readonly) NSMutableDictionary<NSAttributedStringKey, id> * stringAttributes;        // 字符串属性字典 / String attributes dictionary

@property (readonly) NSMutableDictionary<CMFontDescriptorAttributeName, id> * fontAttributes; // 字体属性字典 / Font attributes dictionary

@property (readonly) NSMutableDictionary<CMParagraphStyleAttributeName, id> * paragraphStyleAttributes; // 段落样式属性字典 / Paragraph style attributes dictionary

// 在 fontAttributes 中设置特定符号特征的辅助方法
// Helper method for setting specific symbolic traits in fontAttributes
- (void) setFontSymbolicTraits:(CMFontSymbolicTraits)fontSymbolicTraits;

@end


// 段落样式属性名称常量 / Paragraph style attribute name constants
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineSpacing;                    // 行间距 / Line spacing
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacing;              // 段落间距 / Paragraph spacing
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeAlignment;                      // 对齐方式 / Alignment
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeFirstLineHeadExtraIndent;       // 首行额外缩进 / First line head extra indent
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeHeadExtraIndent;                // 头部额外缩进 / Head extra indent
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeTailExtraIndent;                // 尾部额外缩进 / Tail extra indent
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineBreakMode;                  // 换行模式 / Line break mode
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeMinimumLineHeight;              // 最小行高 / Minimum line height
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeMaximumLineHeight;              // 最大行高 / Maximum line height
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeLineHeightMultiple;             // 行高倍数 / Line height multiple
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeParagraphSpacingBefore;         // 段落前间距 / Paragraph spacing before
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeHyphenationFactor;              // 连字符因子 / Hyphenation factor
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemLabelIndent;            // 列表项标签缩进 / List item label indent
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemBulletString;           // 列表项项目符号字符串 / List item bullet string
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemNumberFormat;           // 列表项数字格式 / List item number format
extern CMParagraphStyleAttributeName const CMParagraphStyleAttributeListItemParagraphPrefix;        // 列表项段落前缀 / List item paragraph prefix

// 自定义样式属性名称常量 / Custom style attribute name constants
extern CMCustomStyleAttributeName const CMHorizontalRuleThickness;                                  // 水平分割线厚度 / Horizontal rule thickness
extern CMCustomStyleAttributeName const CMLinkBold;                                                 // 链接粗体 / Link bold
extern CMCustomStyleAttributeName const CMCustomListBullet;                                         // 自定义列表项目符号 / Custom list bullet
extern CMCustomStyleAttributeName const CMCheckBoxBorderWidth;                                      // 复选框边框宽度 / Checkbox border width
extern CMCustomStyleAttributeName const CMParagraphStyleAttributeListItemLabelIcon;                // 列表项标签图标 / List item label icon
extern CMCustomStyleAttributeName const CMListSingleDigitSize;                                      // 列表单位数大小 / List single digit size
extern CMCustomStyleAttributeName const CMListTwoDigitSize;                                         // 列表两位数大小 / List two digit size
extern CMCustomStyleAttributeName const CMListThreeDigitSize;                                       // 列表三位数大小 / List three digit size
extern CMCustomStyleAttributeName const CMLinkIconPrefix;                                           // 链接图标前缀 / Link icon prefix
extern CMCustomStyleAttributeName const CMLinkIconSpace;                                            // 链接图标间距 / Link icon space
extern CMCustomStyleAttributeName const CMLinkIconSuffix;                                           // 链接图标后缀 / Link icon suffix
extern CMCustomStyleAttributeName const CMOrderListFirstLevelIndent;                                // 有序列表第一级缩进 / Order list first level indent
extern CMCustomStyleAttributeName const CMParagraphStyleAttributeListItemLabelIconSize;            // 列表项标签图标大小 / List item label icon size
extern CMCustomStyleAttributeName const CMListLevelIndent;                                          // 列表级别缩进 / List level indent
extern CMCustomStyleAttributeName const CMListInternalSpace;                                        // 列表内部间距 / List internal space

NS_ASSUME_NONNULL_END
