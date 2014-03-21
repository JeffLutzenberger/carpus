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

- (id) initWithTrailAndColor:(NSMutableArray*)trail lineWidth:(float)lineWidth color:(float[4])color;

- (void) setColor:(float[4])color;

- (void) updateCoordinates:(NSMutableArray*)trail;

- (void) draw;

@end
