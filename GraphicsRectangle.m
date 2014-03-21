//
//  GraphicsRectangle.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "GraphicsRectangle.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GraphicsRectangle {
    int vertexCount;
    float buffer[10 * 12];
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _color[4];
    Vector2D* p1;
    Vector2D* p2;
    Vector2D* p3;
    Vector2D* p4;
    Vector2D* p5;
    Vector2D* p6;
    Vector2D* p7;
    Vector2D* p8;
}

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta lineWidth:(float)lineWidth color:(float*)color {
    self = [super init];
    if (self) {
        vertexCount = 10;
        self.lineWidth = lineWidth;
        _color[0] = color[0];
        _color[1] = color[1];
        _color[2] = color[2];
        _color[3] = color[3];
        float xlin = -(w - lineWidth) * 0.5;
        float xrin = (w - lineWidth) * 0.5;
        float ytin = -(h - lineWidth) * 0.5;
        float ybin = (h - lineWidth) * 0.5;
        float xlout = -(w + lineWidth) * 0.5;
        float xrout = (w + lineWidth) * 0.5;
        float ytout = -(h + lineWidth) * 0.5;
        float ybout = (h + lineWidth) * 0.5;
        p1 = [Vector2D rotateXY:xlout y:ytout theta:theta];
        p2 = [Vector2D rotateXY:xlin y:ytin theta:theta];
        p3 = [Vector2D rotateXY:xrout y:ytout theta:theta];
        p4 = [Vector2D rotateXY:xrin y:ytin theta:theta];
        p5 = [Vector2D rotateXY:xrout y:ybout theta:theta];
        p6 = [Vector2D rotateXY:xrin y:ybin theta:theta];
        p7 = [Vector2D rotateXY:xlout y:ybout theta:theta];
        p8 = [Vector2D rotateXY:xlin y:ybin theta:theta];
        [self updateObject];
    }
    return self;
}

- (void)setColor:(float [4])c {
    _color[0] = c[0];
    _color[1] = c[1];
    _color[2] = c[2];
    _color[3] = c[3];
    [self updateObject];
}

- (void) updateObject {
    int idx = 0;
    //position
    buffer[idx++] = p1.x;
    buffer[idx++] = p1.y;
    buffer[idx++] = 0;
    //normal
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    //color
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    //texture
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    //position
    buffer[idx++] = p2.x;
    buffer[idx++] = p2.y;
    buffer[idx++] = 0;
    //normal
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    //color
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    //texture
    buffer[idx++] = 1;
    buffer[idx++] = 1;
    
    buffer[idx++] = p3.x;
    buffer[idx++] = p3.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    
    buffer[idx++] = p4.x;
    buffer[idx++] = p4.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 1;
    buffer[idx++] = 0;
    
    buffer[idx++] = p5.x;
    buffer[idx++] = p5.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;

    buffer[idx++] = p6.x;
    buffer[idx++] = p6.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;

    buffer[idx++] = p7.x;
    buffer[idx++] = p7.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    
    buffer[idx++] = p8.x;
    buffer[idx++] = p8.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;

    buffer[idx++] = p1.x;
    buffer[idx++] = p1.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;

    buffer[idx++] = p2.x;
    buffer[idx++] = p2.y;
    buffer[idx++] = 0;
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;
    buffer[idx++] = 1;
    
    buffer[idx++] = _color[0];
    buffer[idx++] = _color[1];
    buffer[idx++] = _color[2];
    buffer[idx++] = _color[3];
    
    buffer[idx++] = 0;
    buffer[idx++] = 0;

    if (_vertexArray <= 0) {
        glGenVertexArraysOES(1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        glGenBuffers(1, &_vertexBuffer);
    } else {
        glBindVertexArrayOES(_vertexArray);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(buffer), buffer, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 4 * 12, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 4 * 12, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 4 * 12, BUFFER_OFFSET(24));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 4 * 12, BUFFER_OFFSET(40));
    
    glBindVertexArrayOES(0);
    
}

- (void) draw {
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexCount);
}


@end
