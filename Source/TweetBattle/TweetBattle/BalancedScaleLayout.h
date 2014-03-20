#import <UIKit/UIKit.h>

/// A custom layout that balances items on a beam much like a balanced scale.
///
/// Items with an index path section of 0 will be added to the left side of the beam, while items
/// with an index path of 1 will be added to the right.
///
@interface BalancedScaleLayout : UICollectionViewLayout

@end
