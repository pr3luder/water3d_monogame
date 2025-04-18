// Shader: textures/base_trim/spiderbite
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_proto_zzztblu2;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_spiderbite;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_spiderbite;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_spiderbite;
uniform float3x2 stage3_tcmod;
// stage4's externs
uniform texture stage4_lightmap;
uniform float3x2 stage4_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_proto_zzztblu2>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_spiderbite>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_spiderbite>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage3_sampler = sampler_state
{
	Texture = <stage3_spiderbite>;
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
	output.stage0.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (0.2 * gameTime))) % 1025) * 6.283185) * 0.3;
	output.stage0.uv.y += 1 - sin(((((input.position.y) * 0.001 + (0.2 * gameTime))) % 1025) * 6.283185) * 0.3;
	output.stage0.uv.x += 6 * gameTime;
	output.stage0.uv.y += 0.7 * gameTime;
	output.stage0.uv.x *= 2.5;
	output.stage0.uv.y *= 1;
	output.stage1.uv = input.texcoords;
	// Invalid or unparsed tcMod statement.
	output.stage1.uv.x += 0.3 * gameTime;
	output.stage1.uv.y += 0 * gameTime;
	output.stage2.uv = input.texcoords;
	// Invalid or unparsed tcMod statement.
	output.stage2.uv.x += -0.5 * gameTime;
	output.stage2.uv.y += 0 * gameTime;
	output.stage3.uv = input.texcoords;
	output.stage4.uv = input.lightmapcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_proto_zzztblu2
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_spiderbite
	float4 stage1_source = tex2D(stage1_sampler, input.stage1.uv);
	destination = (stage1_source * stage1_source.a) + (destination * (1.0 -stage1_source.a));

	// stage2_spiderbite
	float4 stage2_source = tex2D(stage2_sampler, input.stage2.uv);
	destination = (stage2_source * stage2_source.a) + (destination * (1.0 -stage2_source.a));

	// stage3_spiderbite
	float4 stage3_source = tex2D(stage3_sampler, input.stage3.uv);
	destination = (stage3_source * stage3_source.a) + (destination * (1.0 -stage3_source.a));

	// stage4_lightmap
	destination = (tex2D(stage4_sampler, input.stage4.uv) * destination) + (destination * (1.0 -destination.a));

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

