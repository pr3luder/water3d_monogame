// Shader: textures/sfx/xmetalfloor_wall_9b
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_metalfloor_wall_9b;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_lightmap;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_metalfloor_wall_9bglow;
uniform float3x2 stage2_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_metalfloor_wall_9b>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_lightmap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_metalfloor_wall_9bglow>;
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
	output.stage1.uv = input.lightmapcoords;
	output.stage2.uv = input.texcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_metalfloor_wall_9b
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_lightmap
	destination = tex2D(stage1_sampler, input.stage1.uv) * destination;

	// stage2_metalfloor_wall_9bglow
	destination = (tex2D(stage2_sampler, input.stage2.uv)) + (destination);

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
