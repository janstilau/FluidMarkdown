// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "StreamingChatViewController.h"
#import "ChatCellHeightManager.h"
#import "AMXMarkdownTextView.h"
#import "AMXRenderService.h"
#import "UIColor+Random.h"

static CGFloat kContentWidth = 330;

// 消息类型枚举
typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeUser = 0,
    MessageTypeAI = 1
};

// 消息模型
@interface ChatMessage : NSObject
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) BOOL isStreaming; // 是否还在接收流式网络输入
@property (nonatomic, assign) BOOL isRenderingComplete; // AMXMarkdownTextView是否已完成渲染
@property (nonatomic, strong) NSDate *timestamp;
@end

@implementation ChatMessage
@end

// 用户消息 Cell
@interface UserMessageCell : UITableViewCell
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *bubbleView;
@end

@implementation UserMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 气泡背景
    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.backgroundColor = [UIColor systemBlueColor];
    self.bubbleView.layer.cornerRadius = 12;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bubbleView];
    
    // 消息文本
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:16];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.messageLabel];
    
    // 约束设置
    [NSLayoutConstraint activateConstraints:@[
        // 气泡约束
        [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        [self.bubbleView.widthAnchor constraintLessThanOrEqualToConstant:280],
        
        // 文本约束
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:12],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-12],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:0],
        [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-0]
    ]];
    
//    self.backgroundColor = [UIColor randomColor];
//    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageLabel.text = nil;
}

- (void)configureWithMessage:(ChatMessage *)message {
    self.messageLabel.text = message.content;
}

@end

@interface BubbleView: UIView
@end
@implementation BubbleView

@end

// AI 消息 Cell
@interface AIMessageCell : UITableViewCell <AMXMarkdownTextViewDelegate>
@property (nonatomic, strong) AMXMarkdownTextView *markdownView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) ChatMessage *message;
@end

@implementation AIMessageCell


/**
 * Markdown 视图尺寸变化回调
 * @param size 新的视图尺寸
 */
-(void)onSizeChange:(CGSize)size {
    
}

/**
 * Markdown 打印状态变化回调
 * @param state 新的打印状态（开始、进行中、完成等）
 */
-(void)didChangeState:(AMXMarkdownPrintState)state {
    
}

/**
 * 点击事件回调
 * @param type 点击类型（链接、图片、代码块等）
 * @param content 点击的内容对象
 * @param gesture 手势识别器
 * @param attachment 文本附件对象
 * @param tapIndex 点击索引
 * @param attrString 属性字符串
 */
-(void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString {
    
}

/**
 * 曝光元素更新回调
 * 用于统计和追踪用户浏览行为
 * @param elements 曝光元素数组，包含渲染事件模型
 */
-(void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements {
    
}

/**
 * 错误处理回调
 * @param error 发生的错误对象
 */
-(void)onError:(NSError*)error {
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 气泡背景
    self.bubbleView = [[BubbleView alloc] init];
    self.bubbleView.backgroundColor = [UIColor systemGray6Color];
    self.bubbleView.layer.cornerRadius = 12;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bubbleView];
    
    // Markdown 视图
    self.markdownView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, 300, 100)];
    self.markdownView.backgroundColor = [UIColor clearColor];
    self.markdownView.translatesAutoresizingMaskIntoConstraints = NO;
    self.markdownView.styleId = @"chat";
    self.markdownView.textViewDelegate = self;
    
    // 关键修复：设置与高度计算一致的内边距配置
    self.markdownView.textContainerInset = UIEdgeInsetsZero;
    self.markdownView.textContainer.lineFragmentPadding = 0;
    
    // 关键修复：禁用用户交互，避免阻塞tableView滑动
    self.markdownView.scrollEnabled = false;
    [self.bubbleView addSubview:self.markdownView];
    
    // 约束设置
    [NSLayoutConstraint activateConstraints:@[
        // 气泡约束
        [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0],
        [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0],
        [self.bubbleView.widthAnchor constraintLessThanOrEqualToConstant:kContentWidth],
        
        // Markdown 视图约束
        [self.markdownView.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:12],
        [self.markdownView.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-12],
        [self.markdownView.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:5],
        [self.markdownView.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-5]
    ]];
    
