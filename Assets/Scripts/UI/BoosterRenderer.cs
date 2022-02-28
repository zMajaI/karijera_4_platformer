using Platformer.Core;
using Platformer.Gameplay;
using Platformer.Mechanics;
using Platformer.Model;
using UnityEngine;
using UnityEngine.UI;

public class BoosterRenderer : MonoBehaviour
{
    [SerializeField] private Image spriteRenderer;

    private GameDatabase.UserBooster booster;

    public GameDatabase.UserBooster Booster
    {
        set
        {
            booster = value;
            spriteRenderer.sprite = Resources.Load<Sprite>($"Images/Boosters/{(int) value.BoosterType}");
        }
    }

    // Update is called once per frame
    void Update()
    {
        // Update time to live
        spriteRenderer.fillAmount =
            booster.timeToLive / GameSettings.Instance.GetTimeToLive(booster.BoosterType);

        booster.timeToLive -= Time.deltaTime;
        if (booster.timeToLive <= 0f)
        {
            Simulation.Schedule<BoosterExpired>().BoosterType = booster.BoosterType;
            GameController.Instance.model.player.RemoveBooster(booster.BoosterType);
        }
    }
}
