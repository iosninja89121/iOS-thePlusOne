//
//  Constants.h
//  IFCC
//
//  Created by My Star on 6/10/16.
//  Copyright © 2016 My Star. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define BUTTON_WIDTH 140
#define BUTTON_HEIGHT 140

//***************** request url ***********************
#define REQUEST_PROVIDERS @"http://plusone-api-dev.herokuapp.com/v1/provider_profiles"
#define REQUEST_SIGN_UP @"http://plusone-api-dev.herokuapp.com/v1/users"
#define REQUEST_UPDATE_PROFILE @"http://plusone-api-dev.herokuapp.com/v1/users/"
#define REQUEST_SIGN_IN @"http://plusone-api-dev.herokuapp.com/v1/access_tokens"
#define REQUEST_SIGN_OUT @"http://plusone-api-dev.herokuapp.com/v1/access_tokens"
#define REQUEST_POST_ORDER @"http://plusone-api-dev.herokuapp.com/v1/orders?access_token="
#define REQUEST_POST_APPOINTMENT @"http://plusone-api-dev.herokuapp.com/v1/appointments?access_token="
#define REQUEST_PUT_APPOINTMENT_ID @"http://plusone-api-dev.herokuapp.com/v1/appointments/"
#define REQUEST_POST_APPOINTMENT_STREAMS @"http://plusone-api-dev.herokuapp.com/v1/appointment_streams/"
#define REQUEST_GET_APPOINTMENTS @"http://plusone-api-dev.herokuapp.com/v1/appointments?access_token="
#define REQUEST_POST_GIFT_SESSIONS @"http://plusone-api-dev.herokuapp.com/v1/gift_sessions?access_token="
#define REQUEST_GET_GIFT_SESSIONS @"http://plusone-api-dev.herokuapp.com/v1/gift_sessions?gift_code=giftCode&access_token=accessToken"
#define REQUEST_POST_APPOINTMENT_INVITES @"http://plusone-api-dev.herokuapp.com/v1/appointment_invites?access_token="
#define REQUEST_GET_APPOINTMENT_INVITES @"http://plusone-api-dev.herokuapp.com/v1/appointment_invites?invite_code=inviteCode"
#define REQUEST_PUT_APPOINTMENT_INVITES @"http://plusone-api-dev.herokuapp.com/v1/appointment_invites/inviteId?access_token=accessToken"

#define REQUEST_POST_USER_PROFILE @"http://plusone-api-dev.herokuapp.com/v1/user_profiles?access_token=accessToken"
#define REQUEST_GET_USER_PROFILE @"http://plusone-api-dev.herokuapp.com/v1/user_profiles/userId?access_token=accessToken"
#define REQUEST_PUT_USER_PROFILE @"http://plusone-api-dev.herokuapp.com/v1/user_profiles/profileId?access_token=accessToken"
//***************** user status ***********************
#define USER_STAT_MEET_NOW 0
#define USER_STAT_SCHEDULE 1
#define USER_STAT_GROUP_SESSION 2
#define USER_STAT_GO_SCHEDULE 3
#define USER_STAT_GIFT_SESSION 4
#define USER_STAT_PLUS_ONE 5

#define MODE_JOIN_NOW 1
#define MODE_JOIN_FUTURE 2

#define INVITE_MODE_JOIN_NOW 1
#define INVITE_MODE_JOIN_FUTURE 2
//***************** Message Constants *****************
#define MSG_EMAIL_BLANK                 @"Please enter your email address"
#define MSG_EMAIL_NOT_VALID             @"Please enter a valid email address"
#define MSG_PASSWORD_EMPTY              @"Password must be at least 5 characters in length"


#define MSG_LASTNAME_BLANK              @"Please enter your last name"
#define MSG_FIRSTNAME_BLANK              @"Please enter your first name"
#define MSG_NAME_EXIST              @"Sorry, but that username is already in use"
#define MSG_EMAIL_EXIST                 @"Sorry, but that email address is already in use"
#define MSG_NETWORK_ERROR          @"Please check your connection to Internet"


#define ERR_EMAIL_EXIST             @"duplicate key value violates unique constraint \"users_email_unique\""
//#define MSG_NAME_BLANK                  @"Please enter your full name"
//
//#define MSG_PASSWORD_LENGTH             @"Password should be more than 6 symbols"

//#define MSG_REPORT_SUCCESSED            @"Thank you, this post has been reported successfully"
//#define MSG_DESCRIPTION_ERROR           @"Description is too short (minimum is 3 characters)"
//#define MSG_CATEGORY_ERROR              @"Please select category"
//#define MSG_SELECT_PHOTO                @"Please select at least one picture"
//#define MSG_LOCATION_ERROR              @"Please select location"
//#define MSG_FRIEND_ERROR                @"Please select users"
//#define SERVER_ERROR_MESSAGE            @"Can't connect to server"
//#define MSG_SHOP_ADDED                  @"New Shop has added correctly"
//#define STATUS_MESSAGE_PLACEHOLDER      @"Status message"
//#define MSG_EMAIL_IN_SYSTEM             @"Please re-enter your password. The password you entered is incorrect. Please try again (make sure your caps lock is off).\n\nForgot your password? Request a new one."
//#define MSG_EMAIL_NOT_IN_SYSTEM         @"This email is not registered on Shopcrew. Please try again(make sure email address entered is correct).\n\nOr join now? Sign up should be a link"
//#define BLOCKED_USER_MESSAGE            @"Uh-oh. You are not authorized to perform this action"

#define MSG_JOIN_NOW @"Please join me in my current health session. Get started by downloading the +1 Health app at 'plus1health.com' and join the session now by entering the following invite code: sessionId"
#define MSG_JOIN_FUTURE @"Please join me in my health session on sessionDate at sessionTime. Get started by downloading the +1 Health app at 'plus1health.com' and join the session on sessionDate at sessionTime by entering the following invite code: sessionId"
#define DESCRIPTION_BEFORE_PLUSONE @"You don't have to do this alone, add someone to support you for the video session."
#define DESCRIPTION_AFTER_PLUSONE @"Your +1 has been contaced with the date and time of your scheduled appointment with instructions how to join."

//**************** keys for NSUserDefaults ***********************
#define KEY_LOGGED_IN                   @"loggedIn"
#define KEY_ACCESS_TOKEN                @"accessToken"
#define KEY_PROFILE                     @"profile"
#define KEY_PURCHASED_SESSIONS          @"purchasedSessions"

//submit payment view controller
#define PAYMENT_METHOD_IAP              1
#define PAYMENT_METHOD_INSURANCE        2
#define PAYMENT_METHOD_CARD             3
#define PAYMENT_METHOD_PAYPAL           4

#define NUM_OF_SESSIONS                 10
#define PRICE_PER_SESSION               0.00

//set time view controller
#define SET_DATE 0
#define SET_START_TIME 1
#define SET_END_TIME 2


#endif /* Constants_h */
