#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "PhotoViewController.h"
#import "PinchTransition.h"

@interface MainViewController () <UICollectionViewDataSource,
                                  UICollectionViewDelegate,
                                  UIGestureRecognizerDelegate,
                                  UINavigationControllerDelegate>

#pragma mark - Private Properties

/// Keeps a reference to the non-interactive transition displayed when the user taps on a photo.
///
@property (nonatomic, strong) PinchTransition *animatedPinchTransition;

/// Keeps a reference to the interactive transition displayed when the user pinch/zoom/rotates a
/// photo.
///
@property (nonatomic, strong) PinchTransition *interactivePinchTransition;

/// Keeps a reference to the user's photo stream. We ask for permission and display thumbnails in a
/// collection view.
///
@property (nonatomic, strong) ALAssetsLibrary *library;

/// An array of photos loaded from the library when the view is instantiated.
///
@property (nonatomic, strong) NSMutableArray *photos;

#pragma mark - Private Outlets

/// Collection view that we use to display the photos in a grid.
///
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

#pragma mark - Private Methods

/// Handles the pinch gesture to track the user's pinch/zoom and decide if we should display the
/// detail view for the photo.
///
- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer;

/// Handles the rotation gesture to rotate the currently selected photo.
///
- (void)handleRotationGestureRecognizer:(UIRotationGestureRecognizer *)rotationGestureRecognizer;

/// Returns an indexPath in the collection view based on the pinch gesture.
///
- (NSIndexPath *)indexPathForPinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer;

/// Returns the photo being displayed at the specified indexPath.
///
- (ALAsset *)photoForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MainViewController

#pragma mark - Init and dealloc methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _library = [[ALAssetsLibrary alloc] init];
        _photos = [NSMutableArray array];
    }

    return self;
}

#pragma mark - Private Methods

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self indexPathForPinchGestureRecognizer:pinchGestureRecognizer];

        if (indexPath != nil)
        {
            self.collectionView.scrollEnabled = NO;

            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *imageView = [[[[cell subviews] objectAtIndex:0] subviews] objectAtIndex:0];
            self.interactivePinchTransition = [[PinchTransition alloc] initFromImageView:imageView];

            PhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
            ALAsset *photo = [self photoForIndexPath:indexPath];
            photoViewController.photo = photo;

            [self.navigationController pushViewController:photoViewController animated:YES];
        }
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [pinchGestureRecognizer locationInView:self.view];
        [self.interactivePinchTransition updateInteractiveTransitionLocation:location];
        [self.interactivePinchTransition updateInteractiveTransitionScale:pinchGestureRecognizer.scale];
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded
        || pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (pinchGestureRecognizer.velocity > 1.5 || self.interactivePinchTransition.scale > 1.75)
        {
            [self.interactivePinchTransition finishInteractiveTransition];
        }
        else
        {
            [self.interactivePinchTransition cancelInteractiveTransition];
        }

        self.interactivePinchTransition = nil;
        self.collectionView.scrollEnabled = YES;
    }
}

- (void)handleRotationGestureRecognizer:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.interactivePinchTransition updateInteractiveTransitionRotation:rotationGestureRecognizer.rotation];
    }
}

- (NSIndexPath *)indexPathForPinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    CGPoint point1 = [pinchGestureRecognizer locationOfTouch:0 inView:self.collectionView];
    CGPoint point2 = [pinchGestureRecognizer locationOfTouch:1 inView:self.collectionView];
    NSIndexPath *indexPath1 = [self.collectionView indexPathForItemAtPoint:point1];
    NSIndexPath *indexPath2 = [self.collectionView indexPathForItemAtPoint:point2];

    if ([indexPath1 isEqual:indexPath2] == YES)
    {
        return indexPath1;
    }
    else
    {
        return nil;
    }
}

- (ALAsset *)photoForIndexPath:(NSIndexPath *)indexPath
{
    return self.photos[indexPath.row];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    ALAsset *photo = [self photoForIndexPath:indexPath];
    UIImageView *imageView = [[[[cell subviews] objectAtIndex:0] subviews] objectAtIndex:0];
    imageView.image = [UIImage imageWithCGImage:photo.aspectRatioThumbnail];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [[[[cell subviews] objectAtIndex:0] subviews] objectAtIndex:0];
    self.animatedPinchTransition = [[PinchTransition alloc] initFromImageView:imageView];

    PhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    ALAsset *photo = [self photoForIndexPath:indexPath];
    photoViewController.photo = photo;

    [self.navigationController pushViewController:photoViewController animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (self.animatedPinchTransition != nil)
    {
        return self.animatedPinchTransition;
    }
    else
    {
        return self.interactivePinchTransition;
    }
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactivePinchTransition;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;

    if (indexPaths.count == 1)
    {
        NSIndexPath *indexPath = indexPaths[0];
        ALAsset *photo = self.photos[indexPath.row];
        PhotoViewController *photoViewController = (PhotoViewController *)segue.destinationViewController;
        photoViewController.photo = photo;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.animatedPinchTransition = nil;
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.alwaysBounceVertical = YES;
    [self.photos removeAllObjects];

    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
        usingBlock:^(ALAssetsGroup *group, BOOL *stop)
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
            {
                if (result)
                {
                    [self.photos addObject:result];

                    if (index == group.numberOfAssets - 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [self.collectionView reloadData];
                        });
                    }
                }
            }];
        }
        failureBlock:^(NSError *error)
        {
            NSLog(@"Error: %@", error);
        }
    ];

    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    pinchGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:pinchGestureRecognizer];

    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGestureRecognizer:)];
    rotationGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:rotationGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

@end
