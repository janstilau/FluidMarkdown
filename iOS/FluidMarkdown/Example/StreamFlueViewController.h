// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMXMarkdownWidget.h"

@interface StreamFlueViewController : UIViewController

@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) AMXMarkdownTextView *contentTextView;
@property (nonatomic, strong) UIScrollView *containerView;

@property (nonatomic, strong) NSString *fullContent;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *streamTimer;
@property (nonatomic, assign) BOOL isStreaming;

@end