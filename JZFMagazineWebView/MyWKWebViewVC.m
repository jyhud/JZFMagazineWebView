//
//  MyWKWebViewVC.m
//  JZFMagazineWebView
//
//  Created by 贾卓峰 on 2017/7/24.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MyWKWebViewVC.h"
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowser.h"


@interface MyWKWebViewVC ()<WKNavigationDelegate,WKUIDelegate,SDPhotoBrowserDelegate>

@property(nonatomic,strong)WKWebView * myWKWebView;
@property(nonatomic,strong)WKWebViewConfiguration * configure;
@property(nonatomic,strong)NSMutableArray* imageUrlArray;
//索引
@property (nonatomic, assign) NSInteger myIndex;
//容器视图
@property (nonatomic, strong) UIView *contenterView;
//本地存储地址
@property (nonatomic, strong) NSMutableDictionary *urlDicts;
//图片数组
@property (nonatomic,strong)  NSMutableArray * imageArray;


@end

@implementation MyWKWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网页展示";
    _contenterView = [[UIView alloc] init];
    _contenterView.center = self.view.center;
    [self.view addSubview:_contenterView];
    
    [self.view addSubview:self.myWKWebView];
    [self manageWithWebPageWithURLString:@"http://news.cctv.com/2017/07/22/ARTI8fhtjXovVDOFyvNIGgtg170722.shtml"];
}


-(void)manageWithWebPageWithURLString:(NSString *)URLStr{
    NSURL *url = [NSURL URLWithString:URLStr];  //[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];//@"http://news.cctv.com/2017/07/22/ARTI8fhtjXovVDOFyvNIGgtg170722.shtml"
    NSString *html = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img\\ssrc[^>]*/>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regex matchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, html.length)];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    for (NSTextCheckingResult *item in result) {
        NSString *imgHtml = [html substringWithRange:[item rangeAtIndex:0]];
        NSArray *tmpArray = nil;
        if ([imgHtml rangeOfString:@"src=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src=\""];
        } else if ([imgHtml rangeOfString:@"src="].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"src="];
        }
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
                NSLog(@"正确解析出来的SRC为：%@", src);
                if (src.length > 0) {
                    NSString *localPath = [docPath stringByAppendingPathComponent:[self md5:src]];
                    // 先将链接取个本地名字，且获取完整路径
                    [self.urlDicts setObject:localPath forKey:src];
                    //通过后缀做筛选操作
                    if ([src hasSuffix:@".png"]||[src hasSuffix:@".jpg"]||[src hasSuffix:@".jpeg"])
                    {
                        [self.imageUrlArray addObject:src];
                    }
                }
            }
        }
    }
    
    // 遍历所有的URL，替换成本地的URL，并异步获取图片
    for (NSString *src in self.urlDicts.allKeys) {
        NSString *localPath = [self.urlDicts objectForKey:src];
        html = [html stringByReplacingOccurrencesOfString:src withString:localPath];
        // 如果已经缓存过，就不需要重复加载了。
        if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            [self downloadImageWithUrl:src];
        }
    }
    NSLog(@"%@", html);
    [self.myWKWebView loadHTMLString:html baseURL:url];

}

#pragma mark-WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    if ([navigationAction.request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [navigationAction.request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        for (NSInteger i = 0; i<_imageUrlArray.count; i++) {
            if ([path isEqualToString:_imageUrlArray[i]]) {
                _myIndex = i;
            }
        }
        
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.currentImageIndex = _myIndex;
        browser.sourceImagesContainerView = _contenterView;
        browser.imageCount = self.imageUrlArray.count;
        browser.delegate = self;
        [browser show];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);

    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{

    [self.myWKWebView evaluateJavaScript:@"function assignImageClickAction(){var imgs=document.getElementsByTagName('img');var length=imgs.length;for(var i=0;i<length;i++){img=imgs[i];img.onclick=function(){window.location.href='image-preview:'+this.src}}}" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    
    [self.myWKWebView evaluateJavaScript:@"assignImageClickAction();" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
    
    //禁止长按
    [self.myWKWebView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout=‘none‘;" completionHandler:^(id _Nullable obj, NSError * _Nullable error){
    
    }];
    [self imageArray];
    for (NSInteger i = 0; i < self.imageUrlArray.count; i++) {
        UIImageView *view = [[UIImageView alloc] init];
        [_imageArray addObject:view];
        NSString * path = [self.urlDicts objectForKey:self.imageUrlArray[i]];
        [view sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
        }];
        [_contenterView addSubview:view];
    }

}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    
}

#pragma mark- WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);

    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);

    
}

#pragma mark - SDPhotoBrowserDelegate

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageName = self.imageUrlArray[index];
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = _imageArray[index];
    return imageView.image;
}


#pragma mark- Private Method

- (void)downloadImageWithUrl:(NSString *)src {

    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:src] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        NSData   * imageData = UIImagePNGRepresentation(image);
        NSString * docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString * localPath = [docPath stringByAppendingPathComponent:[self md5:src]];
        
        if (![imageData writeToFile:localPath atomically:NO]) {
            NSLog(@"写入本地失败：%@", src);
        }else{
            NSLog(@"缓存到本地路径");
        }
        
    }];
    
}
//MD5
- (NSString *)md5:(NSString *)sourceContent {
    if (self == nil || [sourceContent length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([sourceContent UTF8String], (int)[sourceContent lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setters/Getters

-(WKWebView*)myWKWebView{

    if (!_myWKWebView) {
        _myWKWebView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:self.configure];
        _myWKWebView.UIDelegate = self;
        _myWKWebView.navigationDelegate = self;
        
    }
    return _myWKWebView;
}

// WKWebView 的相关配置
-(WKWebViewConfiguration*)configure{
    
    if (!_configure) {
        _configure = [WKWebViewConfiguration new];
    }
    
    return _configure;
}

// 图片链接
-(NSMutableArray *)imageUrlArray{

    if (!_imageUrlArray) {
        _imageUrlArray = [NSMutableArray array];
    }
    return _imageUrlArray;
}

//所有图片的本地存储地址
-(NSMutableDictionary *)urlDicts{

    if (!_urlDicts) {
        _urlDicts = [NSMutableDictionary dictionary];
    }
    return _urlDicts;
    
}
// 图片数组
-(NSMutableArray*)imageArray{

    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}




@end
