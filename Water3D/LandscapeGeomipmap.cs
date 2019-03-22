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
using System.IO;
using System.Drawing;
using System.Collections.Generic;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Water3D.VertexDeclarations;
using IndexType = System.Int16;
namespace Water3D
{
    /// <summary>
	/// renders the landscape out of a bitmap called heightmap
	/// method update is overloaded to provide arbitrary
	/// projection view and world matrix (for render to texture)
	/// </summary>
	public class LandscapeGeomipmap : Object3D
	{
        private FileStream fs;
        private BinaryReader r;
        private String fileName;
        private float[] heightmap;
        private float[] displacementmap;
		private float xgrid = 1.0f; // grid in x-direction, xgrid 1
		private float zgrid = 1.0f; // grid in z direction, zgrid 1

        private Vector3[] tempDiffVec;
        private Vector3[] tempNormal;
        private bool raw;

        private ushort mapSize;
        private ushort patchSize;
        private ushort mapDetail;
        private int numPatchesPerSide;
        private PatchGeomipmap[,] m_Patches;

        private int numTrisRendered = 0;
        private int numPatchesRendered = 0;
        
        private bool doClip;
        private int numIndexBuffers;

        private PositionNormalMultiTexture[] indexedVerts;
        private VertexBuffer vbIndexed;
        private IndexBuffer[] ib;
        private IndexType[] index;
        private float maxHeight;

        private Quadtree quadtree;
		/// <summary>
		/// Chapter 4.3.3, Listing 4.3.19
		/// read heightmap which is an 8 bit greyscale bitmap
		/// </summary>
		/// <param name="device"></param>
		/// <param name="fileName"></param>
		/// <param name="pos"></param>
        public LandscapeGeomipmap(SceneContainer scene, String fileName, Vector3 pos, Matrix rotation, Vector3 scale, ushort mapDetail, ushort mapSize, ushort patchSize, bool doClip)
            : base(scene, pos, rotation, scale)
        {
            this.scene = scene;
            this.fileName = fileName;
            tempDiffVec = new Vector3[8];
            tempNormal = new Vector3[8];
            if (fileName.Split('.').Length > 1 && fileName.Split('.')[1].ToLower() == "raw")
            {
               this.raw = true;
            }
            else
            {
                this.raw = false;
            }
            maxHeight = getHeightMap(0, 0);
            this.mapSize = mapSize;
            this.patchSize = patchSize;
            this.mapDetail = mapDetail;
            this.numPatchesPerSide = mapSize / patchSize;
            this.doClip = doClip;
            setObject(pos.X, pos.Y, pos.Z);
            readHeightmap();
            smoothTerrain(3);
            m_Patches = new PatchGeomipmap[numPatchesPerSide, numPatchesPerSide];
            for (int j = 0; j < numPatchesPerSide; j++)
            {
                for (int i = 0; i < numPatchesPerSide; i++)
                {
                    m_Patches[i, j] = new PatchGeomipmap(this, new Vector3(i * patchSize * (int)scale.X, pos.Y, -j * patchSize * (int)scale.Z), Matrix.Identity, i * patchSize, j * patchSize, patchSize, mapSize, mapDetail);
                }
            }
            quadtree = new Quadtree(pos.X, pos.Z, mapSize * (int)scale.X, patchSize * (int)scale.X);
            //compute number of detailmaps
            /*int t = patchSize / 2;
            while (t >= 1)
            {
                numIndexBuffers++;
                t = t / 2;
            }*/
            // create index buffers
            numIndexBuffers = mapSize / patchSize;
            ib = new IndexBuffer[numIndexBuffers];
            initIndexBuffer();
        }
        

        public void setAllPatchesEffect(EffectContainer effect) 
        {
            for (int j = 0; j < numPatchesPerSide; j++)
            {
                for (int i = 0; i < numPatchesPerSide; i++)
                {
                    m_Patches[i, j].setEffect(effect);
                }
            }  
        }

