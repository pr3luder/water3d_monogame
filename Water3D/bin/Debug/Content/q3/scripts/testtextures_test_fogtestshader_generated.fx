// Shader: textures/test/fogtestshader
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_cloud2;
uniform float3x2 stage0_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_cloud2>;
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
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	output.stage0.uv = input.texcoords;
	output.stage0.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (0.03 * gameTime))) % 1025) * 6.283185) * 0.5;
	output.stage0.uv.y += 1 - sin(((((input.position.y) * 0.001 + (0.03 * gameTime))) % 1025) * 6.283185) * 0.5;
	output.stage0.uv.x += 0.25 * gameTime;
	output.stage0.uv.y += 0.25 * gameTime;
	output.stage0.uv.x *= 2;
	output.stage0.uv.y *= 2;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_cloud2
	destination = (tex2D(stage0_sampler, input.stage0.uv) * destination) + (destination);

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

