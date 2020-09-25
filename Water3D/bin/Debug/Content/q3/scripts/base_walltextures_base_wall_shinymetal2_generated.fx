// Shader: textures/base_wall/shinymetal2
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_lightmap;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_lightmap;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_shinymetal2;
uniform float3x2 stage2_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_lightmap>;
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
	Texture = <stage2_shinymetal2>;
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
	output.stage0.uv = input.lightmapcoords;
	output.stage0.uv.x *= 4;
	output.stage0.uv.y *= 4;
	output.stage1.uv = input.lightmapcoords;
	output.stage2.uv = input.texcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_lightmap
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_lightmap
	float4 stage1_source = tex2D(stage1_sampler, input.stage1.uv);
	destination = (stage1_source) + (destination * stage1_source);

	// stage2_shinymetal2
	destination = tex2D(stage2_sampler, input.stage2.uv) * destination;

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

