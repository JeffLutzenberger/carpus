//
//  GraphicsWarpGridLine.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/24/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GraphicsWarpGridLine : NSObject

@property float lineWidth;

@property NSMutableArray* points;

- (id) initWithCapacity:(int)npoints;

- (void) updateCoordinates;

- (void) draw;

@end
