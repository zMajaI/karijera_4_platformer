using System;
using UnityEditor;
using UnityEngine;

public static class EditorHelper
{
    [MenuItem("Nordeus Debug/Capture Screenshot")]
    public static void CaptureScreenshot()
    {
        ScreenCapture.CaptureScreenshot("screenshot_" + DateTime.Now.Millisecond + ".png",
            ScreenCapture.StereoScreenCaptureMode.BothEyes);
    }
}
