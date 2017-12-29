Shader "Unlit/Chapter6-SpecularVertexLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Glossy("Glossy", Range(8, 256)) = 20
	}

	SubShader
	{
		Tags{"RenderType"="Opaque" "Queue"="Geometry"}
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma multi_compile_fwdbase
				#pragma vertex vert
				#pragma fragment frag

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f
				{
					float4 pos : SV_POSITION;
					fixed4 color : TEXCOORD0;
				};

				uniform fixed4 _Diffuse;
				uniform fixed4 _Specular;
				uniform float _Glossy;

				v2f vert(a2v input)
				{
					v2f output;
					output.pos = UnityObjectToClipPos(input.vertex);
					float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					fixed3 worldNormal = normalize(mul(input.normal,(float3x3)unity_WorldToObject));

					fixed3 reflectDir = normalize(reflect(-lightDir, worldNormal));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

					fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
					fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));
					fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Glossy);

					output.color = fixed4(ambientColor + diffuseColor + specularColor, 1);
					return output;
				}
				fixed4 frag(v2f input) : SV_TARGET
				{
					return input.color;
				}
			ENDCG
		}
	}
}
