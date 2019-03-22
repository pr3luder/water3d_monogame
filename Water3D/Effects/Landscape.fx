float4x4 matWorldViewProj;	
float4x4 matWorld;
texture baseTex;
texture detailTex;
float3 xLightDirection;
float xAmbient;


// data input from application
struct a2v {
     float4 Pos : POSITION;
     float4 Normal : NORMAL;
     float2 texCoord0 : TEXCOORD0;
     float2 texCoord1 : TEXCOORD1;
};

// vertex shader output to pixel shader
struct v2p {
    float4 Pos : POSITION;
    float4 Normal : TEXCOORD0;
    float2 texCoord0 : TEXCOORD1;
    float2 texCoord1 : TEXCOORD2;
    float LightingFactor : TEXCOORD3;
};   

struct p2a {
    float4 color : COLOR0;
};

sampler2D Base = sampler_state
{
   Texture = (baseTex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   ADDRESSW = CLAMP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};

sampler2D Detail = sampler_state
{
   Texture = (detailTex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   ADDRESSW = CLAMP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};

v2p VS_multitext(in a2v IN, uniform float4x4 matWorldViewProj, uniform float4x4 matWorld, float3 xLightDirection, float xAmbient)
{   
	v2p OUT;
	// transform Position
    OUT.Pos = mul(IN.Pos, matWorldViewProj);
    OUT.texCoord0 = IN.texCoord0;
    OUT.texCoord1 = IN.texCoord1;
    
    float3 Normal = normalize(mul(normalize(IN.Normal), matWorld));	
	OUT.LightingFactor = 1;
	OUT.LightingFactor = saturate(dot(Normal, -xLightDirection));
    return OUT;
}

p2a PS_multitext(in v2p IN, uniform sampler2D Base, uniform sampler2D Detail) 
{
	p2a OUT;
	float4 color1 = tex2D(Base, IN.texCoord0);
	float4 color2 = tex2D(Detail, IN.texCoord1);
	
	OUT.color = lerp(color1, color2, 0.5f);
	OUT.color.rgb *= saturate(IN.LightingFactor + xAmbient);
    return OUT;
}


// -------------------------------------------------------------
// 
// -------------------------------------------------------------
technique TShader2
{
    pass P0
    {
        Zenable = true;
        CullMode = None;
        //AlphaBlendEnable = true;
        //SrcBlend = SrcColor;
        //DestBlend = INVSRCCOLOR;
        
        // compile shaders
        VertexShader = compile vs_2_0 VS_multitext(matWorldViewProj, matWorld, xLightDirection, xAmbient);
        PixelShader  = compile ps_2_0 PS_multitext(Base, Detail);
    }
}
