# Alpha - Find It

 Find It is an application that allows users to create unique identifiers for their items and update them with their current contact information in the event that they are lost. People lose their things everyday by leaving them behind or misplacing them. While kind-hearted people might want to help return those items, it often is difficult because there is no way of identifying an owner or trust anyone who says it’s theirs. With Find It, you can always guarantee the ownership of an item because of the unique ID of the item and the verification of an item before you interact with anyone.

Time spent: 20 hours spent in total

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
 - My tags table view controller
 - Detail screen that shows tag details
 - Settings page

## Grading Level
 Same grade for all members

## Differences
None

## User Stories

The following **required** functionality is completed:

- [X] Sign in/up screen with Email and Facebook options
- [X] Profile creation and modification flow
- [X] Tab bar embedded to provide navigation to multiple screens
- [X] Settings page

The following **additional** features are implemented:

- [X] Added Firebase
- [X] Tag creation flow

## Important Messages

1. If you don't have the correct library installed, you may see dependency errors when running the app. A simple 'pod install' in the folder directory should do the trick. In the event that you don't have the correct libraries installed. Follow these steps:
  - Open terminal and type 'brew install ruby'
  - Then 'sudo gem install cocoapods'
  - And finally 'pod install'
  
2. Firebase offers a storage SDK to upload and download images. It's a time consuming process and we have not yet optimized it. As a result, you will not be able to see your tag's image in the table view when the app loads. WILL BE COMING IN BETA. However, feel free to use the image picker when you add a tag.


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
