using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Platformer.Gameplay;
using static Platformer.Core.Simulation;
using Platformer.Model;
using Platformer.Core;
namespace Platformer.Mechanics
{
    /// <summary>
    /// This is the main class used to implement control of the player.
    /// It is a superset of the AnimationController class, but is inlined to allow for any kind of customisation.
    /// </summary>
    public class PlayerController : KinematicObject
    {
        public AudioClip jumpAudio;
        public AudioClip respawnAudio;
        public AudioClip ouchAudio;

        /// <summary>
        /// Max horizontal speed of the player.
        /// </summary>
        public float maxSpeed = 7;
        /// <summary>
        /// Initial jump velocity at the start of a jump.
        /// </summary>
        public float jumpTakeOffSpeed = 7;
        //checkpoint sranje
        public GameObject CheckP;
        //dash sranje
        public float dash_speed = 10f;
        public float dash_len = 0.3f, dash_cd = 2f;
        private float dash_counter;
        private float dash_cool_counter;
        public bool dashing = false;
        public JumpState jumpState = JumpState.Grounded;
        private bool stopJump;
        //player scaling
        GameObject objekat;

        /*internal new*/
        public Collider2D collider2d;
        /*internal new*/
        public AudioSource audioSource;
        public Health health;
        public bool controlEnabled = true;
        //double tap method
        float KeyCooler = 0.5f;
        int KeyCounter = 0;

        bool jump;
        Vector2 move;
        SpriteRenderer spriteRenderer;
        internal Animator animator;
        readonly PlatformerModel model = Simulation.GetModel<PlatformerModel>();

        public Bounds Bounds => collider2d.bounds;

        void Awake()
        {
            health = GetComponent<Health>();
            audioSource = GetComponent<AudioSource>();
            collider2d = GetComponent<Collider2D>();
            spriteRenderer = GetComponent<SpriteRenderer>();
            animator = GetComponent<Animator>();
        }

        protected override void Update()
        {
            objekat = GameObject.Find("Player");
            if (controlEnabled)
            {
                move.x = Input.GetAxis("Horizontal");
                if (jumpState == JumpState.Grounded && Input.GetButtonDown("Jump"))
                    jumpState = JumpState.PrepareToJump;
                else if (Input.GetButtonUp("Jump"))
                {
                    stopJump = true;
                    Schedule<PlayerStopJump>().player = this;
                }
            }
            else
            {
                move.x = 0;
            }
            UpdateJumpState();
            base.Update();
            //if (Input.GetKeyDown(KeyCode.V))
            //{
            //    GameObject cp = Instantiate(CheckP, model.player.transform.position, model.player.transform.rotation);
           // }
            //double tap method

            
            if (Input.GetKeyDown(KeyCode.A) || Input.GetKeyDown(KeyCode.D) || Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.RightArrow))
            {
                if(KeyCooler > 0 && KeyCounter == 1)
                {
                    if (dash_cool_counter <= 0)
                    {
                        if (dash_counter <= 0)
                        {
                            objekat.transform.localScale = new Vector3(0.7f,0.7f,0.7f);
                            maxSpeed = dash_speed;
                            dashing = true;
                            dash_counter = dash_len;
                        }
                    }
                }
                else
                {
                    KeyCooler = 0.5f;
                    KeyCounter += 1;
                }
            }
            if(KeyCooler > 0)
            {
                KeyCooler -= 1 * Time.deltaTime;
            }
            else
            {
                KeyCounter = 0;
            }
            if (dash_counter > 0)
            {
                dash_counter -= Time.deltaTime;
                if (dash_counter <= 0)
                {
                    maxSpeed = 3;
                    dashing = false;
                    dash_cool_counter = dash_cd;
                    objekat.transform.localScale = new Vector3(1f, 1f, 1f);
                }
            }
            if (dash_cool_counter > 0)
            {
                dash_cool_counter -= Time.deltaTime;
            }
        }

        void UpdateJumpState()
        {
            jump = false;
            switch (jumpState)
            {
                case JumpState.PrepareToJump:
                    jumpState = JumpState.Jumping;
                    jump = true;
                    stopJump = false;
                    break;
                case JumpState.Jumping:
                    if (!IsGrounded)
                    {
                        Schedule<PlayerJumped>().player = this;
                        jumpState = JumpState.InFlight;
                    }
                    break;
                case JumpState.InFlight:
                    if (IsGrounded)
                    {
                        Schedule<PlayerLanded>().player = this;
                        jumpState = JumpState.Landed;
                    }
                    break;
                case JumpState.Landed:
                    jumpState = JumpState.Grounded;
                    break;
            }
        }

        protected override void ComputeVelocity()
        {
            if (jump && IsGrounded)
            {
                velocity.y = jumpTakeOffSpeed * model.jumpModifier;
                jump = false;
            }
            else if (stopJump)
            {
                stopJump = false;
                if (velocity.y > 0)
                {
                    velocity.y = velocity.y * model.jumpDeceleration;
                }
            }

            if (move.x > 0.01f)
                spriteRenderer.flipX = false;
            else if (move.x < -0.01f)
                spriteRenderer.flipX = true;

            animator.SetBool("grounded", IsGrounded);
            animator.SetFloat("velocityX", Mathf.Abs(velocity.x) / maxSpeed);

            targetVelocity = move * maxSpeed;
        }

        public enum JumpState
        {
            Grounded,
            PrepareToJump,
            Jumping,
            InFlight,
            Landed
        }
    }
}