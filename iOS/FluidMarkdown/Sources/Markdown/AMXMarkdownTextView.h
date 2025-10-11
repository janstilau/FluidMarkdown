// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AntMarkdown/CMAttributedStringRenderer.h>
#import "AMXMarkdownLogModel.h"
#import "AMXMarkdownCustomRenderEventModel.h"

NS_ASSUME_NONNULL_BEGIN;

/**
 Clickable elemant type
 */
typedef enum : NSUInteger {
    AMXMarkdownTapIconLink,
    AMXMarkdownTapLink,
    AMXMarkdownTapImage,
    AMXMarkdownTapTable,
} AMXMarkdownTapType;
/**
 Printing state
 */
typedef enum : NSUInteger {
    AMXMarkdownPrintStateInitial,
    AMXMarkdownPrintStateRunning,
    AMXMarkdownPrintStatePaused,
    AMXMarkdownPrintStateStopped,
} AMXMarkdownPrintState;

/**
 * AMXMarkdownTextView 代理协议
 * 用于处理 Markdown 文本视图的各种事件回调
 */
@protocol AMXMarkdownTextViewDelegate <NSObject>

/**
 * Markdown 视图尺寸变化回调
 * @param size 新的视图尺寸
 */
-(void)onSizeChange:(CGSize)size;

/**
 * Markdown 打印状态变化回调
 * @param state 新的打印状态（开始、进行中、完成等）
 */
-(void)didChangeState:(AMXMarkdownPrintState)state;

/**
 * 点击事件回调
 * @param type 点击类型（链接、图片、代码块等）
 * @param content 点击的内容对象
 * @param gesture 手势识别器
 * @param attachment 文本附件对象
 * @param tapIndex 点击索引
 * @param attrString 属性字符串
 */
-(void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString;

/**
 * 曝光元素更新回调
 * 用于统计和追踪用户浏览行为
 * @param elements 曝光元素数组，包含渲染事件模型
 */
-(void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements;

/**
 * 错误处理回调
 * @param error 发生的错误对象
 */
-(void)onError:(NSError*)error;

@end

@interface AMXMarkdownTextView : UITextView

@property (nonatomic, weak, nullable) id<AMXMarkdownTextViewDelegate> textViewDelegate;
/**
 Time interval of printing（unit：s），default is  0.025
 */
@property (nonatomic, assign) NSTimeInterval typingSpeed;
/**
 The step length of printing，default is 1
 */
@property (nonatomic, assign) NSInteger chunkSize;
/**
 The unique style id of markdownView instance
 */
@property (nonatomic, strong) NSString* styleId;

/**
 Log model
 */
@property (nonatomic, strong) AMXMarkdownLogModel   *logModel;

/**
 Init with frame, it will change while printing
 */
- (instancetype)initWithFrame_ant_mark:(CGRect)frame;
/**
 Start print with content.
 */
- (void)startStreamingWithContent:(NSString*)content;

/**
 Start print with content, and you can set the index of printing action.
 */
- (void)startStreamingWithContent:(NSString*)content printIndex:(NSInteger)printIndex;
/**
 Append markdown data
 */
- (void)addStreamContent:(NSString *)text;
/**
 Pause, it will continue when run continue function with the previous string
 */
- (void)pause;
/**
 Continue, it will continue after pause function with the previous string
 */
- (void)resume;
/**
 Stop print，it will stop and clear previous string data
 */
- (void)stop;
/**
 Reset, all state recover
 */
- (void)reset;

/**
 Render the markdown string directly without printing process
 */
- (void)renderCompleteContent:(NSString *)text;
/**
 Calculate ths markdownView size with string and style
 */
+ (CGSize)caculateContentSize:(NSString *)markdownText constrainSize:(CGSize)constrainSize styleId:(NSString*)styleId;

@end

NS_ASSUME_NONNULL_END
