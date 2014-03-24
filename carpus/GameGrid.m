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
    for (int i = 0; i < nrows + 1; i ++) {
        [rows addObject:[[NSNumber alloc] initWithFloat:i * self.gridy]];
        for (int j = 0; j < ncols; j ++) {
            Vector2D* p1 = [[Vector2D alloc] initWithXY:self.gridx * j y:self.gridy * i];
            Vector2D* p2 = [[Vector2D alloc] initWithXY:self.gridx * (j + 1) y:self.gridy * i];
            [lines addObject:[[GridWall alloc] initWithPoints:p1 p2:p2]];
        }
    }
    for (int i = 0; i < ncols + 1; i ++) {
        [cols addObject:[[NSNumber alloc] initWithFloat:i * self.gridx]];
        for (int j = 0; j < nrows; j ++) {
            Vector2D* p1 = [[Vector2D alloc] initWithXY:self.gridx * i y:self.gridy * j];
            Vector2D* p2 = [[Vector2D alloc] initWithXY:self.gridx * i y:self.gridy * (j + 1)];
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
