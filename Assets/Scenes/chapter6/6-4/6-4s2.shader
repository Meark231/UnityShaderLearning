Shader "Custom/6-4s2"//逐像素的漫反射 phong 并在unity中创建了两个模型分别用逐顶点和逐像素来对比一下
{
    Properties
    {
        _diffuse("材质颜色",Color)=(1,1,1,1)
    }
    SubShader
    {
      Pass{Tags{"LightMode"="ForwardBase"}
     
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
         #include "Lighting.cginc"//注意这个引用必须放在CGPROGRAM内
        fixed4 _diffuse;
        struct a2v{
            float4 vertex:POSITION;//为了平移的齐次坐标 所以是4维
            float3 normal:NORMAL;
        };
        struct v2f{
            float4 pos:SV_POSITION;
            fixed3 normal:TEXCOORD0;
        };

        v2f vert(a2v v){
            v2f o;
            o.pos=UnityObjectToClipPos(v.vertex);
            o.normal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));//为什么这步这么麻烦？ 因为我们需要把法线转化到世界空间 但是unity提供的矩阵是从世界空间转化到物体空间的 所以我们需要取逆矩阵 但是对于旋转矩阵来说 其逆矩阵等于其转置矩阵 所以我们可以直接使用转置矩阵来进行变换
            return o;
        }

        fixed4 frag(v2f i):SV_Target{
            fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
            fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
            fixed3 diffuse=_LightColor0.rgb*_diffuse.rgb*saturate(dot(i.normal,worldLight));
            return fixed4(ambient+diffuse,1);
        }
        ENDCG
      }
    }
    FallBack "Diffuse"
}
