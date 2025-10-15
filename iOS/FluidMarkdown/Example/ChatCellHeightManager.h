// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AMXMarkdownTextView;

NS_ASSUME_NONNULL_BEGIN

/**
 * 聊天界面 Cell 高度管理器
 * 提供三层缓存机制来优化滚动性能和流式渲染体验
 */
@interface ChatCellHeightManager : NSObject

/**
 * 单例实例
 */
+ (instancetype)sharedManager;

/**
 * 获取静态消息的高度（已完成渲染的历史消息）
 * @param messageId 消息唯一标识
 * @param content 消息内容
 * @param constrainWidth 约束宽度
 * @return 计算得到的高度
 */
- (CGFloat)heightForStaticMessage:(NSString *)messageId 
                          content:(NSString *)content 
                    constrainWidth:(CGFloat)constrainWidth;

/**
 * 获取流式渲染消息的高度（正在渲染中的消息）
 * @param messageId 消息唯一标识
 * @param textView 对应的 AMXMarkdownTextView
 * @return 当前的高度
 */
- (CGFloat)heightForStreamingMessage:(NSString *)messageId 
                            textView:(AMXMarkdownTextView *)textView;

/**
 * 更新流式渲染消息的高度
 * @param height 新的高度
 * @param messageId 消息唯一标识
 */
- (void)updateStreamingHeight:(CGFloat)height forMessageId:(NSString *)messageId;

/**
 * 获取预估高度（用于 UITableView 的 estimatedHeightForRowAtIndexPath）
 * @param messageId 消息唯一标识
 * @return 预估高度
 */
- (CGFloat)estimatedHeightForMessage:(NSString *)messageId;

/**
 * 设置预估高度
 * @param height 预估高度
 * @param messageId 消息唯一标识
 */
- (void)setEstimatedHeight:(CGFloat)height forMessageId:(NSString *)messageId;

/**
 * 标记消息为流式渲染完成状态
 * @param messageId 消息唯一标识
 */
- (void)markMessageAsCompleted:(NSString *)messageId;

/**
 * 清理缓存（内存管理）
 */
- (void)cleanupCache;

/**
 * 清除指定消息的所有缓存
 * @param messageId 消息唯一标识
 */
- (void)clearCacheForMessage:(NSString *)messageId;

@end

NS_ASSUME_NONNULL_END