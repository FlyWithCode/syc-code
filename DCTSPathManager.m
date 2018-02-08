//
//  DCTSPathManager.m
//  DictSDK
//
//  Created by syc on 2016/12/14.
//  Copyright © 2016年 ND. All rights reserved.
//

#import "DCTSPathManager.h"
#import "DCTSNetErrorCode.h"
#import "DCTSNetErrorCodeHelper.h"
#import "NSString+DCTSExtension.h"

#define CLASSICAL_CHINESE_ID @"1" //默认是1
#define IMAGE_URL_REPALCE @"xxxx"
#define OCR_FILE_NAME @"xxxxx"

@interface DCTSPathManager()

@property (nonatomic,strong) NSURL *databaseRoot;  //数据库文件根目录
@property (nonatomic,strong) NSURL *packageRoot;   //离线包文件根目录
@property (nonatomic,strong) NSURL *tempDir;       //临时文件夹，用于存放remue数据，不区分字典，所有子弹共用一个文件夹

@end

@implementation DCTSPathManager

+ (instancetype)instance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURL *documentUrl = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                    inDomain:NSUserDomainMask
                                                                appropriateForURL:nil
                                                                      create:NO
                                                                       error:nil];
        NSURL *cacheUrl = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:NO
                                                                    error:nil];
        
        _databaseRoot = [documentUrl URLByAppendingPathComponent:@"xxxxx"];
        _packageRoot = [cacheUrl URLByAppendingPathComponent:@"xxxxxx"];
        _tempDir = [_packageRoot URLByAppendingPathComponent:@"tmp_dir"];
        
        //创建文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:_databaseRoot.path]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:_databaseRoot withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:_tempDir.path]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:_tempDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:_packageRoot.path]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:_packageRoot withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (NSURL *)dbDir:(NSString *)dictId {
    if (!dictId || [dictId isEqualToString:@""]) {
        dictId = CLASSICAL_CHINESE_ID;  
    }
    NSURL *dictDbDir = [_databaseRoot URLByAppendingPathComponent:dictId];
    [self createDir:dictDbDir];
    return [dictDbDir URLByAppendingPathComponent:@"dict_cache.db"];
}

- (NSURL *)searchDataDir:(NSString *)dictId {
    if (!dictId || [dictId isEqualToString:@""]) {
        dictId = CLASSICAL_CHINESE_ID;  
    }
    NSURL *dictDbDir = [_databaseRoot URLByAppendingPathComponent:dictId];
    [self createDir:dictDbDir];
    return [dictDbDir URLByAppendingPathComponent:@"dict_search_cache.plist"];
}

- (NSURL *)packageDir:(NSString*)dictId {
    if (!dictId || [dictId isEqualToString:@""]) {
        dictId = CLASSICAL_CHINESE_ID; 
    }
    NSURL *dictDir = [[_packageRoot URLByAppendingPathComponent:dictId] URLByAppendingPathComponent:@"pkg_dir"];
    [self createDir:dictDir];
    return dictDir;
}

- (NSURL *)packageTmpDir:(NSString*)dictId {
    if (!dictId || [dictId isEqualToString:@""]) {
        dictId = CLASSICAL_CHINESE_ID;  
    }
    NSURL *dictTmpDir = [[_packageRoot URLByAppendingPathComponent:dictId] URLByAppendingPathComponent:@"pkg_tmp_dir"];
    [self createDir:dictTmpDir];
    return dictTmpDir;
}

- (NSURL *)ebookTagDataDir:(NSString *)dictId {
    if (!dictId || [dictId isEqualToString:@""]) {
        dictId = CLASSICAL_CHINESE_ID;  
    }
    NSURL *dictDbDir = [_databaseRoot URLByAppendingPathComponent:dictId];
    [self createDir:dictDbDir];
    return [dictDbDir URLByAppendingPathComponent:@"dict_ebook_tag_cache.plist"];
}

- (NSURL *)audioDir:(NSString *)dictId {
    NSURL *pkgDir = [self packageDir:dictId];
    NSURL *audioDir = [pkgDir URLByAppendingPathComponent:@"audios"];
    [self createDir:audioDir];
    return audioDir;
}

- (NSURL *)downloadORCFile:(NSString *)dictId {
    NSURL *orcPath = [[self packageDir:dictId] URLByAppendingPathComponent:@"tessdata"];
    [self createDir:orcPath];
    return [orcPath URLByAppendingPathComponent:OCR_FILE_NAME];
}


- (NSURL *)downloadDestinationFile:(NSString *)dictId url:(NSURL *)url {
    NSURL *dictTmpDir = [self packageTmpDir:dictId];
    return [[dictTmpDir URLByAppendingPathComponent:url.absoluteString.md5] URLByAppendingPathExtension:@"zip"];
}

- (NSURL *)downloadResumeFile:(NSURL *)url {
    NSString *name = url.absoluteString.md5;
    return [_tempDir URLByAppendingPathComponent:name];
}

- (NSString *)defaultDictId {
    return CLASSICAL_CHINESE_ID;
}

- (NSString *)parseAudioUrl:(NSString *)url csHost:(NSString *)csHost withDict:(NSString *)dictId error:(NSError *__autoreleasing *)outError {
    NSString *localAudioRoot = [self audioDir:dictId].path;
    NSString *audioFile = [url stringByReplacingOccurrencesOfString:IMAGE_URL_REPALCE withString:localAudioRoot];
    if([[NSFileManager defaultManager] fileExistsAtPath:audioFile]) {
        return audioFile;
    }
    
    //本地不存在,创建文件夹，下载文件
    NSString *tempUrl = [[audioFile stringByDeletingPathExtension] stringByDeletingLastPathComponent];
    [self createPath:tempUrl];
    NSString *httpUrl = [url stringByReplacingOccurrencesOfString:IMAGE_URL_REPALCE withString:csHost];
    [self downloadUrl:httpUrl toLocalFile:audioFile error:outError];
    return audioFile;
}

#pragma mark - private method -
- (void)createDir:(NSURL *)dir {
    if(![[NSFileManager defaultManager] fileExistsAtPath:dir.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:dir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

- (void)createPath:(NSString *)path {
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
}

- (void)downloadUrl:(NSString *)url toLocalFile:(NSString *)localFile error:(NSError *__autoreleasing *)outError {
    NSString *sourceUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sourceUrl]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:outError];
    if (data && !(*outError) && response && response.statusCode == 200) {
        [data writeToFile:localFile atomically:NO];
    } else {
        MUPLogError(@"Fail to download file: %@, %@, %@, %@", url, localFile, *outError, response);
    }
}

@end
