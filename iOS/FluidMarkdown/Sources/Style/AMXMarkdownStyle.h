// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * FluidMarkdown 样式配置系统
 * 
 * 本文件定义了 FluidMarkdown 渲染引擎的完整样式配置体系，包括：
 * - Markdown 元素类型枚举
 * - 字体、间距、颜色等基础样式配置
 * - 列表、表格、代码块等复杂元素的专用配置
 * - 统一的样式管理接口
 */

/**
 * Markdown 元素类型枚举
 * 定义了 FluidMarkdown 支持的所有 Markdown 元素类型
 */
typedef NS_ENUM(NSUInteger, AMXElementType) {
    AMXElementTypeParagraph,        // 段落 - 基础文本段落
    AMXElementTypeHeader1,          // 一级标题 - # 标题
    AMXElementTypeHeader2,          // 二级标题 - ## 标题
    AMXElementTypeHeader3,          // 三级标题 - ### 标题
    AMXElementTypeHeader4,          // 四级标题 - #### 标题
    AMXElementTypeHeader5,          // 五级标题 - ##### 标题
    AMXElementTypeHeader6,          // 六级标题 - ###### 标题
    AMXElementTypeUnorderedList,    // 无序列表 - 使用 -, *, + 的列表
    AMXElementTypeOrderedList,      // 有序列表 - 使用数字编号的列表
    AMXElementTypeTable,            // 表格 - Markdown 表格
    AMXElementTypeBlockQuote,       // 引用块 - > 引用内容
    AMXElementTypeHRule,            // 分割线 - --- 或 *** 分割线
    AMXElementTypeLink,             // 链接 - [文本](URL) 格式的链接
    AMXElementTypeFootNote,         // 脚注 - 页面底部的注释
    AMXElementTypeInlineCode,       // 行内代码 - `代码` 格式的代码
    AMXElementTypeCodeBlock         // 代码块 - ``` 包围的代码块
};

/**
 * 列表前缀类型枚举
 * 定义列表项前缀的显示方式
 */
typedef NS_ENUM(NSUInteger, AMXListPrefixType) {
    AMXListPrefixTypeCharacter,     // 字符前缀 - 使用文字符号（如 •, 1., 2. 等）
    AMXListPrefixTypeImage,         // 图片前缀 - 使用自定义图片作为前缀
};

/**
 * 字体配置类
 * 用于配置文本的字体样式和颜色
 */
@interface AMXFontConfig : NSObject
@property(nonatomic, strong) UIFont *font;          // 字体对象 - 包含字体族、大小、粗细等信息
@property(nonatomic, strong) UIColor* fontColor;    // 字体颜色 - 文本显示的颜色
@end

/**
 * 间距配置类
 * 用于配置段落和行之间的间距
 */
@interface AMXSpacingConfig : NSObject
@property(nonatomic, assign) CGFloat paragraphSpacing;       // 段落后间距 - 段落结束后的空白距离
@property(nonatomic, assign) CGFloat lineSpacing;            // 行间距 - 文本行之间的额外间距
@property(nonatomic, assign) CGFloat paragraphSpacingBefore; // 段落前间距 - 段落开始前的空白距离
@end

/**
 * 列表级别配置类
 * 用于配置不同层级列表的显示样式
 * 支持多级嵌套列表的自定义样式
 */
@interface AMXListLevelConfig : NSObject
@property (nonatomic, assign) AMXListPrefixType prefixType;     // 前缀类型 - 字符或图片
@property (nonatomic, assign) CGFloat symbolIndentation;        // 符号缩进 - 列表符号相对于左边距的缩进距离
@property (nonatomic, strong) NSString *prefixSymbol;           // 前缀符号 - 当 prefixType 为字符类型时使用（如 "•", "1.", "a)" 等）
@property (nonatomic, strong) NSString *prefixSymbolPath;       // 前缀图片路径 - 当 prefixType 为图片类型时使用
@property (nonatomic, assign) CGSize symbolSize;               // 符号大小 - 前缀符号或图片的显示尺寸
@property (nonatomic, assign) CGFloat prefixSpacing;           // 前缀间距 - 前缀符号与列表内容之间的距离

