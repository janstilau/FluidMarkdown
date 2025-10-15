// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "StreamingChatViewController.h"
#import "ChatCellHeightManager.h"
#import "AMXMarkdownTextView.h"
#import "AMXRenderService.h"
#import "UIColor+Random.h"

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
@property (nonatomic, assign) BOOL isStreaming;
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
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:8],
        [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-8]
    ]];
    
    self.backgroundColor = [UIColor randomColor];
    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageLabel.text = nil;
}

- (void)configureWithMessage:(ChatMessage *)message {
    self.messageLabel.text = message.content;
}

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
    self.bubbleView = [[UIView alloc] init];
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
    self.markdownView.userInteractionEnabled = false;
    [self.bubbleView addSubview:self.markdownView];
    
    // 约束设置
    [NSLayoutConstraint activateConstraints:@[
        // 气泡约束
        [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        [self.bubbleView.widthAnchor constraintLessThanOrEqualToConstant:320],
        
        // Markdown 视图约束
        [self.markdownView.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:12],
        [self.markdownView.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-12],
        [self.markdownView.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:8],
        [self.markdownView.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-8]
    ]];
    
    self.backgroundColor = [UIColor randomColor];
    self.contentView.backgroundColor = self.backgroundColor;
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
        // 如果消息已完成，清理缓存以避免复用时的高度错误
        if (!self.message.isStreaming) {
            [[ChatCellHeightManager sharedManager] clearCacheForMessage:self.message.messageId];
        }
        self.message = nil;
    }
    
    NSLog(@"✅ AIMessageCell reset completed");
}

- (void)configureWithMessage:(ChatMessage *)message {
    NSLog(@"🔧 Configuring AIMessageCell with message: %@, isStreaming: %d", message.messageId, message.isStreaming);
    
    self.message = message;
    
    if (message.isStreaming) {
        NSLog(@"🔄 Cell configured for streaming mode - will be mounted by ViewController");
        // 流式渲染模式：隐藏自己的markdownView，等待ViewController挂载共享的markdownView
        self.markdownView.hidden = YES;
    } else {
        NSLog(@"📝 Rendering complete content in cell's own markdownView");
        // 显示自己的markdownView并渲染完整内容
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
    CGFloat constrainWidth = 320 - 24; // 与heightForRowAtIndexPath保持一致
    CGRect newFrame = sharedMarkdownView.frame;
    newFrame.size.width = constrainWidth;
    sharedMarkdownView.frame = newFrame;
    
    // 设置约束，与原来的markdownView位置相同
    [NSLayoutConstraint activateConstraints:@[
        [sharedMarkdownView.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:12],
        [sharedMarkdownView.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-12],
        [sharedMarkdownView.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:8],
        [sharedMarkdownView.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-8]
    ]];
    
    // 显示共享的markdownView
    sharedMarkdownView.hidden = NO;
    
    NSLog(@"✅ Shared markdown view mounted successfully with width: %.2f", constrainWidth);
}

// 卸载共享的流式渲染markdownView
- (void)unmountSharedMarkdownView:(AMXMarkdownTextView *)sharedMarkdownView {
    NSLog(@"🔌 Unmounting shared markdown view from cell");
    
    // 隐藏并从bubbleView中移除共享的markdownView
    sharedMarkdownView.hidden = YES;
    [sharedMarkdownView removeFromSuperview];
    
    // 显示自己的markdownView（如果消息已完成，应该渲染完整内容）
    if (self.message && !self.message.isStreaming) {
        self.markdownView.hidden = NO;
        [self.markdownView renderCompleteContent:self.message.content];
        NSLog(@"📝 Restored cell's own markdownView with complete content");
    }
    
    NSLog(@"✅ Shared markdown view unmounted successfully");
}

@end

// 主控制器
@interface StreamingChatViewController () <UITableViewDataSource, UITableViewDelegate, AMXMarkdownTextViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *inputContainer;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *pauseButton;
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
@end

@implementation StreamingChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置 Markdown 样式
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:@"chat"];
    [self setupUI];
    [self setupData];
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
    
    // 输入框
    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"输入消息...";
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:self.inputField];
    
    // 发送按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:self.sendButton];
    
    // 暂停按钮
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(pauseStreaming) forControlEvents:UIControlEventTouchUpInside];
    self.pauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:self.pauseButton];
    
    // 停止按钮
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setTitle:@"停止" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stopStreaming) forControlEvents:UIControlEventTouchUpInside];
    self.stopButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.stopButton.hidden = YES;
    [self.inputContainer addSubview:self.stopButton];
    
    // 约束设置
    [NSLayoutConstraint activateConstraints:@[
        // TableView
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.inputContainer.topAnchor],
        
        // 输入容器
        [self.inputContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.inputContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.inputContainer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.inputContainer.heightAnchor constraintEqualToConstant:60],
        
        // 输入框
        [self.inputField.leadingAnchor constraintEqualToAnchor:self.inputContainer.leadingAnchor constant:16],
        [self.inputField.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.inputField.heightAnchor constraintEqualToConstant:36],
        
        // 发送按钮
        [self.sendButton.trailingAnchor constraintEqualToAnchor:self.pauseButton.leadingAnchor constant:-8],
        [self.sendButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.sendButton.widthAnchor constraintEqualToConstant:60],
        [self.sendButton.heightAnchor constraintEqualToConstant:36],
        
        // 暂停按钮
        [self.pauseButton.trailingAnchor constraintEqualToAnchor:self.stopButton.leadingAnchor constant:-8],
        [self.pauseButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.pauseButton.widthAnchor constraintEqualToConstant:60],
        [self.pauseButton.heightAnchor constraintEqualToConstant:36],
        
        // 停止按钮
        [self.stopButton.trailingAnchor constraintEqualToAnchor:self.inputContainer.trailingAnchor constant:-16],
        [self.stopButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.stopButton.widthAnchor constraintEqualToConstant:60],
        [self.stopButton.heightAnchor constraintEqualToConstant:36],
        
        // 输入框与发送按钮的间距
        [self.inputField.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-8]
    ]];
}

