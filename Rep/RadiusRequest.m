//
//  RadiusRequest.m
//  radius
//
//  Created by Radius on 8/7/12.
//
//

#import "RadiusRequest.h"
#import "NSString+URLEncoding.h"
#import "RepAppDelegate.h"
#import "MFSlidingView.h"
#import "MFSideMenu/MFSideMenu.h"
#import "RepUserData.h"


@interface RadiusRequest() {
    RadiusResponseHandler _completionHandler;
    RadiusResponseFailureHandler _failureHandler;
    
    RepUserData *_myUserData;
    
    NSMutableData *_receivedData;
    
    NSURLConnection *_connection;
    UIAlertView *myAlertView;
    
}

@end

static BOOL _tokenRejected;
static NSString *_token = nil;
static id<RadiusRequestDelegate> _requestDelegate;
static BOOL _lowConnection;

static NSString *API_DOMAIN = @"repmeback.com";
//static NSString *API_DOMAIN = @"192.168.1.66";
//static NSString *API_DOMAIN = @"localhost";


static NSString *API_BASE_PATH = @"/api/";
static NSString *IMG_BASE_PATH = @"/img/";
//static NSString *API_BASE_PATH = @"/v2/api/";

static NSString *HTTP_PATH = @"https";
//static NSString *HTTP_PATH = @"https";


static NSString *VERSIONS_SUPPORTED = @"~1.1";
static const CGFloat ALERT_VIEW_TAG = 200;


//I will need:
//1. API's all in a folder called /api
//2. API's named such that they go under /api
//3. A domain from which to grab them.
//
//It goes: api domain, then the base path, in case there are more apis, and then the method names.



const static NSString *MULTIPART_BOUNDARY = @"a0z1X2weoif2h030f3hu93ifj9eurhliuhlsidjfnvieurh9384750h298fj49uhf294f93fhisduhf0284hfisudiushf084";

static NSString *DISPOSITION_TEMPLATE = @"Content-Disposition: form-data; name=\"%@\"";

@implementation RadiusRequest

@synthesize underlyingRequest, apiMethod, containsImageData;

