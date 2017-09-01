using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public class SinProcessAnaData
    {
        public SinProcessAnaData()
        {
        }
        /// <summary>
        /// Alias string
        /// </summary>
        public string StrAlias { get; set; } = "";
        /// <summary>
        /// Analyze result
        /// </summary>
        public List<AnaDataDS> AnaDataG { get; set; } = new List<AnaDataDS>();
    }

    public class AnaDataDS
    {
        public AnaDataDS(double seg, double ca, double cp, double cpk)
        {
            this.SegmentValue = seg;
            this.CA = ca;
            this.CP = cp;
            this.CPK = cpk;
        }

        /// <summary>
        /// Analyze Value
        /// </summary>
        public double SegmentValue { get; set; }
        /// <summary>
        /// Process Analyze: CA 、 Oven Temperature Analyze: Percent Value
        /// </summary>
        public double CA { get; set; }
        /// <summary>
        /// CP
        /// </summary>
        public double CP { get; set; }

        public double CPK { get; set; }
    }
    
    public class SinProcessStruct
    {
        public SinProcessStruct()
        {
            this.IsSelect = false;
            this.AnaProcessType = ProcessType.None;
            this.AnaType = AnalyzeType.None;
            this.UpLimitTemp = 30;
            this.DownLimitTemp = 150;
            this.UpLimitValue = 3;
            this.DownLimitValue = 1;
            this.Calculate = 20;
        }

        public SinProcessStruct(SinProcessStruct sinprocess)
        {
            if (sinprocess != null)
            {
                this.IsSelect = sinprocess.IsSelect;
                this.AnaProcessType = sinprocess.AnaProcessType;
                this.AnaType = sinprocess.AnaType;
                this.UpLimitTemp = sinprocess.UpLimitTemp;
                this.DownLimitTemp = sinprocess.DownLimitTemp;
                this.UpLimitValue = sinprocess.UpLimitValue;
                this.DownLimitValue = sinprocess.DownLimitValue;
                this.Calculate = sinprocess.Calculate;
            }
            else
            {
                this.IsSelect = false;
                this.AnaProcessType = ProcessType.None;
                this.AnaType = AnalyzeType.None;
                this.UpLimitTemp = 30;
                this.DownLimitTemp = 150;
                this.UpLimitValue = 3;
                this.DownLimitValue = 1;
                this.Calculate = 20;
            }
        }

        public SinProcessStruct(ProcessType processtype, AnalyzeType anatype)
        {
            this.IsSelect = false;
            this.AnaProcessType = processtype;
            this.AnaType = anatype;
            this.UpLimitTemp = 30;
            this.DownLimitTemp = 150;
            this.UpLimitValue = 3;
            this.DownLimitValue = 1;
            this.Calculate = 20;
        }

        public SinProcessStruct(ProcessType processtype, AnalyzeType anatype, bool isselect, double uplimitvalue, double downlimitvalue,
            double uplimittemp, double downlimittemp, int calculate)
        {
            this.IsSelect = isselect;
            this.AnaProcessType = processtype;
            this.AnaType = anatype;
            this.UpLimitTemp = uplimittemp;
            this.DownLimitTemp = downlimittemp;
            this.UpLimitValue = uplimitvalue;
            this.DownLimitValue = downlimitvalue;
            this.Calculate = calculate;
        }

        public bool IsSelect { get; set; }

        public int Calculate { get; set; }

        public ProcessType AnaProcessType { get; set; }

        public AnalyzeType AnaType { get; set; }

        public double UpLimitTemp { get; set; }

        public double DownLimitTemp { get; set; }

        public double UpLimitValue { get; set; }

        public double DownLimitValue { get; set; }

        public static bool ISEqual(SinProcessStruct prodata1, SinProcessStruct prodata2)
        {
            bool iscom = true;

            if ((prodata1 == null) && (prodata2 == null))
                iscom = true;
            else
            {
                if ((prodata1 == null) || (prodata2 == null))
                    iscom = false;
                else
                {
                    if (prodata1.AnaProcessType != prodata2.AnaProcessType)
                        return false;
                    if (prodata1.AnaType != prodata2.AnaType)
                        return false;
                    if (prodata1.DownLimitTemp != prodata2.DownLimitTemp)
                        return false;
                    if (prodata1.DownLimitValue != prodata2.DownLimitValue)
                        return false;
                    if (prodata1.IsSelect != prodata2.IsSelect)
                        return false;
                    if (prodata1.UpLimitTemp != prodata2.UpLimitTemp)
                        return false;
                    if (prodata1.UpLimitValue != prodata2.UpLimitValue)
                        return false;
                }
            }
            return iscom;
        }
    }
}
