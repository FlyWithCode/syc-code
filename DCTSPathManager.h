//
//  DCTSPathManager.h
//  DictSDK
//
//  Created by syc on 2016/12/14.
//  Copyright © 2016年 ND. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCTSPathManager : NSObject

+ (instancetype)instance;

- (NSURL *)dbDir:(NSString *)dictId;

- (NSURL *)packageDir:(NSString *)dictId;

- (NSURL *)packageTmpDir:(NSString *)dictId;

- (NSURL *)audioDir:(NSString *)dictId;

- (NSURL *)downloadDestinationFile:(NSString *)dictId url:(NSURL *)url;

- (NSURL *)downloadORCFile:(NSString *)dictId;

- (NSURL *)downloadResumeFile:(NSURL *)url;

- (NSString *)defaultDictId;

- (NSString *)parseAudioUrl:(NSString *)url csHost:(NSString *)csHost withDict:(NSString *)dictId error:(NSError *__autoreleasing *)outError;

- (NSURL *)searchDataDir:(NSString *)dictId;

- (NSURL *)ebookTagDataDir:(NSString *)dictId ;

@end
