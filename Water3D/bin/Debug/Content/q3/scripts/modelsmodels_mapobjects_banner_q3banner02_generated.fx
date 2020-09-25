// Shader: models/mapobjects/banner/q3banner02
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_q3banner02;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_q3banner02;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_q3banner02x;
uniform float3x2 stage2_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_q3banner02>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_q3banner02>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_q3banner02x>;
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
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	output.stage0.uv = input.texcoords;
	output.stage0.uv.x *= 0.5;
	output.stage0.uv.y *= 1;
	output.stage0.uv.x += 0.33 * gameTime;
	output.stage0.uv.y += 0 * gameTime;
	output.stage1.uv = input.texcoords;
	output.stage1.uv.x *= 0.3333333;
	output.stage1.uv.y *= 1;
	output.stage1.uv.x += -0.45 * gameTime;
	output.stage1.uv.y += 0 * gameTime;
	output.stage2.uv = input.texcoords;
	output.stage2.uv.x *= 0.25;
	output.stage2.uv.y *= 1;
	output.stage2.uv.x += 1 * gameTime;
	output.stage2.uv.y += 0 * gameTime;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_q3banner02
	destination = (tex2D(stage0_sampler, input.stage0.uv)) + (destination);

	// stage1_q3banner02
	destination = (tex2D(stage1_sampler, input.stage1.uv)) + (destination);

	// stage2_q3banner02x
	destination = (tex2D(stage2_sampler, input.stage2.uv)) + (destination);

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

