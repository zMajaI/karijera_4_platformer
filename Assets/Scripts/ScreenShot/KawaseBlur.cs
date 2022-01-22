using UnityEngine;

namespace Platformer.BlurredScreenshot
{
    public static class KawaseBlur
    {
        public static readonly int[] BlurKernel = {0, 1, 1, 2, 2, 3, 3};

        public static Shader KawaseShader
        {
            get
            {
                if (kawaseShader == null)
                {
                    kawaseShader = Shader.Find("Custom/KawaseBlur");
                }

                return kawaseShader;
            }
        }

        #region Fields/Properties

        private static Shader kawaseShader;
        private static readonly int Offset = Shader.PropertyToID("_Offset");

        #endregion

        #region Public methods

        public static void BlurTexture(RenderTexture screenTex, float downscaleFactor)
        {
            var oldTarget = RenderTexture.active;

            try
            {
                var downscaledTex1 = Screenshot.NewRenderTexture((int) (Screen.width * downscaleFactor),
                    (int) (Screen.height * downscaleFactor));
                var downscaledTex2 = Screenshot.NewRenderTexture((int) (Screen.width * downscaleFactor),
                    (int) (Screen.height * downscaleFactor));
                Graphics.Blit(screenTex, downscaledTex1);

                RenderTexture source = downscaledTex1;
                RenderTexture destination = downscaledTex2;

                Graphics.Blit(screenTex, downscaledTex1);

                var blurMaterial = new Material(KawaseShader);
                blurMaterial.SetColor("_Color", new Color(212,226,250));
                for (int i = 0; i < BlurKernel.Length; i++)
                {
                    blurMaterial.SetVector(Offset,
                        new Vector4(1f / downscaledTex1.width, 1f / downscaledTex1.height, BlurKernel[i]));
                    destination.DiscardContents();
                    Graphics.Blit(source, destination, blurMaterial);
                    var temp = source;
                    source = destination;
                    destination = temp;
                }

                blurMaterial.Destroy();

                screenTex.DiscardContents();
                Graphics.Blit(source, screenTex);
                source.Release();
                source.Destroy();
                destination.Release();
                destination.Destroy();
            }
            catch (System.Exception e)
            {
                Debug.LogException(e);
            }
            finally
            {
                Graphics.SetRenderTarget(oldTarget);
            }
        }

        #endregion
    }
}