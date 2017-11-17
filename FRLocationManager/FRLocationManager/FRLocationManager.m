//
//  FRLocationManager.m
//  FRLocationManager
//
//  Created by YueHui on 2017/11/17.
//  Copyright © 2017年 Feer. All rights reserved.
//

#import "FRLocationManager.h"

@interface FRLocationManager () <CLLocationManagerDelegate>

@property(nonatomic, assign) FRLocationManagerLocationResult locationResult;
@property(nonatomic, assign) FRLocationManagerLocationServiceStatus locationStatus;
@property(nonatomic, copy) CLLocation *currentLocation;

@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation FRLocationManager

+ (instancetype)sharedInstance {
    static FRLocationManager *locationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[FRLocationManager alloc] init];
    });
    return locationManager;
}

- (void)startLocation {
    if ([self checkLocationStatus]) {
        self.locationResult = FRLocationManagerLocationResultLocating;
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self failedLocationWithResultType:FRLocationManagerLocationResultFailure statusType:self.locationStatus];
    }
}

- (void)stopLocation {
    if ([self checkLocationStatus]) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)restartLocation {
    [self stopLocation];
    [self startLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [manager.location copy];
    NSLog(@"Current location is %@", self.currentLocation);
    [self stopLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //如果用户还没选择是否允许定位，则不认为是定位失败
    if (self.locationStatus == FRLocationManagerLocationServiceStatusNotDetermined) {
        return;
    }
    
    //如果正在定位中，那么也不会通知到外面
    if (self.locationResult == FRLocationManagerLocationResultLocating) {
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways ||status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationStatus = FRLocationManagerLocationServiceStatusOK;
        [self startLocation];
    }
    else {
        if (self.locationStatus != FRLocationManagerLocationServiceStatusNotDetermined) {
            [self failedLocationWithResultType:FRLocationManagerLocationResultDefault statusType:FRLocationManagerLocationServiceStatusNoAuthorization];
        }
        else {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark - private methods

- (void)failedLocationWithResultType:(FRLocationManagerLocationResult)result statusType:(FRLocationManagerLocationServiceStatus)status {
    self.locationResult = result;
    self.locationStatus = status;
}

- (BOOL)checkLocationStatus {
    BOOL result = NO;
    BOOL serviceEnable = [self locationServiceEnabled];
    FRLocationManagerLocationServiceStatus authorizationStatus = [self locationServiceStatus];
    if (authorizationStatus == FRLocationManagerLocationServiceStatusOK && serviceEnable) {
        result = YES;
    }
    else if (authorizationStatus == FRLocationManagerLocationServiceStatusNotDetermined) {
        result = YES;
    }
    else {
        result = NO;
    }
    
    if (serviceEnable && result) {
        result = YES;
    }
    else {
        result = NO;
    }
    
    if (!result) {
        [self failedLocationWithResultType:FRLocationManagerLocationResultFailure statusType:self.locationStatus];
    }
    
    return result;
}

- (BOOL)locationServiceEnabled {
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationStatus = FRLocationManagerLocationServiceStatusOK;
        return YES;
    }
    else {
        self.locationStatus = FRLocationManagerLocationServiceStatusUnknownError;
        return NO;
    }
}

- (FRLocationManagerLocationServiceStatus)locationServiceStatus {
    self.locationStatus = FRLocationManagerLocationServiceStatusUnknownError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                self.locationStatus = FRLocationManagerLocationServiceStatusNotDetermined;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationStatus = FRLocationManagerLocationServiceStatusOK;
                break;
            case kCLAuthorizationStatusDenied:
                self.locationStatus = FRLocationManagerLocationServiceStatusNoAuthorization;
                break;
            default:
                break;
        }
    }
    else {
        self.locationStatus = FRLocationManagerLocationServiceStatusUnAvailable;
    }
    return self.locationStatus;
}

#pragma mark - getters and setters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

@end
