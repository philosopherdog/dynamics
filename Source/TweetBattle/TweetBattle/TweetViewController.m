#import "TweetViewController.h"
#import "TweetStream.h"
#import "Tweet.h"

@interface TweetViewController () <TweetStreamDelegate>

@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TweetStream *tweetStream;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation TweetViewController

#pragma mark - Instance methods

- (IBAction)addRandomTweet:(id)sender
{
    int section = arc4random_uniform(2);
    NSMutableArray *array = [self tweetsForSection:section];
    
    Tweet *randomTweet = [[Tweet alloc] init];
    [array addObject:randomTweet];

    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:array.count - 1 inSection:section]]];
}

#pragma mark - TweetStreamDelegate methods

- (void)stream:(TweetStream *)stream didRecieveTweet:(Tweet *)tweet
{
    int section = arc4random_uniform(2);
    
    if ([tweet.text rangeOfString:self.leftHashtag].location == NSNotFound)
    {
        section = 1;
    }
    else if ([tweet.text rangeOfString:self.rightHashtag].location == NSNotFound)
    {
        section = 0;
    }
    
    NSURLSessionDataTask *profileImageDataTask =
    [[NSURLSession sharedSession] dataTaskWithURL:tweet.profileImageURL
                                completionHandler:^(NSData *data,
                                                    NSURLResponse *response,
                                                    NSError *error) {
                                    UIImage *image = [UIImage imageWithData:data];
                                    
                                    if (image != nil)
                                    {
                                        [self.imageCache setObject:image
                                                            forKey:tweet.profileImageURL];
                                    }
                                   
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSMutableArray *array = [self tweetsForSection:section];
                                        [array addObject:tweet];
                                        
                                        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:array.count - 1 inSection:section]]];                                        
                                    });
                                }];
    
    [profileImageDataTask resume];
}

#pragma mark - UICollectionViewDataSource methods

- (NSMutableArray *)tweetsForSection:(NSInteger)section
{
    return self.tweets[section];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self tweetsForSection:section].count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.tweets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    Tweet *tweetForCell = self.tweets[indexPath.section][indexPath.row];

    UIImage *image = [self.imageCache objectForKey:tweetForCell.profileImageURL];
    if (!image)
    {
        image = [UIImage imageNamed:@"profile-image-placeholder"];
    }
        
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = cell.contentView.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:imageView];

    return cell;
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    self.imageCache = [[NSCache alloc] init];
    self.imageCache.countLimit = 40;
    
    self.tweets = @[[NSMutableArray array],
                    [NSMutableArray array]];
    
    self.tweetStream = [[TweetStream alloc] init];
    self.tweetStream.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *keywords = [NSString stringWithFormat:@"%@,%@",
                          self.leftHashtag,
                          self.rightHashtag];
    [self.tweetStream startStreamingTweetsWithKeywords:keywords];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tweetStream stopStreaming];
    
    [super viewWillDisappear:animated];
}

@end
