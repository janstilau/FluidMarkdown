// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AntMarkdown.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * AMXMarkdownCodeViewAttachment 是 AMCodeViewAttachment 的子类，专门用于 Markdown 代码块的渲染。
 * 继承了父类的语法高亮和多语言支持功能，针对 Markdown 解析进行了优化。
 * 主要用于将 Markdown 代码块语法转换为可视化的代码显示组件。
 * 
 * 对应的 Markdown 语法示例：
 * ````
 * ```objc
 * @interface MyClass : NSObject
 * @property (nonatomic, strong) NSString *name;
 * - (void)doSomething;
 * @end
 * ```
 * 
 * ```json
 * {
 *   "name": "John",
 *   "age": 30,
 *   "city": "New York"
 * }
 * ```
 * 
 * ```bash
 * #!/bin/bash
 * echo "Hello World"
 * ls -la
 * ```
 * ````
 */
@interface AMXMarkdownCodeViewAttachment : AMCodeViewAttachment<AMCodeAttachmentBuilder>

@end

NS_ASSUME_NONNULL_END
