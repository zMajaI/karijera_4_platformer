using System;
using Platformer.Core;
using Platformer.Gameplay;
using UnityEngine;

namespace Platformer.Mechanics
{
    [RequireComponent(typeof(Collider2D))]
    [ExecuteInEditMode]
    public class BoosterBase : MonoBehaviour
    {
        [SerializeField]
        private AudioClip boosterCollectAudio;
        [SerializeField]
        private BoosterType boosterType;
        private BoosterType previousBoosterType;
        [SerializeField] private SpriteRenderer spriteRenderer;
        
        private void Update()
        {
            if (previousBoosterType != boosterType)
            {
                previousBoosterType = boosterType;
                spriteRenderer.sprite = Resources.Load<Sprite>($"Images/Boosters/{(int) boosterType}");
            }
        }

        void OnTriggerEnter2D(Collider2D other)
        {
            //only exectue OnPlayerEnter if the player collides with this booster.
            var player = other.gameObject.GetComponent<PlayerController>();
            if (player != null) OnPlayerEnter(player);
        }

        void OnPlayerEnter(PlayerController player)
        {
            Simulation.Schedule<BoosterEquipped>().BoosterType = boosterType;
            player.AddBooster(boosterType);
            
            AudioSource.PlayClipAtPoint(boosterCollectAudio, transform.position);
            Destroy(gameObject);
        }
    }

    public enum BoosterType
    {
        SpeedUp = 1,
        NewBooster,
        djoletov_booster,
        MojBuster , //2
        treci // 3
    }
}