// Shader: models/mapobjects/console/rotate
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_;
uniform float3x2 stage0_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_>;
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
	 float s_stage0 = output.stage0.uv.x;
	 float t_stage0 = output.stage0.uv.y;
	output.stage0.uv.x = s_stage0*cos(0.6981317 * gameTime) + t_stage0 * -sin(0.6981317 * gameTime) + (0.5 - 0.5 * cos(0.6981317 * gameTime)+ 0.5 *sin(0.6981317 * gameTime));
	output.stage0.uv.y = s_stage0*sin(0.6981317 * gameTime) + t_stage0 * cos(0.6981317 * gameTime) + (0.5 - 0.5 * sin(0.6981317 * gameTime)- 0.5 *cos(0.6981317 * gameTime));

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_
	destination = (tex2D(stage0_sampler, input.stage0.uv)) + (destination);

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