        public void readHeightmap()
        {
            if (raw)
            {
                //raw file
                fs = new FileStream(fileName, FileMode.Open, FileAccess.Read);
                //mapSize = (int)Math.Sqrt(fs.Length) - 1;         
                r = new BinaryReader(fs);
                heightmap = new float[mapSize * mapSize];
                displacementmap = new float[mapSize * mapSize];
                for (int i = 0; i < mapSize; i++)
                {
                    for (int j = 0; j < mapSize; j++)
                    {
                        float height = r.ReadByte();
                        if (i == 0 || j == 0 || i == mapSize - 1 || j == mapSize - 1)
                        {
                            height = 0.0f;
                        }
                        heightmap[(mapSize - 1 - i) * mapSize + (mapSize - 1 - j)] = displacementmap[(mapSize - 1 - i) * i + (mapSize - 1 - j)] = height * scale.Y;
                    }
                }
                r.Close();
            }
            else
            {
                heightmap = new float[mapSize * mapSize];
                displacementmap = new float[mapSize * mapSize];
                Microsoft.Xna.Framework.Color[] heightmapColor = new Microsoft.Xna.Framework.Color[mapSize * mapSize];
                Texture2D t = (Texture2D)scene.TextureManager.getTexture(fileName);
                t.GetData<Microsoft.Xna.Framework.Color>(heightmapColor);
                int c = (int)Math.Sqrt(heightmapColor.Length);
                if (c < mapSize)
                {
                    //interpolate
                }
                for (int i = 0; i < mapSize; i++)
                {
                    for (int j = 0; j < mapSize; j++)
                    {
                        heightmap[j + i * mapSize] = displacementmap[j + i * mapSize] = heightmapColor[j + i * mapSize].R *scale.Y;
                    }
                }
            }
        }
        
        private void smoothTerrain(int smoothingPasses)
        {
            if (smoothingPasses <= 0)
            {
                return;
            }
            float[] newHeightData;

            for (int passes = (int)smoothingPasses; passes > 0; --passes)
            {
                newHeightData = new float[mapSize * mapSize];

                for (int x = 0; x < this.mapSize; ++x)
                {
                    for (int z = 0; z < this.mapSize; ++z)
                    {
                        int adjacentSections = 0;
                        float sectionsTotal = 0.0f;

                        int xMinusOne = x - 1;
                        int zMinusOne = z - 1;
                        int xPlusOne = x + 1;
                        int zPlusOne = z + 1;
                        bool bAboveIsValid = zMinusOne > 0;
                        bool bBelowIsValid = zPlusOne < mapSize;

                        // =================================================================
                        if (xMinusOne > 0)            // Check to left
                        {
                            sectionsTotal += this.heightmap[xMinusOne + z * mapSize];
                            ++adjacentSections;

                            if (bAboveIsValid)        // Check up and to the left
                            {
                                sectionsTotal += this.heightmap[xMinusOne + zMinusOne * mapSize];
                                ++adjacentSections;
                            }

                            if (bBelowIsValid)        // Check down and to the left
                            {
                                sectionsTotal += this.heightmap[xMinusOne + zPlusOne * mapSize];
                                ++adjacentSections;
                            }
                        }
                        if (xPlusOne < mapSize)     // Check to right
                        {
                            sectionsTotal += this.heightmap[xPlusOne + z * mapSize];
                            ++adjacentSections;

                            if (bAboveIsValid)        // Check up and to the right
                            {
                                sectionsTotal += this.heightmap[xPlusOne + zMinusOne * mapSize];
                                ++adjacentSections;
                            }

                            if (bBelowIsValid)        // Check down and to the right
                            {
                                sectionsTotal += this.heightmap[xPlusOne + zPlusOne * mapSize];
                                ++adjacentSections;
                            }
                        }
                        if (bAboveIsValid)            // Check above
                        {
                            sectionsTotal += this.heightmap[x + zMinusOne * mapSize];
                            ++adjacentSections;
                        }
                        if (bBelowIsValid)    // Check below
                        {
                            sectionsTotal += this.heightmap[x + zPlusOne * mapSize];
                            ++adjacentSections;
                        }
                        newHeightData[x + z * mapSize] = (this.heightmap[x + z * mapSize] + (sectionsTotal / adjacentSections)) * 0.5f;
                    }
                }

                // Overwrite the HeightData info with our new smoothed info
                for (int x = 0; x < this.mapSize; ++x)
                {
                    for (int z = 0; z < this.mapSize; ++z)
                    {
                        this.heightmap[x + z * mapSize] = newHeightData[x + z * mapSize];
                    }
                }
            }
        }
		/// <summary>
		/// render landscape
        /// render all in one pass with one 
        /// ore more texture over the whole 
        /// landcape
		/// </summary>
        public override void Draw(GameTime time)
        {
            base.Draw(time);
            this.Quadtree.updateObject(this.getScene().getCamera().getObjective().getPosition());
            drawIndexedPrimitives();
        }

		/// <summary>
		/// draw indexed primitives
		/// </summary>
		public override void drawIndexedPrimitives()
		{
            NumPatchesRendered = 0;
            updateEffects();

            foreach (EffectPass pass in effectContainer.getEffect().CurrentTechnique.Passes)
            {
                pass.Apply();
            }
            renderQuadtree(quadtree.Root);
        }

        public void renderQuadtree(QuadtreeNode root)
        {
            if (root.HasChildNodes && root.Level > 0)
            {
                renderQuadtree(root.LowerLeft);
                renderQuadtree(root.LowerRight);
                renderQuadtree(root.UpperLeft);
                renderQuadtree(root.UpperRight);
            }
            else
            {
                if (root.HasChildNodes)
                {
                    renderQuadtreeNode(root, root.Level);
                }
                else
                {
                    renderQuadtreeNode(root, root.Level + 1);
                }
            }
        }

