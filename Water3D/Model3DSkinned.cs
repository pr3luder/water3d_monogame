/*
 * This file is a part of the work done by Andreas Zimmer for the 
 * University of Trier
 * Systemsoftware and Distributed Systems
 * D-54286 Trier
 * Email: andizimmer@gmx.de
 * You are free to use the code in any way you like, modified, unmodified or copy'n'pasted 
 * into your own work. However, I expect you to respect these points:  
 * - If you use this file and its contents unmodified, or use a major 
     part of this file, please credit the author and leave this note. 
 * - Please don't use it in any commercial manner.   
 * - Share your work and ideas too as much as you can.  
 * - It would be nice, if you sent me your modifications of this project
*/

using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework;
using CustomModelAnimation;

namespace Water3D
{
	/// <summary>
	/// load and draw directx .x - files that
	/// describe a 3D object
	/// </summary>
	public class Model3DSkinned : Object3D
	{
        private String clip;
        private String modelName;
        private SkinnedAnimationPlayer skinnedAnimationPlayer;
        private RootAnimationPlayer rootAnimationPlayer;
        private ModelData skinningData;
        private bool animate;
        private bool jumping;
        private bool rising;
        private float jumpHeight;
        private BoundingSphere bsLocal;
        public Model3DSkinned(SceneContainer scene, Vector3 pos, Matrix rotation, Vector3 scale, String modelName, String clip)
            : base(scene, pos, rotation, scale)
		{
            this.scene = scene;
            this.modelName = modelName;

            this.clip = clip;
            this.animate = false;
            this.jumping = false;
            this.rising = false;
            model = scene.Game.Content.Load<Model>(modelName);
            
            // Look up our custom skinning information.
            skinningData = model.Tag as ModelData;
            
            if (skinningData != null)
            {
                if (skinningData.RootAnimationClips != null)
                {
                    rootAnimationPlayer = new RootAnimationPlayer();
                }
                if (skinningData.ModelAnimationClips != null)
                {
                    skinnedAnimationPlayer = new SkinnedAnimationPlayer(skinningData.BindPose, skinningData.InverseBindPose, skinningData.SkeletonHierarchy);
                    skinnedAnimationPlayer.StartClip(skinningData.ModelAnimationClips[clip]);
                    boneTransforms = skinnedAnimationPlayer.GetSkinTransforms();
                    skinnedAnimationPlayer.Update(new GameTime(new TimeSpan(), new TimeSpan(2)));
                }
            }
            bsLocal = new BoundingSphere();
            foreach (ModelMesh mesh in model.Meshes)
            {
                bsLocal = BoundingSphere.CreateMerged(bsLocal, mesh.BoundingSphere);
            }
            setObject(pos.X, pos.Y, pos.Z);
		}

        public void updateAnimation(GameTime gameTime)
        {
            if (animate)
            {
                skinnedAnimationPlayer.Update(gameTime);
            }
        }

        public void startAnimation()
        {
            animate = true;
        }

        public void stopAnimation()
        {
            animate = false;
        }

        public void updateClip(String clip)
        {
            this.clip = clip;
            skinnedAnimationPlayer.StartClip(skinningData.ModelAnimationClips[clip]);
        }

        public override void turnLeft()
        {
            base.turnLeft();
            this.startAnimation();
        }

        public override void turnRight()
        {
            base.turnRight();
            this.startAnimation();
        }

        public override void goForward()
        {
            base.goForward();
            this.startAnimation();
        }

        public override void goBackwards()
        {
            base.goBackwards();
            this.startAnimation();
        }

        public override void Draw(GameTime time)
        {
           
            //worldMatrix = Matrix.CreateFromQuaternion(rotationQuat) * Matrix.CreateTranslation(pos);
            //scene.Game.GraphicsDevice.RasterizerState = RasterizerState.CullNone;
            //scene.Game.GraphicsDevice.DepthStencilState = DepthStencilState.Default;
            
            boneTransforms = skinnedAnimationPlayer.GetSkinTransforms();
            effectContainer.updateMutable(this);
            foreach (ModelMesh mesh in model.Meshes)
            {
                foreach (Effect currentEffect in mesh.Effects)
                {
                    if (currentEffect.GetType() == typeof(SkinnedEffect))
                    {
                        effectContainer.drawMutable(currentEffect);
                    }
                    else
                    {
                        currentEffect.Parameters["Bones"].SetValue(boneTransforms);
                        currentEffect.Parameters["View"].SetValue(World * scene.Camera.MView);
                        currentEffect.Parameters["Projection"].SetValue(scene.Camera.MProjection);
                    }
                }
                mesh.Draw();
                Matrix world = Matrix.Identity;
                world = boneTransforms[mesh.ParentBone.Index] * World;
                bs = bsLocal.Transform(world);
            }
            /* not tested */
            if (!moving)
            {
                stopAnimation();
            }
            else
            {
                startAnimation();
            }
            updateAnimation(time);
            base.Draw(time);
        }

        public override void jump()
        {
            jumpHeight = 0.0f;
            rising = true;
            jumping = true;
        }

		public override void drawIndexedPrimitives()
		{
            
		}

        public SkinnedAnimationPlayer SkinnedAnimationPlayer
        {
            get 
            {
                return skinnedAnimationPlayer;
            }
        }

        public String ModelName
        {
            get
            {
                return modelName;
            }
        }

        public bool Jumping
        {
            get
            {
                return jumping;
            }
        }

        public override void initVertexBuffer()
        {
            throw new NotImplementedException();
        }

        public override void initIndexBuffer()
        {
            throw new NotImplementedException();
        }

        public override bool collides(Object3D obj)
        {
            if (obj.GetType() == typeof(LandscapeGeomipmap))
            {
                if (pos.Y <= ((LandscapeGeomipmap)obj).getHeight(pos) + ((LandscapeGeomipmap)obj).getPosition().Y)
                {
                    return true;
                }
            }
            else if (this.bs.Intersects(obj.BoundingSphere))
            {
                return true;
            }
            return false;
        }
	}
}
