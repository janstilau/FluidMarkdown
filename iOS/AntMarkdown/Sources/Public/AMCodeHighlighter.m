// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <JavaScriptCore/JavaScriptCore.h>

#import "AMCodeHighlighter.h"
#import "AMTextStyles.h"
#import "CMCascadingAttributeStack.h"
#import "AMUtils.h"

// JS 运行环境与样式资源：用于在 iOS 端执行 highlight.js 并将其输出按默认 CSS 转换为富文本
@interface AMCodeHighlighter ()

@property (nonatomic) JSVirtualMachine *vm;
@property (nonatomic) JSContext *context;
@property (nonatomic) NSString *stylesheet;
@property (nonatomic) AMTextStyles *styles;

// 这里也是没有对应的缓存清理的策略.
@property (nonatomic) NSCache<NSString *, NSAttributedString *> *cachedAttributedText; // 缓存「语言+代码」对应的高亮结果，避免重复计算

@end

@implementation AMCodeHighlighter

+ (BOOL)isSupportCodeLan:(NSString *)codeLan
{
    if([codeLan length] == 0)
        return NO;

    static NSDictionary* codeLanDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codeLanDic = @{
            @"bash":@(YES),
            @"c":@(YES),
            @"cpp":@(YES),
            @"swift":@(YES),
            @"csharp":@(YES),
            @"css":@(YES),
            @"go":@(YES),
            @"java":@(YES),
            @"javascript":@(YES),
            @"json":@(YES),
            @"kotlin":@(YES),
            @"latex":@(YES),
            @"markdown":@(YES),
            @"objectivec":@(YES),
            @"php":@(YES),
            @"python":@(YES),
            @"ruby":@(YES),
            @"sql":@(YES),
            @"typescript":@(YES),
            @"xml":@(YES),
        };
    });
    id obj = [codeLanDic objectForKey:codeLan.lowercaseString];
    return (obj != nil);
}

// 核心：初始化高亮器
// - 创建 JS 虚拟机与上下文
// - 加载 highlight.js 与默认主题 CSS（default.min.css），优先从框架 bundle 获取，找不到时回退主 bundle
// - 设置异常捕获与 NSCache（限定总内存消耗）
- (instancetype)initWithStyles:(AMTextStyles *)styles
{
    self = [super init];
    if (self) {
        self.styles = styles;
        
        self.cachedAttributedText = [[NSCache alloc] init];
        self.cachedAttributedText.name = @"Highlighted Code Cache"; // 方便调试与诊断
        self.cachedAttributedText.totalCostLimit = 10 * 1024 * 1024; // 以富文本长度估算 cost，限制缓存总大小
        
        // 创建 JS 虚拟机与上下文
        self.vm = [[JSVirtualMachine alloc] init];
        self.context = [[JSContext alloc] initWithVirtualMachine:self.vm];
        [self.context setExceptionHandler:^(JSContext *context, JSValue *exception) {
            NSLog(@"JS Exception: %@", exception); // 统一输出 JS 异常，避免静默失败
        }];
        // 加载资源：优先从框架的资源包读取，找不到则回退到主包
        NSString *resourcePath = [[NSBundle bundleForClass:self.class] pathForResource:@"highlightjs" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [NSBundle.mainBundle pathForResource:@"highlightjs" ofType:@"bundle"]; // 回退路径
        }
        NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
        NSURL *jsPath = [resourceBundle URLForResource:@"highlight.min" withExtension:@"js"]; // 高亮引擎
        NSURL *stylePath = [resourceBundle URLForResource:@"default.min" withExtension:@"css"]; // 默认主题样式
        self.stylesheet = [NSString stringWithContentsOfURL:stylePath encoding:NSUTF8StringEncoding error:nil];
        NSString *code = [NSString stringWithContentsOfURL:jsPath encoding:NSUTF8StringEncoding error:nil];
        [self.context evaluateScript:code withSourceURL:jsPath]; // 在 JSContext 中注入 hljs
    }
    return self;
}

