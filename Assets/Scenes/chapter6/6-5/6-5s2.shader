Shader "Custom/6-5s2"//补充镜面反射的逐像素光照
{
    Properties{
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)//镜面反射颜色
        _Gloss("Gloss",Range(8.0,256))=20//高光范围
    }
    SubShader{
        Pass{
            Tags{"LightMode"="ForwardBase"}//1

            CGPROGRAM//2
            #pragma vertex vert//3
            #pragma fragment frag
            #include "Lighting.cginc"//4
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldVertex:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
            };
            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
               o.worldVertex= mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
        
               
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
    fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

  fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
 //fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*floor(20*dot(i.worldNormal,worldLightDir))/20; //卡通风格的漫反射但不知道为啥背光面全黑
  fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(i.worldNormal,worldLightDir));//3步获取漫反射 标准化的世界光源 标准化的世界法向量 
 fixed3 reflectDir=normalize(reflect(-worldLightDir,i.worldNormal));//依靠标准化的世界光源和世界法向量自然能算出反射向量
                fixed3 viewDir=normalize(_WorldSpaceCameraPos-i.worldVertex);//视线向量 依靠世界空间摄像机位置和世界空间顶点位置算出
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);//镜面反射计算公式 光线颜色*材质镜面反射颜色*pow(max(0，反射向量和视线向量的点积)，高光范围)

                return fixed4(ambient+diffuse+specular,1);
            }
            ENDCG
        }
    }
    FallBack"Specular"
}
