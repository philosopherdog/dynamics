#import <Foundation/Foundation.h>

@class Tweet;
@protocol TweetStreamDelegate;

/// Connects to the twitter streaming API, allowing you to recieve tweets containing
/// a particular hashtag.
///
@interface TweetStream : NSObject

/// A delegate that will be called each time a tweet is received.
///
@property (nonatomic, weak) id<TweetStreamDelegate> delegate;

/// Opens a connection to the streaming API using the given keywords as the track parameter.
/// See the Twitter Streaming API for details.
///
/// @param keywords
///     Keywords to search for when streaming.
///
- (void)startStreamingTweetsWithKeywords:(NSString *)keywords;

/// Closes the connection to the streaming API.  Only one connection may open at a time so clients
/// should call this method when streaming is finished.
///
- (void)stopStreaming;

@end

/// Delegate protocol for streaming tweets.  Called whenever this stream recieves a tweet, passing
/// the tweet as a parameter.
///
@protocol TweetStreamDelegate <NSObject>

/// Notifies the delegate that a tweet was received.
///
/// @param stream
///     The TweetStream where the tweet originated.
///
/// @param tweet
///     The tweet that was received.
///
- (void)stream:(TweetStream *)stream didRecieveTweet:(Tweet *)tweet;

@end
