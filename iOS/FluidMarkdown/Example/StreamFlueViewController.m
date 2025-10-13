// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "StreamFlueViewController.h"
#import "ToastView.h"
#import "AMXRenderService.h"
#import "AMXMarkdownStyle.h"

@interface StreamFlueViewController ()<AMXMarkdownTextViewDelegate>

@end

@implementation StreamFlueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadDataFromFile];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Stream Flue Demo";
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonWidth = (screenWidth - 60) / 5; // 5个按钮
    CGFloat buttonHeight = 40;
    CGFloat topMargin = 100;
    
    // 创建按钮
    self.startButton = [self createButtonWithTitle:@"开始" 
                                             frame:CGRectMake(10, topMargin, buttonWidth, buttonHeight)
                                            action:@selector(startStreaming)];
    
    self.pauseButton = [self createButtonWithTitle:@"暂停" 
                                             frame:CGRectMake(20 + buttonWidth, topMargin, buttonWidth, buttonHeight)
                                            action:@selector(pauseStreaming)];
    
    self.resumeButton = [self createButtonWithTitle:@"继续" 
                                              frame:CGRectMake(30 + buttonWidth * 2, topMargin, buttonWidth, buttonHeight)
                                             action:@selector(resumeStreaming)];
    
    self.stopButton = [self createButtonWithTitle:@"停止" 
                                            frame:CGRectMake(40 + buttonWidth * 3, topMargin, buttonWidth, buttonHeight)
                                           action:@selector(stopStreaming)];
    
    self.resetButton = [self createButtonWithTitle:@"重置" 
                                             frame:CGRectMake(50 + buttonWidth * 4, topMargin, buttonWidth, buttonHeight)
                                            action:@selector(resetStreaming)];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topMargin + 50, screenWidth - 20, 30)];
    self.statusLabel.text = @"状态: 准备就绪";
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.statusLabel];
    
    // 进度标签
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topMargin + 80, screenWidth - 20, 30)];
    self.progressLabel.text = @"进度: 0/0 字符";
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    self.progressLabel.textColor = [UIColor grayColor];
    [self.view addSubview:self.progressLabel];
    
    // 容器滚动视图
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, topMargin + 120, screenWidth - 20, self.view.frame.size.height - topMargin - 140)];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.containerView.layer.cornerRadius = 8;
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.containerView];
    
    self.contentTextView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, self.containerView.frame.size.width - 20 * 2, self.view.frame.size.height)];
    self.contentTextView.styleId = @"demo";
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.textViewDelegate = self;
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.contentTextView];
    // 注册 Markdown 样式，确保渲染引擎有样式配置
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:@"demo"];
    
    // 初始化状态
    self.currentIndex = 0;
    self.isStreaming = NO;
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor systemBlueColor];
    button.layer.cornerRadius = 8;
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)loadDataFromFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data1" ofType:@"txt"];
    if (filePath) {
        NSError *error;
        self.fullContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"读取文件失败: %@", error.localizedDescription);
            self.fullContent = @"# 错误\n\n无法读取 data1.txt 文件内容。";
        }
    } else {
        self.fullContent = @"# 错误\n\n找不到 data1.txt 文件。";
    }
    // 预处理 Markdown 内容：换行与数学公式标记转换
    self.fullContent = [self markdownReplaceBr:self.fullContent];
    
    [self updateProgressLabel];
}

- (void)updateProgressLabel {
    NSInteger totalLength = self.fullContent.length;
    self.progressLabel.text = [NSString stringWithFormat:@"进度: %ld/%ld 字符 (%.1f%%)", 
                              (long)self.currentIndex, 
                              (long)totalLength, 
                              totalLength > 0 ? (self.currentIndex * 100.0 / totalLength) : 0];
}

#pragma mark - 流式控制方法

- (void)startStreaming {
    if (self.isStreaming) {
        [ToastView showToastInView:self.view withText:@"已在流式显示中" duration:2.0];
        return;
    }
    
    self.isStreaming = YES;
    self.statusLabel.text = @"状态: 流式显示中...";
    [ToastView showToastInView:self.view withText:@"开始流式显示" duration:2.0];
    
    // 初始化流式渲染（进入流式状态）
    [self.contentTextView startStreamingWithContent:@""];
    
    // 开始定时器，每100ms添加20个字符
    self.streamTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(addNextChunk)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)addNextChunk {
    if (self.currentIndex >= self.fullContent.length) {
        [self stopStreaming];
        return;
    }
    
    // 每次取20个字符
    NSInteger chunkSize = 20;
    NSInteger remainingLength = self.fullContent.length - self.currentIndex;
    NSInteger actualChunkSize = MIN(chunkSize, remainingLength);
    
    NSString *chunk = [self.fullContent substringWithRange:NSMakeRange(self.currentIndex, actualChunkSize)];
    
    // 添加到 TextView
    [self.contentTextView addStreamContent:chunk];
    
    self.currentIndex += actualChunkSize;
    [self updateProgressLabel];
    
    // 自动滚动到底部
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
    });
}

