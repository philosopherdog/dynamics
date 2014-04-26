TweetBattle
============

A demonstration of UICollectionView and UIKit Dynamics.  Uses the Twitter streaming API to retrieve tweets matching two different hashtags, adding each tweet's profile image to the left and right half of a beam to indicate which hashtag has more tweets.

Building
--------

1. Initialize Mantle.

	From the root folder of the Dynamics repository:
	~~~sh
	$ git submodule init
	$ git submodule update
	$ ./Source/TweetBattle/Mantle/script/bootstrap
	~~~

2. Setup a Twitter account on the device or simulator (Settings > Twitter).
3. Open TweetBattle.xcodeproj in Xcode, select the TweetBattle target and hit play.

Testing
-------
1. Open TweetBattle.xcodeproj in Xcode.
2. Select the TweetBattle target.
3. Product > Test or Command+U.

Dependencies
------------
- Mantle