        public void renderQuadtreeNode(QuadtreeNode qNode, int detail)
        {
            int width = (int)(qNode.Width / (patchSize * scale.X));
            int iStart = (int)Math.Abs(qNode.X / (patchSize * scale.X));
            int jStart = (int)Math.Abs(qNode.Z / (patchSize * scale.X));
            for (int j = jStart; j < jStart + width; j++)
            {
                for (int i = iStart; i < iStart + width; i++)
                {
                    if (m_Patches[i, j].isVisible())
                    {
                        NumPatchesRendered++;
                        m_Patches[i, j].render(detail);
                       
                    }
                }
            }
        }

        public override void scaleObject(float scaleX, float scaleY, float scaleZ)
        {
        }

		public void changeXGrid(float xgrid)
		{
			this.xgrid = xgrid;
            readHeightmap();;
            setObject(pos.X, pos.Y, pos.Z);
		}

		public void changeZGrid(float zgrid)
		{
			this.zgrid = zgrid;
            readHeightmap(); 
            setObject(pos.X, pos.Y, pos.Z);
		}
        
        public float getHeightMap(float x, float y)
        {
            if (x > mapSize - 1 || y > mapSize - 1)
                return 0.0f;
            return heightmap[(int)x + (int)y * mapSize];
        }
        
        // This function takes in a position, and returns the heightmap's height at that
        // point. Be careful - this function will throw an IndexOutOfRangeException if
        // position isn't on the heightmap!
        // This function is explained in more detail in the accompanying doc.
        public float getHeight(Vector3 position)
        {
            Vector3 positionOnHeightmap = new Vector3();
            // the first thing we need to do is figure out where on the heightmap
            // "position" is. This'll make the math much simpler later.
            positionOnHeightmap = position - pos;
            if (positionOnHeightmap.Z < 0)
            {
                positionOnHeightmap.Z = -positionOnHeightmap.Z;
            }
            // we'll use integer division to figure out where in the "heights" array
            // positionOnHeightmap is. Remember that integer division always rounds
            // down, so that the result of these divisions is the indices of the "upper
            // left" of the 4 corners of that cell.
            int left, top;
            left = (int)positionOnHeightmap.X / (int)scale.X;
            top = (int)positionOnHeightmap.Z / (int)scale.Z;

            // next, we'll use modulus to find out how far away we are from the upper
            // left corner of the cell. Mod will give us a value from 0 to terrainScale,
            // which we then divide by terrainScale to normalize 0 to 1.
            float xNormalized = (positionOnHeightmap.X % scale.X) / scale.X;
            float zNormalized = (positionOnHeightmap.Z % scale.Z) / scale.Z;

            // Now that we've calculated the indices of the corners of our cell, and
            // where we are in that cell, we'll use bilinear interpolation to calculuate
            // our height. This process is best explained with a diagram, so please see
            // the accompanying doc for more information.
            // First, calculate the heights on the bottom and top edge of our cell by
            // interpolating from the left and right sides.
            float topHeight = 0.0f;
            float bottomHeight = 0.0f;
            if (left < 0 || left > mapSize - 2)
            {
                left = 0;
            }
            if (top < 0 || top > mapSize - 2)
            {
                top = 0;
            }
            // next, interpolate between those two values to calculate the height at our
            // position.
            topHeight = MathHelper.Lerp(heightmap[left + top * mapSize], heightmap[(left + 1) + top * mapSize], xNormalized);
            bottomHeight = MathHelper.Lerp(heightmap[left + (top + 1) * mapSize], heightmap[(left + 1) + (top + 1) * mapSize], xNormalized);

            float height = MathHelper.Lerp(topHeight, bottomHeight, zNormalized);

            return height;
        }

