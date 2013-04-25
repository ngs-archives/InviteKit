# InviteKit

The one-stop framework for integrating *INVITE A FRIEND* function in your app.


## Dependencies

* Accounts framework
* AdSupport framework
* CFNetwork framework
* CoreData framework
* CoreLocation framework
* libresolv
* libsqlite3
* libxml2
* MobileCoreServices framework
* Security framework
* Social framework
* QuartzCore framework


## Configuration

    HEADER_SEARCH_PATHS = $(SDKROOT)/usr/include/libxml2:$(BUILT_PRODUCTS_DIR)/facebook-ios-sdk

## Prefix Header

Add the below lines inside `#ifdef __OBJC__` section of *YOUR_APP-prefix.pch* file.

    #import <SystemConfiguration/SystemConfiguration.h>
    #import <MobileCoreServices/MobileCoreServices.h>