- (void)setupData {
    self.messages = [[NSMutableArray alloc] init];
    self.heightManager = [ChatCellHeightManager sharedManager];
    self.currentDataFileIndex = 0;
    
    // 设置数据文件路径 - 从 data1.txt 开始，然后是 data1.txt 到 data7.txt
    self.dataFilePaths = @[
        [[NSBundle mainBundle] pathForResource:@"data1" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data2" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data3" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data4" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data5" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data6" ofType:@"txt"],
        [[NSBundle mainBundle] pathForResource:@"data7" ofType:@"txt"]
    ];
    
    NSLog(@"📁 Setup data files, total count: %ld", (long)self.dataFilePaths.count);
}

- (void)setupSharedStreamingMarkdownView {
    // 创建共享的流式渲染 AMXMarkdownTextView，设置合适的初始frame
    CGFloat constrainWidth = 320 - 24; // 气泡宽度减去内边距，与heightForRowAtIndexPath保持一致
    self.sharedStreamingMarkdownView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, constrainWidth, 100)];
    self.sharedStreamingMarkdownView.delegate = self;
    self.sharedStreamingMarkdownView.backgroundColor = [UIColor clearColor];
    self.sharedStreamingMarkdownView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sharedStreamingMarkdownView.styleId = @"chat";
    self.sharedStreamingMarkdownView.userInteractionEnabled = NO;
    
    // 初始状态下隐藏，只有在流式渲染时才显示
    self.sharedStreamingMarkdownView.hidden = YES;
    
    NSLog(@"🔧 Shared streaming markdown view initialized with width: %.2f", constrainWidth);
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
    aiMessage.timestamp = [NSDate date];
    
    NSLog(@"📝 Created AI message: %@, isStreaming: %d", aiMessage.messageId, aiMessage.isStreaming);
    
    [self.messages addObject:aiMessage];
    self.currentStreamingMessage = aiMessage;
    
    // 显示停止按钮
    self.sendButton.hidden = YES;
    self.stopButton.hidden = NO;
    
    // 刷新 TableView
    NSLog(@"🔄 Reloading table view, messages count: %ld", (long)self.messages.count);
    [self.tableView reloadData];
    [self scrollToBottom];
    
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
        self.streamingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(streamNextChunk) userInfo:nil repeats:YES];
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
    
    NSLog(@"🔄 streamNextChunk called, index: %ld, total: %ld", (long)self.streamingIndex, (long)self.streamingContent.length);
    
    // 每次添加 3 个字符
    NSInteger chunkSize = 3;
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
            
            NSLog(@"📏 Updated height: %.2f for message: %@", newHeight, self.currentStreamingMessage.messageId);
        }
        
        // 延迟更新 TableView 高度，避免在更新期间调用
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        });
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
    
    // 标记消息为完成状态
    if (self.messages.count > 0) {
        ChatMessage *lastMessage = self.messages.lastObject;
        lastMessage.isStreaming = NO;
        // 将流式高度转换为最终高度
        [self.heightManager markMessageAsCompleted:lastMessage.messageId];
    }
    
    // 恢复发送按钮，隐藏停止按钮
    [self resetButtonStates];
    
    NSLog(@"✅ Streaming completed, buttons reset");
}

