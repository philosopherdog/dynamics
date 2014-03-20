#import "TweetStream.h"
#import "Tweet.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TweetStream () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSMutableString *buffer;
@property (nonatomic, strong) NSURLSessionDataTask *currentDataTask;

@end

@implementation TweetStream

- (id)init
{
    self = [super init];
    if (self)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)startStreamingTweetsWithKeywords:(NSString *)keywords
{
    if ([self userHasAccessToTwitter])
    {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                NSArray *twitterAccounts =
                [self.accountStore accountsWithAccountType:twitterAccountType];
                
                // Setup a streaming request.
                NSURL *url = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
                NSDictionary *params = @{@"track" : keywords};
                SLRequest *request =
                [SLRequest requestForServiceType:SLServiceTypeTwitter
                                   requestMethod:SLRequestMethodGET
                                             URL:url
                                      parameters:params];
                
                //  Attach our account to the request.
                [request setAccount:[twitterAccounts lastObject]];
                
                // Start a delegate based URL session, delegation beats blocks for streams.
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                      delegate:self
                                                                 delegateQueue:nil];
                
                // Start a data task with the preauthorized prepared URL for streaming.
                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[request preparedURLRequest]];
                [dataTask resume];
                
                self.currentDataTask = dataTask;
            }
        }];
    }
}

- (void)stopStreaming
{
    [self.currentDataTask cancel];
    self.currentDataTask = nil;
}


#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.buffer = [NSMutableString string];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    static NSString *StatusDelimiter = @"\r\n";
    
    // Append incoming data to a buffer
    [self.buffer appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    // Search the buffer for the next delimiter.
    NSRange delimiter = [self.buffer rangeOfString:StatusDelimiter];
    
    while (delimiter.location != NSNotFound)
    {
        NSRange statusRange = NSMakeRange(0, delimiter.location);
        NSString *status = [self.buffer substringWithRange:statusRange];
        
        // Delete the status from the buffer
        [self.buffer deleteCharactersInRange:statusRange];
        
        // Make sure we hit the delimiter
        assert([self.buffer characterAtIndex:0] == '\r');
        assert([self.buffer characterAtIndex:1] == '\n');
        
        // Delete the delimiter
        [self.buffer deleteCharactersInRange:NSMakeRange(0, 2)];

        // Process the status
        [self processIncomingStatus:status];
        
        // Look for the next delimiter
        delimiter = [self.buffer rangeOfString:StatusDelimiter];
    }
}

- (void)processIncomingStatus:(NSString *)status
{
    // Jump to a background queue, JSON processing can be completely parallel.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *JSONData = [status dataUsingEncoding:NSUTF8StringEncoding];
        __autoreleasing NSError *JSONError;
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData
                                                            options:0
                                                              error:&JSONError];
        if (JSONError)
        {
            // Let's just bail in this case.
            NSLog(@"Invalid JSON from stream: %@", [JSONError localizedDescription]);
            return;
        }
        
        __autoreleasing NSError *modelError;
        Tweet *tweet = [MTLJSONAdapter modelOfClass:[Tweet class]
                                 fromJSONDictionary:JSONDictionary
                                              error:&modelError];
        if (modelError)
        {
            // Blow up if our model is hosed, should not happen.
            NSAssert(false, @"Error creating model: %@", [modelError localizedDescription]);
            return;
        }
        
        // Bounce back to main before notifying our delegate.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate stream:self didRecieveTweet:tweet];
        });
    });
}

@end
