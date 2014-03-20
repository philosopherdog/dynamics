#import "FadeTransition.h"

@implementation FadeTransition

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = transitionContext.containerView.bounds;

    [transitionContext.containerView insertSubview:toViewController.view
                                      belowSubview:fromViewController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
                     {
                         fromViewController.view.alpha = 0.0;
                         [transitionContext finishInteractiveTransition];
                     }
                     completion:^(BOOL finished)
                     {
                         [transitionContext completeTransition:YES];
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

@end
