#import <Mantle/Mantle.h>

/// Partial representation of a tweet, retrieved from the streaming API.
///
@interface Tweet : MTLModel<MTLJSONSerializing>

/// The Twitter user's profile image.
///
@property (nonatomic, copy, readonly) NSURL *profileImageURL;

/// The text of the tweet.
///
@property (nonatomic, copy, readonly) NSString *text;

@end
