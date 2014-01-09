//
// Created by wilsonwan on 14-1-9.
//
// Copyright (c) 2013年 Tencent. All rights reserved.
//


#import "RDRPrefetchService.h"
#import "RDRPasteBoardMonitor.h"


@interface RDRPrefetchService() <UIWebViewDelegate>
@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSMutableArray *urlList;
@end

@implementation RDRPrefetchService
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAddArticle:)
                                                     name:kNotificationDidInsertArticle
                                                   object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)urlList {
    if (_urlList == nil) {
        _urlList = [NSMutableArray array];
    }
    return _urlList;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return _webView;
}

- (void)didAddArticle:(NSNotification *)notification {
    NSString *url = [notification.userInfo objectForKey:kKeyUrl];
    assert([url isKindOfClass:[NSString class]]);

    [self.urlList addObject:url];

    if (self.urlList.count <= 1) {
        [self prefetchUrl:url];
    }
}

- (void)prefetchUrl:(NSString *)url {
    NSLog(@"start prefetch: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;

    [self.webView loadRequest:request];
}

- (void)prefetchNextUrl {
    if (self.urlList.count <= 0) {
        return;
    }
    [self.urlList removeObjectAtIndex:0];

    if (self.urlList.count <= 0) {
        return;
    }
    [self prefetchUrl:self.urlList.firstObject];
}

#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return YES;
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    NSLog(@"start prefetch");
//}
//
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"prefetch finished");

    [self prefetchNextUrl];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"prefetch failed: %@", error);

    [self prefetchNextUrl];
}

@end