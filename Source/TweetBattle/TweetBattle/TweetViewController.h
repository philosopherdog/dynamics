#import <UIKit/UIKit.h>

/// Displays an epic battle between users that tweet one of two hashtags.
///
@interface TweetViewController : UICollectionViewController

/// Tweets containing this hashtag will be attached to the left side of the beam.
///
@property (nonatomic, strong) NSString *leftHashtag;

/// Tweets containing this hashtag will be attached to the right side of the beam.
///
@property (nonatomic, strong) NSString *rightHashtag;

@end
