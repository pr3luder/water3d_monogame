// Shader: textures/ctf/killblockctf_b
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_fire_ctfblue;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_blocks18cgeomtrn2;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_blocks18cgeomtrn2;
uniform float3x2 stage2_tcmod;
// stage3's externs
uniform texture stage3_killblockgeomtrn;
uniform float3x2 stage3_tcmod;
// stage4's externs
uniform texture stage4_lightmap;
uniform float3x2 stage4_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_fire_ctfblue>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_blocks18cgeomtrn2>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_blocks18cgeomtrn2>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage3_sampler = sampler_state
{
	Texture = <stage3_killblockgeomtrn>;
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
	output.stage0.uv.x += 0 * gameTime;
	output.stage0.uv.y += 1 * gameTime;
	output.stage0.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (1.6 * gameTime))) % 1025) * 6.283185) * 0.25;
	output.stage0.uv.y += 1 - sin(((((input.position.y) * 0.001 + (1.6 * gameTime))) % 1025) * 6.283185) * 0.25;
	output.stage0.uv.x *= 0.5;
	output.stage0.uv.y *= 0.5;
	output.stage1.uv = input.texcoords;
	 float s_stage1 = output.stage1.uv.x;
	 float t_stage1 = output.stage1.uv.y;
	output.stage1.uv.x = s_stage1*cos(0.5235988 * gameTime) + t_stage1 * -sin(0.5235988 * gameTime) + (0.5 - 0.5 * cos(0.5235988 * gameTime)+ 0.5 *sin(0.5235988 * gameTime));
	output.stage1.uv.y = s_stage1*sin(0.5235988 * gameTime) + t_stage1 * cos(0.5235988 * gameTime) + (0.5 - 0.5 * sin(0.5235988 * gameTime)- 0.5 *cos(0.5235988 * gameTime));
	// Invalid or unparsed tcMod statement.
	output.stage2.uv = input.texcoords;
	 float s_stage2 = output.stage2.uv.x;
	 float t_stage2 = output.stage2.uv.y;
	output.stage2.uv.x = s_stage2*cos(0.3490658 * gameTime) + t_stage2 * -sin(0.3490658 * gameTime) + (0.5 - 0.5 * cos(0.3490658 * gameTime)+ 0.5 *sin(0.3490658 * gameTime));
	output.stage2.uv.y = s_stage2*sin(0.3490658 * gameTime) + t_stage2 * cos(0.3490658 * gameTime) + (0.5 - 0.5 * sin(0.3490658 * gameTime)- 0.5 *cos(0.3490658 * gameTime));
	// Invalid or unparsed tcMod statement.
	output.stage3.uv = input.texcoords;
	output.stage4.uv = input.lightmapcoords;

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_fire_ctfblue
	destination = tex2D(stage0_sampler, input.stage0.uv);

	// stage1_blocks18cgeomtrn2
	float4 stage1_source = tex2D(stage1_sampler, input.stage1.uv);
	destination = (stage1_source * stage1_source.a) + (destination * (1.0 -stage1_source.a));

	// stage2_blocks18cgeomtrn2
	float4 stage2_source = tex2D(stage2_sampler, input.stage2.uv);
	destination = (stage2_source * stage2_source.a) + (destination * (1.0 -stage2_source.a));

	// stage3_killblockgeomtrn
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

