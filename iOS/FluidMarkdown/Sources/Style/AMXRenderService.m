// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXRenderService.h"
// AMXMarkdownExtendEngine 是一个内部类, 直接就隐藏在 M 文件里面了
/**
 * AMX Markdown 扩展引擎
 * 内部类，用于管理自定义样式配置的存储和检索
 */
@interface AMXMarkdownExtendEngine : NSObject
{
    @private
    dispatch_semaphore_t _configMapLock;  // 线程安全锁
}
@property (nonatomic, strong) NSMutableDictionary *styleConfigMap;  // 样式配置映射表

/**
 * 设置自定义样式配置
 * @param styleConfig 样式配置对象
 * @param styleId 样式唯一标识符
 */
-(void)setCustomStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId;

/**
 * 获取指定ID的样式配置
 * @param styleId 样式唯一标识符
 * @return 对应的样式配置对象，不存在时返回nil
 */
-(AMXMarkdownStyleConfig*)getStyleConfigWithId:(NSString*)styleId;
@end

@implementation AMXMarkdownExtendEngine
-(instancetype)init {
    if (self = [super init]) {
        _configMapLock = dispatch_semaphore_create(1);
        _styleConfigMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setCustomStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId {
    dispatch_semaphore_wait(self->_configMapLock, DISPATCH_TIME_FOREVER);
    self.styleConfigMap[styleId] = styleConfig;
    dispatch_semaphore_signal(self->_configMapLock);
}
-(AMXMarkdownStyleConfig*)getStyleConfigWithId:(NSString*)styleId {
    dispatch_semaphore_wait(self->_configMapLock, DISPATCH_TIME_FOREVER);
    AMXMarkdownStyleConfig* config = self.styleConfigMap[styleId];
    dispatch_semaphore_signal(self->_configMapLock);
    return config;
}
@end
@interface AMXRenderService()
@property (nonatomic, strong)AMXMarkdownExtendEngine* extendEngine;
@end
@implementation AMXRenderService
+ (instancetype)shared {
    static AMXRenderService *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = AMXRenderService.new;
    });
    return _shared;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        self.extendEngine = [[AMXMarkdownExtendEngine alloc] init];
    }
    return self;
}
-(void)setMarkdownStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId
{
    [self.extendEngine setCustomStyleWithId:styleConfig styleId:styleId];
}
-(AMXMarkdownStyleConfig*)getMarkdownStyleWithId:(NSString*)styleId {
    return [self.extendEngine getStyleConfigWithId:styleId];
}
@end
