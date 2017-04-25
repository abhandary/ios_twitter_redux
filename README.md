# Project 4 - *Chitter Redux*

Time spent: **23** hours spent in total

**Project Leaderboard Rank: 1 (out of 80 cohorts)**


## User Stories

The following **required** functionality is completed:

- [x] Hamburger menu
   - [x] Dragging anywhere in the view should reveal the menu.
   - [x] The menu should include links to your profile, the home timeline, and the mentions view.
   - [x] The menu can look similar to the example or feel free to take liberty with the UI.
- [x] Profile page
   - [x] Contains the user header view
   - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline
   - [x] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [x] Profile Page
   - [x] Implement the paging view for the user description.
   - [x] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [x] Pulling down the profile page should blur and resize the header image.
- [x] Account switching
   - [x] Long press on tab bar to bring up Account view with animation
   - [x] Tap account to switch to
   - [x] Include a plus button to Add an Account
   - [x] Swipe to delete an account


The following **additional** features are implemented:

- [x] Use of UIWebview based controller to enable the app to clean up web cookies related to Oauth tokens so that the user can have a clean logout and login experience
- [x] Once user switches accounts, the home timeline and Mentions screens will correctly show the autenticated user's
timeline and mentions.
- [x] The menu has an additional 'Logout' and 'About' section
- [x] Added a hamburger icon, which when tapped will toggle the reveal of the hamburger menu.
- [x] In the accounts view, if the current account is deleted the user will be switched to the next available account. If there are no other accounts available then the user will be logged out after a prompt. 



## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](chitter_redux_demo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).


## License

    Copyright 2017 Akshay Bhandary

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
