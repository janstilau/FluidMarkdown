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
