// Shader: textures/skies/pj_arena4_sky
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_dimclouds;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_pjbasesky;
uniform float3x2 stage1_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_dimclouds>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_pjbasesky>;
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

struct VertexShaderInput
{
	float4 position : POSITION0;
};

struct VertexShaderOutput
{
	float4 position : POSITION0;
	stage0_input stage0;
	stage1_input stage1;
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	float3 S = normalize(float3(input.position.x, input.position.z, input.position.y));
	S.z = 1 * (S.z + 0,707);
	S = normalize(S);

	output.stage0.uv = float2(S.x, S.y);
	output.stage0.uv.x += 0.015 * gameTime;
	output.stage0.uv.y += 0.016 * gameTime;
	output.stage0.uv.x *= 3;
	output.stage0.uv.y *= 3;
	output.stage1.uv = float2(S.x, S.y);
	output.stage1.uv.x += -0.01 * gameTime;
	output.stage1.uv.y += -0.012 * gameTime;
	output.stage1.uv.x *= 5;
	output.stage1.uv.y *= 5;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_dimclouds
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_pjbasesky
	destination = (tex2D(stage1_sampler, input.stage1.uv)) + (destination);

	destination.a = 1.0;

	return destination;
}

technique Technique1
{
	pass Pass1
	{
		VertexShader = compile vs_4_0_level_9_1 VertexShaderProgram();
		PixelShader = compile ps_4_0_level_9_1 PixelShaderProgram();
	}
}
