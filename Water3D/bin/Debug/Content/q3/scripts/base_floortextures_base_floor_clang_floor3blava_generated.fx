// Shader: textures/base_floor/clang_floor3blava
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_protolava2;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_clang_floor3blava;
uniform float3x2 stage1_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_protolava2>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_clang_floor3blava>;
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
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	output.stage0.uv = input.texcoords;
	output.stage0.uv.x *= 5;
	output.stage0.uv.y *= 5;
	output.stage0.uv.x += 0.04 * gameTime;
	output.stage0.uv.y += 0.03 * gameTime;
	output.stage0.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (0.01 * gameTime))) % 1025) * 6.283185) * 0.1;
	output.stage0.uv.y += 1 - sin(((((input.position.y) * 0.001 + (0.01 * gameTime))) % 1025) * 6.283185) * 0.1;
	output.stage1.uv = input.texcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_protolava2
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_clang_floor3blava
	float4 stage1_source = tex2D(stage1_sampler, input.stage1.uv);
	destination = (stage1_source * stage1_source.a) + (destination * (1.0 -stage1_source.a));

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
