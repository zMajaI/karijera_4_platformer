using System;
using UnityEngine;

namespace Platformer.BlurredScreenshot
{
    public class Screenshot : IDisposable
    {
        #region Fields/Properties

		private RenderTexture blurredTexture;

		#endregion

		#region Public methods

		public void Dispose()
		{
			if (blurredTexture != null)
			{
				blurredTexture.Release();
				blurredTexture.Destroy();
				blurredTexture = null;
			}
		}

		public static RenderTexture GetTemporaryRenderTexture(RenderTexture source, int rtW, int rtH, int depth)
		{
			RenderTexture rt = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
			rt.filterMode = FilterMode.Bilinear;
			rt.depth = depth;
			rt.autoGenerateMips = false;
			rt.useMipMap = false;
			return rt;
		}

		/// <summary>
		/// Create render texture that is same size as the screen.
		/// </summary>
		public static RenderTexture NewRenderTexture(int depth = 24)
		{
			return NewRenderTexture(Screen.width, Screen.height, depth);
		}

		/// <summary>
		/// Create render texture with given size.
		/// </summary>
		public static RenderTexture NewRenderTexture(int width, int height, int depth = 0)
		{
			var result = new RenderTexture(width, height, depth, RenderTextureFormat.ARGB32)
			{
				wrapMode = TextureWrapMode.Clamp,
				filterMode = FilterMode.Bilinear,
				autoGenerateMips = false,
				useMipMap = false,
				anisoLevel = 0
			};
			return result;
		}

		/// <summary>
		/// Screenshots the whole screen applies blur and sets the texture to given UI texture.
		/// </summary>
		public RenderTexture TakeScreenShotAndBlur(Camera uiCamera)
		{
			if (blurredTexture == null) blurredTexture = NewRenderTexture();

			// create new RenderTexture and render the screen to it
			uiCamera.targetTexture = blurredTexture;
			uiCamera.Render();
			uiCamera.targetTexture = null;

			// Make it blurry
			KawaseBlur.BlurTexture(blurredTexture, 0.25f);

			// Convert RenderTexture to Texture2D
			//		Texture2D tex = new Texture2D(blurredTexture.width, blurredTexture.height, TextureFormat.ARGB32, false);
			//		RenderTexture.active = blurredTexture;
			//		tex.ReadPixels(new Rect(0, 0, blurredTexture.width, blurredTexture.height), 0, 0);
			//		tex.Apply();

			return blurredTexture;
		}

		#endregion
    }
}