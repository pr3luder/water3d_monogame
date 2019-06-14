// Shader: textures/liquids/xctf_painwater
// Generic Externs
uniform float4x4 worldViewProj;
uniform float gameTime;
// stage0's externs
uniform texture stage0_pool2;
uniform float3x2 stage0_tcmod;
// stage1's externs
uniform texture stage1_pool3;
uniform float3x2 stage1_tcmod;
// stage2's externs
uniform texture stage2_bolts;
uniform float3x2 stage2_tcmod;

sampler stage0_sampler = sampler_state
{
	Texture = <stage0_pool2>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage1_sampler = sampler_state
{
	Texture = <stage1_pool3>;
	minfilter = LINEAR;
	magfilter = LINEAR;
	mipfilter = NONE;
	AddressU = Wrap;
	AddressV = Wrap;
};
sampler stage2_sampler = sampler_state
{
	Texture = <stage2_bolts>;
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
	output.stage0.uv.x *= 33.33334;
	output.stage0.uv.y *= 33.33334;
	output.stage0.uv.x += 0.001 * gameTime;
	output.stage0.uv.y += 0.001 * gameTime;
	output.stage1.uv = input.texcoords;
	output.stage1.uv.x += 1 - sin(((((input.position.x + input.position.z) * 0.001 + (0.01 * gameTime))) % 1025) * 6.283185) * 0.1;
	output.stage1.uv.y += 1 - sin(((((input.position.y) * 0.001 + (0.01 * gameTime))) % 1025) * 6.283185) * 0.1;
	output.stage1.uv.x *= 2;
	output.stage1.uv.y *= 2;
	output.stage1.uv.x += -0.025 * gameTime;
	output.stage1.uv.y += 0.02 * gameTime;
	output.stage2.uv = input.texcoords;
	output.stage2.uv.x *= 5;
	output.stage2.uv.y *= 5;
	output.stage2.uv.x += 0.1 * gameTime;
	output.stage2.uv.y += 0.1 * gameTime;
	 float s_stage2 = output.stage2.uv.x;
	 float t_stage2 = output.stage2.uv.y;
	output.stage2.uv.x = s_stage2*cos(5.061455 * gameTime) + t_stage2 * -sin(5.061455 * gameTime) + (0.5 - 0.5 * cos(5.061455 * gameTime)+ 0.5 *sin(5.061455 * gameTime));
	output.stage2.uv.y = s_stage2*sin(5.061455 * gameTime) + t_stage2 * cos(5.061455 * gameTime) + (0.5 - 0.5 * sin(5.061455 * gameTime)- 0.5 *cos(5.061455 * gameTime));

	return output;
};

float4 PixelShaderProgram(VertexShaderOutput input) : COLOR0
{
	float4 destination = (float4)0;
	float4 source = (float4)0;

	// stage0_pool2
	float4 stage0_source = tex2D(stage0_sampler, input.stage0.uv);
	destination = (stage0_source) + (destination * stage0_source);

	// stage1_pool3
	destination = (tex2D(stage1_sampler, input.stage1.uv) * destination) + (destination);

	// stage2_bolts
	destination = (tex2D(stage2_sampler, input.stage2.uv)) + (destination);

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