/**
 * 创建指定层级的默认列表样式
 * @param level 列表层级（0-4）
 * @return 默认配置的列表样式对象
 */
+ (instancetype)defaultStyle:(NSInteger)level;
@end

/**
 * 表格单元格样式配置类
 * 用于配置表格中单个单元格的显示样式
 */
@interface AMXTableCellStyle : NSObject
@property (nonatomic, strong) AMXFontConfig *font;      // 单元格字体配置 - 包含字体和颜色信息
@property (nonatomic, strong) UIColor *backgroundColor; // 单元格背景色 - 单元格的背景颜色
@property (nonatomic, assign) UIEdgeInsets padding;     // 单元格内边距 - 内容与单元格边框的距离
@end

/**
 * 表格样式配置类
 * 用于配置整个表格的显示样式和布局
 */
@interface AMXTableStyleConfig : NSObject
@property (nonatomic, assign) CGFloat rowSpacing;           // 行间距 - 表格行之间的间距
@property (nonatomic, assign) CGFloat columnSpacing;        // 列间距 - 表格列之间的间距
@property (nonatomic, assign) CGFloat borderWidth;          // 边框宽度 - 表格边框线的粗细
@property (nonatomic, assign) CGFloat maxWidth;             // 表格最大宽度 - 表格显示的最大宽度限制
@property (nonatomic, assign) CGFloat maxHeight;            // 表格最大高度 - 表格显示的最大高度限制
// 所有相关的显示值, 其实都进行了配置. 
@property (nonatomic, assign) CGFloat firstColumnMaxWidth;  // 首列最大宽度 - 第一列的最大宽度限制
@property (nonatomic, assign) CGFloat columnMaxWidth;       // 列最大宽度 - 其他列的最大宽度限制
@property (nonatomic, strong) NSString* operationIconPath;  // 操作图标路径 - 表格操作按钮的图标路径（格式：bundleName/iconName）
@property (nonatomic, strong) AMXFontConfig *titlefont;     // 标题字体配置 - 表格标题的字体样式
@property (nonatomic, strong) UIColor *titleBackgroundColor; // 标题背景色 - 表格标题行的背景颜色
@property (nonatomic, strong) AMXTableCellStyle *headerStyle;  // 表头样式 - 表格头部单元格的样式配置
@property (nonatomic, strong) AMXTableCellStyle *contentStyle; // 内容样式 - 表格内容单元格的样式配置

/**
 * 创建默认的表格样式配置
 * @return 包含默认设置的表格样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 分割线配置类
 * 用于配置 Markdown 分割线（--- 或 ***）的显示样式
 */
@interface AMXHRuleConfig : NSObject
@property (nonatomic, strong) UIColor *color;  // 分割线颜色 - 分割线的显示颜色
@property (nonatomic, assign) CGFloat height;  // 分割线高度 - 分割线的粗细程度

/**
 * 创建默认的分割线样式配置
 * @return 包含默认设置的分割线样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 链接配置类
 * 用于配置 Markdown 链接的显示样式和行为
 */
@interface AMXLinkConfig : NSObject
@property (nonatomic, assign) CGFloat spacing;          // 链接间距 - 链接文本与周围内容的间距
@property (nonatomic, strong) NSString *iconPath;      // 链接图标路径 - 链接旁边显示的图标路径
@property (nonatomic, assign) BOOL underLine;          // 下划线显示 - 是否为链接添加下划线
@property (nonatomic, assign) NSInteger prefixOrSuffix; // 图标位置 - 图标显示位置（1: 前缀, 2: 后缀）

/**
 * 创建默认的链接样式配置
 * @return 包含默认设置的链接样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 脚注配置类
 * 用于配置 Markdown 脚注的显示样式
 */
@interface AMXFootNoteConfig : NSObject
@property (nonatomic, assign) CGSize size;              // 脚注尺寸 - 脚注标记的显示大小
@property (nonatomic, strong) UIColor* backgroundColor; // 脚注背景色 - 脚注标记的背景颜色

/**
 * 创建默认的脚注样式配置
 * @return 包含默认设置的脚注样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 引用块样式配置类
 * 用于配置 Markdown 引用块（> 引用内容）的显示样式
 */
