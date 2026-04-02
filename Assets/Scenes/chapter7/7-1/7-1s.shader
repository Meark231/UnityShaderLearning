   Shader "Custom/7-1s"//材质的shader 这次和上次隔了快10来天了 注释比较详细 再复习一遍
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}//纹理图片 把图片拖进来的
        _Specular("Specualr",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader
    {
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;//纹理名_ST来声明某个纹理的属性 SCALE TRANSLATION .xy是缩放值 .zw是偏移值
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;//第一组纹理坐标
            };

            struct v2f {
                float4 pos:SV_POSITION; //裁剪空间的顶点坐标
                float3 worldNormal: TEXCOORD0;//世界空间下的法线坐标 
                float3 worldPos:TEXCOORD1;//世界空间下的顶点坐标 用来求光线向量和视线向量
                float2 uv:TEXCOORD2;//存储纹理坐标的uv
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);//顶点坐标转裁切空间坐标

                o.worldNormal=UnityObjectToWorldNormal(v.normal);//模型法线->世界法线

                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;//顶点坐标->世界坐标

                o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;//很好理解 缩放+偏移 相当于内置函数o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                

                return o;

            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));//这得到的是所有顶点指向世界光源的向量们


                fixed3  albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;//材质叠加颜色 前面是Cg的tex2D函数 对纹理进行采样

                 fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;//环境光 同时也基于物体色

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));//物体色*光色*cos夹角

                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));//得到所有顶点指向摄像机的向量们

                fixed3 halfDir=normalize(worldLightDir+viewDir);//bliinphong 

                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);//注意这里看的是高光系数了，和物体颜色妹关系，(当然这很显然)

                return fixed4(ambient+diffuse+specular,1.0);
            }


            ENDCG
        }
        }
    FallBack "Specular"
        }
