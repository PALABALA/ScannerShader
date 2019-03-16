Shader "Hidden/Scanner"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScannerDistance ("Scanner Distance", float) = 0
        _ScannerWidth ("Scanner Width", float) = 0.3
        _ScanWaveColor ("Scan Wave Color", Color) = (1, 0, 0, 1) 
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float sonarDistance : float;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _ScannerDistance;
            float _ScannerWidth;
            float3 _ScannerWorldSpacePosition;
            float3 _ScannerWorldSpaceForwardDir;
            float4 _ScanWaveColor;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float linearDepth = Linear01Depth(rawDepth);
                
                float3 worldSpacePosition = _WorldSpaceCameraPos + _ScannerWorldSpaceForwardDir * linearDepth * 1000;
                float fragmentDistance = distance(worldSpacePosition, _ScannerWorldSpacePosition);                
                
                if (fragmentDistance > _ScannerDistance - _ScannerWidth && fragmentDistance < _ScannerDistance && linearDepth < 1)
                {
                    col = _ScanWaveColor;
                }

                return col;
            }
            ENDCG
        }
    }
}
