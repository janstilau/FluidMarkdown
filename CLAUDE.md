# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码仓库中工作时提供指导。

## 项目概述

FluidMarkdown 是一个跨平台（iOS 和 Android）Markdown 渲染库，专为 AI 驱动应用中的流式内容显示而设计。该库支持 Markdown 内容的渐进式渲染，支持核心 Markdown 语法和选定的 HTML 标签。

## 仓库结构

### iOS 平台
- **iOS/AntMarkdown/** - 基于 CommonMark 的核心 Markdown 解析和渲染模块
- **iOS/FluidMarkdown/** - 流式输出组件和示例应用
- **iOS/FluidMarkdown.xcworkspace** - 主要 iOS 工作空间（使用这个，而不是 .xcodeproj）

### Android 平台
- **Android/AntFluid/** - 主要 Android 项目，包含：
  - **fluid-markdown/** - 流式输出组件
  - **markwon-**** - 基于 Markwon 库的语法解析和样式渲染模块
  - **app-sample/** - 演示用法的示例应用

## 构建和运行命令

### iOS
```bash
# 导航到 iOS 目录
cd iOS

# 打开工作空间（CocoaPods 依赖必需）
open FluidMarkdown.xcworkspace

# 从 Xcode 构建和运行
# 目标：FluidMarkdown
# 配置：Debug/Release
```

### Android
```bash
# 导航到 Android 目录
cd Android/AntFluid

# 构建项目
./gradlew build

# 运行示例应用
./gradlew :app-sample:installDebug

# 构建特定模块
./gradlew :fluid-markdown:build
./gradlew :markwon-core:build
```

## 核心架构组件

### iOS 架构
- **AMXMarkdownWidget** - 流式功能的主要公共 API 头文件
- **AMXMarkdownTextView** - 流式 Markdown 内容的核心文本视图
- **AMXRenderService** - 样式配置和渲染管理
- **AntMarkdown** - 提供基于 CommonMark 解析的静态库
- **外部依赖**：
  - CocoaMarkdown（MIT 许可证）- Markdown 解析
  - iosMath（MIT 许可证）- 数学公式渲染
  - cmark-gfm（MIT 许可证）- CommonMark 规范实现

### Android 架构
- **PrinterMarkDownTextView** - 主要流式 TextView 组件
- **AFMInitializer** - 全局初始化（必须调用一次）
- **MarkdownParser** - 基于 Markwon 的核心解析逻辑
- **MarkdownStyles** - 样式配置系统
- **ElementClickEventCallback** - 点击事件处理接口
- **核心模块**：
  - markwon-core - 基础 Markwon 功能
  - markwon-ext-* - 表格、语法高亮等扩展模块
  - fluid-markdown - 主要流式组件

## 初始化模式

### iOS
```objectivec
// 初始化样式
AMXMarkdownStyleConfig* config = [AMXMarkdownStyleConfig defaultConfig];
[[AMXRenderService shared] setMarkdownStyleWithId:config styleId:@"demo"];

// 开始流式渲染
AMXMarkdownTextView* textView = [[AMXMarkdownTextView alloc] initWithFrame:frame];
[textView startStreamingWithContent:@"初始内容"];
[textView addStreamContent:@"追加内容"];
```

### Android
```kotlin
// 全局初始化（必需一次）
AFMInitializer.init(context, backgroundTaskHandler, imageHandler, logHandler)

// 配置组件
val markdownTextView = findViewById<PrinterMarkDownTextView>(R.id.markdown_view)
val styles = MarkdownStyles.getDefaultStyles()
markdownTextView.init(styles, elementClickEventCallback)

// 开始流式渲染或设置内容
markdownTextView.startPrinting(content)
// 或
markdownTextView.setMarkdownText(content)
```

## 已知限制

- 表格内的可点击元素显示为纯文本
- 不支持表格单元格内的嵌套 HTML 标签
- Android 表格可能溢出容器（不支持水平滚动）

## 开发指南

- iOS：核心组件使用 Objective-C，保持与现有 Cocoa API 的兼容性
- Android：新代码使用 Kotlin，现有 Markwon 集成使用 Java
- 两个平台：保持流式渲染性能特征
- 样式自定义应可扩展且不破坏现有 API

## 示例应用

### iOS
- **StreamPreviewViewController** - 基础流式输出演示
- **AIChatViewController** - 使用静态数据的 AI 对话场景

### Android
- **MainActivity** - 普通渲染模式
- **PrinterActivity** - 流式打印演示
- **ListActivity** - 列表格式流式打印