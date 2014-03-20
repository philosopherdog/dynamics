#import "PhotoViewController.h"
#import "FadeTransition.h"

@interface PhotoViewController () <UINavigationControllerDelegate>

#pragma mark - Private Properties

/// Dynamic animator reference to control our physics simulation.
///
@property (nonatomic, strong) UIDynamicAnimator *animator;

/// Attachment behavior to update the position of the photo based on the user's pan gesture.
///
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

/// Custom transition to fade out the view when the user flings the photo.
///
@property (nonatomic, strong) FadeTransition *fadeTransition;

/// Push behavior to fling the photo in the direction of the user's pan gesture.
///
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

/// Snap behavior to snap back the photo if the user's pan gesture wasn't a fling.
///
@property (nonatomic, strong) UISnapBehavior *snapBehavior;

#pragma mark - Private Methods

/// Handles the pan gesture and determines if the photo should be snapped back or flung to dismiss
/// this view.
///
- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer;

@end

@implementation PhotoViewController

#pragma mark - Private Methods

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint anchorPoint = [panGestureRecognizer locationInView:self.view];

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
//        [self.animator removeAllBehaviors];
//
//        CGPoint center = {
//            CGRectGetMidX(self.imageView.bounds),
//            CGRectGetMidY(self.imageView.bounds)
//        };
//
//        CGPoint touch = [panGestureRecognizer locationInView:self.imageView];
//        UIOffset offset = UIOffsetMake(touch.x - center.x, touch.y - center.y);
//
//        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.imageView
//                                                            offsetFromCenter:offset
//                                                            attachedToAnchor:anchorPoint];
//
//        [self.animator addBehavior:self.attachmentBehavior];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        self.attachmentBehavior.anchorPoint = anchorPoint;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
//        [self.animator removeAllBehaviors];
//
//        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
//        CGFloat magnitude = sqrtf(velocity.x * velocity.x + velocity.y * velocity.y);
//
//        if (magnitude > 1500.0)
//        {
//            CGFloat imageViewWidth = CGRectGetWidth(self.imageView.bounds);
//            CGFloat imageViewHeight = CGRectGetHeight(self.imageView.bounds);
//            CGFloat ratio = (imageViewWidth * imageViewHeight) / 10000;
//
//            // Constant ratio of of our view's size to the 100 x 100 point size square. Refer to
//            // the UIPushBehavior documentation for details.
//            CGVector pushDirection = CGVectorMake(velocity.x / ratio, velocity.y / ratio);
//
//            CGPoint touch = [panGestureRecognizer locationInView:self.view];
//            CGPoint center = self.imageView.center;
//            UIOffset offset = UIOffsetMake(touch.x - center.x, touch.y - center.y);
//
//            self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.imageView]
//                                                                 mode:UIPushBehaviorModeInstantaneous];
//
//            self.pushBehavior.pushDirection = pushDirection;
//            [self.pushBehavior setTargetOffsetFromCenter:offset forItem:self.imageView];
//            self.pushBehavior.active = YES;
//            [self.animator addBehavior:self.pushBehavior];
//
////            UIDynamicBehavior *exitCheckBehavior = [[UIDynamicBehavior alloc] init];
////
////            exitCheckBehavior.action = ^
////            {
////                if (CGRectIntersectsRect(self.view.bounds, self.imageView.frame) == NO)
////                {
////                    self.fadeTransition = [[FadeTransition alloc] init];
////                    [self.navigationController popViewControllerAnimated:YES];
////                }
////            };
////
////            [self.animator addBehavior:exitCheckBehavior];
//        }
//        else
//        {
//            self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.imageView
//                                                         snapToPoint:self.view.center];
//
//            self.snapBehavior.damping = 0.8;
//            [self.animator addBehavior:self.snapBehavior];
//        }
    }
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return self.fadeTransition;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    ALAssetRepresentation *representation = self.photo.defaultRepresentation;
    CGImageRef image = representation.fullScreenImage;
    self.imageView.image = [UIImage imageWithCGImage:image];

//    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                                           action:@selector(handlePanGesture:)];
//
//    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

@end
