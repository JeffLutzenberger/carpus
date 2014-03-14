//
//  GraphicsTrace.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GraphicsTrace : NSObject

@property float* color;

- (id) initWithTrailAndColor:(NSMutableArray*)trail lineWidth:(float)lineWidth color:(float *)color;

- (void) updateCoordinates:(NSMutableArray*)trail;

- (void) draw;

@end
