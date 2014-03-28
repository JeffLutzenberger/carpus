//
//  GameGrid.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/22/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GameGrid.h"
#import "GridWall.h"

@implementation GameGrid {
    NSMutableArray* lines;
    NSMutableArray* rows;
    NSMutableArray* cols;
}

- (id)initWithWidthHeightAndGridSpacing:(float)w h:(float)h gridx:(float)gridx gridy:(float)gridy {
    self = [super init];
    if (self) {
        float ncols = round(w / gridx);
        float nrows = round(h / gridy);
        self.w = w;
        self.h = h;
        self.gridx = gridx;
        self.gridy = gridy;
        lines = [[NSMutableArray alloc] init];
        rows = [[NSMutableArray alloc] init];
        cols = [[NSMutableArray alloc] init];
        [self setRowsCols:nrows ncols:ncols];
    }
    return self;
}

- (void) setRowsCols:(int)nrows ncols:(int)ncols {
    [lines removeAllObjects];
    [rows removeAllObjects];
    [cols removeAllObjects];
    self.h = nrows * self.gridy;
    self.w = ncols * self.gridx;
    for (int iRow = 0; iRow < nrows + 1; iRow ++) {
        [rows addObject:[[NSNumber alloc] initWithFloat:iRow * self.gridy]];
        for (int jCol = 0; jCol < ncols; jCol ++) {
            Vector2D* p1 = [[Vector2D alloc] initWithXY:self.gridx * jCol y:self.gridy * iRow];
            Vector2D* p2 = [[Vector2D alloc] initWithXY:self.gridx * (jCol + 1) y:self.gridy * iRow];
            [lines addObject:[[GridWall alloc] initWithPoints:p1 p2:p2]];
        }
    }
    for (int iCol = 0; iCol < ncols + 1; iCol ++) {
        [cols addObject:[[NSNumber alloc] initWithFloat:iCol * self.gridx]];
        for (int iRow = 0; iRow < nrows; iRow ++) {
            Vector2D* p1 = [[Vector2D alloc] initWithXY:self.gridx * iCol y:self.gridy * iRow];
            Vector2D* p2 = [[Vector2D alloc] initWithXY:self.gridx * iCol y:self.gridy * (iRow + 1)];
            [lines addObject:[[GridWall alloc] initWithPoints:p1 p2:p2]];
        }
    }
}

- (void) setCols:(int)ncols {
    [self setRowsCols:[rows count] - 1 ncols:ncols];
}

- (void) setRows:(int)nrows {
    [self setRowsCols:nrows ncols:[cols count] - 1];
}

- (int) nCols {
    return round(self.w / self.gridx);
}

- (int) nRows {
    return round(self.h / self.gridy);
}

- (Vector2D*) extents {
    return [[Vector2D alloc] initWithXY:self.w y:self.h];
}

- (Vector2D*) center {
    return [[Vector2D alloc] initWithXY:self.w * 0.5 y:self.h * 0.5];
}

- (CGPoint) centerOfTouchedTile:(CGPoint)pos {
    CGPoint p = CGPointMake(768 * 0.5, 1024 * 0.5);
    int tile = -1;
    NSNumber* x = [[NSNumber alloc] initWithFloat:pos.x];
    NSNumber* y = [[NSNumber alloc] initWithFloat:pos.y];
    NSNumber* t1;
    NSNumber* t2;
    for (int i = 0; i < [cols count] - 1; i++) {
        t1 = (NSNumber*)[cols objectAtIndex:i];
        t2 = (NSNumber*)[cols objectAtIndex:i + 1];
        if ([x doubleValue] > [t1 doubleValue] && [x doubleValue] < [t2 doubleValue]) {
            tile = i + 1;
            p.x = i * 768 + 768 * 0.5;
            break;
        }
    }
    for (int i = 0; i < [rows count] - 1; i ++) {
        t1 = (NSNumber*)[rows objectAtIndex:i];
        t2 = (NSNumber*)[rows objectAtIndex:i + 1];
        if ([y doubleValue] > [t1 doubleValue] && [y doubleValue] < [t2 doubleValue]) {
            tile *= i + 1;
            p.y = i * 1024 + 1024 * 0.5;
            break;
        }
    }
    return p;
}

/* returns top, bottom, left, right */
- (NSMutableArray*) getGridWallsForTile:(int)rowIndex colIndex:(int)colIndex {
    NSMutableArray* walls = [[NSMutableArray alloc] init];
    
    //top
    [walls addObject:[lines objectAtIndex:colIndex + rowIndex * [self nCols]]];
    //bottom
    [walls addObject:[lines objectAtIndex:colIndex + (rowIndex + 1) * [self nCols]]];
    int offset = ([self nRows] + 1) * [self nCols];
    //left
    [walls addObject:[lines objectAtIndex:offset + rowIndex + colIndex * [self nRows]]];
    //right
    [walls addObject:[lines objectAtIndex:offset + rowIndex + (colIndex + 1) * [self nRows]]];
    
    return walls;
}

/* wall index order: top, bottom, left, right */
- (void) addDoor:(int)tileRowIndex tileColIndex:(int)tileColIndex wallIndex:(int)wallIndex s1:(float)s1 s2:(float)s2 {
    NSMutableArray* walls = [self getGridWallsForTile:tileRowIndex colIndex:tileColIndex];
    
    GridWall* wall = (GridWall*)[walls objectAtIndex:wallIndex];
    [wall setDoor:s1 s2:s2];
    
}

- (BOOL) sameTile:(Vector2D*)p1 p2:(Vector2D*)p2 {
    return [self tileNumber:p1] == [self tileNumber:p2];
}

- (int) tileNumber:(Vector2D*)p {
    int tile = -1;
    NSNumber* x = [[NSNumber alloc] initWithFloat:p.x];
    NSNumber* y = [[NSNumber alloc] initWithFloat:p.y];
    for (int i = 0; i < [cols count] - 1; i++) {
        if (x > (NSNumber*)[cols objectAtIndex:i] && x < (NSNumber*)[cols objectAtIndex:i + 1]) {
            tile = i + 1;
            break;
        }
    }
    for (int i = 0; i < [rows count] - 1; i ++) {
        if (y > (NSNumber*)[rows objectAtIndex:i] && y < (NSNumber*)[rows objectAtIndex:i + 1]) {
            tile *= i + 1;
            break;
        }
    }
    return tile;
}

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

- (Vector2D*) hit:(Particle*)p {
    for (GridWall* l in lines) {
        Vector2D* n = [l hit:p];
        if (n) return n;
    }
    return nil;
}


- (void) draw:(Camera*)camera {
    [camera translateObject:0 y:0 z:-0.5];
    for (GridWall* w in lines) {
        [w draw:camera];
    }
}

@end
