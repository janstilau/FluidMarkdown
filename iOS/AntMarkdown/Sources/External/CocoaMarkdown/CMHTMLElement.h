//
//  CMHTMLElement.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/16/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMHTMLElementTransformer;

@interface CMHTMLElement : NSObject
// 真正有作用的, 其实是在 transformer 中, 这里的 buffer 仅仅是做收集的工作. 
@property (nonatomic, readonly) id<CMHTMLElementTransformer> transformer;
@property (nonatomic, readonly) NSString *tagName;
@property (nonatomic, readonly) NSMutableString *buffer;

- (instancetype)initWithTransformer:(id<CMHTMLElementTransformer>)transformer;

@end