@interface AMXBlockquoteStyle : NSObject
@property (nonatomic, strong) UIColor *lineColor;  // 引用线颜色 - 引用块左侧竖线的颜色
@property (nonatomic, assign) CGFloat lineWidth;   // 引用线宽度 - 引用块左侧竖线的粗细
@property (nonatomic, assign) CGFloat indentation; // 引用缩进 - 引用内容相对于左边距的缩进距离

/**
 * 创建默认的引用块样式配置
 * @return 包含默认设置的引用块样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 行内代码配置类
 * 用于配置 Markdown 行内代码（`代码`）的显示样式
 */
@interface AMXInlineCodeConfig : NSObject
@property(nonatomic, strong) UIColor* backgroundColor;  // 行内代码背景色 - 代码文本的背景颜色
@property(nonatomic, strong) AMXFontConfig* codeFont;   // 行内代码字体配置 - 代码文本的字体样式

/**
 * 创建默认的行内代码样式配置
 * @return 包含默认设置的行内代码样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 代码块配置类
 * 用于配置 Markdown 代码块（``` 包围的代码）的显示样式
 */
@interface AMXCodeBlockConfig : NSObject
@property(nonatomic, strong) UIColor* titleBackgroundColor; // 代码块标题背景色 - 代码块顶部标题栏的背景颜色
@property(nonatomic, strong) AMXFontConfig *titleFont;      // 代码块标题字体配置 - 标题文本的字体样式
@property(nonatomic, strong) UIColor* backgroundColor;      // 代码块背景色 - 代码内容区域的背景颜色
@property(nonatomic, assign) CGFloat borderWidth;           // 代码块边框宽度 - 代码块边框线的粗细
@property(nonatomic, strong) UIColor* borderColor;          // 代码块边框颜色 - 代码块边框线的颜色
@property (nonatomic, strong) NSString* operationIconPath;  // 操作图标路径 - 代码块操作按钮的图标路径（格式：bundleName/iconName）

/**
 * 创建默认的代码块样式配置
 * @return 包含默认设置的代码块样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * 下划线配置类
 * 用于配置文本下划线的显示样式
 */
@interface AMXUnderLineConfig : NSObject
@property(nonatomic, strong) UIColor* lineColor;    // 下划线颜色 - 下划线的显示颜色
@property(nonatomic, assign) CGFloat lineWidth;     // 下划线宽度 - 下划线的粗细程度
@property(nonatomic, assign) CGFloat lineOffset;    // 下划线偏移 - 下划线相对于文本基线的偏移距离

/**
 * 创建默认的下划线样式配置
 * @return 包含默认设置的下划线样式对象
 */
+ (instancetype)defaultStyle;
@end

/**
 * Markdown 样式配置主类
 * 
 * 这是 FluidMarkdown 样式系统的核心类，统一管理所有 Markdown 元素的样式配置。
 * 提供了完整的样式定制能力，包括字体、间距、颜色、布局等各个方面。
 * 
 * 主要功能：
 * - 管理不同 Markdown 元素类型的字体和间距配置
 * - 支持多级列表的层级样式配置
 * - 提供表格、代码块、链接等复杂元素的专用样式配置
 * - 统一的样式获取和设置接口
 */
@interface AMXMarkdownStyleConfig : NSObject

// MARK: - 复杂元素样式配置
@property(nonatomic, strong) AMXTableStyleConfig* tableConfig;      // 表格样式配置 - 控制表格的整体显示样式
@property(nonatomic, strong) AMXHRuleConfig* hRuleConfig;           // 分割线样式配置 - 控制分割线的显示样式
@property(nonatomic, strong) AMXFootNoteConfig* footNoteConfig;     // 脚注样式配置 - 控制脚注标记的显示样式
@property(nonatomic, strong) AMXLinkConfig* linkConfig;             // 链接样式配置 - 控制链接的显示样式和行为
@property(nonatomic, strong) AMXInlineCodeConfig* inlineCodeConfig; // 行内代码样式配置 - 控制行内代码的显示样式
@property(nonatomic, strong) AMXCodeBlockConfig* codeBlockConfig;   // 代码块样式配置 - 控制代码块的显示样式
@property(nonatomic, strong) AMXUnderLineConfig* underlineConfig;   // 下划线样式配置 - 控制下划线的显示样式
@property(nonatomic, strong) AMXBlockquoteStyle* blockQuoteConfig;  // 引用块样式配置 - 控制引用块的显示样式

