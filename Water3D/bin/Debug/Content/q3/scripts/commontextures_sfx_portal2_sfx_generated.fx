// Shader: textures/sfx/portal2_sfx
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_portal_sfx3;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_portal_sfx1;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_portal_sfx;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_portalfog;
uniform float3x2 stage3_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_portal_sfx3>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_portal_sfx1>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_portal_sfx>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage3_sampler = sampler_state
{
	Texture = <stage3_portalfog>;
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
	output.stage1.uv = input.texcoords;
	 float s_stage1 = output.stage1.uv.x;
	 float t_stage1 = output.stage1.uv.y;
	output.stage1.uv.x = s_stage1*cos(6.283185 * gameTime) + t_stage1 * -sin(6.283185 * gameTime) + (0.5 - 0.5 * cos(6.283185 * gameTime)+ 0.5 *sin(6.283185 * gameTime));
	output.stage1.uv.y = s_stage1*sin(6.283185 * gameTime) + t_stage1 * cos(6.283185 * gameTime) + (0.5 - 0.5 * sin(6.283185 * gameTime)- 0.5 *cos(6.283185 * gameTime));
	output.stage2.uv = input.texcoords;
	output.stage3.uv = input.texcoords;
	output.stage3.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (0 * gameTime))) % 1025) * 6.283185) * 0;
	output.stage3.uv.y += 1 - sin(((((input.position.y) * 0.001 + (0 * gameTime))) % 1025) * 6.283185) * 0;
	 float s_stage3 = output.stage3.uv.x;
	 float t_stage3 = output.stage3.uv.y;
	output.stage3.uv.x = s_stage3*cos(0.001745329 * gameTime) + t_stage3 * -sin(0.001745329 * gameTime) + (0.5 - 0.5 * cos(0.001745329 * gameTime)+ 0.5 *sin(0.001745329 * gameTime));
	output.stage3.uv.y = s_stage3*sin(0.001745329 * gameTime) + t_stage3 * cos(0.001745329 * gameTime) + (0.5 - 0.5 * sin(0.001745329 * gameTime)- 0.5 *cos(0.001745329 * gameTime));
	output.stage3.uv.x += 0.01 * gameTime;
	output.stage3.uv.y += 0.03 * gameTime;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_portal_sfx3
	float4 stage0_source = tex2D(stage0_sampler, input.stage0.uv);
	destination = (stage0_source * stage0_source.a) + (destination * (1.0 -stage0_source.a));

	// stage1_portal_sfx1
	destination = tex2D(stage1_sampler, input.stage1.uv) * destination;

	// stage2_portal_sfx
	destination = (tex2D(stage2_sampler, input.stage2.uv)) + (destination);

	// stage3_portalfog
	float4 stage3_source = tex2D(stage3_sampler, input.stage3.uv);
	destination = (stage3_source * stage3_source.a) + (destination * (1.0 -stage3_source.a));

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

