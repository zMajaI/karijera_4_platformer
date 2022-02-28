using Platformer.Core;
using Platformer.Mechanics;

namespace Platformer.Gameplay
{
    public class BoosterEquipped : Simulation.Event<BoosterEquipped>
    {
        public BoosterType BoosterType;
        public override void Execute()
        {
            
        }
    }
    
    public class BoosterExpired : Simulation.Event<BoosterExpired>
    {
        public BoosterType BoosterType;
        public override void Execute()
        {
            
        }
    }
}