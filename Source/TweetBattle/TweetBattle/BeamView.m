#import "BeamView.h"

@implementation BeamView

+ (NSString *)kind
{
    return NSStringFromClass(self);
}

+ (NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

@end
