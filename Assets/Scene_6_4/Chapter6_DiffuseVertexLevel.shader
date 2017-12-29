Shader "Unlit/Chapter6_DiffuseVertexLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "Lighting.cginc"
				#include "UnityCG.cginc"

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 color : TEXCOORD0;
				};

				uniform fixed3 _Diffuse;

				v2f vert(a2v input)
				{
					v2f output;
					float3 worldNormal = normalize(mul(input.normal, (float3x3)unity_WorldToObject));
					float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
					float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

					output.color = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir)) + UNITY_LIGHTMODEL_AMBIENT.rgb;
					output.pos = UnityObjectToClipPos(input.vertex);
					return output;
				}

				fixed3 frag(v2f input) : SV_TARGET
				{
					return input.color;
				}
			ENDCG
		}
	}
}