//    self.backgroundColor = [UIColor randomColor];
//    self.contentView.backgroundColor = self.backgroundColor;
    
    self.bubbleView.layer.borderColor = UIColor.redColor.CGColor;
    self.bubbleView.layer.borderWidth = 1;
    
    self.markdownView.layer.borderColor = UIColor.orangeColor.CGColor;
    self.markdownView.layer.borderWidth = 1;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    NSLog(@"♻️ AIMessageCell prepareForReuse called");
    
    // 检查是否有挂载的共享markdownView，如果有则unmount
    if (self.bubbleView.subviews.count > 1) {
        // 查找是否有共享的markdownView
        for (UIView *subview in self.bubbleView.subviews) {
            if ([subview isKindOfClass:[AMXMarkdownTextView class]] && subview != self.markdownView) {
                NSLog(@"🔌 Found mounted shared markdownView, unmounting...");
                [self unmountSharedMarkdownView:(AMXMarkdownTextView *)subview];
                break;
            }
        }
    }
    
    // 重置 markdownView 状态
    [self.markdownView reset];
    self.markdownView.textViewDelegate = nil;
    
    // 清理消息引用和高度缓存
    if (self.message) {
        // 如果消息已完成渲染，清理缓存以避免复用时的高度错误
        if (self.message.isRenderingComplete) {
            [[ChatCellHeightManager sharedManager] clearCacheForMessage:self.message.messageId];
        }
        self.message = nil;
    }
    
    NSLog(@"✅ AIMessageCell reset completed");
}

- (void)configureWithMessage:(ChatMessage *)message {
    NSLog(@"🔧 Configuring AIMessageCell with message: %@, isStreaming: %d, isRenderingComplete: %d", 
          message.messageId, message.isStreaming, message.isRenderingComplete);
    
    self.message = message;
    
    if (message.isStreaming || !message.isRenderingComplete) {
        NSLog(@"🔄 Cell configured for streaming/rendering mode - will be mounted by ViewController");
        // 流式渲染模式或渲染未完成：隐藏自己的markdownView，等待ViewController挂载共享的markdownView
        self.markdownView.hidden = YES;
    } else {
        NSLog(@"📝 Rendering complete content in cell's own markdownView");
        // 渲染完成：显示自己的markdownView并渲染完整内容
        self.markdownView.hidden = NO;
        [self.markdownView renderCompleteContent:message.content];
    }
}

// 挂载共享的流式渲染markdownView到当前cell
- (void)mountSharedMarkdownView:(AMXMarkdownTextView *)sharedMarkdownView {
    NSLog(@"🔗 Mounting shared markdown view to cell");
    
    // 隐藏自己的markdownView
    self.markdownView.hidden = YES;
    
    // 将共享的markdownView添加到bubbleView中
    sharedMarkdownView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:sharedMarkdownView];
    
    // 更新共享markdownView的frame以匹配约束宽度
    CGFloat constrainWidth = kContentWidth - 24; // 与heightForRowAtIndexPath保持一致
    CGRect newFrame = sharedMarkdownView.frame;
    newFrame.size.width = constrainWidth;
    sharedMarkdownView.frame = newFrame;
    
    // 设置约束，与原来的markdownView位置相同
    [NSLayoutConstraint activateConstraints:@[
        [sharedMarkdownView.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:12],
        [sharedMarkdownView.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-12],
        [sharedMarkdownView.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:5],
        [sharedMarkdownView.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-5]
    ]];
}

