# Beta - Find It

 Find It is an application that allows users to create unique identifiers for their items and update them with their current contact information in the event that they are lost. People lose their things everyday by leaving them behind or misplacing them. While kind-hearted people might want to help return those items, it often is difficult because there is no way of identifying an owner or trust anyone who says it’s theirs. With Find It, you can always guarantee the ownership of an item because of the unique ID of the item and the verification of an item before you interact with anyone.

## Implementation Contributions
Marcos Ortiz: 33.33%
 - Implemented Firebase
 - Login screen
 - Add tag flow and upload

Susan Seo: 33.33%
 - Majority of UI design
 - Model classes
 - Tab bar implementation

Jacob Rodenbusch: 33.33%
 - My Reports table view controller
 - Detail screen that shows tag details
 - Settings page

## Grading Level
 Same grade for all members

## Differences
 Map view and related functions removed because we thought the added benefit would be minimal and unnecessary. The address from the reporting user should be enough to find the item.

## User Stories

The following **required** functionality is completed:

- [X] Sign in/up screen with Email and Facebook options
- [X] Profile creation and modification flow
- [X] Tab bar embedded to provide navigation to multiple screens
- [X] Settings page
- [X] Tag creation and search capabilities
- [X] Lost/Found reporting of tags

The following **additional** features are implemented:

- [X] Added Firebase
- [X] Tag creation flow
- [X] Asynchronous loading of item images
- [X] Tutorial screens before sign-in
- [X] Persistence of user log-in credentials between loads

## Important Messages

1. If you don't have the correct library installed, you may see dependency errors when running the app. A simple 'pod install' in the folder directory should do the trick. In the event that you don't have the correct libraries installed. Follow these steps:
  - Open terminal and type 'brew install ruby'
  - Then 'sudo gem install cocoapods'
  - CD to your project folder and type 'pod install'
  
  1.2 In the case that the above steps still do not fix dependency errors, you may be reinstalling pods with your Xcode open or your pods won't allow overwriting. To resolve, try:
  - Deleting the "Pods" folder with your current workspace open
  - Quit Xcode and open terminal
  - CD to your project folder and reinstall pods using 'pod install'
  
2. You can create an account of your own if you like but we have two example accounts with registered items if you would rather use those. Also we recommend you use these users if you want to try the "Reporting functionality"

    User 1: Micah Drennan
    Address: 123 Swift Lane
             San Antonio, TX
    Phone: 210-478-9673
    email: first@gmail.com
    password: password

        Item 1 ID: WHL227
        Item name: iPhone 6 Plus
        Description: Black with light wear on the sides

        Item 2 ID: HYO099
        Item name: Osprey Backpack
        Description: Green with name patch on the left side

    User 2: Sofia Castillo
    Address: 456 Fast Street
             Austin, TX
    Phone: 210-478-9671
    email: second@gmail.com
    password: password

        Item 1 ID: VKF459
        Item name: Soundlink III
        Description: Gray with name on back

        Item 2 ID: DOR504
        Item name: Audio-Technica Earphones
        Description: Brown with light scuff marks

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/whSMAm2.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with RecordIt

## License

    Copyright 2017 Camden Developers

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
