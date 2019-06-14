// Shader: textures/ctf/ctf_redflag
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_ctf_redflag;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_blueflagmap;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_ctf_redflag;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_lightmap;
uniform float3x2 stage3_tcmod;
// stage4's externs
uniform texture stage4_shadow;
uniform float3x2 stage4_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_ctf_redflag>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_blueflagmap>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_ctf_redflag>;
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
	Texture = <stage4_shadow>;
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
	output.stage1.uv.x *= 0.1111111;
	output.stage1.uv.y *= 0.3333333;
	output.stage1.uv.x += 0.1 * gameTime;
	output.stage1.uv.y += 0.7 * gameTime;
	output.stage2.uv = input.texcoords;
	output.stage3.uv = input.lightmapcoords;
	output.stage4.uv = input.texcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_ctf_redflag
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_blueflagmap
	destination = (tex2D(stage1_sampler, input.stage1.uv)) + (destination);

	// stage2_ctf_redflag
	float4 stage2_source = tex2D(stage2_sampler, input.stage2.uv);
	destination = (stage2_source * stage2_source.a) + (destination * (1.0 -stage2_source.a));

	// stage3_lightmap
	destination = (tex2D(stage3_sampler, input.stage3.uv) * destination) + (destination * (1.0 -destination.a));

	// stage4_shadow
	destination = tex2D(stage4_sampler, input.stage4.uv) * destination;

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

