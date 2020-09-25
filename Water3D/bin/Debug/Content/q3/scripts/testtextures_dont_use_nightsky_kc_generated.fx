// Shader: textures/dont_use/nightsky_kc
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_strangesky3_kc;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_strangesky;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_strangesky2_kc;
uniform float3x2 stage2_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_strangesky3_kc>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_strangesky>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_strangesky2_kc>;
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
	output.stage0.uv.x += 0.03 * gameTime;
	output.stage0.uv.y += 0.03 * gameTime;
	output.stage1.uv = input.texcoords;
	output.stage1.uv.x += 0.05 * gameTime;
	output.stage1.uv.y += 0.05 * gameTime;
	output.stage2.uv = input.texcoords;
	output.stage2.uv.x += 0.01 * gameTime;
	output.stage2.uv.y += 0.01 * gameTime;
	output.stage2.uv.x *= 2;
	output.stage2.uv.y *= 2;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_strangesky3_kc
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_strangesky
	float4 stage1_source = tex2D(stage1_sampler, input.stage1.uv);
	destination = (stage1_source) + (destination * stage1_source);

	// stage2_strangesky2_kc
	float4 stage2_source = tex2D(stage2_sampler, input.stage2.uv);
	destination = (stage2_source * destination) + (destination * stage2_source);

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

