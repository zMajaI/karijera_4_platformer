using System;
using System.Collections.Generic;
using Platformer.Gameplay;
using Platformer.Mechanics;

namespace Platformer.Model
{
    public class GameDatabase
    {
        public static GameDatabase Instance = new GameDatabase();
        public UserData CurrentUser { get; private set; }
        public Action BoosterEquippedCallback;
        public Action BoosterExpiredCallback;

        private GameDatabase()
        {
            CurrentUser = new UserData();
            PlayerTokenCollision.OnExecute += PlayerCollectedToken;
            EnemyDeath.OnExecute += PlayerKilledEnemy;
            BoosterEquipped.OnExecute += BoosterEquippedHandler;
            BoosterExpired.OnExecute += BoosterExpiredHandler;
        }

        private void BoosterExpiredHandler(BoosterExpired e)
        {
            var booster = CurrentUser.equippedBoosters.Find(b => b.BoosterType == e.BoosterType);
            if (booster != null)
            {
                CurrentUser.equippedBoosters.Remove(booster);
            }
            
            BoosterExpiredCallback?.Invoke();
        }

        private void BoosterEquippedHandler(BoosterEquipped e)
        {
            var alreadyEquipped = CurrentUser.equippedBoosters.Find(b => b.BoosterType == e.BoosterType);
            if (alreadyEquipped != null)
            {
                CurrentUser.equippedBoosters.Remove(alreadyEquipped);
            }

            CurrentUser.equippedBoosters.Add(new UserBooster
                {BoosterType = e.BoosterType, timeToLive = GameSettings.Instance.GetTimeToLive(e.BoosterType)});
            
            BoosterEquippedCallback?.Invoke();
        }

        private void PlayerKilledEnemy(EnemyDeath enemyDeath)
        {
            CurrentUser.EnemiesKilled++;
        }

        private void PlayerCollectedToken(PlayerTokenCollision playerTokenCollision)
        {
            CurrentUser.Tokens++;
        }

        public void SetUsername(string newName)
        {
            CurrentUser.Username = newName;
        }

        public void ResetScore()
        {
            CurrentUser.Tokens = 0;
            CurrentUser.EnemiesKilled = 0;
        }

        ~GameDatabase()
        {
            PlayerTokenCollision.OnExecute -= PlayerCollectedToken;
            EnemyDeath.OnExecute -= PlayerKilledEnemy;
            BoosterEquipped.OnExecute -= BoosterEquippedHandler;
            BoosterExpired.OnExecute -= BoosterExpiredHandler;
        }

        public class UserData
        {
            public string Username = "";
            public int Tokens { get; internal set; }
            public int EnemiesKilled { get; internal set; }
            public int Score => Tokens * 10 + EnemiesKilled * 100;

            public List<UserBooster> equippedBoosters = new List<UserBooster>();
            
        }

        public class UserBooster
        {
            public BoosterType BoosterType;
            public float timeToLive;
            
        }
        
        
    }
}
   
