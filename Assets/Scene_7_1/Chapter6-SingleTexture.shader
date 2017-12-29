Shader "Unlit/Chapter6-SingleTexture"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white"{}
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
				//#pragma target 5.0
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					half2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 clipPos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					half2 uv : TEXCOORD2;
				};

				uniform fixed4 _Color;
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform fixed4 _Specular;
				uniform float _Gloss;

				v2f vert(a2v input)
				{
					v2f output;
					output.clipPos = UnityObjectToClipPos(input.vertex);
					output.worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
					output.worldNormal = UnityObjectToWorldNormal(input.normal);
					output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
					return output;
				}

				fixed4 frag(v2f input) : SV_TARGET
				{
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(input.worldPos));
					fixed3 worldNormal = normalize(input.worldNormal);
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(input.worldPos));

					fixed3 halfDir = normalize(lightDir + viewDir);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_MainTex, input.uv).rgb * saturate(dot(lightDir, worldNormal));

					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1);
				}
			ENDCG
		}
	}

	Fallback "Specular"
}