// MARK: - 全局配置方法

/**
 * 创建包含所有默认设置的样式配置对象
 * 
 * 该方法会创建一个完整的样式配置实例，包含所有 Markdown 元素的默认样式设置。
 * 开发者可以基于此默认配置进行自定义修改。
 * 
 * @return 包含默认样式设置的 AMXMarkdownStyleConfig 实例
 */
+ (instancetype)defaultConfig;

// MARK: - 基础样式配置方法

/**
 * 为指定的 Markdown 元素类型设置字体配置
 * 
 * @param config 字体配置对象，包含字体和颜色信息
 * @param type Markdown 元素类型（如段落、标题、列表等）
 */
- (void)setFontConfig:(AMXFontConfig *)config forElementType:(AMXElementType)type;

/**
 * 为指定的 Markdown 元素类型设置间距配置
 * 
 * @param config 间距配置对象，包含段落间距、行间距等信息
 * @param type Markdown 元素类型（如段落、标题、列表等）
 */
- (void)setSpacingConfig:(AMXSpacingConfig *)config forElementType:(AMXElementType)type;

/**
 * 为指定的 Markdown 元素类型设置行高
 * 
 * @param lineHeight 行高值（以点为单位）
 * @param type Markdown 元素类型（如段落、标题、列表等）
 */
- (void)setLineHeightConfig:(CGFloat)lineHeight forElementType:(AMXElementType)type;

// MARK: - 列表样式配置方法

/**
 * 为指定层级的有序列表添加样式配置
 * 
 * 支持多级嵌套列表，每个层级可以有不同的样式设置。
 * 
 * @param config 列表层级配置对象，包含前缀符号、缩进、间距等信息
 * @param level 列表层级（0-4，0 为最外层）
 */
- (void)addOrderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level;

/**
 * 为指定层级的无序列表添加样式配置
 * 
 * 支持多级嵌套列表，每个层级可以有不同的样式设置。
 * 
 * @param config 列表层级配置对象，包含前缀符号、缩进、间距等信息
 * @param level 列表层级（0-4，0 为最外层）
 */
- (void)addUnorderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level;

// MARK: - 样式获取方法

/**
 * 获取指定 Markdown 元素类型的字体配置
 * 
 * @param type Markdown 元素类型
 * @return 对应的字体配置对象，如果未设置则返回 nil
 */
- (AMXFontConfig*)getFontConfig:(AMXElementType)type;

/**
 * 获取指定 Markdown 元素类型的间距配置
 * 
 * @param type Markdown 元素类型
 * @return 对应的间距配置对象，如果未设置则返回 nil
 */
- (AMXSpacingConfig*)getSpacingConfig:(AMXElementType)type;

/**
 * 获取指定 Markdown 元素类型的行高设置
 * 
 * @param type Markdown 元素类型
 * @return 对应的行高值，如果未设置则返回 0
 */
- (CGFloat)getLineHeight:(AMXElementType)type;

/**
 * 获取所有层级的有序列表配置
 * 
 * @return 包含所有层级配置的字典，键为层级字符串，值为配置对象
 */
- (NSDictionary*)getAllLevelOrderListConfigs;

/**
 * 获取指定层级的有序列表配置
 * 
 * @param level 列表层级（0-4）
 * @return 对应层级的列表配置对象，如果未设置则返回 nil
 */
- (AMXListLevelConfig *)getOrderListConfig:(NSUInteger)level;

/**
 * 获取所有层级的无序列表配置
 * 
 * @return 包含所有层级配置的字典，键为层级字符串，值为配置对象
 */
- (NSDictionary*)getAllLevelUnorderListConfigs;

/**
 * 获取指定层级的无序列表配置
 * 
 * @param level 列表层级（0-4）
 * @return 对应层级的列表配置对象，如果未设置则返回 nil
 */
- (AMXListLevelConfig *)getUnorderListConfig:(NSUInteger)level;

@end

NS_ASSUME_NONNULL_END
