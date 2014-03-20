#import "PinchTransition.h"
#import "MainViewController.h"
#import "PhotoViewController.h"

@interface PinchTransition()

#pragma mark - Private Properties

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) id <UIViewControllerContextTransitioning> context;
@property (nonatomic, strong) UIImageView *fromImageView;
@property (nonatomic, assign, readwrite) CGFloat rotation;
@property (nonatomic, assign, readwrite) CGFloat scale;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIImageView *toImageView;

@end

@implementation PinchTransition

#pragma mark - Init Methods

- (id)initFromImageView:(UIImageView *)fromImageView
{
    if ((self = [super init]))
    {
        _fromImageView = fromImageView;
    }

    return self;
}

#pragma mark - Instance Methods

- (void)cancelInteractiveTransition
{
    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];

    CGPoint fromImageViewCenter = [self.context.containerView convertPoint:self.fromImageView.center
                                                                  fromView:self.fromImageView.superview];

    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:photoViewController.imageView
                                                            snapToPoint:fromImageViewCenter];

    snapBehavior.damping = 0.8;

    [self.animator removeAllBehaviors];
    [self.animator addBehavior:snapBehavior];

    [UIView animateWithDuration:[self transitionDuration:self.context]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
                     {
                         photoViewController.backgroundView.alpha = 0.0;
                         self.toImageView.transform = CGAffineTransformIdentity;
                         self.toImageView.bounds = self.fromImageView.bounds;
                         [self.context cancelInteractiveTransition];
                     }
                     completion:^(BOOL finished)
                     {
                         self.fromImageView.alpha = 1.0;
                         [self.context completeTransition:NO];
                     }];
}

- (void)finishInteractiveTransition
{
    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];

    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:photoViewController.imageView
                                                            snapToPoint:photoViewController.view.center];

    snapBehavior.damping = 0.8;

    [self.animator removeAllBehaviors];
    [self.animator addBehavior:snapBehavior];

    [UIView animateWithDuration:[self transitionDuration:self.context]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
                     {
                         photoViewController.backgroundView.alpha = 100.0;
                         self.toImageView.transform = CGAffineTransformIdentity;
                         self.toImageView.bounds = photoViewController.view.bounds;
                         self.toImageView.contentMode = UIViewContentModeScaleAspectFit;
                         [self.context finishInteractiveTransition];
                     }
                     completion:^(BOOL finished)
                     {
                         self.fromImageView.alpha = 1.0;
                         [self.context completeTransition:YES];
                     }];
}

- (CGFloat)percentComplete
{
    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];

    CGSize currentSize = self.toImageView.frame.size;
    CGSize initialSize = self.fromImageView.frame.size;
    CGSize fullSize = photoViewController.view.frame.size;

    BOOL initialLandscape = self.fromImageView.image.size.width > self.fromImageView.image.size.height;
    BOOL currentLandscape = currentSize.width > currentSize.height;

    if (initialLandscape != currentLandscape)
    {
        CGFloat currentHeight = currentSize.height;
        currentSize.height = currentSize.width;
        currentSize.width = currentHeight;
    }

    CGFloat percentComplete;

    if (initialLandscape)
    {
        // Landscape
        percentComplete = (currentSize.width - initialSize.width) / (fullSize.width - initialSize.width);
    }
    else
    {
        // Portrait
        percentComplete = (currentSize.height - initialSize.height) / (fullSize.height - initialSize.height);
    }

    percentComplete = MIN(MAX(percentComplete, 0.0), 1.0);

    return percentComplete;
}

- (void)updateInteractiveTransitionLocation:(CGPoint)location
{
    self.toImageView.center = location;
}

- (void)updateInteractiveTransitionRotation:(CGFloat)rawRotation
{
    CGFloat adjustedRotation = rawRotation - self.rotation;
    self.rotation = rawRotation;
    self.toImageView.transform = CGAffineTransformRotate(self.toImageView.transform, adjustedRotation);
}

- (void)updateInteractiveTransitionScale:(CGFloat)rawScale
{
    CGFloat adjustedScale = 1.0 + rawScale - self.scale;
    self.scale = rawScale;
    self.toImageView.transform = CGAffineTransformScale(self.toImageView.transform, adjustedScale, adjustedScale);

    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];

    CGFloat percentComplete = [self percentComplete];
    photoViewController.backgroundView.alpha = percentComplete;
    [self.context updateInteractiveTransition:percentComplete];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;

    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    photoViewController.backgroundView.alpha = 0.0;
    photoViewController.view.frame = self.context.containerView.bounds;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:photoViewController.view];
    self.toImageView = photoViewController.imageView;

    CGRect fromImageViewFrame = [self.context.containerView convertRect:self.fromImageView.frame
                                                               fromView:self.fromImageView.superview];

    self.toImageView.frame = fromImageViewFrame;
    self.toImageView.contentMode = self.fromImageView.contentMode;

    [self.context.containerView addSubview:photoViewController.view];
    self.fromImageView.alpha = 0.0;

    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:photoViewController.imageView
                                                            snapToPoint:photoViewController.view.center];

    snapBehavior.damping = 0.8;

    [self.animator removeAllBehaviors];
    [self.animator addBehavior:snapBehavior];

    [UIView animateWithDuration:[self transitionDuration:self.context]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
                     {
                         photoViewController.backgroundView.alpha = 1.0;
                         self.toImageView.bounds = photoViewController.view.bounds;
                         self.toImageView.contentMode = UIViewContentModeScaleAspectFit;
                     }
                     completion:^(BOOL finished)
                     {
                         self.fromImageView.alpha = 1.0;
                         [self.context completeTransition:YES];
                     }];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    // Don't need to do anything.
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;

    PhotoViewController *photoViewController = (PhotoViewController *)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    photoViewController.backgroundView.alpha = 0.0;
    photoViewController.view.frame = self.context.containerView.bounds;

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:photoViewController.view];
    self.rotation = 0.0;
    self.scale = 1.0;
    self.toImageView = photoViewController.imageView;

    CGRect fromImageViewFrame = [self.context.containerView convertRect:self.fromImageView.frame
                                                               fromView:self.fromImageView.superview];

    self.toImageView.frame = fromImageViewFrame;

    size_t imageWidth = self.fromImageView.image.size.width;
    size_t imageHeight = self.fromImageView.image.size.height;
    CGFloat aspectRatio =  imageWidth / (imageHeight * 1.0);
    CGRect toImageViewBounds = self.fromImageView.bounds;

    if (imageWidth > imageHeight)
    {
        // Landscape
        toImageViewBounds.size.width = toImageViewBounds.size.height * aspectRatio;
    }
    else
    {
        // Portrait
        toImageViewBounds.size.height = toImageViewBounds.size.width / aspectRatio;
    }

    [self.context.containerView addSubview:photoViewController.view];

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
                     {
                         self.fromImageView.alpha = 0.0;
                         self.toImageView.bounds = toImageViewBounds;
                         self.toImageView.contentMode = self.fromImageView.contentMode;
                     }
                     completion:nil];
}

@end
