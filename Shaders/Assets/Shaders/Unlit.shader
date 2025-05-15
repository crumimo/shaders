Shader "Unlit/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _Blend ("Blend", Range(0, 1)) = 0
        
        _ParallaxTex ("Parallax Texture", 2D) = "white" {}
        _ParallaxFrequency ("Frequency", float) = 1
        _ParallaxIntensity ("Intensity", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _SecondaryTex;
            float4 _Secondary_ST;

            float _Blend;
            
            sampler2D _ParallaxTex;
            float4 _ParallaxTex_ST;
            
            float _ParallaxFrequency;
            float _ParallaxIntensity;

            float3 _PlayerPosition;

            v2f vert (appdata v)
            {
                v2f o;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float worldNormal = mul(v.normal, unity_ObjectToWorld);
                float3 diff =_PlayerPosition - worldPos.xyz;

                
                worldPos.xyz += diff * 0.5f;
                worldPos.xyz += dot(worldNormal, normalize(diff));

                v.vertex = mul(unity_WorldToObject, worldPos);
                
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float2 parallaxUV = o.uv * _ParallaxFrequency;

                parallaxUV.x += (_Time.x * 10 + v.vertex.x);
                
                fixed4 col = tex2Dlod(_ParallaxTex, float4(o.uv * parallaxUV, 0, 0));

                v.vertex.xyz += v.normal * _ParallaxIntensity * col.r;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col1 = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_SecondaryTex, i.uv);
                fixed4 col = lerp(col1, col2, _Blend);
                
                return col;
            }
            ENDCG
        }
    }
}
