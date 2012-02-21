////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// 
///  Copyright 2009 Aurora Feint, Inc.
/// 
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///  
///  	http://www.apache.org/licenses/LICENSE-2.0
///  	
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
/// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class OFChallengeToUser;

@protocol OFChallengeDelegate<NSObject>

@required
////////////////////////////////////////////////////////////
///
/// @note	It is recommended to present the user with a start challenge screen before launching the actual challenge
///
////////////////////////////////////////////////////////////
- (void)userLaunchedChallenge:(OFChallengeToUser*)challengeToLaunch withChallengeData:(NSData*)challengeData;

////////////////////////////////////////////////////////////
///
/// @note	This gets called when the user selects Try Again after completing a challenge.
///			You must keep track of what challenge the player is in. The challenge data will not be downloaded again. 
///			For one shot challenges this method may be left empty.
///
////////////////////////////////////////////////////////////
- (void)userRestartedChallenge;

@optional

////////////////////////////////////////////////////////////
///
/// @note	If this is implemented the send challenge screen will have a "Create Stronger Challenge" button (MultiAttempts challenges only)
///			If this is not implemented the "Create Stronger Challenge" is left out
///			This gets called when the user select the "Create Stronger Challenge" button
///
////////////////////////////////////////////////////////////
- (void)userRestartedCreateChallenge;

////////////////////////////////////////////////////////////
///
/// @note	This gets called as the OFCompletedChallenge screen is closing if the user did not send out challenges. 
///			You should here direct the user to an appropriate screen.
///
////////////////////////////////////////////////////////////
- (void)completedChallengeScreenClosed;

////////////////////////////////////////////////////////////
///
/// @note	This gets called as the OFSendChallenge screen is closing if the user did not send out challenges. 
///			You should here direct the user to an appropriate screen.
///
////////////////////////////////////////////////////////////
- (void)sendChallengeScreenClosed;

////////////////////////////////////////////////////////////
///
/// @note	Gets called after user logs into OpenFeint
///			If he has pending unviewed challenges.  If you use custom UI it is
///			recommended to somewhere indicate the number of new challenges
///
////////////////////////////////////////////////////////////
-(void)userBootedWithUnviewedChallenges:(NSUInteger)numChallenges;

////////////////////////////////////////////////////////////
///
/// @note	This gets called from the send challenge controller or completed challenge controller or if the user sends out challenges.
///			sendChallengeScreenClosed or completedChallengeScreenClosed will get called after this depending on what screen its called from
///
////////////////////////////////////////////////////////////
- (void)userSentChallenges;

@end
