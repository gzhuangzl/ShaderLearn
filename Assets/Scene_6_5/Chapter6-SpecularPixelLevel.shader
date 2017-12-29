Shader "Unlit/Chapter6-SpecularPixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) =(1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Glossy("Glossy", Range(8,256)) = 20
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
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

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
				uniform fixed4 _Specular;
				uniform float _Glossy;

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
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(input.worldPos));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.worldPos));
					fixed3 worldNormal = normalize(input.worldNormal);
					fixed3 reflectLightDir = normalize(reflect(-lightDir, worldNormal));

					fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
					fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, worldNormal));
					fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectLightDir, viewDir)), _Glossy);

					return fixed4(ambientColor + specularColor + diffuseColor, 1);
				}
			ENDCG
		}
	}
}
