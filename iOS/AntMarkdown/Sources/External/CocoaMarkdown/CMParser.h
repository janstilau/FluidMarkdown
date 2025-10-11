//
//  CMParser.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMNode;
@class CMTable;
@class CMDocument;
@protocol CMParserDelegate;

/**
 *  Not really a parser, but you can pretend it is. 
 *
 *  This class takes a `CMDocument` (which contains the tree for the already-parsed 
 *  Markdown data) and traverses the tree to implement `NSXMLParser`-style delegate 
 *  callbacks.
 *
 *  This is useful for implementing custom renderers.
 *
 *  @warning This class is not thread-safe and can only be accessed from a single
 *  thread at a time.
 */
@interface CMParser : NSObject

/**
 *  Initializes the receiver with a document.
 *
 *  @param document CommonMark document.
 *  @param delegate Delegate to receive callbacks during parsing.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithDocument:(CMDocument *)document delegate:(id<CMParserDelegate>)delegate;

/**
 *  Document being parsed.
 */
@property (nonatomic, readonly) CMDocument *document;

/**
 *  Delegate to receive callbacks during parsing.
 */
@property (nonatomic, weak, readonly) id<CMParserDelegate> delegate;

/**
 *  Returns the node currently being parsed, or `nil` if not parsing.
 */
@property (atomic, readonly) CMNode *currentNode;

/**
 *  Start parsing.
 */
- (void)parse;

/**
 *  Stop parsing. If implemented, `-parserDidAbort:` will be called on the delegate.
 */
- (void)abortParsing;

@end

/**
 * CM 解析器代理协议
 * 用于处理 Markdown 解析过程中的各种元素回调
 */
@protocol CMParserDelegate <NSObject>

@optional
/**
 * 解析器开始解析文档回调
 * @param parser 解析器实例
 */
- (void)parserDidStartDocument:(CMParser *)parser;

/**
 * 解析器结束解析文档回调
 * @param parser 解析器实例
 */
- (void)parserDidEndDocument:(CMParser *)parser;

/**
 * 解析器中止解析回调
 * @param parser 解析器实例
 */
- (void)parserDidAbort:(CMParser *)parser;

/**
 * 发现文本内容回调
 * @param parser 解析器实例
 * @param text 文本内容
 */
- (void)parser:(CMParser *)parser foundText:(NSString *)text;

/**
 * 发现水平分割线回调
 * @param parser 解析器实例
 */
- (void)parserFoundHRule:(CMParser *)parser;

/**
 * 开始标题元素回调
 * @param parser 解析器实例
 * @param level 标题级别（1-6）
 */
- (void)parser:(CMParser *)parser didStartHeaderWithLevel:(NSInteger)level;

/**
 * 结束标题元素回调
 * @param parser 解析器实例
 * @param level 标题级别（1-6）
 */
- (void)parser:(CMParser *)parser didEndHeaderWithLevel:(NSInteger)level;

/**
 * 开始段落元素回调
 * @param parser 解析器实例
 */
- (void)parserDidStartParagraph:(CMParser *)parser;

/**
 * 结束段落元素回调
 * @param parser 解析器实例
 */
- (void)parserDidEndParagraph:(CMParser *)parser;

/**
 * 开始斜体元素回调
 * @param parser 解析器实例
 */
- (void)parserDidStartEmphasis:(CMParser *)parser;

/**
 * 结束斜体元素回调
 * @param parser 解析器实例
 */
- (void)parserDidEndEmphasis:(CMParser *)parser;

/**
 * 开始粗体元素回调
 * @param parser 解析器实例
 */
- (void)parserDidStartStrong:(CMParser *)parser;

/**
 * 结束粗体元素回调
 * @param parser 解析器实例
 */
- (void)parserDidEndStrong:(CMParser *)parser;

/**
 * 开始删除线元素回调
 * @param parser 解析器实例
 */
- (void)parserDidStartStrikethrough:(CMParser *)parser;

/**
 * 结束删除线元素回调
 * @param parser 解析器实例
 */
- (void)parserDidEndStrikethrough:(CMParser *)parser;

/**
 * 开始链接元素回调
 * @param parser 解析器实例
 * @param URL 链接地址
 * @param title 链接标题
 */
