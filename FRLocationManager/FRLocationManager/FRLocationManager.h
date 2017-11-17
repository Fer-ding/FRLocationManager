//
//  FRLocationManager.h
//  FRLocationManager
//
//  Created by YueHui on 2017/11/17.
//  Copyright © 2017年 Feer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, FRLocationManagerLocationServiceStatus) {
    FRLocationManagerLocationServiceStatusDefalut,              //默认状态
    FRLocationManagerLocationServiceStatusOK,                   //定位功能正常
    FRLocationManagerLocationServiceStatusUnknownError,         //未知错误
    FRLocationManagerLocationServiceStatusUnAvailable,          //定位功能关掉了
    FRLocationManagerLocationServiceStatusNoAuthorization,      //定位功能打开，但是用户不允许使用定位
    FRLocationManagerLocationServiceStatusNoNetwork,            //没有网络
    FRLocationManagerLocationServiceStatusNotDetermined         //用户还没做出是否要允许应用使用定位功能的决定，第一次安装应用的时候会提示用户做出是否允许使用定位功能的决定
};

typedef NS_ENUM(NSUInteger, FRLocationManagerLocationResult) {
    FRLocationManagerLocationResultDefault,               //默认状态
    FRLocationManagerLocationResultLocating,              //定位中
    FRLocationManagerLocationResultSuccess,               //定位成功
    FRLocationManagerLocationResultFailure,               //定位失败
    FRLocationManagerLocationResultParamsError,           //调用API的参数错了
    FRLocationManagerLocationResultTimeout,               //超时
    FRLocationManagerLocationResultNoNetwork,             //没有网络
    FRLocationManagerLocationResultNoContent              //API没返回数据或返回数据是错的
};

@interface FRLocationManager : NSObject

@property(nonatomic, assign, readonly) FRLocationManagerLocationResult locationResult;
@property(nonatomic, assign, readonly) FRLocationManagerLocationServiceStatus locationStatus;
@property(nonatomic, copy, readonly) CLLocation *currentLocation;

+ (instancetype)sharedInstance;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;

@end
