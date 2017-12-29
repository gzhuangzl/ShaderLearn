Shader "Unlit/RampTexture"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_RampTex("Ramp Texture", 2D) = "white"{}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8,256)) = 20
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
					float3 worldPos : TEXCOORD0;
					float3 worldNormal : TEXCOORD1;
				};

				fixed4 _Color;
				sampler2D _RampTex;
				fixed4 _Specular;
				float _Gloss;

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldNormal = mul(v.normal, unity_WorldToObject);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;

					fixed3 diffuse = _Color.rgb * _LightColor0.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 halfDir = normalize(worldLightDir + viewDir);

					fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1);
				}
			ENDCG
		}
	}
}
