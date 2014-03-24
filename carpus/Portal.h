//
//  Portal.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/23/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Rectangle.h"

@interface Portal : Rectangle

@property ETColor inColor;
@property ETColor outColor;
@property Rectangle* outlet;

- (Vector2D*)hit:(Particle *)p;

- (void)draw:(Camera *)camera;

@end
