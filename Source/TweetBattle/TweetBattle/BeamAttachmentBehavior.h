#import <UIKit/UIKit.h>

/// A custom behavior that simulates the attachment of an item to a beam.
///
@interface BeamAttachmentBehavior : UIDynamicBehavior

/// Creates an attachment behavior between an item and a beam, either on the furthest left
/// or right side of the beam.
///
/// @param item
///     The item to attach to the beam.
///
/// @param beam
///     The beam to attach the item to.
///
/// @param left
///     YES if the item should be attached to the lefthand side of the beam; NO if the righthand.
///
- (instancetype)initWithItem:(id<UIDynamicItem>)item
              attachedToBeam:(id<UIDynamicItem>)beam
                      onLeft:(BOOL)left;

@end
