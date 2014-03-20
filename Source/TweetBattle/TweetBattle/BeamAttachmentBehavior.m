#import "BeamAttachmentBehavior.h"

@implementation BeamAttachmentBehavior

- (instancetype)initWithItem:(id<UIDynamicItem>)item
              attachedToBeam:(id<UIDynamicItem>)beam
                      onLeft:(BOOL)left
{
    self = [super init];
    
    if (self)
    {
        CGSize beamSize = beam.bounds.size;
        
        UIOffset attachmentOffset = UIOffsetMake((left ? -0.5f : 0.5f) * beamSize.width, 0.0f);
        
        UIAttachmentBehavior *itemBeamAttachment = [[UIAttachmentBehavior alloc] initWithItem:item
                                                                             offsetFromCenter:UIOffsetZero
                                                                               attachedToItem:beam
                                                                             offsetFromCenter:attachmentOffset];
        itemBeamAttachment.length = 60.0f;
        itemBeamAttachment.damping = 0.4f;
        itemBeamAttachment.frequency = 1.0f;
        [self addChildBehavior:itemBeamAttachment];        
    }
    
    return self;
}

@end
