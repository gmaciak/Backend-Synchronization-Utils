//
//  LocalStorageObject.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 24.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "NSObject+WSObject.h"
#import "BSULoadingWithJSON.h"
#import "RLMResults+Array.h"
#import "BSUDataProvider.h"
#import "BSULocalDataModel.h"

@interface BSULocalDataObject : RLMObject <BSULoadingWithJSON, BSULocalDataModel>

@end


#define RLM_SELF_CLASS NSClassFromString([[self class] className])
