// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "ChatCellHeightManager.h"
#import "AMXMarkdownTextView.h"

static const NSInteger kMaxCachedHeights = 50;
static const NSInteger kMaxEstimatedHeights = 100;
static const CGFloat kDefaultEstimatedHeight = 100.0;
static const CGFloat kCellPadding = 10.0;

@interface ChatCellHeightManager ()

// 第一层：预估高度（快速返回，避免卡顿）
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *estimatedHeights;

// 第二层：精确高度缓存（已计算完成的）
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *cachedHeights;

// 第三层：流式渲染中的动态高度
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *streamingHeights;

// 消息创建时间（用于缓存清理）
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSDate*> *messageTimestamps;

@end

@implementation ChatCellHeightManager

+ (instancetype)sharedManager {
    static ChatCellHeightManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChatCellHeightManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _estimatedHeights = [[NSMutableDictionary alloc] init];
        _cachedHeights = [[NSMutableDictionary alloc] init];
        _streamingHeights = [[NSMutableDictionary alloc] init];
        _messageTimestamps = [[NSMutableDictionary alloc] init];
        
        // 监听内存警告
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (CGFloat)heightForStaticMessage:(NSString *)messageId 
                          content:(NSString *)content 
                    constrainWidth:(CGFloat)constrainWidth {
    
    // 1. 先查精确高度缓存
    NSNumber *cachedHeight = self.cachedHeights[messageId];
    if (cachedHeight) {
        return cachedHeight.floatValue;
    }
    
    // 2. 使用 AMXMarkdownTextView 的静态计算方法
    CGSize constrainSize = CGSizeMake(constrainWidth, CGFLOAT_MAX);
    CGSize contentSize = [AMXMarkdownTextView
                          caculateContentSize:content
                                                    constrainSize:constrainSize
                                                          styleId:@"chat"];
    
    CGFloat totalHeight = contentSize.height + kCellPadding;
    
    // 3. 缓存结果
    self.cachedHeights[messageId] = @(totalHeight);
    self.messageTimestamps[messageId] = [NSDate date];
    
    // 4. 同时设置预估高度
    self.estimatedHeights[messageId] = @(totalHeight);
    
    NSLog(@"更新静态高度 %@ 为 %@", messageId, @(totalHeight));
    
    return totalHeight;
}

- (CGFloat)heightForStreamingMessage:(NSString *)messageId 
                            textView:(AMXMarkdownTextView *)textView {
    
    NSNumber *cachedHeight = self.streamingHeights[messageId];
    if (cachedHeight) {
        return cachedHeight.floatValue;
    }
    // 流式渲染中，使用实时计算
    CGSize limitSize = CGSizeMake(textView.frame.size.width, CGFLOAT_MAX);
    CGSize contentSize = [AMXMarkdownTextView calculateSizeWithLayoutManager:textView limitSize:limitSize];
    
    CGFloat totalHeight = contentSize.height + kCellPadding;
    
    // 缓存当前高度（用于平滑动画）
    self.streamingHeights[messageId] = @(totalHeight);
    self.messageTimestamps[messageId] = [NSDate date];
    
    // 更新预估高度
    self.estimatedHeights[messageId] = @(totalHeight);
    
    return totalHeight;
}

- (void)updateStreamingHeight:(CGFloat)height forMessageId:(NSString *)messageId {
    self.streamingHeights[messageId] = @(height);
    self.estimatedHeights[messageId] = @(height);
    self.messageTimestamps[messageId] = [NSDate date];
}

- (CGFloat)estimatedHeightForMessage:(NSString *)messageId {
    NSNumber *estimated = self.estimatedHeights[messageId];
    return estimated ? estimated.floatValue : kDefaultEstimatedHeight;
}

- (void)setEstimatedHeight:(CGFloat)height forMessageId:(NSString *)messageId {
    self.estimatedHeights[messageId] = @(height);
    self.messageTimestamps[messageId] = [NSDate date];
}

- (void)markMessageAsCompleted:(NSString *)messageId {
    // 将流式渲染的高度移动到精确缓存中
    NSNumber *streamingHeight = self.streamingHeights[messageId];
    if (streamingHeight) {
        [self.streamingHeights removeObjectForKey:messageId];
    }
}

- (void)clearCacheForMessage:(NSString *)messageId {
    [self.estimatedHeights removeObjectForKey:messageId];
    [self.cachedHeights removeObjectForKey:messageId];
    [self.streamingHeights removeObjectForKey:messageId];
    [self.messageTimestamps removeObjectForKey:messageId];
}

#pragma mark - Cache Management

- (void)cleanupCache {
    [self cleanupCacheWithMaxCount:kMaxCachedHeights forDictionary:self.cachedHeights];
    [self cleanupCacheWithMaxCount:kMaxEstimatedHeights forDictionary:self.estimatedHeights];
    
    // 清理对应的时间戳
    NSMutableSet *allValidKeys = [NSMutableSet set];
    [allValidKeys addObjectsFromArray:self.cachedHeights.allKeys];
    [allValidKeys addObjectsFromArray:self.estimatedHeights.allKeys];
    [allValidKeys addObjectsFromArray:self.streamingHeights.allKeys];
    
    NSArray *timestampKeys = self.messageTimestamps.allKeys;
    for (NSString *key in timestampKeys) {
        if (![allValidKeys containsObject:key]) {
            [self.messageTimestamps removeObjectForKey:key];
        }
    }
}

- (void)cleanupCacheWithMaxCount:(NSInteger)maxCount forDictionary:(NSMutableDictionary *)dictionary {
    if (dictionary.count <= maxCount) {
        return;
    }
    
    // 按时间排序，保留最新的
    NSArray *sortedKeys = [dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        NSDate *date1 = self.messageTimestamps[key1] ?: [NSDate distantPast];
        NSDate *date2 = self.messageTimestamps[key2] ?: [NSDate distantPast];
        return [date2 compare:date1]; // 降序，最新的在前
    }];
    
    // 移除多余的缓存
    for (NSInteger i = maxCount; i < sortedKeys.count; i++) {
        [dictionary removeObjectForKey:sortedKeys[i]];
    }
}

- (void)handleMemoryWarning {
    // 收到内存警告时，清理一半的缓存
    [self cleanupCacheWithMaxCount:kMaxCachedHeights / 2 forDictionary:self.cachedHeights];
    [self cleanupCacheWithMaxCount:kMaxEstimatedHeights / 2 forDictionary:self.estimatedHeights];
}

@end
