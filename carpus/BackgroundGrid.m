//
//  BackgroundGrid.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "BackgroundGrid.h"
#import "GraphicsWarpGridLine.h"


@implementation BackgroundGrid {
    NSMutableArray* graphicsRows;
    NSMutableArray* graphicsCols;
    float nrows;
    float ncols;
}

- (id) initWithSizeAndSpacing:(float)w h:(float)h gridx:(float)gridx gridy:(float)gridy {
    self = [super init];
    if (self) {
        _w = w;
        _h = h;
        _gridx = gridx;
        _gridy = gridy;
        
        ncols = round(w / gridx) + 1.0;
        nrows = round(h / gridy) + 1.0;
        float stiffness = 0.28;
        float damping = 0.08;
        _springs = [[NSMutableArray alloc] init];
        _points = [[NSMutableArray alloc] init];
        _fixedPoints = [[NSMutableArray alloc] init];
        _lines = [[NSMutableArray alloc] init];
        _rows  = [[NSMutableArray alloc] init];
        _cols = [[NSMutableArray alloc] init];
        
        // create the point masses
        for (float x = 0.0; x <= w; x += gridx) {
            for (float y = 0; y <= h; y += gridy) {
                [_points addObject:[[PointMass alloc] initWithPosition:x y:y]];
                [_fixedPoints addObject:[[PointMass alloc] initWithPosition:x y:y]];
            }
        }
        
        // link the point masses with springs
        int index = 0;
        int index2 = 0;
        for (int y = 0; y < (int)nrows; y++) {
            for (int x = 0; x < (int)ncols; x++) {
                index = y + x * nrows;
                if (x == 0 || y == 0 || x == ncols - 1 || y == nrows - 1) {
                    // anchor the border of the grid
                    [_springs addObject:[[Spring alloc] initWithPositionStiffnessAndDamping:[_fixedPoints objectAtIndex:index ] v2:[_points objectAtIndex:index] stiffness:0.1 damping:0.1]];
                    //this.springs.push(new Spring(this.fixedPoints[x][y], this.points[x][y], 0.1, 0.1));
                } else if (x % 3 == 0 && y % 3 == 0) {
                    // loosely anchor 1/9th of the point masses
                    [_springs addObject:[[Spring alloc] initWithPositionStiffnessAndDamping:[_fixedPoints objectAtIndex:index ] v2:[_points objectAtIndex:index] stiffness:0.002 damping:0.02]];
                }
                
                if (x > 0) {
                    index2 = y + (x - 1) *  nrows;
                    [_springs addObject:[[Spring alloc] initWithPositionStiffnessAndDamping:[_fixedPoints objectAtIndex:index2 ] v2:[_points objectAtIndex:index] stiffness:stiffness        damping:damping]];
                    //this.springs.push(new Spring(this.points[x - 1][y], this.points[x][y], stiffness, damping));
                }
                if (y > 0) {
                    index2 = (y - 1) + x *  nrows;
                    [_springs addObject:[[Spring alloc] initWithPositionStiffnessAndDamping:[_fixedPoints objectAtIndex:index2 ] v2:[_points objectAtIndex:index] stiffness:stiffness        damping:damping]];
                    //this.springs.push(new Spring(this.points[x][y - 1], this.points[x][y], stiffness, damping));
                }
            }
        }
        
        //initialize our graphics row and col lines
        graphicsCols = [[NSMutableArray alloc] init];
        graphicsRows = [[NSMutableArray alloc] init];
        for (int x = 0; x < ncols; x++) {
            [graphicsCols addObject:[[GraphicsWarpGridLine alloc] initWithCapacity:nrows]];
        }
        for (int y = 0; y < nrows; y++) {
            [graphicsRows addObject:[[GraphicsWarpGridLine alloc] initWithCapacity:ncols]];
        }
        
    }
    return self;
}

- (void) update:(float)dt {
    for (Spring* s in _springs) {
        [s update:dt];
    }
    for (PointMass* p in _points) {
        [p update:dt];
    }
}

- (void) applyExplosiveForce:(float)x y:(float)y force:(float)force radius:(float)radius {
    for (PointMass* mass in _points) {
        float dist2 = [Vector2D squaredLength:[[Vector2D alloc] initWithXY:x - mass.x y:y - mass.y]];
        if (dist2 < radius * radius) {
            Vector2D* f = [[Vector2D alloc] initWithXY:mass.x - x y:mass.y - y];
            f.x *= 100 * force / (10000 + dist2);
            f.y *= 100 * force / (10000 + dist2);
            [mass applyForce:f.x fy:f.y];
            [mass increaseDamping:0.6];
        }
    }
}

- (void) draw:(Camera*)camera {
    //float width = [_points count];
    //float height = [_points count];
    PointMass* p;
    //PointMass* pright;
    //PointMass* pdown;
    Vector2D* gridPoint;
    GraphicsWarpGridLine* row;
    GraphicsWarpGridLine* col;

    //update the points for each grid line...
    //make the vertical lines

    for (int y = 0; y < nrows; y++) {
        row = [graphicsRows objectAtIndex:y];
        float thickness = (y + 1) % 4 == 1 ? 2.0 : 1.0;
        row.lineWidth = thickness;
        for (int x = 0; x < ncols; x++) {
            p = [_points objectAtIndex:y + x * nrows];
            gridPoint = [row.points objectAtIndex:x];
            gridPoint.x = p.x;
            gridPoint.y = p.y;
        }
    }
    
    for (int x = 0; x < ncols; x++) {
        col= [graphicsCols objectAtIndex:x];
        float thickness = (x + 1) % 4 == 1 ? 2.0 : 1.0;
        col.lineWidth = thickness;
        for (int y = 0; y < nrows; y++) {
            p = [_points objectAtIndex:y + x * nrows];
            gridPoint = [col.points objectAtIndex:y];
            gridPoint.x = p.x;
            gridPoint.y = p.y;
        }
    }
    
    [camera translateObject:0.0 y:0.0 z:0.0];
    for (int y = 0; y < nrows; y++) {
        row = [graphicsRows objectAtIndex:y];
        [row updateCoordinates];
        [row draw];
    }
    for (int x = 0; x < ncols; x++) {
        col = [graphicsCols objectAtIndex:x];
        [col updateCoordinates];
        [col draw];
    }
}

@end
