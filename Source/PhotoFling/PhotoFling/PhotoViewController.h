#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

/// View controller to display a photo and allow the user to fling the photo to dismiss with UIKit
/// dynamics. This view controller implements custom view controller transitions for dismissing
/// the view.
///
@interface PhotoViewController : UIViewController

#pragma mark - Properties

/// The photo to display.
///
@property (nonatomic, strong) ALAsset *photo;

#pragma mark - IBOutlets

/// A reference to the background view that's used by the custom transition to fade in and out the
/// background while the view controller is being displayed.
///
@property (nonatomic, weak) IBOutlet UIView *backgroundView;

/// A reference to the image view that's displaying the photo. This is used by the custom transition
/// to animate the image while the user transitions between MainViewController and this view
/// controller.
///
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end
