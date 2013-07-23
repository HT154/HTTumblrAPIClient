//
//  TMAPIClient+TMAPIClientPrivateMethods.h
//  Treadr
//
//  Created by Joshua Basch on 5/16/13.
//  Copyright (c) 2013 HT154. All rights reserved.
//

#import "TMAPIClient.h"

@interface HTTumblrAPIClient : TMAPIClient

+ (HTTumblrAPIClient *)sharedInstance;

//reply
- (JXHTTPOperation *)replyRequest:(NSString *)postID reblogKey:(NSString *)reblogKey replyText:(NSString *)replyText;
- (void)reply:(NSString *)postID reblogKey:(NSString *)reblogKey replyText:(NSString *)replyText callback:(TMAPICallback)callback;

//ask
- (JXHTTPOperation *)askRequest:(NSString *)blogName question:(NSString *)question anonymous:(BOOL)anonymous;
- (void)ask:(NSString *)blogName question:(NSString *)question anonymous:(BOOL)anonymous callback:(TMAPICallback)callback;

//notes
-(JXHTTPOperation *)notesRequest:(NSString *)blogName postID:(NSString *)postID parameters:(NSDictionary *)parameters;
-(void)notes:(NSString *)blogName postID:(NSString *)postID parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback;

//reply to ask
-(JXHTTPOperation *)replyToAskRequest:(NSString *)blogName parameters:(NSDictionary *)parameters;
-(void)replyToAsk:(NSString *)blogName parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback;

//fanmail
-(JXHTTPOperation *)fanmailRequest:(NSString *)blogName parameters:(NSDictionary *)parameters;
-(void)fanmail:(NSString *)blogName parameters:(NSDictionary *)parameters callback:(TMAPICallback)callback;

//tracked tags
-(JXHTTPOperation *)trackedTagsRequest;
-(void)trackedTags:(TMAPICallback)callback;

//track tag
-(JXHTTPOperation *)trackTagRequest:(NSString *)tag;
-(void)trackTag:(NSString *)tag callback:(TMAPICallback)callback;

//untrack tag
-(JXHTTPOperation *)untrackTagRequest:(NSString *)tag;
-(void)untrackTag:(NSString *)tag callback:(TMAPICallback)callback;

//mark tag read
-(JXHTTPOperation *)readTagRequest:(NSString *)tag;
-(void)readTag:(NSString *)tag callback:(TMAPICallback)callback;
  
//search
-(JXHTTPOperation *)searchRequest:(NSString *)query;
-(void)search:(NSString *)query callback:(TMAPICallback)callback;

//notifications
-(JXHTTPOperation *)notificationsRequest;
-(void)notifications:(TMAPICallback)callback;

//upload avatar
-(JXHTTPOperation *)uploadAvatarRequest:(NSString *)blogName imagePath:(NSString *)imagePath;
-(void)uploadAvatar:(NSString *)blogName imagePath:(NSString *)imagePath callback:(TMAPICallback)callback;

@end