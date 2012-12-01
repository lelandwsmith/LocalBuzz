//
//  XMPPFramework.h
//  LocalBuzz
//
//  Created by Vincent Leung on 11/18/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#ifndef LocalBuzz_XMPPFramework_h
#define LocalBuzz_XMPPFramework_h
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPMUC.h"
#import "XMPPRoom.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoomHybridStorage.h"

//logging
#import "DDLog.h"
#import "DDTTYLogger.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#endif