// 卸载共享的流式渲染markdownView
- (void)unmountSharedMarkdownView:(AMXMarkdownTextView *)sharedMarkdownView {
    NSLog(@"🔌 Unmounting shared markdown view from cell");
    
    // 隐藏并从bubbleView中移除共享的markdownView
    [sharedMarkdownView removeFromSuperview];
    NSLog(@"✅ Shared markdown view unmounted successfully");
}

@end

// 主控制器
@interface StreamingChatViewController () <UITableViewDataSource, UITableViewDelegate, AMXMarkdownTextViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *inputContainer;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) NSMutableArray<ChatMessage *> *messages;
@property (nonatomic, strong) ChatCellHeightManager *heightManager;

// 数据文件相关
@property (nonatomic, strong) NSArray<NSString *> *dataFilePaths;
@property (nonatomic, assign) NSInteger currentDataFileIndex;

// 流式渲染相关
@property (nonatomic, strong) ChatMessage *currentStreamingMessage;
@property (nonatomic, strong) NSString *streamingContent;
@property (nonatomic, assign) NSInteger streamingIndex;
@property (nonatomic, strong) NSTimer *streamingTimer;
@property (nonatomic, assign) BOOL isStreaming;

// 专用的流式渲染 AMXMarkdownTextView（不在cell中，在ViewController层面）
@property (nonatomic, strong) AMXMarkdownTextView *sharedStreamingMarkdownView;
@property (nonatomic, strong) AIMessageCell *currentMountedCell;

// 尺寸变化优化相关
@property (nonatomic, assign) CGSize lastRecordedSize;
@end

@implementation StreamingChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化尺寸记录
    self.lastRecordedSize = CGSizeZero;
    
    // 设置 Markdown 样式
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:@"chat"];
    [self setupUI];
    [self setupData];
    
    // 添加 tableView contentSize 监听
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"流式聊天";
    
    // 导航栏按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearMessages)];
    
    // TableView
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // 注册 Cell
    [self.tableView registerClass:[UserMessageCell class] forCellReuseIdentifier:@"UserMessageCell"];
    [self.tableView registerClass:[AIMessageCell class] forCellReuseIdentifier:@"AIMessageCell"];
    
    // 初始化共享的流式渲染 AMXMarkdownTextView
    [self setupSharedStreamingMarkdownView];
    
    // 输入容器
    self.inputContainer = [[UIView alloc] init];
    self.inputContainer.backgroundColor = [UIColor systemGray6Color];
    self.inputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputContainer];
    
    // 发送按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:self.sendButton];
    
    
    // 停止按钮
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stopStreaming) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.stopButton.hidden = YES;
    [self.inputContainer addSubview:self.stopButton];
    
    // 约束设置（双按钮布局：左侧发送，右侧停止）
    [NSLayoutConstraint activateConstraints:@[
        // TableView
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.inputContainer.topAnchor constant:-20],
        
        // 输入容器
        [self.inputContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.inputContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.inputContainer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.inputContainer.heightAnchor constraintEqualToConstant:60],
        
        // 发送按钮（左侧）
        [self.sendButton.leadingAnchor constraintEqualToAnchor:self.inputContainer.leadingAnchor constant:16],
        [self.sendButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.sendButton.widthAnchor constraintEqualToConstant:60],
        [self.sendButton.heightAnchor constraintEqualToConstant:36],
        
        // 停止按钮（右侧）
        [self.stopButton.trailingAnchor constraintEqualToAnchor:self.inputContainer.trailingAnchor constant:-16],
        [self.stopButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.stopButton.widthAnchor constraintEqualToConstant:60],
        [self.stopButton.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)setupData {
    self.messages = [[NSMutableArray alloc] init];
    self.heightManager = [ChatCellHeightManager sharedManager];
    self.currentDataFileIndex = 0;
    
//    NSMutableArray *paths = [NSMutableArray array];
//    for (NSInteger i = 1; i <= 7; i++) {
//        NSString *fileName = [NSString stringWithFormat:@"data%ld", (long)i];
//        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
//        if (path) [paths addObject:path];
//    }
//    self.dataFilePaths = [paths copy];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSInteger i = 1; i <= 20; i++) {
        NSString *fileName = [NSString stringWithFormat:@"latex%ld", (long)i];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
        if (path) [paths addObject:path];
    }
    self.dataFilePaths = [paths copy];
    
    NSLog(@"📁 Setup data files, total count: %ld", (long)self.dataFilePaths.count);
}

