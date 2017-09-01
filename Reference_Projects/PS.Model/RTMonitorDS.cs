using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public class RTMonitorDS
    {
        public RTMonitorDS()
        {
        }
        /// <summary>
        /// PIS与PC间网络链接状态
        /// </summary>
        public bool NetworkStat { get; set; } = false;
        /// <summary>
        /// PIS与PIS Exmd连接状态
        /// </summary>
        public bool PISExmdLinkStat { get; set; } = false;

        /// <summary>
        /// 炉子链速、各温区数据
        /// </summary>
        public List<AnaDataDS> RTOvenData { get; set; } = new List<AnaDataDS>();
        /// <summary>
        /// CPK
        /// </summary>
        public double RTCPK { get; set; } = 0;
        /// <summary>
        /// 左偏振
        /// </summary>
        public PolarizeInfo LPolarizeInfo { get; set; } = new PolarizeInfo();
        /// <summary>
        /// 右偏振
        /// </summary>
        public PolarizeInfo RPolarizeInfo { get; set; } = new PolarizeInfo();
        /// <summary>
        /// 内部温度
        /// </summary>
        public double InnerTemp { get; set; } = 0;
        /// <summary>
        /// 内部湿度
        /// </summary>
        public double InnerHumidity { get; set; } = 0;

        public class PolarizeInfo
        {
            public PolarizeInfo()
            {
                
            }

            public bool IsSelect { get; set; } = false;

            public double XValue { get; set; } = 0;

            public double YValue { get; set; } = 0;

            public double ZValue { get; set; } = 0;
        }
    }
}