// 核心：执行高亮流程
// 步骤：
// 1) 先查缓存（语言+代码）命中则直接返回
// 2) 选择 hljs.highlight（显式语言且受支持）或 hljs.highlightAuto（自动检测）获取 HTML 片段
// 3) 注入默认 CSS 与字体尺寸，包装成完整 <pre><code> HTML
// 4) 使用 NSHTMLTextDocumentType 转为 NSAttributedString，并应用段落样式
// 5) 写入缓存并返回
- (NSAttributedString *)highlightCodeString:(NSString *)code language:(NSString *)language
{
    NSAttributedString *attr = [self cachedAttributedCodeForCode:code language:language];
    if (!attr) {
        JSValue *hljs = self.context[@"hljs"];
        JSValue *result = nil;
        // The result of calling the value as a constructor, or nil if the value cannot be treated as a JavaScript constructor.
        if (language.length && [AMCodeHighlighter isSupportCodeLan:language]) {
            // 显式指定语言且受支持：可获得更准确的高亮
            result = [hljs invokeMethod:@"highlight" withArguments:@[code, @{
                @"language": language
            }]];
        } else {
            // 未指定/不支持：回退到自动检测
            result = [hljs invokeMethod:@"highlightAuto" withArguments:@[code]];
        }
        NSString * value = [result[@"value"] toString]; // 高亮后的 HTML 片段
        // 字体：以样式中的 codeBlock 字体为基准，并附加自定义的字体属性（如特性）
        UIFont *font = self.styles.codeBlockAttributes.stringAttributes[NSFontAttributeName];
        if ([font isKindOfClass:[UIFont class]] && self.styles.codeBlockAttributes.fontAttributes.count > 0) {
            font = [font fontByAddingCMAttributes:self.styles.codeBlockAttributes.fontAttributes];
        }
        // 拼装完整 HTML（注入默认 CSS 与字号），供 NSHTML 解析
        NSError *error = nil;
        NSString *html = [NSString stringWithFormat:
                          @"<style>"
                          @"code{font-size: %.2fpx}"
                          @"%@"
                          @"</style>"
                          @"<pre><code class=\"hljs\">"
                          @"%@"
                          @"</code></pre>", font ? font.pointSize : 13, self.stylesheet, value];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                                                   options:@{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, // 关键：按 HTML 文档解析
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
        }
                                                                        documentAttributes:nil
                                                                                     error:&error];
        /*
         本质原因
         - NSAttributedString 内置了一个“HTML 导入器”。当你用 initWithData:options: 并设置 NSDocumentTypeDocumentAttribute = NSHTMLTextDocumentType 时，系统会把这份 HTML 解析成文本运行（text runs），并把标签/CSS 转成对应的富文本属性，最终得到一个 NSAttributedString / NSMutableAttributedString 。

         - 解析 HTML（构建简化的 DOM）。
         - 应用可支持的 CSS（内联 style 和文内 <style> ），计算每段文字的最终样式。
         - 按样式切分成多个文本段，映射为 NSAttributedString 的属性：
           - 颜色/字体： NSForegroundColorAttributeName 、 NSFontAttributeName
           - 粗体/斜体： UIFontDescriptorTraits （strong/b/italic/em）
           - 下划线/删除线： NSUnderlineStyleAttributeName 、 NSStrikethroughStyleAttributeName
           - 段落： NSParagraphStyle （对齐、缩进、行距、段前后距）
           - 链接： NSLinkAttributeName （ <a href> ）
           - 图片： NSTextAttachment （ <img> ）
         - 返回你构造的可变子类实例（你用了 NSMutableAttributedString alloc ），因此结果是可变的。
         为何你的代码能高亮

         - 你把 highlight.js 产生的类名（如 hljs-keyword ）对应的 CSS 放进 <style> ，系统在导入时读取这些规则，把不同 <span class="..."> 的样式转成文字颜色/字体等属性。
         - <pre><code> 让换行和空白按“代码块”呈现（白空格保留、行内样式应用），再统一用 code{font-size: ...} 或设置 font-family 达到等宽效果。
         */
        // 去掉末尾换行，避免影响布局高度
        if ([attri.mutableString hasSuffix:@"\n"]) {
            [attri.mutableString deleteCharactersInRange:NSMakeRange(attri.length - 1, 1)];
        }
        // 应用段落样式（缩进、行距等来自 AMTextStyles）
        NSParagraphStyle *paragraph = [NSParagraphStyle paragraphStyleWithCMAttributes:self.styles.codeBlockAttributes.paragraphStyleAttributes];
        if (paragraph) {
            [attri addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attri.length)];
        }
        // 写入缓存，提升后续同内容渲染性能
        attr = [attri copy];
        // 这个 Code 缓存的时候, 是按照
        @synchronized (self) {
            if (attr) {
                NSString *cacheKey = [NSString stringWithFormat:@"%@: %@", language, code];
                [self.cachedAttributedText setObject:attr
                                              forKey:cacheKey
                                                cost:attr.length]; // 以长度估算 cost
            } else {
                AMLogDebug(@"fail to highlight code: %@", code);
            }
        }
    }
    return attr;
}

// 仅从缓存读取高亮结果（线程安全）
- (NSAttributedString *)cachedAttributedCodeForCode:(NSString *)code language:(NSString *)language
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@:%@", language, code];
    @synchronized (self) {
        return [self.cachedAttributedText objectForKey:cacheKey];
    }
}

@end
