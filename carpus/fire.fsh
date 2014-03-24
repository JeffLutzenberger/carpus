precision mediump float;

uniform float     iGlobalTime;           // shader playback time (in seconds)

const vec2 iResolution = vec2(256, 256);

#define _PI 3.1415926535897932384626433832795

vec2 shockcenter1 = vec2(iResolution.x/4.0,iResolution.y/4.0*3.0);

vec2 shockcenter2 = vec2(iResolution.x/4.0*3.0,iResolution.y/4.0);

vec2 getPixelShift(vec2 center,vec2 pixelpos,float startradius,float size,float shockfactor)
{
	float m_distance = distance(center,pixelpos);
	if( m_distance > startradius && m_distance < startradius+size )
	{
		float sin_dist = sin((m_distance -startradius)/size* _PI )*shockfactor;
		return ( pixelpos - normalize(pixelpos-center)*sin_dist )/ iResolution.xy;
	}
	else
		return gl_FragCoord.xy / iResolution.xy;
}


void main(void)
{
	float startradius = mod(iGlobalTime , 1.0) *600.0;
	float size = mod(iGlobalTime , 1.0) *200.0;
	float shockfactor = 50.0-mod(iGlobalTime , 1.0)*50.0;
	
	vec2 total_shift = getPixelShift(shockcenter1,gl_FragCoord.xy,startradius,size,20.0) + getPixelShift(shockcenter2,gl_FragCoord.xy,startradius,size,20.0);
	gl_FragColor = texture2D(iChannel0,total_shift);
	
}

/*
float rand(vec2 co){
	return fract(sin(dot(co.xy+vec2(19.1523,12.12345),vec2(13.4658,46.5465))) * 41846.59456);
}

float noiselayer(vec2 uv) {
    vec2 f = fract(uv);
    uv = floor(uv);
    float v = uv.x+uv.y*1e3;
    vec4 r = vec4(v, v+1., v+1e3, v+1e3+1.);
    r = fract(1e5*sin(r*1e-2));
    f = f*f*(3.0-2.0*f);
    return (mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y));
}

float noise(vec2 p, float iterations, float scale) {
	float n=0.;
	float o=1.+(iterations>1.?0.:.6), ao=0.;
	for (float r=0.; r<10.; r++) {
		if (r>iterations-.9) break;
		vec2 pr=vec2(12.5432,13.2343)*r;
		o*=.6;
		n+=noiselayer(p+pr)*o;
		n+=noiselayer(p+pr+50.5)*o;
		p=(p)*scale;
	}
	return pow(n,1.5)*.3;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy-.5;
	uv.x*=iResolution.x/iResolution.y;
	float dx=floor(uv.x*3.3333);
	uv.x=mod(uv.x,.3)-.15;
	vec2 p=uv*6.;
	float t=iGlobalTime*3.;
	float n=noise(p-vec2(dx*10.,t), dx+4., 1.7)*.5;
	float n2=noise(p*2., dx+4., 1.7);
	float c=1.-pow(max(0.,length(uv*vec2(1.8+uv.y*1.5,.75))-n*max(0.,uv.y+.15)),1.4)*10.;
	c=max(0.,c);
	vec3 col=vec3(c*1.2,c*c,c*c*.4);
	//if (uv.y<-.25 && uv.x<.145) col=vec3(n2);
	//col=vec3(n2);
	gl_FragColor = vec4(col,1.0);
}
*/