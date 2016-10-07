//
//  NetworkClient.h
//  shopcrew
//
//  Created by Alexey Kushnirov on 1/28/15.
//  Copyright (c) 2015 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkClient : NSObject
{
    
}

+ (NetworkClient*)sharedInstance;

- (void)getProvidersWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;

- (void)loginWithEmail:(NSString*)strEmail
              password:(NSString*)strPassword
               success:(void(^)(NSDictionary*))success
               failure:(void(^)(NSString*))failure;

- (void)signUpWithEmail:(NSString*)strEmail
               password:(NSString*)password
              firstName:(NSString*)firstName
               lastName:(NSString*)lastName
                success:(void(^)(NSDictionary*))success
                failure:(void(^)(NSString* message))failure;


- (void) postOrderWithId:(NSNumber*) iid
                  userId:(NSNumber*) userId
           sessionsCount:(NSNumber*) sessionsCount
                  isGift:(NSNumber*) isGift
           paymentMethod:(NSString*) paymentMethod
           transactionId:(NSString*) transactionId
             sessionRate:(NSNumber*) sessionRate
             totalAmount:(NSNumber*) totalAmount
               createdAt:(NSString*) createdTime
               updatedAt:(NSString*) updatedTime
                 success:(void(^)(NSDictionary*))success
                 failure:(void(^)(NSString* message))failure;

- (void) updateProfileWithUserId:(NSString*) strUserId
                            info:(NSDictionary*) dicInfo
                         success:(void(^)(NSDictionary*))success
                         failure:(void(^)(NSString* message))failure;

- (void) postAppointmentWithUserId:(NSNumber*) userId
                        providerId:(NSNumber*) providerId
                      scheduledFor:(NSString*) meetingTime
                           success:(void(^)(NSDictionary*))success
                           failure:(void(^)(NSString* message))failure;

- (void) putAppointmentWithAppointmentId:(NSInteger) appointmentId
                               status:(NSString*) status
                               rating:(NSNumber*) rating
                             feedback:(NSString*)feedback
                              success:(void(^)(NSDictionary*))success
                              failure:(void(^)(NSString* message))failure;
- (void) postAppointmentStreamsWithAppointmentId:(NSInteger) appointmentId
                                         success:(void(^)(NSDictionary*))success
                                         failure:(void(^)(NSString* message))failure;
- (void) getAppointmentsWithSuccess:(void(^)(NSArray*))success
                            failure:(void(^)(NSString* message))failure;
- (void) postGiftSessionsWithuserId:(NSInteger) userId
                            orderId:(NSInteger) orderId
                      sessionsCount:(NSInteger) sessionsCount
                     recipientPhone:(NSString*) recipientPhone
                            success:(void(^)(NSDictionary*))success
                            failure:(void(^)(NSString* message))failure;
- (void) getGiftSessionsWithGiftCode:(NSString*)giftCode
                             success:(void(^)(NSDictionary* dic))success
                             failure:(void(^)(NSString* message))failure;
- (void) postAppointmentInvitesWithappointmentId:(NSInteger) appointmentId
                            userId:(NSInteger) userId
                      firstName:(NSString*)firstName
                                        lastName:(NSString*)lastName
                    recipentPhone:(NSString*) recipientPhone
                            success:(void(^)(NSDictionary*))success
                            failure:(void(^)(NSString* message))failure;
- (void) getAppointmentInvitesWithInviteCode:(NSString*)inviteCode
                             success:(void(^)(NSDictionary* dic))success
                             failure:(void(^)(NSString* message))failure;
- (void) putAppointmentInvitesWithInviteId:(NSInteger)inviteId
                                    userId:(NSInteger)userId
                                     success:(void(^)(NSDictionary* dic))success
                                     failure:(void(^)(NSString* message))failure;

- (void) postUserProfileWithUserId:(NSInteger)userId
                     profilePicUrl:(NSString*)profilePictureUrl
                             phone:(NSString*)phone
                     notifications:(BOOL)notifications
                           success:(void(^)(NSDictionary* dic))success
                           failure:(void(^)(NSString* message))failure;
- (void) getUserProfileWithUserId:(NSInteger)userId
                          success:(void(^)(NSDictionary* dic))success
                          failure:(void(^)(NSString* message))failure;
- (void) putUserProfileWithProfileId:(NSInteger)profileId
                       profilePicUrl:(NSString*)profilePictureUrl
                               phone:(NSString*)phone
                       notifications:(BOOL)notifications
                             success:(void(^)(NSDictionary* dic))success
                             failure:(void(^)(NSString* message))failure;
