//
//  TweetTests.m
//  TweetCollection
//
//  Created by Adam May on 3/11/14.
//  Copyright (c) 2014 Livefront. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tweet.h"

@interface TweetTests : XCTestCase

@property (nonatomic, strong) Tweet *tweet;

@end

@implementation TweetTests

#pragma mark - Setup and teardown

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    NSURL *testURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"tweet" withExtension:@"json"];
    
    NSError *error;
    NSData *JSONData = [NSData dataWithContentsOfURL:testURL options:0 error:&error];
    
    XCTAssertNil(error, @"Error loading tweet.json %@", [error localizedDescription]);
    XCTAssertNotNil(JSONData, @"Could not load tweet.json from the bundle");
    
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                   options:0
                                                                     error:&error];
    
    self.tweet = [MTLJSONAdapter modelOfClass:[Tweet class]
                           fromJSONDictionary:JSONDictionary
                                        error:nil];
    
    XCTAssertNotNil(self.tweet, @"Could not load tweet from tweet.json");
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Test methods

- (void)testProfileImageURL
{
    XCTAssertNotNil(self.tweet.profileImageURL, @"Must have a non-nil profileImageURL");
    XCTAssertEqualObjects([self.tweet.profileImageURL absoluteString], @"http://pbs.twimg.com/profile_images/378800000652825054/f7dd6ad2a48faa68bdbaa5f1ba8719dd_normal.jpeg", @"Must transform profileImagURL to an NSURL.");
}

- (void)testText
{
    XCTAssertNotNil(self.tweet.text, @"Msut have non-nil text");
    XCTAssertEqualObjects(self.tweet.text,
                          @"Where is #Coldplay? Maybe this is the greatest Rick Roll ever pulled. #itunesfestival #SXSW",
                          @"Must transform text from JSON");
}

@end