- (void)setupSharedStreamingMarkdownView {
    // 创建共享的流式渲染 AMXMarkdownTextView，设置合适的初始frame
    CGFloat constrainWidth = kContentWidth - 24; // 气泡宽度减去内边距，与heightForRowAtIndexPath保持一致
    self.sharedStreamingMarkdownView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, constrainWidth, 100)];
    self.sharedStreamingMarkdownView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.5];
    self.sharedStreamingMarkdownView.delegate = self;
    self.sharedStreamingMarkdownView.backgroundColor = [UIColor clearColor];
    self.sharedStreamingMarkdownView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sharedStreamingMarkdownView.styleId = @"chat";
    self.sharedStreamingMarkdownView.panGestureRecognizer.enabled = false;
    
    // 关键修复：设置与高度计算一致的内边距配置
    self.sharedStreamingMarkdownView.textContainerInset = UIEdgeInsetsZero;
    self.sharedStreamingMarkdownView.textContainer.lineFragmentPadding = 0;
    
    // 关键修复：完全禁用用户交互，避免阻塞tableView滑动
    self.sharedStreamingMarkdownView.scrollEnabled = NO;
    
    // 移除所有手势识别器，避免干扰tableView的滑动
    for (UIGestureRecognizer *gesture in self.sharedStreamingMarkdownView.gestureRecognizers) {
        [self.sharedStreamingMarkdownView removeGestureRecognizer:gesture];
    }
    
    self.sharedStreamingMarkdownView.layer.borderColor = [[UIColor purpleColor] CGColor];
    self.sharedStreamingMarkdownView.layer.borderWidth = 2;
}

#pragma mark - Actions

- (void)sendMessage {
    NSLog(@"📤 Send button pressed, current file index: %ld", (long)self.currentDataFileIndex);
    
    // 检查是否正在流式传输
    if (self.isStreaming) {
        NSLog(@"⚠️ Already streaming, ignoring send request");
        return;
    }
    
    // 获取当前数据文件路径
    NSString *currentFilePath = self.dataFilePaths[self.currentDataFileIndex];
    NSLog(@"📁 Using data file: %@", [currentFilePath lastPathComponent]);
    
    // 添加用户消息 - 显示当前发送的是第几条数据
    ChatMessage *userMessage = [[ChatMessage alloc] init];
    userMessage.messageId = [self generateMessageId];
    userMessage.content = [NSString stringWithFormat:@"发送第 %ld 条数据 (%@)", 
                          (long)self.currentDataFileIndex + 1, 
                          [currentFilePath lastPathComponent]];
    userMessage.type = MessageTypeUser;
    userMessage.isStreaming = NO;
    userMessage.isRenderingComplete = YES; // 用户消息不需要渲染
    userMessage.timestamp = [NSDate date];
    
    [self.messages addObject:userMessage];
    
    // 刷新 TableView
    [self.tableView reloadData];
    [self scrollToBottom];
    
    // 开始 AI 回复
    [self startAIResponse];
}

