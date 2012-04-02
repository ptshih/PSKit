# This is a WORK IN PROGRESS

DM me @ptshih if you're interested in using PSKit or parts of it :)

Required Frameworks
---
* QuartzCore
* SystemConfiguration
* MobileCoreServices
* CoreLocation
* CoreText
* MessageUI
* libsqlite3
* libz (optional, unused)
* CoreData (optional)

External Modules
---
* AFNetworking
* AFURLCache
* TTTAttributedLabel (requires CoreText.framework)
* FormatterKit
* PullToRefresh
* JSONKit
* Reachability
* SVProgressHUD
* Reachability (optional)
* egodatabase (optional)
* Facebook (optional)

Cool Stuff
---
* PSCollectionView (think Pinterest style table views)

Shared Centers (Singletons)
---
* PSDatabaseCenter (requires egodatabase module, requires libsqlite3.framework, requires a #define SQLITE_DB @"db_file_name" in Constants.h)
* PSFacebookCenter (requires Facebook module)
* PSURLCache
* PSLocationCenter (requires CoreLocation.framework)
* PSMailCenter (requires MessageUI.framework)
* PSReachabilityCenter (requires Reachability module)
* PSSearchCenter
* PSToastCenter
* PSCoreDataStack (requires CoreData.framework)

Categories
---
* NSArray
* NSData
* NSDate
* NSObject
* NSString
* NSURL
* UIBarButtonItem
* UIButton
* UIColor
* UIDevice-Hardware
* UIImage
* UILabel
* UIScreen
* UIView
* Others

PSKit Core
---
* PSStateMachine
* PSObject
* PSView
* PSCell
* PSViewController
* PSBaseViewController
* PSTableViewController
* PSCollectionViewController

Usage
---
1. Link required frameworks
2. If using PSStylesheet, Create PSStyleSheet.plist and add to project. In application didFinishLaunching add "[PSStyleSheet setStyleSheet:@"PSStyleSheet"];" to set the new style sheet. Look at PSStyleSheet-Default.plist for examples
3. Import PSConstants.h where PSKit is needed. It's recommended to create a Constants.h and import it in the PCH file.
 
Config
---
PSConstants.h contains #defines for lots of PSKit's configuration
It also imports PSCategories.h which is required by PSKit

PSStyleSheet
---
This is a custom stylesheet driven by a plist file
This reads from PSStyleSheet-Default.plist by default
Set a new one: PSStyleSheet setStyleSheet:@"YOUR_STYLESHEET_NAME"];

LICENSE
---
Copyright (C) 2011 Peter Shih. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

* Neither the name of the author nor the names of its contributors may be used
to endorse or promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
