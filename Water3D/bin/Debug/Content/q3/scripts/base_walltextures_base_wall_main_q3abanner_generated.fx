// Shader: textures/base_wall/main_q3abanner
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_main_q3abanner;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_comp3text;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_comp3textb;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_lightmap;
uniform float3x2 stage3_tcmod;
// stage4's externs
uniform texture stage4_lightmap;
uniform float3x2 stage4_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_main_q3abanner>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_comp3text>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_comp3textb>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage3_sampler = sampler_state
{
	Texture = <stage3_lightmap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage4_sampler = sampler_state
{
	Texture = <stage4_lightmap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};

struct stage0_input
{
	float2 uv : TEXCOORD0;
};
struct stage1_input
{
	float2 uv : TEXCOORD1;
};
struct stage2_input
{
	float2 uv : TEXCOORD2;
};
struct stage3_input
{
	float2 uv : TEXCOORD3;
};
struct stage4_input
{
	float2 uv : TEXCOORD4;
};

struct VertexShaderInput
{
	float4 position : POSITION0;
	float3 normal : NORMAL0;
	float2 texcoords : TEXCOORD0;
	float2 lightmapcoords : TEXCOORD1;
	float4 diffuse : COLOR0;
};

struct VertexShaderOutput
{
	float4 position : POSITION0;
	stage0_input stage0;
	stage1_input stage1;
	stage2_input stage2;
	stage3_input stage3;
	stage4_input stage4;
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	output.stage0.uv = input.texcoords;
	output.stage1.uv = input.texcoords;
	output.stage1.uv.x += 3 * gameTime;
	output.stage1.uv.y += 3 * gameTime;
	output.stage2.uv = input.texcoords;
	output.stage2.uv.x += 3 * gameTime;
	output.stage2.uv.y += 3 * gameTime;
	output.stage3.uv = input.lightmapcoords;
	output.stage4.uv = input.lightmapcoords;
	output.stage4.uv.x *= 2;
	output.stage4.uv.y *= 2;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_main_q3abanner
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_comp3text
	destination = (tex2D(stage1_sampler, input.stage1.uv)) + (destination);

	// stage2_comp3textb
	destination = (tex2D(stage2_sampler, input.stage2.uv)) + (destination);

	// stage3_lightmap
	destination = tex2D(stage3_sampler, input.stage3.uv) * destination;

	// stage4_lightmap
	destination = (tex2D(stage4_sampler, input.stage4.uv)) + (destination);

	destination.a = 1.0;

	return destination;
}

technique Technique1
{
	pass Pass1
	{
		VertexShader = compile vs_4_1 VertexShaderProgram();
		PixelShader = compile ps_4_1 PixelShaderProgram();
	}
}