- (void)startAIResponse {
    NSLog(@"🤖 Starting AI response");
    
    // 创建 AI 消息
    ChatMessage *aiMessage = [[ChatMessage alloc] init];
    aiMessage.messageId = [self generateMessageId];
    aiMessage.content = @"";
    aiMessage.type = MessageTypeAI;
    aiMessage.isStreaming = YES;
    aiMessage.isRenderingComplete = NO; // 初始状态为未完成渲染
    aiMessage.timestamp = [NSDate date];
    
    NSLog(@"📝 Created AI message: %@, isStreaming: %d", aiMessage.messageId, aiMessage.isStreaming);
    
    [self.messages addObject:aiMessage];
    self.currentStreamingMessage = aiMessage;
    
    // 显示停止按钮，隐藏发送按钮
    self.sendButton.hidden = YES;
    self.stopButton.hidden = NO;
    
    // 刷新 TableView
    NSLog(@"🔄 Reloading table view, messages count: %ld", (long)self.messages.count);
    [self.tableView reloadData];
//    [self scrollToBottom];
    
    NSLog(@"📍 Scrolled to last message");
    
    // 开始流式渲染
    [self startStreamingFromCurrentDataFile];
}

- (void)startStreamingFromCurrentDataFile {
    NSLog(@"🚀 Starting streaming from data file, index: %ld", (long)self.currentDataFileIndex);
    
    NSString *filePath = self.dataFilePaths[self.currentDataFileIndex];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"📖 Read content from file: %@, length: %ld", [filePath lastPathComponent], (long)content.length);
    NSLog(@"📄 Content preview: %@", [content substringToIndex:MIN(100, content.length)]);
    
    if (content.length > 0) {
        // 初始化共享的流式渲染markdownView
        [self.sharedStreamingMarkdownView reset];
        self.sharedStreamingMarkdownView.textViewDelegate = self;
        [self.sharedStreamingMarkdownView startStreamingWithContent:@""];
        
        NSLog(@"🔧 Shared streaming markdown view initialized and started");
        
        // 开始流式渲染
        self.streamingContent = content;
        self.streamingIndex = 0;
        self.isStreaming = YES;
        
        NSLog(@"⏰ Starting streaming timer");
        
        // 启动定时器进行流式渲染
        self.streamingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(streamNextChunk) userInfo:nil repeats:YES];
    } else {
        NSLog(@"❌ 无法读取文件内容: %@", filePath);
        // 如果读取失败，也要重置按钮状态
        [self resetButtonStates];
    }
    
    // 准备下一个文件索引（循环）
    self.currentDataFileIndex = (self.currentDataFileIndex + 1) % self.dataFilePaths.count;
    NSLog(@"📋 Next file index prepared: %ld", (long)self.currentDataFileIndex);
}

// 流式渲染下一个字符块
- (void)streamNextChunk {
    if (!self.isStreaming || !self.streamingContent || self.streamingIndex >= self.streamingContent.length) {
        [self stopStreamingTimer];
        return;
    }
    
    // 每次添加 3 个字符
    NSInteger chunkSize = 5;
    NSInteger remainingLength = self.streamingContent.length - self.streamingIndex;
    NSInteger actualChunkSize = MIN(chunkSize, remainingLength);
    
    NSString *chunk = [self.streamingContent substringWithRange:NSMakeRange(self.streamingIndex, actualChunkSize)];
    NSLog(@"📝 Current chunk: '%@'", chunk);
    
    // 直接使用共享的流式渲染markdownView
    if (self.sharedStreamingMarkdownView) {
        NSLog(@"📄 Adding content to shared markdownView: '%@'", chunk);
        [self.sharedStreamingMarkdownView addStreamContent:chunk];
        
        // 更新当前流式消息的rawContent
        if (self.currentStreamingMessage) {
            NSString *currentContent = self.currentStreamingMessage.content ?: @"";
            self.currentStreamingMessage.content = [currentContent stringByAppendingString:chunk];
            
            // 更新高度缓存
            CGFloat newHeight = [self.heightManager heightForStreamingMessage:self.currentStreamingMessage.messageId textView:self.sharedStreamingMarkdownView];
            [self.heightManager updateStreamingHeight:newHeight forMessageId:self.currentStreamingMessage.messageId];
        }
        
        // 延迟更新 TableView 高度，避免在更新期间调用
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView beginUpdates];
//            [self.tableView endUpdates];
//        });
    } else {
        NSLog(@"❌ Shared streaming markdownView is nil");
    }
    
    self.streamingIndex += actualChunkSize;
}

