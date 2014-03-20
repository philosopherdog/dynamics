#import <UIKit/UIKit.h>

/// A simple decoration view for displaying a beam.
///
@interface BeamView : UICollectionReusableView

/// Helper method for this kind of decoration view
///
+ (NSString *)kind;

/// Helper method for the index path of this decoration view.
///
+ (NSIndexPath *)indexPath;

@end