/*
 - (void)receivedRequestWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)getSettingsList:(NSString*)strProfileId success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)editSettings:(NSString*)strEmail
            password:(NSString*)strPassword
            location:(NSString*)strLocation
              gender:(int)iGender
       posts_visible:(int) posts_visible
       push_messages:(int)push_messages
          push_votes:(int)push_votes
       push_comments:(int)push_comments
         push_follow:(int)push_follow
       push_requests:(int)push_requests
        push_friends:(int)push_friends
  push_feedback_tags:(int)push_feedback_tags
       push_reminder:(int)push_reminder
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure;

- (void)getCrewstersWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)getCrewsters: (int) user_id
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure;

- (void)addUserToCrew:(int)iUserId
              success:(void(^)(NSDictionary*))success
              failure:(void(^)(void))failure;

- (void) unfollowUserToCrew: (int) user_id
                    success:(void(^)(NSDictionary*))success
                    failure:(void(^)(void))failure;

- (void)getCrewzing:(int) user_id
            success:(void(^)(NSDictionary*))success
            failure:(void(^)(void))failure;


//Search.
- (void)searchUsers:(NSString*)strSearchParam
              limit: (int) limit
               skip: (int) skip
                lat: (float) lat
                lng: (float) lng
            success:(void(^)(NSArray*))success
            failure:(void(^)(void))failure;

- (void)searchByHashtag:(NSString*)strSearchParam
                success:(void(^)(NSArray*))success
                failure:(void(^)(void))failure;
- (void) getPopularFeedbacks: (int) limit
                        skip: (int) skip
                     success: (void(^)(NSArray *arrResponse))success
                     failure:(void(^)(void))failure;
- (void)searchUsersByName: (NSString*)username success:(void(^)(NSArray*))success failure:(void(^)(void))failure;
- (void)getNearbyFeedback: (float)lat
                      lng: (float)lng
                    limit: (int) limit
                     skip: (int) skip
                  success: (void(^)(NSArray *arrResponse))success
                  failure:(void(^)(void))failure;
- (void)searchFriendsFriend: (void(^)(NSArray*))success failure:(void(^)(void))failure;


//Feedback.
- (void) getFeedbackWithSuccessBlock: (int) limit
                               skip: (int) skip
                            success: (void(^)(NSArray *arrResponse))success
                            failure:(void(^)(void))failure;
- (void)getFeedbackOfUser: (int) limit
                     skip: (int) skip
                  user_id: (int) user_id
                  success: (void(^)(NSArray *arrResponse))success
                  failure:(void(^)(void))failure;

- (void) getOneFeedback: (int) feedback_id
                success: (void(^)(NSDictionary *arrResponse))success
                failure:(void(^)(void))failure;

- (void) getFeedbackByHashTagName: (NSString*) hashtag
                          success: (void(^)(NSArray *arrResponse))success
                          failure:(void(^)(void))failure;

- (void) getFeedbackByHashtag: (int) hash_id
                        limit: (int) limit
                         skip: (int) skip
                      success: (void(^)(NSArray *arrResponse))success
                      failure:(void(^)(void))failure;

- (void) deleteFeedback: (int)feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void) getShareTemplate: (int)feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void) reportFeedback: (int) feedback_id success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void) makeVoteWithItemId:(NSNumber*)itemId success:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;
- (void) makeVoteWithItemId:(NSNumber*)itemId type:(NSNumber*)type success:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;
- (void) getPhotoMapFeedback: (NSString*) locationId
                     success: (void(^)(NSArray *arrResponse))success
                     failure:(void(^)(void))failure;

//Profile.
- (void)getMyProfileWithSuccessBlock:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)getUserProfile:(NSString*)strProfileId success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)editProfile:(NSString*)strFullname
              phone:(NSString*)strPhone
            website:(NSString*)website
     status_message:(NSString*)status_message
      posts_visible:(int)posts_visible
           image_id:(int)image_id
            success:(void(^)(NSDictionary*))success
            failure:(void(^)(void))failure;

- (void)editUsername:(NSString*) username
             success:(void(^)(NSDictionary*))success
             failure:(void(^)(void))failure;
- (void) getSettingsView:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)uploadAvatarWithData:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;

- (void) getExploreWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;
- (void) getRegisteredEmails: (NSArray*) arrEmail success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;
- (void) getRegisteredPhones: (NSArray*) arrPhone success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;

//Create Item.
- (void)createShopItem:(NSMutableDictionary*) diccSharedParams
          andImageData:(NSMutableArray*)arrImgData
               success:(void(^)(void)) success
               failure:(void(^)(void))failure;
- (void)uploadImageWithData:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;
- (void)checkSocialTokens:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;
- (void)setSocialTokens:(int) provider
                  token: (NSString*) token
            expiry_time: (int)expiry_time
         social_user_id: (int)social_user_id
          signedRequest: (NSString*)signedRequest
                 secret: (NSString*)secret
                success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;

- (void)findFriendsWithNumbers:(NSArray*)arrNumbers success:(void(^)(NSDictionary*))success failure:(void(^)(void))failure;
- (void)sendInviteWithContacts:(NSArray*)attContacts success:(void(^)(void))success failure:(void(^)(void))failure;
- (void)getFriendsOfFriends:(NSArray*)arrNumbers success:(void(^)(NSDictionary *dicResp)) success failure:(void(^)(void))failure;
- (void)getCommentsForForItemWithId:(int)itemID success:(void(^)(NSArray *dicResp)) success failure:(void(^)(void))failure;
- (void)addCommentsForItemWithId:(int)itemID withText:(NSString*)strText success:(void(^)(void))success failure:(void(^)(void))failure;
- (void)reportComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure;
- (void)deleteComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure;
- (void)getVotesForItemsId:(int)itemID success:(void(^)(NSArray *arrResult)) success failure:(void(^)(void))failure;
- (void)getCategoriesWithSuccessBlock:(void(^)(NSArray *dicResp)) success failure:(void(^)(void))failure;
- (void)getBrowseWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;
- (void)getMyListWithSuccessBlock:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;
- (void)getProfileInfo:(void(^)(NSDictionary *dicResponse))success failure:(void(^)(void))failure;

//Activity.
- (void)getActivity: (int) userId
              is_my: (int) is_my
              limit: (int) limit
               skip: (int) skip
            success:(void(^)(NSArray *arrResult))success failure:(void(^)(void))failure;
- (void) cancelAllRequest;

#pragma mark User Place.
- (void) createUserPlace: (NSString*) google_id
                 address: (NSString*)address
                    name: (NSString*)name
                     lat: (float) lat
                     lng: (float) lng
                 success:(void(^)(NSDictionary *dicResponse)) success
                 failure:(void(^)(void))failure;

- (void) getShopList: (int) user_id
             success:(void(^)(NSArray *arrResult)) success
             failure:(void(^)(void))failure;

- (void) deletePlaceList: (int) shopId
                 success:(void(^)(NSDictionary *dicResponse)) success
                 failure:(void(^)(void))failure;

- (void) userWalking: (float) lat
                 lng: (float) lng
             success:(void(^)(NSDictionary *dicResponse)) success
             failure:(void(^)(void))failure;

//Location Services.
- (void)searchPlaces:(NSString *)keyword
              radius:(int)radius
                 lat: (float) lat
                 lng: (float) lng
             success:(void (^)(NSArray *))success
             failure:(void (^)(NSString *))failure;

- (void) searchGlobalPlaces: (NSString*) keyword
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSString *))failure;

//Direct Message.
- (void)createDirectMessage:(NSMutableDictionary*) diccSharedParams
               andImageData:(NSMutableArray*)arrImgData
               success:(void(^)(void)) success
               failure:(void(^)(void))failure;
- (void)uploadDMImage:(NSData*)imgData success:(void(^)(NSDictionary *dicResponse)) success failure:(void(^)(void))failure;
- (void) getDMList:(int) limit
              skip:(int) skip
           success:(void(^)(NSArray *arrResponse))success
           failure:(void(^)(void))failure;
- (void) deleteDM:(int) dm_id
          success:(void(^)(void))success
          failure:(void(^)(void))failure;
- (void)makeDMVoteWithItemId:(NSNumber*)itemId
                     success:(void(^)(NSDictionary *dicResponse))success
                     failure:(void(^)(void))failure;
- (void) makeDMVoteWithItemId:(NSNumber*)itemId
                         type:(NSNumber*)type
                      success:(void(^)(NSDictionary *dicResponse))success
                      failure:(void(^)(void))failure;
- (void) getDMComments:(int) message_id
                 limit:(int) limit
                  skip:(int) skip
               success:(void(^)(NSArray *arrResponse))success
               failure:(void(^)(void))failure;
- (void)addDMComment:(int)itemID withText:(NSString*)strText success:(void(^)(void))success failure:(void(^)(void))failure;
- (void)reportDMComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure;
 
- (void)deleteDMComment: (int)commentID success:(void(^)(void))success failure:(void(^)(void))failure;
*/

@end

