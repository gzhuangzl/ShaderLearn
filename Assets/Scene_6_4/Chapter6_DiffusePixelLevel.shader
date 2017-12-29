Shader "Unlit/Chapter6_DiffusePixelLevel"
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
					float4 clipPos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					float3 worldNormal : TEXCOORD1;
				};

				uniform fixed4 _Diffuse;

				v2f vert(a2v input)
				{
					v2f output;
					output.clipPos = UnityObjectToClipPos(input.vertex);
					output.worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
					output.worldNormal = mul(input.normal, (float3x3)unity_WorldToObject);
					return output;
				}

				fixed4 frag(v2f input) : SV_TARGET
				{
					fixed3 normal = normalize(input.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(input.worldPos));

					return fixed4(_LightColor0.rgb * _Diffuse.rgb * saturate(dot(normal, lightDir)) + UNITY_LIGHTMODEL_AMBIENT.rgb, 1);
				}
			ENDCG
		}
	}
}
