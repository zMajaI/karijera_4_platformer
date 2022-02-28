using Platformer.Gameplay;
using Platformer.Model;
using TMPro;
using UnityEngine;

namespace Platformer.UI
{
    public class LevelCanvas : MonoBehaviour
    {
        #region Fields and Properties

        [SerializeField] private PauseMenu pauseMenu;
        [SerializeField] private LevelEndedPopup levelEndedPopup;
        [SerializeField] private TMP_Text lblTokens;
        [SerializeField] private TMP_Text lblEnemiesKilled;
        [SerializeField] private TMP_Text lblUsername;
        [SerializeField] private RectTransform equippedBoosters;
        
        #endregion Fields and Properties
        
        private static LevelCanvas _instance;
        public static LevelCanvas Instance => _instance;

        void Awake()
        {
            if (_instance == null) _instance = this;

            PlayerDeath.OnExecute += PlayerDiedCallback;
            PlayerEnteredVictoryZone.OnExecute += PlayerWonCallback;

            GameDatabase.Instance.BoosterEquippedCallback += UpdateBoosters;
            GameDatabase.Instance.BoosterExpiredCallback += UpdateBoosters;
            
            lblUsername.text = GameDatabase.Instance.CurrentUser.Username;
            GameDatabase.Instance.ResetScore();

            UpdateBoosters();

        }

        private void UpdateBoosters()
        {
            for (int i = 0; i < equippedBoosters.childCount; i++)
            {
                Destroy(equippedBoosters.GetChild(0).gameObject);
            }

            foreach (var booster in GameDatabase.Instance.CurrentUser.equippedBoosters)
            {
                var boosterRenderer = Instantiate(Resources.Load<BoosterRenderer>("Prefabs/BoosterRenderer"),
                    equippedBoosters, true);
                boosterRenderer.Booster = booster;
            }
        }

        private void OnDestroy()
        {
            PlayerDeath.OnExecute -= PlayerDiedCallback;
            PlayerEnteredVictoryZone.OnExecute -= PlayerWonCallback;
            
            GameDatabase.Instance.BoosterEquippedCallback -= UpdateBoosters;
            GameDatabase.Instance.BoosterExpiredCallback -= UpdateBoosters;
        }

        private void Update()
        {
            lblTokens.text = GameDatabase.Instance.CurrentUser.Tokens.ToString();
            lblEnemiesKilled.text = GameDatabase.Instance.CurrentUser.EnemiesKilled.ToString();
        }

        #region Event Handlers
        
        private void PlayerDiedCallback(PlayerDeath playerDeath)
        {
            levelEndedPopup.Show(false);
        }

        private void PlayerWonCallback(PlayerEnteredVictoryZone playerEnteredVictoryZone)
        {
            levelEndedPopup.Show(true);
        }

        public void BtnPauseClicked()
        {
            pauseMenu.Show();
        }

        #endregion Event Handlers
    }
}