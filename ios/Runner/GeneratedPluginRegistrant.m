//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <android_intent/AndroidIntentPlugin.h>
#import <firebase_admob/FirebaseAdMobPlugin.h>
#import <geolocator/GeolocatorPlugin.h>
#import <google_api_availability/GoogleApiAvailabilityPlugin.h>
#import <google_maps_flutter/GoogleMapsPlugin.h>
#import <location_permissions/LocationPermissionsPlugin.h>
#import <shared_preferences/SharedPreferencesPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTAndroidIntentPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTAndroidIntentPlugin"]];
  [FLTFirebaseAdMobPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseAdMobPlugin"]];
  [GeolocatorPlugin registerWithRegistrar:[registry registrarForPlugin:@"GeolocatorPlugin"]];
  [GoogleApiAvailabilityPlugin registerWithRegistrar:[registry registrarForPlugin:@"GoogleApiAvailabilityPlugin"]];
  [FLTGoogleMapsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMapsPlugin"]];
  [LocationPermissionsPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPermissionsPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