// 停止流式渲染定时器
- (void)stopStreamingTimer {
    NSLog(@"⏹️ Stopping streaming timer");
    
    if (self.streamingTimer) {
        [self.streamingTimer invalidate];
        self.streamingTimer = nil;
    }
    self.isStreaming = NO;
    
    // 标记数据流式输入完成
    if (self.messages.count > 0) {
        ChatMessage *lastMessage = self.messages.lastObject;
        lastMessage.isStreaming = NO;
        
        // 数据流式输入完成
        
        // 如果渲染也已完成，则完全完成消息处理
        if (lastMessage.isRenderingComplete) {
            [self handleMessageRenderingComplete];
        }
    }
    
    NSLog(@"✅ Data streaming completed");
}

// 处理消息渲染完全完成（数据输入和渲染都完成）
- (void)handleMessageRenderingComplete {
    NSLog(@"🎉 Message completely finished (data + rendering)");
    
    if (self.currentStreamingMessage) {
        // 将流式高度转换为最终高度
        [self.heightManager markMessageAsCompleted:self.currentStreamingMessage.messageId];
        
        // 卸载共享的markdownView，让cell使用自己的markdownView显示完整内容
        if (self.currentMountedCell) {
            [self.currentMountedCell unmountSharedMarkdownView:self.sharedStreamingMarkdownView];
            self.currentMountedCell = nil;
        }
        
        // 刷新对应的cell以显示完整内容
        NSInteger messageIndex = [self.messages indexOfObject:self.currentStreamingMessage];
        if (messageIndex != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"🔄 Reloaded cell at indexPath: %@ to show complete content", indexPath);
        }
        
        self.currentStreamingMessage = nil;
    }
    
    // 恢复发送按钮，隐藏停止按钮
    [self resetButtonStates];
    
    NSLog(@"✅ Message rendering completely finished, buttons reset");
}

// 重置按钮状态
- (void)resetButtonStates {
    self.sendButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.sendButton.enabled = YES;
}

// 暂停功能已移除（仅保留发送与停止按钮）

- (void)stopStreaming {
    NSLog(@"🛑 Stop streaming button pressed");
    
    [self stopStreamingTimer];
    
    // 停止 AMXMarkdownTextView 的渲染（直接停止共享视图）
    if (self.sharedStreamingMarkdownView) {
        [self.sharedStreamingMarkdownView stop];
    }
}

- (void)clearMessages {
    [self stopStreaming];
    [self.messages removeAllObjects];
    [self.heightManager cleanupCache];
    [self.tableView reloadData];
}

#pragma mark - Helper Methods

- (NSString *)generateMessageId {
    return [[NSUUID UUID] UUIDString];
}

