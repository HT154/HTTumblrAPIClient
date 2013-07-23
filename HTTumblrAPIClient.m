//
//  TMAPIClient+TMAPIClientPrivateMethods.m
//  Treadr
//
//  Created by Joshua Basch on 5/16/13.
//  Copyright (c) 2013 HT154. All rights reserved.
//

#import "HTTumblrAPIClient.h"
#import "NSData+Base64.h"

@interface TMAPIClient (InternalPrivateMethods)

NSString *blogPath(NSString *ext, NSString *blogName);
NSString *URLWithPath(NSString *path);
- (JXHTTPOperation *)getRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (JXHTTPOperation *)postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
- (JXHTTPOperation *)multipartPostRequest:(NSString *)blogName type:(NSString *)type parameters:(NSDictionary *)parameters filePathArray:(NSArray *)filePathArray contentTypeArray:(NSArray *)contentTypeArray;
- (JXHTTPMultipartBody *)multipartBodyForParameters:(NSDictionary *)parameters filePathArray:(NSArray *)filePathArray contentTypeArray:(NSArray *)contentTypeArray;
- (void)signRequest:(JXHTTPOperation *)request withParameters:(NSDictionary *)parameters;

@end

@implementation HTTumblrAPIClient

+ (id)sharedInstance{
    static HTTumblrAPIClient *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{ instance = [[HTTumblrAPIClient alloc] init]; });
    return instance;
}

#pragma mark API Methods

//reply
- (JXHTTPOperation *)replyRequest:(NSString *)postID reblogKey:(NSString *)reblogKey replyText:(NSString *)replyText{
	return [self postRequestWithPath:@"user/post/reply" parameters:@{@"post_id": postID, @"reblog_key": reblogKey, @"reply_text": replyText}];
}

- (void)reply:(NSString *)postID reblogKey:(NSString *)reblogKey replyText:(NSString *)replyText callback:(TMAPICallback)callback{
	[self sendRequest:[self replyRequest:postID reblogKey:reblogKey replyText:replyText] callback:callback];
}

//ask
- (JXHTTPOperation *)askRequest:(NSString *)blogName question:(NSString *)question anonymous:(BOOL)anonymous;{
	return [self postRequestWithPath:blogPath(@"ask", blogName) parameters:@{@"tumblelog": blogName, @"question": question, @"anonymous": @(anonymous)}];
}

- (void)ask:(NSString *)blogName question:(NSString *)question anonymous:(BOOL)anonymous callback:(TMAPICallback)callback{
	[self sendRequest:[self askRequest:blogName question:question anonymous:anonymous] callback:callback];
}

//notes GET
-(JXHTTPOperation *)notesRequest:(NSString *)blogName postID:(NSString *)postID parameters:(NSDictionary *)parameters{
	NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	mutableParameters[@"id"] = postID;
	return [self getRequestWithPath:blogPath(@"notes", blogName) parameters:mutableParameters];
}

-(void)notes:(NSString *)blogName postID:(NSString *)postID parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback{
	[self sendRequest:[self notesRequest:blogName postID:postID parameters:parameters] callback:callback];
}

//reply to ask
-(JXHTTPOperation *)replyToAskRequest:(NSString *)blogName parameters:(NSDictionary *)parameters{
	return [self postRequestWithPath:blogPath(@"question/reply", blogName) parameters:parameters];
}

-(void)replyToAsk:(NSString *)blogName parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback{
	[self sendRequest:[self replyToAskRequest:blogName parameters:parameters] callback:callback];
}

//fanmail
-(JXHTTPOperation *)fanmailRequest:(NSString *)blogName parameters:(NSDictionary *)parameters{
	return [self postRequestWithPath:blogPath(@"fanmail", blogName) parameters:parameters];
}

-(void)fanmail:(NSString *)blogName parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback{
	[self sendRequest:[self fanmailRequest:blogName parameters:parameters] callback:callback];
}

//tracked tags GET
-(JXHTTPOperation *)trackedTagsRequest{
	return [self getRequestWithPath:@"user/tags" parameters:nil];
}

-(void)trackedTags:(TMAPICallback)callback{
	[self sendRequest:[self trackedTagsRequest] callback:callback];
}

