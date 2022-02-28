using Platformer.Mechanics;
using UnityEngine;

public class GameSettings : MonoBehaviour
{

    [Header("Player Settings")] 
    public float MaxSpeed;
    public float SpeedUpBoosterMaxSpeed;

    [Header("Boosters Settings")] 
    public float BasicBoosterTTL = 10;
    public float SpeedUpBoosterTTL = 10;
    
    public static GameSettings Instance;

    private void Awake()
    {
        Instance = this;
    }

    public float GetTimeToLive(BoosterType boosterType)
    {
        switch (boosterType)
        {
            case BoosterType.SpeedUp:
                return SpeedUpBoosterTTL;
        }
        return BasicBoosterTTL;
    }
}