/// create a request sent using the POST method and the multipart/form-data content type
/// the data parameter should be a null-terminated list of data, content type, filename, parameter name tuples
+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod multipartData:(id)data, ...
{
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@%@", HTTP_PATH,API_DOMAIN,API_BASE_PATH,apiMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",MULTIPART_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    [request setValue:VERSIONS_SUPPORTED forHTTPHeaderField:@"accept_version"];
    
    [request setHTTPMethod:@"POST"];

    
    if(_token) {
        //params = [NSMutableDictionary dictionaryWithDictionary:params];
        //[params setValue:_token forKey:@"token"];];
    } else if (!params) {
        params = [[NSDictionary alloc] init];
    }
    
    NSMutableData *body = [[NSMutableData alloc] init];
    
    // Append parameters
    for (NSString *paramString in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", paramString] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:paramString]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
//    NSEnumerator *e = params.keyEnumerator;
//    NSString *key;
//    while((key=e.nextObject)) {
//        
//        id value = [params objectForKey:key];
//    
//        NSString *disposition = [NSString stringWithFormat:DISPOSITION_TEMPLATE,key];
//        
//        [body appendData:[disposition dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        [body appendData:[[NSString stringWithFormat:@"\r\n\r\n%@\r\n--%@\r\n",value,MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    }
    
    // Append data
    NSString* FileParamConstant = @"pic";

    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", MULTIPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];

    request.HTTPBody = body;
    
    NSString * length = [NSString stringWithFormat:@"%d",[body length]];
    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    
    
    radiusRequest.underlyingRequest = request;
    return radiusRequest;
}

+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod httpMethod:(NSString *)httpMethod
{
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    
    NSMutableURLRequest *request;
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@%@",HTTP_PATH,API_DOMAIN,API_BASE_PATH,apiMethod];
    
    if(_token) {
        //params = [NSMutableDictionary dictionaryWithDictionary:params];
        //[params setValue:_token forKey:@"token"];
    } else if (!params) {
        params = [[NSDictionary alloc] init];
    }
    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSEnumerator *e = params.keyEnumerator;
    NSString *key;
    BOOL first = YES;
    while((key = e.nextObject)) {
        if (!first) {
            [paramString appendString:@"&"];
        }
        else {
            first = NO;
        }
        id value = [params objectForKey:key];
        if([value isKindOfClass:[NSString class]]) {
            value = [value urlEncodeUsingEncoding:NSUTF8StringEncoding];
        }
        [paramString appendFormat:@"%@=%@",[key urlEncodeUsingEncoding:NSUTF8StringEncoding],value];
    }
    
    if([httpMethod isEqualToString:@"GET"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
        
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
    } else if([httpMethod isEqualToString:@"POST"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        
        request.HTTPMethod = @"POST";
        
        NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = body;
        
        NSString *length = [NSString stringWithFormat:@"%d",body.length];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:VERSIONS_SUPPORTED forHTTPHeaderField:@"accept_version"];

    } else {
        return nil;
    }
    
//    if(_token) {
//        // Add token to request as cookie
//        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    API_DOMAIN,NSHTTPCookieDomain,
//                                    @"\\",NSHTTPCookiePath,
//                                    @"token",NSHTTPCookieName,
//                                    _token,NSHTTPCookieValue, nil];
//        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
//        NSArray *cookies = [NSArray arrayWithObject:cookie];
//        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
//    }
    
    radiusRequest.underlyingRequest = request;
    
    return radiusRequest;
}

+(RadiusRequest *)requestWithParameters:(NSDictionary *)params basePath:(NSString*)path apiMethod:(NSString *)apiMethod httpMethod:(NSString *)httpMethod
{
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    
    NSMutableURLRequest *request;
    NSString *urlString;
    
    if ([path isEqualToString:@"img"]) {
        urlString = [NSString stringWithFormat:@"%@://%@%@%@",HTTP_PATH,API_DOMAIN,IMG_BASE_PATH,apiMethod];

    }else{
        urlString = [NSString stringWithFormat:@"%@://%@%@%@",HTTP_PATH,API_DOMAIN,API_BASE_PATH,apiMethod];

    }
    
    
    if(_token) {
        //params = [NSMutableDictionary dictionaryWithDictionary:params];
        //[params setValue:_token forKey:@"token"];
    } else if (!params) {
        params = [[NSDictionary alloc] init];
    }
    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSEnumerator *e = params.keyEnumerator;
    NSString *key;
    BOOL first = YES;
    while((key = e.nextObject)) {
        if (!first) {
            [paramString appendString:@"&"];
        }
        else {
            first = NO;
        }
        id value = [params objectForKey:key];
        if([value isKindOfClass:[NSString class]]) {
            value = [value urlEncodeUsingEncoding:NSUTF8StringEncoding];
        }
        [paramString appendFormat:@"%@=%@",[key urlEncodeUsingEncoding:NSUTF8StringEncoding],value];
    }
    
    if([httpMethod isEqualToString:@"GET"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlString,paramString]];
        
        request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
    } else if([httpMethod isEqualToString:@"POST"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        
        request.HTTPMethod = @"POST";
        
        NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = body;
        
        NSString *length = [NSString stringWithFormat:@"%d",body.length];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:VERSIONS_SUPPORTED forHTTPHeaderField:@"accept_version"];
        
    } else {
        return nil;
    }
    
    //    if(_token) {
    //        // Add token to request as cookie
    //        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
    //                                    API_DOMAIN,NSHTTPCookieDomain,
    //                                    @"\\",NSHTTPCookiePath,
    //                                    @"token",NSHTTPCookieName,
    //                                    _token,NSHTTPCookieValue, nil];
    //        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    //        NSArray *cookies = [NSArray arrayWithObject:cookie];
    //        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    //    }
    
    radiusRequest.underlyingRequest = request;
    
    return radiusRequest;
}

+(RadiusRequest *)requestWithParameters:(NSDictionary *)params apiMethod:(NSString *)apiMethod
{
    return [self requestWithParameters:params apiMethod:apiMethod httpMethod:@"GET"];
}

+(RadiusRequest *) requestWithAPIMethod:(NSString *)apiMethod
{
    return [self requestWithParameters:nil apiMethod:apiMethod];
}

+(RadiusRequest *) requestWithURL: (NSString *)myURL{
    
    RadiusRequest *radiusRequest = [[RadiusRequest alloc] init];
    
    NSMutableURLRequest *request;
    
    NSString *urlString = [NSString stringWithFormat:@"%@", myURL];
    
    
    NSMutableString *paramString = [[NSMutableString alloc] init];
    

        NSURL *url = [NSURL URLWithString:urlString];
        request = [NSMutableURLRequest requestWithURL:url];
        
        request.HTTPMethod = @"POST";
        
        NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = body;
        
        NSString *length = [NSString stringWithFormat:@"%d",body.length];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:VERSIONS_SUPPORTED forHTTPHeaderField:@"accept_version"];

    if(_token) {
        // Add token to request as cookie
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    API_DOMAIN,NSHTTPCookieDomain,
                                    @"\\",NSHTTPCookiePath,
                                    @"token",NSHTTPCookieName,
                                    _token,NSHTTPCookieValue, nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        NSArray *cookies = [NSArray arrayWithObject:cookie];
        [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    }
    
    radiusRequest.underlyingRequest = request;
    
    return radiusRequest;
    
}


+(void)setToken:(NSString *)token {
    _token = token;
    _tokenRejected = NO;
}

+(NSString *)token
{
    return _token;
}

+(void)setRequestDelegate:(id<RadiusRequestDelegate>)delegate
{
    _requestDelegate = delegate;
}

-(void)start
{
    [self startWithCompletionHandler:nil];
}

-(void)startWithCompletionHandler:(RadiusResponseHandler)handler
{
    [self startWithCompletionHandler:handler failureHandler:nil];
}

-(void)startWithCompletionHandler:(RadiusResponseHandler)completionHandler failureHandler:(RadiusResponseFailureHandler)failureHandler
{
    _completionHandler = completionHandler;
    _failureHandler = failureHandler;
    
    _connection = [NSURLConnection connectionWithRequest:self.underlyingRequest delegate:self];
    
    _receivedData = [[NSMutableData alloc] init];
    
    [_connection start];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if([self.dataDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.dataDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    _myUserData = [RepUserData sharedRepUserData];
    
    NSHTTPURLResponse *myResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%i", myResponse.statusCode);
    
    if (myResponse.statusCode == 500 ||myResponse.statusCode == 502 || myResponse.statusCode == 503) {
        RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        for (int i = 0; i<[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies count]; i++) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies objectAtIndex:i]];
        }
        
        myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Server Issues!! Check back later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        myAlertView.tag = ALERT_VIEW_TAG;
        if (![[MFSideMenuManager sharedManager].navigationController.view viewWithTag:ALERT_VIEW_TAG]) {
            [myAlertView show];
            
        }
        [appDelegate showLoginView];
        
        

    }
    
    if([self.dataDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.dataDelegate connection:connection didReceiveResponse:response];
    }
    
    _receivedData.length = 0;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if([self.dataDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [self.dataDelegate connection:connection didReceiveData:data];
    }
    
    [_receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    

    if([self.dataDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [self.dataDelegate connectionDidFinishLoading:connection];
    }
    
    if(_lowConnection) {
        _lowConnection = NO;
        if([_requestDelegate respondsToSelector:@selector(radiusRequestDidDetectRecoveredConnection:)]) {
            [_requestDelegate radiusRequestDidDetectRecoveredConnection:self];
        }
    }
    
    NSError *jsonError;
    id response = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if(!response && [apiMethod isEqualToString:@"pic"]) {
        // bad response from backend

        response = _receivedData;
        containsImageData = YES;
    }
    
    if(!response) {
        // bad response from backend
        RadiusError *error = [[RadiusError alloc] initWithType:RadiusErrorBadResponse message:@"Bad Response"];
        
        if(_completionHandler) {
            _completionHandler(nil,error);
        }
        return;
    }
    
    
    if([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"error"]) {
        RadiusError *error = [[RadiusError alloc] initWithResponseObject:response];
        
        if(error.type == RadiusErrorBadToken) {
            if([_requestDelegate respondsToSelector:@selector(radiusRequestDidFailWithBadToken:)] && !_tokenRejected) {
                [_requestDelegate radiusRequestDidFailWithBadToken:self];
            }
            _tokenRejected = YES;
            return;
        }
        
        if(_completionHandler) {
            _completionHandler(nil,error);
        }
        return;
    }

    if([response isKindOfClass:[NSDictionary class]] && [[response objectForKey:@"success"] integerValue] == 0) {
        
        if ([[[response objectForKey:@"err"] objectForKey:@"bypass"] integerValue] == 1) {
            
            if ([[response objectForKey:@"err"]objectForKey:@"message"]){
                
                myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                myAlertView.tag = ALERT_VIEW_TAG;
                    [myAlertView show];

            
            }
            
        }else if(![apiMethod isEqualToString:@"index"]){
            
            myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", [[response objectForKey:@"err"] objectForKey:@"message"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            myAlertView.tag = ALERT_VIEW_TAG;
            
            NSLog(@"%@",[MFSideMenuManager sharedManager].navigationController.view);
            

            RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [MFSlidingView slideOut];
            for (int i = 0; i<[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies count]; i++) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies objectAtIndex:i]];
            }
            [appDelegate showLoginView];
            
            if (![[MFSideMenuManager sharedManager].navigationController.view viewWithTag:ALERT_VIEW_TAG]) {
                if (_myUserData.alertViewShown) {
                    return;
                }else{
                    [myAlertView show];
                    _myUserData.alertViewShown = YES;
                }
                
            }
            return;
            
        }


        
    }
    
    if([response isKindOfClass:[NSDictionary class]] && [[response objectForKey:@"auth"] integerValue] == 0 && ![apiMethod isEqualToString:@"index"]) {
        
        myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Authentication Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        myAlertView.tag = ALERT_VIEW_TAG;
        if (![[MFSideMenuManager sharedManager].navigationController.view viewWithTag:ALERT_VIEW_TAG]) {
            [myAlertView show];
            
        }
        
        RepAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [MFSlidingView slideOut];
        for (int i = 0; i<[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies count]; i++) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:[[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies objectAtIndex:i]];
        }
        [appDelegate showLoginView];
        return;
        
        
        
    }
    
    if(_completionHandler) {
        _completionHandler(response,nil);
    }
    
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if([_dataDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [_dataDelegate connection:connection didFailWithError:error];
    }
    
    if(_failureHandler) {
        _failureHandler(error);
        return;
    } else {
        if(!_lowConnection) {
            _lowConnection = YES;
            if([_requestDelegate respondsToSelector:@selector(radiusRequestDidDetectBadConnection:errorCode:)]) {
                [_requestDelegate radiusRequestDidDetectBadConnection:self errorCode:error.code];
            }
        }
    }
    
    
    // try again after a few seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self retry];
    });
}

-(void)cancel
{
    [_connection cancel];
}

-(void)retry
{
    [self startWithCompletionHandler:_completionHandler];
}

+(BOOL)lowConnection
{
    return _lowConnection;
}


@end
