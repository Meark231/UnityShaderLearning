Shader "Custom/7-4s"//遮罩纹理
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1) 
    _MainTex ("Main Tex", 2D) = "white" {} 
    _BumpMap ("Normal Map", 2D) = "bump" {} 
    _BumpScale("Bump Scale", Float) = 1.0 

    _SpecularMask ("Specular Mask", 2D) = "white" {} //高光反射的遮罩
    _SpecularScale ("Specular Scale", Float) = 1.0 

    _Specular ("Specular", Color) = (1, 1, 1, 1) 
    _Gloss ("Gloss", Range(8.0, 256)) = 20 
    }
    SubShader
    {
        Pass{
           
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment  frag

        fixed4 _Color;

        sampler2 _MainTex;
        float4 _MainTex_ST;//贴图 法线 遮罩 共用一个纹理！

        sampler2 _BumpMap;
   

        float _BumpScale;

        sampler2D _SpecularMask;
      

        float _SpecularScale;

        fixed4 _Specular;
        float _Gloss;



            ENDCG
        }
    }
    FallBack "Diffuse"
}