- (void)scrollToBottom {
    if (self.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = self.messages[indexPath.row];
    if (message.type == MessageTypeUser) {
        UserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMessageCell" forIndexPath:indexPath];
        cell.layer.borderColor = UIColor.blueColor.CGColor;
        cell.layer.borderWidth = 2;
        [cell configureWithMessage:message];
        NSLog(@"👤 Created UserMessageCell");
        return cell;
    } else {
        AIMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AIMessageCell" forIndexPath:indexPath];
        [cell configureWithMessage:message];
        
        // 如果是流式渲染消息或渲染未完成的消息，需要挂载共享的markdownView
        if (message.isStreaming || !message.isRenderingComplete) {
            NSLog(@"🔗 Mounting shared markdown view for streaming/rendering message");
            
            // 先卸载之前的cell（如果有）
            if (self.currentMountedCell && self.currentMountedCell != cell) {
                [self.currentMountedCell unmountSharedMarkdownView:self.sharedStreamingMarkdownView];
                self.currentMountedCell = nil;
            }
            
            // 挂载到当前cell
            [cell mountSharedMarkdownView:self.sharedStreamingMarkdownView];
            self.currentMountedCell = cell;
        }
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = self.messages[indexPath.row];
    
    if (message.type == MessageTypeUser) {
        // 用户消息使用简单的文本高度计算
        CGSize size = [message.content boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                    context:nil].size;
        return size.height + 32; // 加上 padding
    } else {
        // AI 消息使用高度管理器
        CGFloat constrainWidth = kContentWidth - 24; // 气泡宽度减去内边距
        if (message.isStreaming || !message.isRenderingComplete) {
            // 流式渲染中的消息或渲染未完成的消息，使用共享的markdownView计算高度
            if (self.sharedStreamingMarkdownView) {
                CGFloat hegith = [self.heightManager heightForStreamingMessage:message.messageId textView:self.sharedStreamingMarkdownView];
                NSLog(@"%@ 高度动态 %@", message.messageId, @(hegith));
                return hegith;
            } else {
                return [self.heightManager estimatedHeightForMessage:message.messageId];
            }
        } else {
            // 渲染完成的静态消息
            CGFloat hegith = [self.heightManager heightForStaticMessage:message.messageId
                                                                content:message.content
                                                         constrainWidth:constrainWidth];
            NSLog(@"%@ 高度静态 %@", message.messageId, @(hegith));
            return hegith;
        }
    }
}

#pragma mark - AMXMarkdownTextViewDelegate

- (void)onSizeChange:(CGSize)size {
    // 尺寸变化优化：只有当尺寸真正发生变化时才执行后续逻辑
    if (CGSizeEqualToSize(size, self.lastRecordedSize)) {
        NSLog(@"😁 Size unchanged (%.2f, %.2f), skipping update", size.width, size.height);
        return;
    }
    
    NSLog(@"😁 Size changed from (%.2f, %.2f) to (%.2f, %.2f)",
          self.lastRecordedSize.width, self.lastRecordedSize.height,
          size.width, size.height);
    
    // 记录新的尺寸
    self.lastRecordedSize = size;
    
    if (self.currentStreamingMessage) {
        // 更新流式渲染消息的高度
        [self.heightManager updateStreamingHeight:size.height + 10 forMessageId:self.currentStreamingMessage.messageId];
        
        // 立即更新 TableView 高度 - 使用 reload 方式刷新流式消息 cell
        NSIndexPath *streamingIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        
        // 方法2：重新加载流式消息的 cell - 确保高度变化立即生效
        [self.tableView reloadRowsAtIndexPaths:@[streamingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        // 检查是否需要滚动到底部
        if (!self.tableView.isTracking && !self.tableView.isDragging && !self.tableView.isDecelerating) {
            // 检查是否已经在底部附近
            CGFloat contentHeight = self.tableView.contentSize.height;
            CGFloat tableViewHeight = self.tableView.frame.size.height;
            CGFloat currentOffset = self.tableView.contentOffset.y;
            CGFloat bottomOffset = contentHeight - tableViewHeight;
            
            // 定义底部附近的阈值（例如距离底部50像素以内）
            CGFloat bottomThreshold = 50.0;
            
            // 只有当前偏移在底部附近时才自动滚动到底部
            if (currentOffset >= bottomOffset - bottomThreshold) {
                [self scrollToBottom];
            }
        }
    }
}

// 计算TableView的总内容高度
- (CGFloat)calculateTotalContentHeight {
    CGFloat totalHeight = 0;
    
    for (NSInteger i = 0; i < self.messages.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CGFloat cellHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
        totalHeight += cellHeight;
    }
    
    return totalHeight;
}

- (void)onPrintComplete {
    NSLog(@"✅ AMXMarkdownTextView print complete");
    
    if (self.currentStreamingMessage) {
        // 流式渲染完成，将消息标记为非流式状态
        self.currentStreamingMessage.isStreaming = NO;
        [self.heightManager markMessageAsCompleted:self.currentStreamingMessage.messageId];
        
        NSLog(@"🔄 Streaming completed for message: %@", self.currentStreamingMessage.messageId);
        
        // 卸载共享的markdownView，让cell使用自己的markdownView显示完整内容
        if (self.currentMountedCell) {
            [self.currentMountedCell unmountSharedMarkdownView:self.sharedStreamingMarkdownView];
            self.currentMountedCell = nil;
        }
        
        // 隐藏共享的markdownView
        self.sharedStreamingMarkdownView.hidden = YES;
        
        // 刷新对应的cell以显示完整内容
        NSInteger messageIndex = [self.messages indexOfObject:self.currentStreamingMessage];
        if (messageIndex != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"🔄 Reloaded cell at indexPath: %@ to show complete content", indexPath);
        }
        
        self.currentStreamingMessage = nil;
        
        NSLog(@"🔄 Resetting button states after print complete");
        
        // 重置按钮状态
        [self resetButtonStates];
    }
}

- (void)onError:(NSError *)error {
    NSLog(@"Markdown rendering error: %@", error.localizedDescription);
}

static inline void dispatch_async_on_main_queue(void (^block)()) {
    if(!block) return;
    dispatch_async(dispatch_get_main_queue(), block);
}

/**
 * Markdown 打印状态变化回调
 * @param state 新的打印状态（开始、进行中、完成等）
 */
-(void)didChangeState:(AMXMarkdownPrintState)state {
    NSLog(@"📊 AMXMarkdownTextView state changed to: %ld", (long)state);
    dispatch_async_on_main_queue(^{
        if (!self.currentStreamingMessage) {
            return;
        }
        
        switch (state) {
            case AMXMarkdownPrintStateRunning:
                NSLog(@"🏃 Markdown rendering started/resumed");
                break;
                
            case AMXMarkdownPrintStatePaused:
                NSLog(@"⏸️ Markdown rendering paused");
                
                // 当渲染暂停且数据流式输入已完成时，认为渲染完毕
                if (!self.currentStreamingMessage.isStreaming) {
                    NSLog(@"✅ Markdown rendering completed (paused + streaming finished)");
                    // 标记渲染完成
                    
                    self.currentStreamingMessage.isRenderingComplete = YES;
                    [self handleMessageRenderingComplete];
                }
                break;
                
            case AMXMarkdownPrintStateStopped:
                NSLog(@"🛑 Markdown rendering stopped (manual stop)");
                // 保留 stopped 状态的处理，但不在此状态下触发渲染完毕逻辑
                self.currentStreamingMessage.isRenderingComplete = YES;
                [self handleMessageRenderingComplete];
                break;
                
            case AMXMarkdownPrintStateInitial:
                NSLog(@"🔄 Markdown rendering initialized");
                self.currentStreamingMessage.isRenderingComplete = NO;
                break;
                
            default:
                break;
        }
    });
}

/**
 * 点击事件回调
 * @param type 点击类型（链接、图片、代码块等）
 * @param content 点击的内容对象
 * @param gesture 手势识别器
 * @param attachment 文本附件对象
 * @param tapIndex 点击索引
 * @param attrString 属性字符串
 */
-(void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString {
    
}

/**
 * 曝光元素更新回调
 * 用于统计和追踪用户浏览行为
 * @param elements 曝光元素数组，包含渲染事件模型
 */
-(void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements {
    
}

#pragma mark - KVO

/**
 * 清理资源
 */
- (void)dealloc {
    // 移除 KVO 监听
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    NSLog(@"🗑️ StreamingChatViewController dealloc - KVO observer removed");
}

/**
 * KVO 监听回调
 * 监听 tableView 的 contentSize 变化
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"] && object == self.tableView) {
        CGSize oldSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        NSLog(@"📏 TableView contentSize changed:");
        NSLog(@"📏 Old size: %.2f x %.2f", oldSize.width, oldSize.height);
        NSLog(@"📏 New size: %.2f x %.2f", newSize.width, newSize.height);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
