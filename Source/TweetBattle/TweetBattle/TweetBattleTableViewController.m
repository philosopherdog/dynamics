#import "TweetBattleTableViewController.h"
#import "TweetViewController.h"

@interface TweetBattleTableViewController ()

@property (nonatomic, strong) NSArray *battles;

@end

@implementation TweetBattleTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.battles = @[
                         @[@"#awesome", @"#cool"],                         
                         @[@"#mobilemarchadam", @"#mobilemarchsam"],
                         @[@"#android", @"#iphone"]
                         ];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.battles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BattleCell"
                                                            forIndexPath:indexPath];
    
    NSArray *battle = self.battles[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ vs %@", battle[0], battle[1]];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    
    NSArray *battle = self.battles[selected.row];
    
    NSString *leftHashtag = battle[0];
    NSString *rightHashtag = battle[1];
    
    TweetViewController *destination = [segue destinationViewController];
    destination.leftHashtag = leftHashtag;
    destination.rightHashtag = rightHashtag;
    destination.title = [NSString stringWithFormat:@"%@ vs %@",
                         leftHashtag,
                         rightHashtag];
    
}


@end
