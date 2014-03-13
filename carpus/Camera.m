//
//  Camera.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Camera.h"
#import <GLKit/GLKit.h>

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@implementation Camera {
    GLKMatrix4 modelViewProjectionMatrix;
    GLKMatrix3 normalMatrix;

}

- (id) initWithCenterAndSize:(float)x y:(float)y w:(float)w h:(float)h {
    self = [super init];
    if (self) {
        float left = x - w * 0.5;
        float right = x + w * 0.5;
        float bottom = y + h * 0.5;
        float top = y - h * 0.5;
        self.center = [[Vector2D alloc] initWithXY:x y:y];
        self.projectionMatrix = GLKMatrix4MakeOrtho (left, right, bottom, top, 0.1f, 100.0f);
        self.baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0f);
        
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.baseModelViewMatrix), NULL);
        
        modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.baseModelViewMatrix);

    }
    return self;
}

- (void)translateObject:(float)x y:(float)y z:(float)z {
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(x, y, z);
    modelViewMatrix = GLKMatrix4Multiply(self.baseModelViewMatrix, modelViewMatrix);
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(NSString*)vshFile fshFile:(NSString*)fshFile program:(GLuint*)program {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    *program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vshFile ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fshFile ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(*program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(*program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(*program, GLKVertexAttribColor, "color");
    
    // Link program.
    if (![self linkProgram:*program]) {
        NSLog(@"Failed to link program: %d", *program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(*program);
            program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(*program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(*program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(*program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(*program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
