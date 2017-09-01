using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public class RecipeProfileDS
    {
        public RecipeProfileDS()
        {
            this.BoardIndex = 0;
            this.StartTime = new DateTime();
            this.EndTime = new DateTime();
            this.RecipeName = "";
            this.BoardLength = 0;
            this.FirstFlag = false;
            this.TrackIndex = 0;
            this.StatisIndex = 0;
            this.ProcessAnaDataG = new List<List<AnaDataDS>>();
            this.OvenAnaDataG = new List<AnaDataDS>();
            this.OvenTempOffset = 0;
            this.SpeedOffset = 0;
            this.PCBCPK = 0;
            this.ReportImage = null;
            this.SNCode = "";
            this.PISIndex = 0;
            this.SimplingTempValueG = new List<double>();
        }
        /// <summary>
        /// Recipe Name
        /// </summary>
        public string RecipeName { get; set; }
        ///// <summary>
        ///// Product Name
        ///// </summary>
        //public string ProName { get; set; }
        /// <summary>
        /// Statistics Index
        /// </summary>
        public int StatisIndex { get; set; }
        /// <summary>
        /// Track Index
        /// </summary>
        public int TrackIndex { get; set; }
        /// <summary>
        /// Board Index
        /// </summary>
        public int BoardIndex { get; set; }
        ///// <summary>
        ///// Produce Line
        ///// </summary>
        //public string ProLine { get; set; }
        /// <summary>
        /// Produce Start Time
        /// </summary>
        public DateTime StartTime { get; set; }
        /// <summary>
        /// Produce End Time
        /// </summary>
        public DateTime EndTime { get; set; }
        ///// <summary>
        ///// Baseprofile Name
        ///// </summary>
        //public string BaseName { get; set; }
        ///// <summary>
        ///// Reflow Name
        ///// </summary>
        //public string ReflowName { get; set; }
        ///// <summary>
        ///// Oven Technology Name
        ///// </summary>
        //public string OvenTechName { get; set; }
        ///// <summary>
        ///// Process TechnologyName
        ///// </summary>
        //public string ProcessTechName { get; set; }

        //public bool IsControlCode { get; set; }

        //public string ControlCode { get; set; }
        /// <summary>
        /// SN Code
        /// </summary>
        public string SNCode { get; set; }
        /// <summary>
        /// Board Length
        /// </summary>
        public double BoardLength { get; set; }
        /// <summary>
        /// Report Image
        /// </summary>
        public System.Drawing.Image ReportImage { get; set; }
        /// <summary>
        /// First Flag
        /// </summary>
        public bool FirstFlag { get; set; }
        /// <summary>
        /// PIS Index
        /// </summary>
        public double PISIndex { get; set; }
        /// <summary>
        /// CPK
        /// </summary>
        public double PCBCPK { get; set; }
        /// <summary>
        /// Temperature Offset in every oven region
        /// </summary>
        public double OvenTempOffset { get; set; }
        /// <summary>
        /// Convery speed offset
        /// </summary>
        public double SpeedOffset { get; set; }
        ///// <summary>
        ///// TCs distribute
        ///// </summary>
        //public List<int> Distribute { get; set; }
        ///// <summary>
        ///// TCs temperature value
        ///// </summary>
        //public List<List<double>> TempValueG { get; set; }
        /// <summary>
        /// Simpling Inner temperature、Humidity、TCs temperature group
        /// </summary>
        public List<double> SimplingTempValueG { get; set; }
        /// <summary>
        /// Process technology analyze value
        /// </summary>
        public List<List<AnaDataDS>> ProcessAnaDataG { get; set; }
        /// <summary>
        /// Oven technology analyze value (Including Convery speed)
        /// </summary>
        public List<AnaDataDS> OvenAnaDataG { get; set; }

        public int PISIndexBaseNum { get; set; } = 0;

        public int PISIndexAlarmNum { get; set; } = 0;

        public int PISIndexWarningNum { get; set; } = 0;

        public int OvenTempBaseNum { get; set; } = 0;

        public int OvenTempAlarmNum { get; set; } = 0;

        public int OvenTempWarningNum { get; set; } = 0;
    }
}
