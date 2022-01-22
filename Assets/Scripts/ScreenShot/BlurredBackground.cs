using UnityEngine;
using UnityEngine.UI;

namespace Platformer.BlurredScreenshot
{
   public class BlurredBackground : MonoBehaviour
   {
      [SerializeField] private RawImage rawBackground;
      
      public void Show()
      {
         var screenShot = new Screenshot();
         var blurredTex = screenShot.TakeScreenShotAndBlur(FindObjectOfType<Camera>());
         rawBackground.texture = blurredTex;
         rawBackground.enabled = true;
      }

      public void Hide()
      {
         rawBackground.texture = null;
         rawBackground.enabled = false;
      }
   }
}