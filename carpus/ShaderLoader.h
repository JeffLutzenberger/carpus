//
//  ShaderLoader.h
//  carpus
//
//  Created by Jeff Lutzenberger on 3/29/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShaderLoader : NSObject

+ (BOOL)load:(NSString*)vshFile fshFile:(NSString*)fshFile program:(GLuint*)program;

@end
