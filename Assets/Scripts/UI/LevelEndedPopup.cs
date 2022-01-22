using Platformer.BlurredScreenshot;
using Platformer.Model;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Platformer.UI
{
    public class LevelEndedPopup : MonoBehaviour
    {
        #region Fields and Properties
        
        [SerializeField] private BlurredBackground blurredBackground;
        [SerializeField] private TMP_Text lblTokens;
        [SerializeField] private TMP_Text lblEnemiesKilled;
        [SerializeField] private TMP_Text lblUsername;
        [SerializeField] private TMP_Text lblScore;
        [SerializeField] private TMP_Text lblTitle;

        [SerializeField] private Color titleLostColor;
        [SerializeField] private Color titleWonColor;
        
        #endregion Fields and Properties

        public void Show(bool won)
        {
            blurredBackground.Show();
            gameObject.SetActive(true);
            
            lblTokens.text = GameDatabase.Instance.CurrentUser.Tokens.ToString();
            lblEnemiesKilled.text = GameDatabase.Instance.CurrentUser.EnemiesKilled.ToString();
            lblUsername.text = GameDatabase.Instance.CurrentUser.Username;
            lblScore.text = GameDatabase.Instance.CurrentUser.Score.ToString();
        }

        #region Event Handlers
        
        public void BtnMainMenuClicked()
        {
            SceneManager.LoadScene("Assets/Scenes/MainScene.unity", LoadSceneMode.Single);
        }

        public void BtnReplayClicked()
        {
            SceneManager.LoadScene("Assets/Scenes/LevelScene.unity", LoadSceneMode.Single);
        }

        #endregion Event Handlers
    }
}