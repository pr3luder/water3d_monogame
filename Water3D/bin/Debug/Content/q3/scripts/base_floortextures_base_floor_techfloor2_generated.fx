// Shader: textures/base_floor/techfloor2
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_lightmap;
uniform float3x2 stage3_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_>;
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
};

VertexShaderOutput VertexShaderProgram(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.position = mul(input.position, worldViewProj);
	output.stage0.uv = input.texcoords;
	 float s_stage0 = output.stage0.uv.x;
	 float t_stage0 = output.stage0.uv.y;
	output.stage0.uv.x = s_stage0*cos(1.22173 * gameTime) + t_stage0 * -sin(1.22173 * gameTime) + (0.5 - 0.5 * cos(1.22173 * gameTime)+ 0.5 *sin(1.22173 * gameTime));
	output.stage0.uv.y = s_stage0*sin(1.22173 * gameTime) + t_stage0 * cos(1.22173 * gameTime) + (0.5 - 0.5 * sin(1.22173 * gameTime)- 0.5 *cos(1.22173 * gameTime));
	// Invalid or unparsed tcMod statement.
	output.stage1.uv = input.texcoords;
	 float s_stage1 = output.stage1.uv.x;
	 float t_stage1 = output.stage1.uv.y;
	output.stage1.uv.x = s_stage1*cos(-0.8726646 * gameTime) + t_stage1 * -sin(-0.8726646 * gameTime) + (0.5 - 0.5 * cos(-0.8726646 * gameTime)+ 0.5 *sin(-0.8726646 * gameTime));
	output.stage1.uv.y = s_stage1*sin(-0.8726646 * gameTime) + t_stage1 * cos(-0.8726646 * gameTime) + (0.5 - 0.5 * sin(-0.8726646 * gameTime)- 0.5 *cos(-0.8726646 * gameTime));
	// Invalid or unparsed tcMod statement.
	output.stage2.uv = input.texcoords;
	 float s_stage2 = output.stage2.uv.x;
	 float t_stage2 = output.stage2.uv.y;
	output.stage2.uv.x = s_stage2*cos(0.5235988 * gameTime) + t_stage2 * -sin(0.5235988 * gameTime) + (0.5 - 0.5 * cos(0.5235988 * gameTime)+ 0.5 *sin(0.5235988 * gameTime));
	output.stage2.uv.y = s_stage2*sin(0.5235988 * gameTime) + t_stage2 * cos(0.5235988 * gameTime) + (0.5 - 0.5 * sin(0.5235988 * gameTime)- 0.5 *cos(0.5235988 * gameTime));
	// Invalid or unparsed tcMod statement.
	output.stage3.uv = input.lightmapcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_
	destination = tex2D(stage1_sampler, input.stage1.uv);

	// stage2_
	destination = tex2D(stage2_sampler, input.stage2.uv);

	// stage3_lightmap
	destination = tex2D(stage3_sampler, input.stage3.uv) * destination;

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
