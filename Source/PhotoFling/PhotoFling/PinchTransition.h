#import <AssetsLibrary/AssetsLibrary.h>

/// Custom view controller transition to allow the user to pinch/zoom/rotate photos from the
/// collection view in MainViewController. This transition handles setting up the transition, fading
/// in and out the destination view's background, and cleaning up after the transition is finised or
/// cancelled.
///
/// The view controller that initiated the transition should send periodic updates about the current
/// state of the view to this transition based on the updateInteractiveTransition*: methods.
///
/// The transition uses the scale of the image in the transition to determine the current completion
/// percentage.
///
@interface PinchTransition : NSObject <UIViewControllerAnimatedTransitioning,
                                       UIViewControllerInteractiveTransitioning>

#pragma mark - Properties

/// Current rotation amount applied to the selected photo during the transition. This value is read-
/// only. Use the updateInteractiveTransitionRotation: to indicate a new value.
///
@property (nonatomic, assign, readonly) CGFloat rotation;

/// Current scale amount applied to the selected photo during the transition. This value is read-
/// only. Use the updateInteractiveTransitionScale: method to indicate a new value.
///
@property (nonatomic, assign, readonly) CGFloat scale;

#pragma mark - Init Methods

/// Creates a new instance of the transition with the specified source image view.
///
/// @param fromImageView
///     The image view that is being transitioned to the new destination.
///
- (id)initFromImageView:(UIImageView *)fromImageView;

#pragma mark - Instance Methods

/// Cancels the transition.
///
- (void)cancelInteractiveTransition;

/// Finishes the transition and fully displays the destination view controller.
///
- (void)finishInteractiveTransition;

/// Indicates the current transition completion percentage.
///
- (CGFloat)percentComplete;

/// Updates the location value of the image view. This will reposition the image.
///
- (void)updateInteractiveTransitionLocation:(CGPoint)location;

/// Updates the rotation value for the image view transform. This will rotate the image.
///
- (void)updateInteractiveTransitionRotation:(CGFloat)rotation;

/// Updates the scale value for the image view transform. This will scale the image.
///
- (void)updateInteractiveTransitionScale:(CGFloat)scale;

@end