// 重置按钮状态
- (void)resetButtonStates {
    self.sendButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.sendButton.enabled = YES;
}

// 暂停流式渲染
- (void)pauseStreaming {
    if (self.isStreaming && self.streamingTimer) {
        [self.streamingTimer invalidate];
        self.streamingTimer = nil;
        self.isStreaming = NO;
        [self.pauseButton setTitle:@"继续" forState:UIControlStateNormal];
        
        // 暂停 AMXMarkdownTextView
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        AIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.markdownView) {
            [cell.markdownView pause];
        }
    } else if (!self.isStreaming && self.streamingContent && self.streamingIndex < self.streamingContent.length) {
        // 恢复流式渲染
        self.isStreaming = YES;
        self.streamingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(streamNextChunk) userInfo:nil repeats:YES];
        [self.pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        
        // 恢复 AMXMarkdownTextView
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        AIMessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.markdownView) {
            [cell.markdownView resume];
        }
    }
}

- (void)stopStreaming {
    NSLog(@"🛑 Stop streaming button pressed");
    
    [self stopStreamingTimer];
    
    // 停止 AMXMarkdownTextView 的渲染 - 避免在更新期间调用 cellForRowAtIndexPath
    if (self.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        NSArray *visibleCells = [self.tableView visibleCells];
        
        for (UITableViewCell *cell in visibleCells) {
            if ([cell isKindOfClass:[AIMessageCell class]]) {
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                if (cellIndexPath && cellIndexPath.row == indexPath.row) {
                    AIMessageCell *aiCell = (AIMessageCell *)cell;
                if (aiCell.markdownView) {
                    [aiCell.markdownView stop];
                }
                    break;
                }
            }
        }
    }
    
    // 重置暂停按钮状态
    [self.pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
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
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = self.messages[indexPath.row];
    NSLog(@"🏗️ Creating cell for indexPath: %@, message type: %d, isStreaming: %d", indexPath, message.type, message.isStreaming);
    
    if (message.type == MessageTypeUser) {
        UserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMessageCell" forIndexPath:indexPath];
        [cell configureWithMessage:message];
        NSLog(@"👤 Created UserMessageCell");
        return cell;
    } else {
        AIMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AIMessageCell" forIndexPath:indexPath];
        [cell configureWithMessage:message];
        
        // 如果是流式渲染消息，需要挂载共享的markdownView
        if (message.isStreaming) {
            NSLog(@"🔗 Mounting shared markdown view for streaming message");
            
            // 先卸载之前的cell（如果有）
            if (self.currentMountedCell && self.currentMountedCell != cell) {
                [self.currentMountedCell unmountSharedMarkdownView:self.sharedStreamingMarkdownView];
                self.currentMountedCell = nil;
            }
            
            // 挂载到当前cell
            [cell mountSharedMarkdownView:self.sharedStreamingMarkdownView];
            self.currentMountedCell = cell;
            
            NSLog(@"✅ Shared markdown view mounted to current streaming cell");
        }
        
        NSLog(@"🤖 Created AIMessageCell, streaming: %d", message.isStreaming);
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
        CGFloat constrainWidth = 320 - 24; // 气泡宽度减去内边距
        
        if (message.isStreaming) {
            // 流式渲染中的消息，使用共享的markdownView计算高度
            if (self.sharedStreamingMarkdownView) {
                return [self.heightManager heightForStreamingMessage:message.messageId textView:self.sharedStreamingMarkdownView];
            } else {
                return [self.heightManager estimatedHeightForMessage:message.messageId];
            }
        } else {
            // 静态消息
            return [self.heightManager heightForStaticMessage:message.messageId
                                                      content:message.content
                                               constrainWidth:constrainWidth];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = self.messages[indexPath.row];
    
    if (message.type == MessageTypeUser) {
        return 60;
    } else {
        return [self.heightManager estimatedHeightForMessage:message.messageId];
    }
}

#pragma mark - AMXMarkdownTextViewDelegate

- (void)onSizeChange:(CGSize)size {
    if (self.currentStreamingMessage) {
        // 更新流式渲染消息的高度
        [self.heightManager updateStreamingHeight:size.height + 32 forMessageId:self.currentStreamingMessage.messageId];
        
        // 平滑更新 TableView 高度
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        // 保持滚动到底部
        [self scrollToBottom];
    }
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


@end
