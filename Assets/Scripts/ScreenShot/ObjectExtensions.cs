using UnityEngine;

public static class ObjectExtensions 
{
    /// <summary>
    /// Destroy objectToDestroy.
    /// </summary>
    public static void Destroy(this Object objectToDestroy)
    {
        if (objectToDestroy == null) { return; }

        if (Application.isPlaying)
        {
            Object.Destroy(objectToDestroy);
        }
#if UNITY_EDITOR
        else if (UnityEditor.EditorUtility.IsPersistent(objectToDestroy))
        {
            // Part of a prefab
            Object.DestroyImmediate(objectToDestroy, true);
        }
#endif
        else
        {
            Object.DestroyImmediate(objectToDestroy);
        }
    }

    /// <summary>
    /// Destroy objectToDestroy immediate.
    /// </summary>
    public static void DestroyImmediate(this Object objectToDestroy)
    {
        if (objectToDestroy == null) { return; }

        Object.DestroyImmediate(objectToDestroy);
    }
}
