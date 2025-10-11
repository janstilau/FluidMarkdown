//
//  CMDocument.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cmark-gfm.h"

@class CMNode;

typedef NS_OPTIONS(NSInteger, CMDocumentOptions) {
    /** Default options.
     *  默认选项。
     */
    CMDocumentOptionsDefault = CMARK_OPT_DEFAULT,
    /**
     * Include a `data-sourcepos` attribute on all block elements.
     * 在所有块级元素上包含 `data-sourcepos` 属性。
     */
    CMDocumentOptionsSourcepos = CMARK_OPT_SOURCEPOS,
    /**
     * Render `softbreak` elements as hard line breaks.
     * 将 `softbreak` 元素渲染为硬换行。
     */
    CMDocumentOptionsHardBreaks = CMARK_OPT_HARDBREAKS,
    /** `CMARK_OPT_SAFE` is defined here for API compatibility,
        but it no longer has any effect. "Safe" mode is now the default:
        set `CMARK_OPT_UNSAFE` to disable it.
     *  `CMARK_OPT_SAFE` 在此定义是为了 API 兼容性，
        但它不再有任何效果。"安全"模式现在是默认的：
        设置 `CMARK_OPT_UNSAFE` 来禁用它。
     */
    CMDocumentOptionsSafe = CMARK_OPT_SAFE,
    /** Render `softbreak` elements as spaces.
     *  将 `softbreak` 元素渲染为空格。
     */
    CMDocumentOptionsNoBreaks = CMARK_OPT_NOBREAKS,
    /**
     * Normalize tree by consolidating adjacent text nodes.
     * 通过合并相邻的文本节点来规范化树结构。
     */
    CMDocumentOptionsNormalize = CMARK_OPT_NORMALIZE,
    /** Validate UTF-8 in the input before parsing, replacing illegal
     * sequences with the replacement character U+FFFD.
     *  在解析前验证输入中的 UTF-8，将非法序列替换为替换字符 U+FFFD。
     */
    CMDocumentOptionsValidateUTF8 = CMARK_OPT_VALIDATE_UTF8,
    /**
     * Convert straight quotes to curly, --- to em dashes, -- to en dashes.
     * 将直引号转换为弯引号，--- 转换为长破折号，-- 转换为短破折号。
     */
    CMDocumentOptionsSmart = CMARK_OPT_SMART,
    /** Use GitHub-style <pre lang="x"></pre> tags for code blocks instead of
     * <pre><code class="language-x"></code></pre>
     *  对代码块使用 GitHub 风格的 <pre lang="x"></pre> 标签，而不是
     *  <pre><code class="language-x"></code></pre>
     */
    CMDocumentOptionsGithubPreLang = CMARK_OPT_GITHUB_PRE_LANG,

    /** Be liberal in interpreting inline HTML tags.
     *  在解释内联 HTML 标签时采用宽松模式。
     */
    CMDocumentOptionsLiberalHTMLTag = CMARK_OPT_LIBERAL_HTML_TAG,

    /** Parse footnotes.
     *  解析脚注。
     */
    CMDocumentOptionsFootNotes = CMARK_OPT_FOOTNOTES,
    /** Only parse strikethroughs if surrounded by exactly 2 tildes.
     * Gives some compatibility with redcarpet.
     *  仅当被恰好 2 个波浪号包围时才解析删除线。
     *  提供与 redcarpet 的一些兼容性。
     */
    CMDocumentOptionsStrikeThrough = CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE,

    /** Use style attributes to align table cells instead of align attributes.
     *  使用样式属性而不是对齐属性来对齐表格单元格。
     */
    CMDocumentOptionsTablePreferStyle =  CMARK_OPT_TABLE_PREFER_STYLE_ATTRIBUTES,

    /** Include the remainder of the info string in code blocks in
     * a separate attribute.
     *  将代码块中信息字符串的剩余部分包含在单独的属性中。
     */
    CMDocumentOptionsFullInfo = CMARK_OPT_FULL_INFO_STRING,
    /** Render raw HTML and unsafe links (`javascript:`, `vbscript:`,
     * `file:`, and `data:`, except for `image/png`, `image/gif`,
     * `image/jpeg`, or `image/webp` mime types).  By default,
     * raw HTML is replaced by a placeholder HTML comment. Unsafe
     * links are replaced by empty strings.
     *  渲染原始 HTML 和不安全的链接（`javascript:`、`vbscript:`、
     *  `file:` 和 `data:`，除了 `image/png`、`image/gif`、
     *  `image/jpeg` 或 `image/webp` MIME 类型）。默认情况下，
     *  原始 HTML 被占位符 HTML 注释替换。不安全的链接被空字符串替换。
     */
    CMDocumentOptionsUnsafe = CMARK_OPT_UNSAFE,
    
    CMDocumentOptionsFootNotesWithoutDefinition = CMARK_OPT_FOOTNOTES_WITHOUT_DEFINITION,
};

/**
 *  A Markdown document conforming to the CommonMark spec.
 *  符合 CommonMark 规范的 Markdown 文档。
 */
@interface CMDocument : NSObject

/**
 *  Root node of the document.
 *  文档的根节点。
 */
@property (nonatomic, readonly) CMNode *rootNode;

/**
 *  Initializes the receiver with a string.
 *  使用字符串初始化接收器。
 *
 *  @param string Markdown document string.
 *  @param string Markdown 文档字符串。
 *  @param options Document options.
 *  @param options 文档选项。
 *
 *  @return An initialized instance of the receiver.
 *  @return 接收器的初始化实例。
 */
- (instancetype)initWithString:(NSString *)string options:(CMDocumentOptions)options;

/**
 *  Initializes the receiver with data.
 *  使用数据初始化接收器。
 *
 *  @param data Markdown document data.
 *  @param data Markdown 文档数据。
 *  @param options Document options.
 *  @param options 文档选项。
 *
 *  @return An initialized instance of the receiver.
 *  @return 接收器的初始化实例。
 */
- (instancetype)initWithData:(NSData *)data options:(CMDocumentOptions)options;

/**
 *  Initializes the receiver with data read from a file.
 *  使用从文件读取的数据初始化接收器。
 *
 *  @param path The file path to read from.
 *  @param path 要读取的文件路径。
 *  @param options Document options.
 *  @param options 文档选项。
 *
 *  @return An initialized instance of the receiver, or `nil` if the file
 *  could not be opened.
 *  @return 接收器的初始化实例，如果文件无法打开则返回 `nil`。
 */
- (instancetype)initWithContentsOfFile:(NSString *)path options:(CMDocumentOptions)options;


/**
 *  Base URL for links and images in the document.
 *  文档中链接和图片的基础 URL。
 *
 *  Used as a base when a link destination is a scheme-less path (relative or absolute).
 *  当链接目标是无协议路径（相对或绝对）时用作基础。
 *
 *  If the document has been created using `-[initWithContentsOfFile:options]`, linkBaseURL defaults to the document file's parent directory.
 *  如果文档是使用 `-[initWithContentsOfFile:options]` 创建的，linkBaseURL 默认为文档文件的父目录。
 */
@property (nonatomic) NSURL *linksBaseURL;

/**
 *  Get the absolute URL for a link or image node based on the documents's link base URL if needed
 *  根据文档的链接基础 URL 获取链接或图片节点的绝对 URL（如果需要）
 *
 *  @param node Markdown document data.
 *  @param node Markdown 文档数据。
 *
 *  @return the actual target URL of the node taking into account the documents's link base URL
 *  @return 考虑文档链接基础 URL 的节点实际目标 URL
 */
- (NSURL*) targetURLForNode:(CMNode *)node;

@end
