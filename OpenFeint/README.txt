********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

                             OpenFeint 2.4.3

                          release date 2.3.2010

                              Release Notes

        Copyright (c) 2009-2010 Aurora Feint Inc. All Rights Reserved.

********************************************************************************

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

********************************************************************************
**** What's New? (Version 2.4.3, 2.3.2010) 
********************************************************************************
- Replaced our use of NSXMLParser with the significantly faster Parsifal
  - Specific information about Parsifal can be found here: http://www.saunalahti.fi/~samiuus/toni/xmlproc/
- The SDK will now compile even if you are forcing everything to be compiled as Objective-C++ (GCC_INPUT_FILETYPE)
- Various bugfixes
  - Crash on 2.x devices when tapping the banner before it was populated
  - Failure to show a notification when posting the first high score to an ascending leaderboard
  - Deprecation warning in OFSelectProfilePictureController when iPhoneOS Deployment Target is set to 3.1 or higher

********************************************************************************
**** Integration Changes (Version 2.4.3, 2.3.2010)
********************************************************************************
**** No new changes since 2.4. Changes from 2.4 are listed below:

- If you are setting your 'iPhone OS Deployment Target' below 3.0 you must weak-link the following libraries
  (See #8 below)
    * UIKit
    * MapKit
- OpenFeintSettingDisableChat has been removed
    * Instead use OpenFeintSettingDisableUserGeneratedContent
- Some new library dependencies have been added
    * CFNetwork
    * CoreLocation
    * MapKit (if building with SDK 3.0 or newer)
- Automatically posting to facebook and twitter when unlocking an achievement is turned off by default.
    * Set OpenFeintSettingPromptToPostAchievementUnlock to true to enable automatic posting of social notifications.

********************************************************************************
**** Getting Started
********************************************************************************
---------------------------------------------
---- Building OpenFeint With Your Project:
---------------------------------------------

For the latest information on integrating OpenFeint please check: 
	http://www.openfeint.com/developers/support/index.php/kb/article/000055

1. Make sure you have the current version of OpenFeint. Unzip the file.
2. If you have previously used OpenFeint, delete the existing group reference from your project.
3. If you have previously used OpenFeint, delete your build directory. Otherwise xcode might get confused and the game will crash because xcode didn't realize a .xib file changed
4. Drag and drop the unzipped folder titled OpenFeint onto your project in XCode. Make sure it's included as a group and not a folder reference.
5. If your game is landscape only or portrait only, remove the Resources/Landscape or Resources/Portrait folder from your project, whichever you don't need. This is not a necessary step but helps cut down the application size. You need to do this every time you download a new OpenFeint project.
6. Right click on your project icon in the Groups & Files pane. Select Get Info.
       * Select the Build tab. Make sure you have Configuration set to All Configurations
       * Add to Other Linker Flags the value -ObjC
		 ** NOTE: If the current value says <Multiple values> then you may not add the -ObjC flag for "All Configurations" 
		 **       but you must instead do it one configuration at a time.
       * Ensure 'Call C++ Default Ctors/Dtors in Objective-C' is checked under the 'GCC 4.2 - Code Generation' section
       * NOTE: Older Xcode projects may have to add this as a user defined setting GCC_OBJC_CALL_CXX_CDTORS set to YES

7. Ensure the following frameworks are included in your link step:
   (do this by right clicking on your project and selecting "Add->Existing Frameworks...")
       * Foundation
       * UIKit
       * CoreGraphics
       * QuartzCore
       * Security
       * SystemConfiguration
       * libsql3.0.dylib (located in (iPhoneSDK Folder)/usr/lib/)
       * CFNetwork
       * CoreLocation
       * MapKit (if building with SDK 3.0 or newer)

8. If you have set your 'iPhoneOS Deployment Target' to any version before 3.0 you must weak link some libraries.
       * Select 'Targets' in the Groups & Files pane.
       * Right click your target and select Get Info.
       * Select the 'General' tab.
       * Under 'Linked Libraries' change the following libraries from 'Required' to 'Weak'
           * UIKit
           * MapKit

9. You must have a prefix header. It must have the following line: #import "OpenFeintPrefix.pch"

---------------------------------------------
---- Releasing your title with OpenFeint:
---------------------------------------------	
- Register an Application on api.openfeint.com
- Use the ProductKey and ProductSecret for your registered application.
- When launching your app, OpenFeint will print out what servers it is using to the console/log using NSLog. 
  NOTE: Make sure your application is using https://api.openfeint.com/
- Make sure you're offline configuration XML file is up to date. This file is downloadable in the developer dashboard under the 'Offline' section and should be re-downloaded every time you change something in the developer dashboard.
  


---------------------------------------------
---- How To Use OpenFeint
---------------------------------------------

For a more comprehensive beginner guide please visit our help website:
	http://www.openfeint.com/developers/support/index.php/kb/article/000022	

#import "OpenFeint.h"

// Initialize OpenFeint on the title screen after you've displayed any splash screens. 
// OpenFeint will present a modal the first time it's initialized to conform with apple regulations.

- (void)initializeOpenfeint
{
    [OpenFeint initializeWithProductKey:yourProductKey
                              andSecret:yourProductSecret
                         andDisplayName:yourApplicationNameForUsers
                            andSettings:aDictionaryOfOpenFeintSettings    // see OpenFeintSettings.h
                           andDelegates:aDelegateContainer];              // see OFDelegatesContainer.h
                           
    // You probably want to invoke this from a button instead of directly here.
    [OpenFeint launchDashboard];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[OpenFeint applicationDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[OpenFeint applicationWillResignActive];
}



********************************************************************************
**** Known Issues
********************************************************************************
- Delegate parameters from OF Services are not easily exposed yet.
- You must be compiling with Objective-C++ to use the OpenFeint APIs. (Use a .mm file extension)
- There are a small number of non-prefixed symbols in the global namespace.
- Notifications do not perform well on top of OpenGL based game views.
- Occasional non-error logging spew needs to be scoped with OpenFeint and togglable
- When resizing the keyboard in chat, the text pops up or down 40 pixels before animating.


********************************************************************************
**** Changelog
********************************************************************************

---------------------------------------------
---- Version 2.4.2 (1.18.2010)
---------------------------------------------
- High Score notifications will only be shown when the new score is better than the old score.
  - This only applies to leaderboards where 'Allow Worse Scores' is not checked
  - This also means that high scores that are not better will not generate a server request
- 'Play Challenge' button is click-able again
- Updated Unity support
- Other bug fixes

---------------------------------------------
---- Version 2.4.1 (1.7.2010)
---------------------------------------------
- Portrait support is back
- Bug fixes!
- Improved user experience in Forums

---------------------------------------------
---- Version 2.4 (12.17.2009)
---------------------------------------------
- New UI
    * New clean and user-friendly look.
    * New simplified organization with only three tabs. One for the game, one for the user and one for game discovery.
- Cloud Storage
    * Upload data and store it on the OpenFeint servers.
    * Share save data between multiple devices so the player never has to lose his progress.
- Geolocation
    * Allow players to compete with users nearby.
    * Distance based leaderboards.
    * Map view with user scores near you.
    * All location-based functionality is opt-in.
- Presence
    * The player can immediately see when his or her friends come online through in-game notification.
    * Friends page has a section for all friends who are currently online.
    * All presence functionality is opt-in.
- IM
    * The player can send private messages to his or her friends.
    * Real-time notifications of new messages are sent through presence.
    * IM page is updated in real-time allowing synchronous chat.
    * Messages can be received when offline and new messages are indicated with a badge within the OpenFeint dashboard.
    * Conversation history with each player is preserved the same as in the SMS app.
- Forums
    * Players can now form a community within the game itself.
    * Global, developer and game specific forums.
    * Forums can be moderated through the developer dashboard.
    * Players can report other players, a certain number of reports will remove a post/thread and ban the user for a time period.
    * Add a thread to My Conversations to get notified of new posts in it.
- My Conversations
    * A single go-to place where the player can see all of his or her IM conversations and favorite forum threads.
- Custom Profile Picture
    * Players can now upload a profile picture from their album or take one using the device’s camera.
- Ticker
    * The OpenFeint dashboard now has a persistent marquee at the top of the screen.
    * Ticker streams interesting information and advice to the player.
- Cross Promotion
    * Cross promote between your own games or team up with other developers to cross promote their games.
    * New banner on the dashboard landing page where you can cross promote other games.
    * Add games to promote from the developer dashboard.
    * OpenFeint reserves the right to promote gold games through the banner.
    * Games you select to cross promote will also be available through the Fan Club and through the Discovery tab.
- Developer Announcements
    * Send out announcements about updates, new releases and more to your users directly though your game.
    * New announcements will be marked with a badge in the OpenFeint dashboard.
    * Announcements may be linked to a game id and will generate a buy button that linked to the game’s iPurchase page.
    * Announcements are added through the developer dashboard.
- Developer Newsletter
    * Send out email newsletters to your players from the OpenFeint developer dashboard.
    * Players may opt-in to developer newsletters from the Fan Club.
- Suggest a feature
    * Get feedback from your players straight from the game.
    * Players may give feedback and comment on feedback from the Fan Club.
    * Player suggestions can be viewed in the developer dashboard where you can also respond directly to the player.
- Add Game as Favorite
    * Players now have a way of showing their friends which OpenFeint enabled games are their favorites.
    * Players can mark a game as a favorite from the Fan Club.
    * The My Games tab has a new section for favorite games.
    * When looking at a list of friend’s games, favorites are starred.
    * When marking a game as favorite, players are asked to comment on why it's a favorite.
    * When looking at an iPurchase page for a favorite game owned by a friend, comments on why the game is a favorite are displayed.
- Discovery Tab
    * The third tab is now the game discovery tab. This is a place where players can come to find new games.
    * Friends Games section lists games owned by the player’s friends.
    * The Feint Five section lists five random games. Press shuffle to list five new games.
    * OpenFeint News provides news about the network.
    * Featured games lists games featured by OpenFeint.
    * More Games lists a larger group of games in the OpenFeint network.
    * Developer Picks section lists games featured by the developer of the game being played.
- Option to display OpenFeint notifications at the top of the screen instead of the bottom.
    * Set OpenFeintSettingInvertNotifications to true when initializing OpenFeint to show notifications from top.
- Automatically posting to Facebook and Twitter when unlocking an achievement is turned off by default.
    * Set OpenFeintSettingPromptToPostAchievementUnlock to true to enable automatic posting of social notifications.

---------------------------------------------
---- Version 2.3 (10.05.2009)
---------------------------------------------
- Multiple Accounts Per Device
    * Multiple OpenFeint accounts may be attached to a single device.
    * When starting a new game, user may choose which user to log in as if there are multiple users attached to his device
    * When user switches account from the settings tab, he will be presented with a list of accounts tied to the device if there is more than one
- Facebook/Twitter may be tied to more than one account
    * User will no longer get an error message when trying to attach Facebook/Twitter to an account if that Facebook/Twitter account has already been use by OpenFeint.
- Select Profile Picture Functionality
    * User may from the settings tab choose profile picture between Facebook, Twitter and the standard OpenFeint profile picture.
- Remove Account From Device
    * User may completely remove the account from the current device if he wants to sell his device etc.
- Create New User
    * From the OpenFeint intro flow or the Switch User screen, the user may choose to create a new OpenFeint account.
- Log Out
    * User may from the settings tab log out of OpenFeint for the current game. When logged out OpenFeint will act as if you said no to OpenFeint in the first place and not make any server calls.
- Remove Facebook/Twitter
    * Option on the settings tab to disconnect facebook or twitter from the current account

---------------------------------------------
---- Version 2.2 (9.29.2009)
---------------------------------------------
- Game Profile Pages accessible for any game from any game. Game Profile Page allows you to:
    * View Leaderboards
    * View Achievements
    * View Challenges
    * Find out which of your friends are playing
- User Comparison. Tap 'Compare with a Friend' to see how you stack up against your OpenFeint friends!
    * Browsing into a game profile page through another user's profile will default to comparing against that user.
    * Game Profile page comparison shows a breakdown of the results for achievements, leaderboards and challenges
    * Achievements page shows unlocked achievements for each user
    * Challenges page shows pending challenges between the two users, number of won challenges/ties for each user and challenge history between the two users.
    * Leaderboards page shows the result for each user for each leaderboard
- Unregistered user support. Now you can let OpenFeint manage all of your high score data!
    * Users that opt-out of OpenFeint can still open the dashboard and view their local high scores.
    * When the user signs up for OpenFeint any previous scores gets attributed to the new user.
    * This **REQUIRES** that you download an offline configuration XML file and add it to your project.
      This file is downloadable in the developer dashboard under the 'Offline' section.
      See http://help.openfeint.com/faqs/guides-2/offline for more information. 
- Improved offline support. 
    * More obvious when a user is using OpenFeint in offline mode.
    * User no longer need to be online once for offline leaderboards to work.
- Improved friends list. 
     *Friends list now shows all friends in a alphabetical list.

---------------------------------------------
---- Version 2.1.2 (9.09.2009)
---------------------------------------------
- Fixed an issue with OpenFeint not initializing properly when user says no to push notifications

---------------------------------------------
---- Version 2.1.1 (8.28.2009)
---------------------------------------------
- Fix compiling issues with Snow Leopard XCode 3.2

---------------------------------------------
---- Version 2.0.2 (7.22.2009)
---------------------------------------------
- Added displayText option to highscores. If set this is displayed instead of the score (score is still used for sorting)
- Removed status bar in the dashboard
- Fixed bug with showing a few black frames when opening the OpenFeint dashboard form an OpenGL game

---------------------------------------------
---- Version 2.0.1 (7.13.2009)
---------------------------------------------
- Improved OpenFeint "Introduction flow"
- User may set their name when first getting an account
- User may at any time import friends from Twitter or Facebook
- Nicer landing page in the dashboard encouraging you to import friends until you have some
- Fixed compatibility issues with using the 3.0 base sdk and 2.x deployment targets

---------------------------------------------
---- Version 2.0 (6.29.2009)
---------------------------------------------
- Friends:
- 	A player can import friends from twitter and facebook:
- 	A player can see all of his or her friends in one place:
- Feint Library:
-	A player can see all the games they've played in once place
- Social Player Profiles:
- 	A player can see the name and avatar of the profile owner:
- 	A player can see all the games the profile owner has played:
- 	A player can see all the friends the profile owner has:
- Achievements:
- 	A developer can add up to 100 achievements to a game:
- 	Each player has a gamerscore and earns points when unlocking achievements:
- 	Achievements can be compared between friends for a particular game:
- 	If you do not have any achievements to be compared, there is an iPromote Page link with a call to action prominantly visible
- 	Achievements can be unlocked by the game client when on or offline:
- 	Achievements unlocked offline are syncronized when next online:
- Friend Leaderboards:
- 	A leaderboard can be sorted by friends:
- 	Player avatars are visible on the leaderboard:
- Chat Room:
- 	Each chat message has a player's profile avatar next to it:
- 	Each chat message has some kind of visual representation of the game they are using:
- 	Clicking on a person's chat message takes you to their profile:
- Chat Room Moderation:
- 	A player report can optionally include a reason:
- 	A player can click "report this user" on a player's profile:
- 	A developer can give Moderator privileges to up to 5 users from the dashboard:
- 	When a player has been flagged more than a certain number of times, they are not allowed to chat for a relative amount of time:
- 	Moderators reporting a user immediately flags them:
- Fixed iPhone SDK 3.0 compatibility issues
- Lots of bugfixes
- Lots of user interface changes
- Lots of Perforamnce improvements
- Fixed compatibility with iPod Music Picker
- Fixed glitch visual glitch in landscape when running on a 2.0 device and building with the 3.0 SDK

---------------------------------------------
---- Version 1.7 (5.29.2009)
---------------------------------------------
- Simplified account setup
- Users can access OpenFeint without setting up an account
- Login is only required once per device instead of per app
- 3.0 compatibility fixes
- Various bug fixes

---------------------------------------------
---- Version 1.7 (5.22.2009)
---------------------------------------------
- Simplified account setup
- Users can access OpenFeint without setting up an account
- Login is only required once per device instead of per app
- 3.0 compatibility fixes
- Various bug fixes

---------------------------------------------
---- Version 1.6.1 (5.13.2009)
---------------------------------------------
- OpenFeint works properly on 3.0 devices.

---------------------------------------------
---- Version 1.6 (4.29.2009)
---------------------------------------------
- Dashboard now supports landscape (interface orientation is a setting when initializing OF).
- OpenFeint can now be compiled against any iPhone SDK version
- Various minor bug-fixes

---------------------------------------------
---- Version 1.5 (4.21.2009) 
---------------------------------------------
- One Touch iPromote
- Keyboard can now be toggled in the chat rooms
- Greatly improved performance and memory usage of chat rooms
- Profanity Filter is now even more clean.
- Massive scale improvements
- Improved internal analytics for tracking OF usage
- User conversion rate tracking (view, buy, return)
- Various minor bug-fixes

---------------------------------------------
---- Version 1.0 (3.26.2009)
---------------------------------------------
- Users can login with their Facebook accounts (using FBConnect)
- Every user now has proper account "settings"
- Global "publishing" permissions are now present on account creation screens
- Chat scrolling now works properly in 2.0, 2.1, 2.2, and 2.2.1.
- DashboardDidAppear delegate implemented by request


---------------------------------------------
---- Version 3.20.2009
---------------------------------------------
- Users can login with other account containers (twitter)
- Added global, developer, and game lobbies
- Developer and game rooms can be configured from developer website
- Account error handling improved
- Polling system improvements: remote throttling, disabled when device locks
- Improved versioning support
- Leaderboard values can be 64 bit integers (requested feature!)
- Removed profile screens
- Added Settings tab with Logout button
- Final tab organization and art integration
- Lots of minor bug fixes and tweaks

---------------------------------------------
---- Version 3.15.2009
---------------------------------------------
- Out of dashboard background notifications
- Multiple leaderboards for each title (configurable via web site)
- Landscape keyboard issue addressed
- Startup time significantly reduced
- Multi-threaded API calls now work properly
- Added profanity filter to server
- Basic request based version tracking
- Now using HTTPS for all data communication

---------------------------------------------
---- Version 3.10.2009
---------------------------------------------
- Robust connectivity and server error handling
- Integration protocol no longer requires all callbacks
- Various Bugfixes

---------------------------------------------
---- Version 3.6.2009
---------------------------------------------
- Each game has a dedicated chat room
- First implementation of background alerts
- Framework preparation for future features
- Framework enhancements for table views

---------------------------------------------
---- Version 3.3.2009
---------------------------------------------
- First pass at Leaderboards ("Global" and "Near You")
- Tabbed Dashboard with temporary icons
- OFHighScore API for setting high score
- OpenFeintDelegate now works
- OpenFeint api changed to allow a per-dashboard delegate
- Automatically prompt to setup account before submitting requests
- Placeholder in-game alerts
- Better offline and error support
- Smaller library size (AuroraLib has been mostly removed)

---------------------------------------------
---- Version 2.25.2009
---------------------------------------------
- First draft public API
- Placeholder profile
- Placeholder Dashboard
- Account create, login, and logout 