//track tag
-(JXHTTPOperation *)trackTagRequest:(NSString *)tag{
	return [self postRequestWithPath:@"user/tags/add" parameters:@{@"tag": tag}];
}

-(void)trackTag:(NSString *)tag callback:(TMAPICallback)callback{
	[self sendRequest:[self trackTagRequest:tag] callback:callback];
}

//untrack tag
-(JXHTTPOperation *)untrackTagRequest:(NSString *)tag{
	return [self postRequestWithPath:@"user/tags/remove" parameters:@{@"tag": tag}];
}

-(void)untrackTag:(NSString *)tag callback:(TMAPICallback)callback{
	[self sendRequest:[self untrackTagRequest:tag] callback:callback];
}

//mark tag read
-(JXHTTPOperation *)readTagRequest:(NSString *)tag{
	return [self postRequestWithPath:[NSString stringWithFormat:@"user/tags/%@/read",[tag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] parameters:nil];
}

-(void)readTag:(NSString *)tag callback:(TMAPICallback)callback{
	[self sendRequest:[self readTagRequest:tag] callback:callback];
}

//search
-(JXHTTPOperation *)searchRequest:(NSString *)query{
	return [self getRequestWithPath:[NSString stringWithFormat:@"search/%@",[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] parameters:nil];
}

-(void)search:(NSString *)query callback:(TMAPICallback)callback{
	[self sendRequest:[self searchRequest:query] callback:callback];
}

//notifications GET
-(JXHTTPOperation *)notificationsRequest{
	return [self getRequestWithPath:@"user/notifications" parameters:nil];
}

-(void)notifications:(TMAPICallback)callback{
	[self sendRequest:[self notificationsRequest] callback:callback];
}

//upload avatar
-(JXHTTPOperation *)uploadAvatarRequest:(NSString *)blogName imagePath:(NSString *)imagePath{
	JXHTTPOperation *request = [JXHTTPOperation withURLString:URLWithPath(blogPath(@"avatar", blogName))];
	request.requestMethod = @"POST";
	request.continuesInAppBackground = YES;
	
	NSDictionary *parameters = @{@"api_key": self.OAuthConsumerKey, @"data": [[[NSData alloc] initWithContentsOfFile:imagePath] base64EncodedStringWithSeparateLines:YES]};
	
	request.requestBody = [JXHTTPFormEncodedBody withDictionary:parameters];
	[self signRequest:request withParameters:parameters];
	
	return request;
}

-(void)uploadAvatar:(NSString *)blogName imagePath:(NSString *)imagePath callback:(TMAPICallback)callback{
	[self sendRequest:[self uploadAvatarRequest:blogName imagePath:imagePath] callback:callback];
}

#pragma mark Override to fix response for avatar upload requests

- (void)sendRequest:(JXHTTPOperation *)request queue:(NSOperationQueue *)queue callback:(TMAPICallback)callback {
    if (callback) {
        __block typeof(callback) blockCallback = callback;
        
        request.didFinishLoadingBlock = ^(JXHTTPOperation *operation) {
			NSDictionary *response = nil;
			if(([operation.request.URL.absoluteString rangeOfString:@"/avatar"].location != NSNotFound) && [operation.request.HTTPMethod isEqual:@"POST"]){
				response = [NSJSONSerialization JSONObjectWithData:[[[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"{\"meta\":{\"status\":400,\"msg\":\"Bad Request\"},\"response\":{\"errors\":\"You must supply the source for the image\"}}" withString:@""] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
			}else{
				response = operation.responseJSON;
			}
			int statusCode = response[@"meta"] ? [response[@"meta"][@"status"] intValue] : 0;
			
			NSError *error = nil;
			
			if (statusCode/100 != 2)
				error = [NSError errorWithDomain:@"Request failed" code:statusCode userInfo:nil];
			
			[queue addOperationWithBlock:^{
				blockCallback(response[@"response"], error);
				blockCallback = nil;
			}];
        };
        
        request.didFailBlock = ^(JXHTTPOperation *operation) {
            [queue addOperationWithBlock:^{
                blockCallback(nil, operation.error);
                blockCallback = nil;
            }];
        };
    }
    
    [self.queue addOperation:request];
}

@end
