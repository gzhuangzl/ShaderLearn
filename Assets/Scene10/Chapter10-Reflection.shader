Shader "Unlit/Chapter10-Reflection"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_ReflectColor ("Reflect Color", Color) = (1,1,1,1)
		_ReflectAmount("Reflect Amount", Range(0,1)) = 1
		_CubeMap("Reflection Map", Cube) = "_Skybox"{}
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
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float3 worldViewDir : TEXCOORD2;
					float3 worldReflect : TEXCOORD3;
				};

				fixed4 _Color;
				fixed4 _ReflectColor;
				fixed _ReflectAmount;
				samplerCUBE _CubeMap;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldViewDir  = UnityWorldSpaceViewDir(o.worldPos);
					o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed3 lightDir = UnityWorldSpaceLightDir(i.worldPos);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.rgb;
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(lightDir, worldNormal));

					fixed3 reflectColor = texCUBE(_CubeMap, i.worldReflect).rgb * _ReflectColor.rgb;

					return fixed4(ambient + lerp(diffuse, reflectColor, _ReflectAmount), 1);
				}
			ENDCG
		}
	}

	Fallback "Specular"
}
