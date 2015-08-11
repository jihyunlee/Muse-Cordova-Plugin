/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVMuse.h"

@interface CDVMuse ()

@property (weak, nonatomic) IXNMuseManager *manager;
@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL sawOneBlink;

@end

@implementation CDVMuse

// @synthesize delegate;

- (void)pluginInitialize {
    NSLog(@"------------------------------");
    NSLog(@" Muse Cordova Plugin");
    NSLog(@" (c)2015 Jihyun Lee");
    NSLog(@"------------------------------");

    [super pluginInitialize];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    @synchronized (self.manager) {
        // All variables and listeners are already wired up; return.
        if (self.manager)
            return;
        self.manager = [IXNMuseManager sharedManager];
    }

    // to resume connection if we disconnected in applicationDidEnterBakcground::
    // else if (self.muse.getConnectionState == IXNConnectionStateDisconnected)
    //     [self.muse runAsynchronously];
	
    [self.manager addObserver:self
                   forKeyPath:[self.manager connectedMusesKeyPath]
                      options:(NSKeyValueObservingOptionNew |
                               NSKeyValueObservingOptionInitial)
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	NSLog(@"CDVMuse::observeValueForKeyPath");

    if ([keyPath isEqualToString:[self.manager connectedMusesKeyPath]]) {
        NSSet *connectedMuses = [change objectForKey:NSKeyValueChangeNewKey];
        if (connectedMuses.count) {
            [self startWithMuse:[connectedMuses anyObject]];
        }
    }
}

- (void)startWithMuse:(id<IXNMuse>)muse
{
	NSLog(@"CDVMuse::startWithMuse");
	
    @synchronized (self.muse) {
        if (self.muse) {
            return;
        }
        self.muse = muse;
    }
	
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeBattery];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeAccelerometer];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeEeg];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDroppedAccelerometer];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDroppedEeg];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeQuantization];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDrlRef];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeAlphaAbsolute];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeBetaAbsolute];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDeltaAbsolute];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeThetaAbsolute];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeGammaAbsolute];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeAlphaRelative];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeBetaRelative];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDeltaRelative];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeThetaRelative];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeGammaRelative];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeAlphaScore];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeBetaScore];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeDeltaScore];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeThetaScore];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeGammaScore];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeHorseshoe];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeArtifacts];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeMellow];
	[self.muse registerDataListener:self
							   type:IXNMuseDataPacketTypeConcentration];
//	[self.muse registerDataListener:self
//							   type:IXNMuseDataPacketTypeTotal];

    [self.muse registerConnectionListener:self];
    [self.muse runAsynchronously];
}

- (void)reconnectToMuse
{
	NSLog(@"CDVMuse::reconnectToMuse");

  [self.muse runAsynchronously];
}

- (void)getEEG:(CDVInvokedUrlCommand *)command
{
	CDVPluginResult* pluginResult = nil;

	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet
{
	NSString *str = [[NSString alloc] init];
	for (NSString *item in packet.values) {
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%f,", [item doubleValue]]];
	}

    switch (packet.packetType) {
        case IXNMuseDataPacketTypeBattery:
            NSLog(@"received::Battery %@", str);
            break;
        case IXNMuseDataPacketTypeAccelerometer:
			NSLog(@"received::Accelerometer %@", str);
            break;
		case IXNMuseDataPacketTypeEeg:
			NSLog(@"received::Eeg %@", str);
			break;
		case IXNMuseDataPacketTypeDroppedAccelerometer:
			NSLog(@"received::DroppedAccelerometer %@", str);
			break;
		case IXNMuseDataPacketTypeDroppedEeg:
			NSLog(@"received::DroppedEeg %@", str);
			break;
		case IXNMuseDataPacketTypeQuantization:
			NSLog(@"received::Quantization %@", str);
			break;
		case IXNMuseDataPacketTypeDrlRef:
			NSLog(@"received::DrlRef %@", str);
			break;
		case IXNMuseDataPacketTypeAlphaAbsolute:
			NSLog(@"received::AlphaAbsolute %@", str);
			break;
		case IXNMuseDataPacketTypeBetaAbsolute:
			NSLog(@"received::BetaAbsolute %@", str);
			break;
		case IXNMuseDataPacketTypeDeltaAbsolute:
			NSLog(@"received::DeltaAbsolute %@", str);
			break;
		case IXNMuseDataPacketTypeThetaAbsolute:
			NSLog(@"received::ThetaAbsolute %@", str);
			break;
		case IXNMuseDataPacketTypeGammaAbsolute:
			NSLog(@"received::GammaAbsolute %@", str);
			break;
		case IXNMuseDataPacketTypeAlphaRelative:
			NSLog(@"received::AlphaRelative %@", str);
			break;
		case IXNMuseDataPacketTypeBetaRelative:
			NSLog(@"received::BetaRelative %@", str);
			break;
		case IXNMuseDataPacketTypeDeltaRelative:
			NSLog(@"received::DeltaRelative %@", str);
			break;
		case IXNMuseDataPacketTypeThetaRelative:
			NSLog(@"received::ThetaRelative %@", str);
			break;
		case IXNMuseDataPacketTypeGammaRelative:
			NSLog(@"received::GammaRelative %@", str);
			break;
		case IXNMuseDataPacketTypeAlphaScore:
			NSLog(@"received::AlphaScore %@", str);
			break;
		case IXNMuseDataPacketTypeBetaScore:
			NSLog(@"received::BetaScore %@", str);
			break;
		case IXNMuseDataPacketTypeDeltaScore:
			NSLog(@"received::DeltaScore %@", str);
			break;
		case IXNMuseDataPacketTypeThetaScore:
			NSLog(@"received::ThetaScore %@", str);
			break;
		case IXNMuseDataPacketTypeGammaScore:
			NSLog(@"received::GammaScore %@", str);
			break;
		case IXNMuseDataPacketTypeHorseshoe:
			NSLog(@"received::Horseshoe %@", str);
			break;
		case IXNMuseDataPacketTypeArtifacts:
			NSLog(@"received::Artifacts %@", str);
			break;
		case IXNMuseDataPacketTypeMellow:
			NSLog(@"received::Mellow %@", str);
			break;
		case IXNMuseDataPacketTypeConcentration:
			NSLog(@"received::Concentration %@", str);
			break;
		case IXNMuseDataPacketTypeTotal:
			NSLog(@"received::Total %@", str);
			break;
		case IXNMuseDataPacketTypeCount:
			NSLog(@"received::Count %@", str);
			break;
        default:
			NSLog(@"received::UNDEFINED %@", str);
            break;
    }
}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet
{
	NSLog(@"receiveMuseArtifactPacket");

    if (!packet.headbandOn)
        return;

    if ( !self.sawOneBlink ) {
        self.sawOneBlink = YES;
        self.lastBlink = !packet.blink;
    }
	
    if (self.lastBlink != packet.blink) {
        if (packet.blink)
            NSLog(@"blink");
        self.lastBlink = packet.blink;
    }
	
	if( packet.jawClench ) {
		NSLog(@"jawClench");
	}
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet
{
	NSLog(@"receiveMuseConnectionPacket prev:%ld", (long)packet.previousConnectionState );

    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
	
    NSLog(@"connect: %@", state);
	
    if (packet.currentConnectionState == IXNConnectionStateConnected) {
    }
	else if (packet.currentConnectionState == IXNConnectionStateDisconnected) {
        [self performSelector:@selector(reconnectToMuse)
                            withObject:nil
                            afterDelay:0];
    }
}
@end