        public override void initIndexBuffer()
        {
            // fill index buffers of all details
            for (int i = 0; i < ib.Length; i++)
            {
                int mapDetail = (int)Math.Pow((double)2, (double)i);
                if (mapDetail > patchSize)
                {
                    mapDetail = patchSize;
                }
                index = new IndexType[(patchSize / mapDetail) * (patchSize / mapDetail) * 6 + (patchSize / mapDetail) * 24];
                ib[i] = new IndexBuffer(scene.Game.GraphicsDevice, typeof(IndexType), (patchSize / mapDetail) * (patchSize / mapDetail) * 6 + (patchSize / mapDetail) * 24, BufferUsage.None);
                int j = 0;
                //fill index buffer
                for (int z = 0; z < patchSize; z += mapDetail)
                {
                    for (int x = 0; x < patchSize; x += mapDetail)
                    {
                        IndexType lowerLeft = (IndexType)(x + z * (patchSize + 1));
                        IndexType lowerRight = (IndexType)((x + mapDetail) + z * (patchSize + 1));
                        IndexType topLeft = (IndexType)(x + (z + mapDetail) * (patchSize + 1));
                        IndexType topRight = (IndexType)((x + mapDetail) + (z + mapDetail) * (patchSize + 1));

                        index[j++] = topLeft;
                        index[j++] = lowerRight;
                        index[j++] = lowerLeft;

                        index[j++] = topLeft;
                        index[j++] = topRight;
                        index[j++] = lowerRight;
                    }
                }
                //skirt
                for (int x = 0; x < patchSize; x += mapDetail)
                {
                    IndexType lL = (IndexType)((patchSize + 1) * (patchSize + 1) + x);
                    IndexType lR = (IndexType)((patchSize + 1) * (patchSize + 1) + x + mapDetail);
                    IndexType tL = (IndexType)x;
                    IndexType tR = (IndexType)(x + mapDetail);

                    index[j++] = tL;
                    index[j++] = lR;
                    index[j++] = lL;

                    index[j++] = tL;
                    index[j++] = tR;
                    index[j++] = lR; 
                }
                for (int z = 0; z < patchSize; z += mapDetail)
                {
                    IndexType lL = (IndexType)((patchSize + 1) * (patchSize + 1) + patchSize + 1 + z);
                    IndexType lR = (IndexType)((patchSize + 1) * (patchSize + 1) + patchSize + 1 + z + mapDetail);
                    IndexType tL = (IndexType)(patchSize + z * (patchSize + 1));
                    IndexType tR = (IndexType)(patchSize + (z + mapDetail) * (patchSize + 1));

                    index[j++] = tL;
                    index[j++] = lR;
                    index[j++] = lL;

                    index[j++] = tL;
                    index[j++] = tR;
                    index[j++] = lR;
                }
                for (int x = 0; x < patchSize; x += mapDetail)
                {
                    IndexType lL = (IndexType)((patchSize + 1) * (patchSize + 1) + 2 * (patchSize + 1) + x);
                    IndexType lR = (IndexType)((patchSize + 1) * (patchSize + 1) + 2 * (patchSize + 1) + x + mapDetail);
                    IndexType tL = (IndexType)((patchSize + 1) * (patchSize + 1) - 1 - x);
                    IndexType tR = (IndexType)((patchSize + 1) * (patchSize + 1) - 1 - x - mapDetail);

                    index[j++] = tL;
                    index[j++] = lR;
                    index[j++] = lL;

                    index[j++] = tL;
                    index[j++] = tR;
                    index[j++] = lR;
                }
                for (int z = 0; z < patchSize; z += mapDetail)
                {
                    IndexType lL = (IndexType)((patchSize + 1) * (patchSize + 1) + 3 * (patchSize + 1) + z);
                    IndexType lR = (IndexType)((patchSize + 1) * (patchSize + 1) + 3 * (patchSize + 1) + z + mapDetail);
                    IndexType tL = (IndexType)((patchSize + 1) * patchSize - z * (patchSize + 1));
                    IndexType tR = (IndexType)((patchSize + 1) * patchSize - (z + mapDetail) * (patchSize + 1));

                    index[j++] = tL;
                    index[j++] = lR;
                    index[j++] = lL;

                    index[j++] = tL;
                    index[j++] = tR;
                    index[j++] = lR;
                }
                // Lock the IndexBuffer
                ib[i].SetData<IndexType>(index);
            }
        }

        public override void initVertexBuffer()
        {
            throw new NotImplementedException();
        }

        public Quadtree Quadtree
        {
            get
            {
                return quadtree;
            }
        }

        public IndexBuffer[] IndexBuffer
        {
            get
            {
                return ib;
            }
            set
            {
                ib = value;
            }
        }

        public int NumTrisRendered
        {
            get
            {
                return numTrisRendered;
            }
            set
            {
                numTrisRendered = value;
            }
        }

        public int NumPatchesRendered
        {
            get
            {
                return numPatchesRendered;
            }
            set
            {
                numPatchesRendered = value;
            }
        }

        public void hole(float x, float z)
        {
            int iH = (int)(x / scale.X);
            int jH = (int)(-z / scale.Z);
            for (int k = 0; k < 20; k++)
            {
                for (int l = 0; l < 20; l++)
                {
                    displacementmap[(iH + l) + (jH + k) * mapSize] -= 1.0f;
                }
            }
            effectContainer.updateUniformData("displacement", displacementmap);
            /*
            for (int j = 0; j < numPatchesPerSide; j++)
            {
                for (int i = 0; i < numPatchesPerSide; i++)
                {
                    m_Patches[i, j].drawIndexedPrimitives();
                }
            }
            */
        }
	}
}
