Shader "Unlit/Chapter8-AlphaBlendZWrite"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_AlphaScale("Alpha Scale", Range(0,10)) = 1
	}

	SubShader
	{
		Tags{"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
		//write depth
		Pass
		{
			ColorMask 0
			ZWrite On
			//以下代码是不要的
			//CGPROGRAM
			//	#pragma vertex vert
			//	#pragma fragment frag
			//	#include "UnityCg.cginc"

			//	float4 vert(float4 vertex : POSITION) : SV_POSITION
			//	{
			//		return UnityObjectToClipPos(vertex);
			//	}

			//	fixed4 frag() : SV_TARGET
			//	{
			//		return fixed4(1,1,1,1);
			//	}
			//ENDCG
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _AlphaScale;

				v2f vert(appdata_base v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed4 albedo = _Color * tex2D(_MainTex, i.uv);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
					fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldNormal, lightDir));

					return fixed4(ambient + diffuse, albedo.a * _AlphaScale);
				}
			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}
