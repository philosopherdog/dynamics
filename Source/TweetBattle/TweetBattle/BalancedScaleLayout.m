#import "BalancedScaleLayout.h"
#import "BeamAttachmentBehavior.h"
#import "BeamView.h"

static CGSize const kItemSize = {40.0f, 40.0f};

@interface BalancedScaleLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@end

@implementation BalancedScaleLayout

#pragma mark - Init methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self registerClass:[BeamView class]
    forDecorationViewOfKind:[BeamView kind]];

        self.animator = [[UIDynamicAnimator alloc]
                         initWithCollectionViewLayout:self];
    }
    
    return self;
}

#pragma mark - Private methods

- (CGRect)beamFrame
{
    CGFloat beamWidth = 0.5 * self.collectionViewContentSize.width;
    
    return (CGRect)
    {
        .origin.x = CGRectGetMidX(self.collectionView.bounds) -
            beamWidth * 0.5,
        .origin.y = CGRectGetMidY(self.collectionView.bounds),
        .size.width = beamWidth,
        .size.height = 10.0f
    };
}

- (CGRect)itemFrame
{
    return (CGRect)
    {
        .origin.x = CGRectGetMidX(self.collectionView.bounds) -
            kItemSize.width * 0.5,
        .origin.y = CGRectGetMaxY(self.collectionView.bounds) +
            kItemSize.height,
        .size = kItemSize
    };
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)
    layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

- (UICollectionViewLayoutAttributes *)
    layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                atIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator
            layoutAttributesForDecorationViewOfKind:decorationViewKind
                                        atIndexPath:indexPath];
}

- (void)prepareLayout
{
    if (self.animator.behaviors.count == 0)
    {
        // Create a decoration view for the beam
        UICollectionViewLayoutAttributes *beam;
        beam = [UICollectionViewLayoutAttributes
                layoutAttributesForDecorationViewOfKind:[BeamView kind]
                                          withIndexPath:[BeamView indexPath]];
        beam.frame = [self beamFrame];
        
        // Adding resistance to the beam so it's harder to tip
        UIDynamicItemBehavior *resistance;
        resistance = [[UIDynamicItemBehavior alloc]
                      initWithItems:@[beam]];
        resistance.angularResistance = 300.0f;
        [self.animator addBehavior:resistance];
        
        // Attach the beam to the center
        UIAttachmentBehavior *attachmentBehavior;
        attachmentBehavior = [[UIAttachmentBehavior alloc]
                              initWithItem:beam
                              attachedToAnchor:beam.center];
        [self.animator addBehavior:attachmentBehavior];
        
        // Adding gravity
        UIGravityBehavior *gravityBehavior =
            [[UIGravityBehavior alloc]
             initWithItems:@[beam]];
        [self.animator addBehavior:gravityBehavior];
        self.gravityBehavior = gravityBehavior;
        
        // Setup collisions for later when items are added
        UICollisionBehavior *collisionBehavior =
            [[UICollisionBehavior alloc]
             initWithItems:@[]];
        [self.animator addBehavior:collisionBehavior];
        self.collisionBehavior = collisionBehavior;
    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    for (UICollectionViewUpdateItem *item in updateItems)
    {
        if (item.updateAction == UICollectionUpdateActionInsert)
        {
            // Set the new item's initial position
            NSIndexPath *path = item.indexPathAfterUpdate;
            UICollectionViewLayoutAttributes *item;
            item = [UICollectionViewLayoutAttributes
                    layoutAttributesForCellWithIndexPath:path];
            item.frame = [self itemFrame];
            
            // Grab the beam
            UICollectionViewLayoutAttributes *beam =
            [self layoutAttributesForDecorationViewOfKind:[BeamView kind]
                                              atIndexPath:[BeamView indexPath]];
            
            BeamAttachmentBehavior *beamAttachment =
                [[BeamAttachmentBehavior alloc]
                     initWithItem:item
                   attachedToBeam:beam
                           onLeft:(item.indexPath.section == 0)];
            
            [self.animator addBehavior:beamAttachment];
            
            [self.collisionBehavior addItem:item];
            [self.gravityBehavior addItem:item];
        }
    }
}

@end