- (void)parser:(CMParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title;

/**
 * 结束链接元素回调
 * @param parser 解析器实例
 * @param URL 链接地址
 * @param title 链接标题
 */
- (void)parser:(CMParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title;

/**
 * 开始图片元素回调
 * @param parser 解析器实例
 * @param URL 图片地址
 * @param title 图片标题
 */
- (void)parser:(CMParser *)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title;

/**
 * 结束图片元素回调
 * @param parser 解析器实例
 * @param URL 图片地址
 * @param title 图片标题
 */
- (void)parser:(CMParser *)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title;

/**
 * 开始脚注定义回调
 * @param parser 解析器实例
 * @param content 脚注内容
 * @param index 引用计数索引
 */
- (void)parser:(CMParser *)parser didStartFootNoteDefination:(NSString *)content refCount:(NSInteger)index;

/**
 * 结束脚注定义回调
 * @param parser 解析器实例
 * @param content 脚注内容
 * @param index 引用计数索引
 */
- (void)parser:(CMParser *)parser didEndFootNoteDefination:(NSString *)content refCount:(NSInteger)index;

/**
 * 开始脚注引用回调
 * @param parser 解析器实例
 * @param index 脚注索引
 * @param title 脚注标题
 * @param content 脚注定义内容
 */
- (void)parser:(CMParser *)parser didStartFootNoteRefIndex:(NSInteger)index title:(NSString *)title defination:(NSString *)content;

/**
 * 结束脚注引用回调
 * @param parser 解析器实例
 * @param index 脚注索引
 * @param title 脚注标题
 * @param content 脚注定义内容
 */
- (void)parser:(CMParser *)parser didEndFootNoteRefIndex:(NSInteger)index title:(NSString *)title defination:(NSString *)content;

/**
 * 开始表格元素回调
 * @param parser 解析器实例
 * @param columns 表格列数
 */
- (void)parser:(CMParser *)parser didStartTableWithNumberOfColumns:(NSUInteger)columns;

/**
 * 结束表格元素回调
 * @param parser 解析器实例
 * @param columns 表格列数
 */
- (void)parser:(CMParser *)parser didEndTableWithNumberOfColumns:(NSUInteger)columns;

/**
 * 开始表格行回调
 * @param parser 解析器实例
 * @param isHeader 是否为表头行
 */
- (void)parser:(CMParser *)parser didStartTableRowIsHeader:(BOOL)isHeader;

/**
 * 结束表格行回调
 * @param parser 解析器实例
 * @param isHeader 是否为表头行
 */
- (void)parser:(CMParser *)parser didEndTableRowIsHeader:(BOOL)isHeader;

/**
 * 开始表格单元格回调
 * @param parser 解析器实例
 * @param alignment 文本对齐方式
 */
- (void)parser:(CMParser *)parser didStartTableCellWithAlignment:(NSTextAlignment)alignment;

/**
 * 结束表格单元格回调
 * @param parser 解析器实例
 * @param alignment 文本对齐方式
 */
- (void)parser:(CMParser *)parser didEndTableCellWithAlignment:(NSTextAlignment)alignment;

/**
 * 发现HTML块回调
 * @param parser 解析器实例
 * @param HTML HTML内容
 */
- (void)parser:(CMParser *)parser foundHTML:(NSString *)HTML;

/**
 * 发现内联HTML回调
 * @param parser 解析器实例
 * @param HTML HTML内容
 */
- (void)parser:(CMParser *)parser foundInlineHTML:(NSString *)HTML;

/**
 * 发现表情符号回调
 * @param parser 解析器实例
 * @param emoji 表情符号
 */
- (void)parser:(CMParser *)parser foundEmoji:(NSString *)emoji;

/**
 * 发现代码块回调
 * @param parser 解析器实例
 * @param code 代码内容
 * @param info 代码语言信息
 */
- (void)parser:(CMParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info;

/**
 * 发现内联代码回调
 * @param parser 解析器实例
 * @param code 代码内容
 */
- (void)parser:(CMParser *)parser foundInlineCode:(NSString *)code;

/**
 * 发现数学公式块回调
 * @param parser 解析器实例
 * @param code 数学公式内容
 */
- (void)parser:(CMParser *)parser foundMathBlock:(NSString *)code;

/**
 * 发现内联数学公式回调
 * @param parser 解析器实例
 * @param code 数学公式内容
 */
- (void)parser:(CMParser *)parser foundInlineMath:(NSString *)code;

/**
 * 发现软换行回调
 * @param parser 解析器实例
 */
- (void)parserFoundSoftBreak:(CMParser *)parser;

/**
 * 发现硬换行回调
 * @param parser 解析器实例
 */
- (void)parserFoundLineBreak:(CMParser *)parser;

/**
 * 开始引用块回调
 * @param parser 解析器实例
 */
- (void)parserDidStartBlockQuote:(CMParser *)parser;

/**
 * 结束引用块回调
 * @param parser 解析器实例
 */
- (void)parserDidEndBlockQuote:(CMParser *)parser;

/**
 * 开始无序列表回调
 * @param parser 解析器实例
 * @param tight 是否为紧凑模式
 */
- (void)parser:(CMParser *)parser didStartUnorderedListWithTightness:(BOOL)tight;

/**
 * 结束无序列表回调
 * @param parser 解析器实例
 * @param tight 是否为紧凑模式
 */
- (void)parser:(CMParser *)parser didEndUnorderedListWithTightness:(BOOL)tight;

/**
 * 开始有序列表回调
 * @param parser 解析器实例
 * @param num 起始编号
 * @param tight 是否为紧凑模式
 */
- (void)parser:(CMParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;

/**
 * 结束有序列表回调
 * @param parser 解析器实例
 * @param num 起始编号
 * @param tight 是否为紧凑模式
 */
- (void)parser:(CMParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight;

/**
 * 开始列表项回调
 * @param parser 解析器实例
 */
- (void)parserDidStartListItem:(CMParser *)parser;

/**
 * 结束列表项回调
 * @param parser 解析器实例
 */
- (void)parserDidEndListItem:(CMParser *)parser;

@end

