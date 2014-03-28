//
//  GameGrid.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Particle.h"

@interface GameGrid : NSObject

@property (nonatomic) float w;
@property (nonatomic) float h;
@property (nonatomic) float gridx;
@property (nonatomic) float gridy;

- (id)initWithWidthHeightAndGridSpacing:(float)w h:(float)h gridx:(float)gridx gridy:(float)gridy;

- (void) setRowsCols:(int)nrows ncols:(int)ncols;

- (void) setCols:(int)ncols;

- (void) setRows:(int)nrows;

- (int) nCols;

- (int) nRows;

- (Vector2D*) extents;

- (Vector2D*) center;

/* returns top, bottom, left, right */
- (NSMutableArray*) getGridWallsForTile:(int)rowIndex colIndex:(int)colIndex;

/* wall index order: top, bottom, left, right */
- (void) addDoor:(int)tileRowIndex tileColIndex:(int)tileColIndex wallIndex:(int)wallIndex s1:(float)s1 s2:(float)s2;

- (BOOL) sameTile:(Vector2D*)p1 p2:(Vector2D*)p2;

- (int) tileNumber:(Vector2D*)p;

- (CGPoint) centerOfTouchedTile:(CGPoint)pos;

/*update: function (dt) {
 var i = 0;
 for (i = 0; i < this.lines.length; i += 1) {
 this.lines[i].update(dt);
 }
 },
 
 selectionHit : function (p) {
 var i, n;
 for (i = 0; i < this.lines.length; i += 1) {
 n = this.lines[i].circleHit(p);
 if (n) {
 return n;
 }
 }
 return undefined;
 },
 */

- (Vector2D*) hit:(Particle*)p;


- (void) draw:(Camera*)camera;

@end