- (void)pauseStreaming {
    if (!self.isStreaming) {
        [ToastView showToastInView:self.view withText:@"当前未在流式显示" duration:2.0];
        return;
    }
    
    [self.streamTimer invalidate];
    self.streamTimer = nil;
    self.statusLabel.text = @"状态: 已暂停";
    [ToastView showToastInView:self.view withText:@"暂停流式显示" duration:2.0];
}

- (void)resumeStreaming {
    if (!self.isStreaming) {
        [ToastView showToastInView:self.view withText:@"请先开始流式显示" duration:2.0];
        return;
    }
    
    if (self.streamTimer) {
        [ToastView showToastInView:self.view withText:@"已在流式显示中" duration:2.0];
        return;
    }
    
    self.statusLabel.text = @"状态: 流式显示中...";
    [ToastView showToastInView:self.view withText:@"继续流式显示" duration:2.0];
    
    self.streamTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(addNextChunk)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopStreaming {
    [self.streamTimer invalidate];
    self.streamTimer = nil;
    self.isStreaming = NO;
    self.statusLabel.text = @"状态: 已停止";
    [ToastView showToastInView:self.view withText:@"停止流式显示" duration:2.0];
}

- (void)resetStreaming {
    [self stopStreaming];
    self.currentIndex = 0;
    [self.contentTextView renderCompleteContent:@""];
    self.statusLabel.text = @"状态: 准备就绪";
    [self updateProgressLabel];
    [ToastView showToastInView:self.view withText:@"重置完成" duration:2.0];
}

- (void)scrollToBottom {
    CGPoint bottomOffset = CGPointMake(0, self.containerView.contentSize.height - self.containerView.bounds.size.height);
    if (bottomOffset.y > 0) {
        [self.containerView setContentOffset:bottomOffset animated:YES];
    }
}

#pragma mark - AMXMarkdownTextViewDelegate

- (void)onSizeChange:(CGSize)size {
    [self.contentTextView setFrame:CGRectMake(10, 10, self.containerView.frame.size.width - 20, size.height)];
    [self.containerView setContentSize:CGSizeMake(self.containerView.frame.size.width, size.height + 20)];
    
    // 自动滚动到底部
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
    });
}

- (void)onError:(NSError*)error {
    NSLog(@"Markdown 渲染错误: %@", error.localizedDescription);
    [ToastView showToastInView:self.view withText:[NSString stringWithFormat:@"渲染错误: %@", error.localizedDescription] duration:3.0];
}

- (void)didChangeState:(AMXMarkdownPrintState)state {
    switch (state) {
        case AMXMarkdownPrintStateStopped:
            [self scrollToBottom];
            break;
        case AMXMarkdownPrintStatePaused:
            // 处理暂停状态
            break;
        default:
            break;
    }
}

- (void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements {
    // 处理曝光元素更新
}

- (void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString {
}

- (void)dealloc {
    [self.streamTimer invalidate];
    self.streamTimer = nil;
}

- (NSString*)markdownReplaceBr:(NSString *)markdown {
    if(!(markdown && [markdown isKindOfClass:[NSString class]] && ![@"" isEqualToString:markdown]))
        return markdown;
    
    NSString* resStr = [markdown stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
    NSString *pattern = @"\\\\\[([\\s\\S]*?)\\\\\]";
    
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (error) {
        return resStr;
    }
    
    NSString *replacementString = @"$$$1$$";
    NSString *resultString = [regex stringByReplacingMatchesInString:resStr options:0 range:NSMakeRange(0, resStr.length) withTemplate:replacementString];
    
    
    NSString *pattern2 = @"\\\\\((.*?)\\\\\)";
    
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:pattern2 options:0 error:&error];
    
    if (error) {
        NSLog(@"regular exception: %@", error.localizedDescription);
        return resultString;
    }
    
    NSString *replacementString2 = @"$$1$";
    NSString *resultString2 = [regex2 stringByReplacingMatchesInString:resultString options:0 range:NSMakeRange(0, resultString.length) withTemplate:replacementString2];
    
    return resultString2;
}

@end
