using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public class BaseProfileDS
    {
        public BaseProfileDS()
        {
        }
        /// <mammary>
        /// 创建时间
        /// </mammary>
        public DateTime CreateTime { get; set; } = new DateTime();
        /// <mammary>
        /// 产品名称
        /// </mammary>
        public string ProName { get; set; } = "";
        /// <mammary>
        /// 基准名称
        /// </mammary>
        public string BaseName { get; set; } = "";
        /// <mammary>
        /// 回流炉名称
        /// </mammary>
        public string ReflowName { get; set; } = "";
        /// <mammary>
        /// 板面
        /// </mammary>
        public int BoardSurface { get; set; } = 0;
        /// <mammary>
        /// 公司名称
        /// </mammary>
        public string CompanyName { get; set; } = "";
        /// <mammary>
        /// 客户名称
        /// </mammary>
        public string CustomerName { get; set; } = "";
        /// <mammary>
        /// 制程工艺名称
        /// </mammary>
        public string ProcessTechName { get; set; } = "";
        /// <mammary>
        /// 回流炉控制参数名称
        /// </mammary>
        public string OvenTechName { get; set; } = "";
        /// <mammary>
        /// 产线
        /// </mammary>
        public string ProLine { get; set; } = "";
        /// <mammary>
        /// 是否使用控制码
        /// </mammary>
        public bool IsControlCode { get; set; } = false;
        /// <mammary>
        /// 控制码
        /// </mammary>
        public string ControlCode { get; set; } = "";
        /// <mammary>
        /// 操作员
        /// </mammary>
        public string Operator { get; set; } = "";
        /// <mammary>
        /// 板长
        /// </mammary>
        public double BoardLength { get; set; } = 0;
        /// <mammary>
        /// 是否有别名
        /// </mammary>
        public bool IsAlias { get; set; } = false;
        /// <mammary>
        /// 采样频率
        /// </mammary>
        public double Interval { get; set; } = 0.5;

        public int ChannelDistributeLow { get; set; } = 0;

        public int ChannelDistributeHigh { get; set; } = 0;

        public DateTime StartTime { get; set; } = new DateTime();

        public DateTime EndTime { get; set; } = new DateTime();

        public string BarcodeString { get; set; } = "";

        public string DescriptionString { get; set; } = "";

        public virtual System.Drawing.Image ReportImage { get; set; } = null;
        /// <summary>
        /// 是否使用条码
        /// </summary>
        public bool IsSN { get; set; } = false;
        /// <summary>
        /// 是否使用扩展模块
        /// </summary>
        public bool IsPISExmd { get; set; } = false;

        /// <summary>
        /// Produce process technology struct 
        /// </summary>
        public List<SinProcessStruct> ProcessTechDS { get; set; } = new List<SinProcessStruct>();
        /// <summary>
        /// Process analyze data result
        /// </summary>
        public List<SinProcessAnaData> ProcessAnaDataG { get; set; } = new List<SinProcessAnaData>();

        public List<TempValueSimplingDataG> TempValueSimplingDataGG { get; set; } = new List<TempValueSimplingDataG>();

        public OvenInfo OvenInfoData { get; set; } = new OvenInfo();

        public ReflowTCsInfo ReflowTCsData { get; set; } = new ReflowTCsInfo();

        public WarningInfo WarningInf { get; set; } = new WarningInfo();

        public int CPKCalNum { get; set; } = 25;

        public int RTCPKCalNum { get; set; } = 100;

        public int RTOvenTempBaseNum { get; set; } = 0;

        public int RTOvenTempAlarmNum { get; set; } = 0;

        public int RTOvenTempWarningNum { get; set; } = 0;


        public class TempValueSimplingDataG
        {
            public TempValueSimplingDataG()
            {

                this.TotalIndex = 0;//tinyint
                this.TCTempValue = 1;//**float(6,2)*/
                this.InnerTempValue = 0;
                this.Mosit = 0;
                this.CurArriveLength = 0;//float(7,2)
                this.CurTCIndex = 0;//tinyint
                this.CurReflowRegIndex = 0;//tinyint
                this.CurConverySpeed = 0;
                this.TempValueG = new List<double>();
            }

            /// <mammary>
            /// 索引
            /// </mammary>
            public int TotalIndex { get; set; }
            /// <mammary>
            /// 探头温度值
            /// </mammary>
            public double TCTempValue { get; set; }

            public double InnerTempValue { get; set; }
            /// <mammary>
            /// 湿度
            /// </mammary>
            public double Mosit { get; set; }
            /// <mammary>
            /// 当前到达长度
            /// </mammary>
            public double CurArriveLength { get; set; }
            /// <mammary>
            /// 当前探头序列
            /// </mammary>
            public int CurTCIndex { get; set; }
            /// <mammary>
            /// 当前炉区序列
            /// </mammary>
            public int CurReflowRegIndex { get; set; }
            /// <mammary>
            /// 当前链速
            /// </mammary>
            public double CurConverySpeed { get; set; }
            /// <mammary>
            /// 探头温度值 
            /// </mammary>
            public List<double> TempValueG { get; set; }
        }


        public class OvenInfo
        {
            public OvenInfo()
            {
                this.OvenDes = "";//varchar(50)
                this.ConverySpeed = 0;//float(5,1)
                this.OvenLength = 0;//float(7,2)
                this.SegNum = 0;//tinyint
                this.FirstLength = 0;//float(7,2)
                this.OvenSegInfoG = new List<OvenSegInfo>();
            }

            public string OvenDes { get; set; }

            public double ConverySpeed { get; set; }

            public double OvenLength { get; set; }

            public int SegNum { get; set; }

            public double FirstLength { get; set; }
            /// <mammary>
            /// 20组
            /// </mammary>
            public List<OvenSegInfo> OvenSegInfoG { get; set; }

            public class OvenSegInfo
            {
                public OvenSegInfo()
                {
                    this.OvenSegIndex = 0;//tinyint
                    this.Distance = 0;//float(7,2)
                    this.UpTemp = 0;//float(5,2)
                    this.DownTemp = 0;//float(5,2)
                }

                public int OvenSegIndex { get; set; }

                public double Distance { get; set; }

                public double UpTemp { get; set; }

                public double DownTemp { get; set; }
            }


        }
        /// <mammary>
        /// 126字段
        /// </mammary>
        public class ReflowTCsInfo
        {
            public ReflowTCsInfo()
            {
                this.TCsDes = "";//varchar(50)
                this.IsStartODD = false;//bool
                this.OvenLength = 0;//float(7,2)
                this.TCsNum = 0;//tinyint
                this.ReflowTCSegInfoG = new List<ReflowTCSegInfo>();
            }

            public string TCsDes { get; set; }

            public bool IsStartODD { get; set; }

            public double OvenLength { get; set; }

            public int TCsNum { get; set; }
            /// <mammary>
            /// 40组
            /// </mammary>
            public List<ReflowTCSegInfo> ReflowTCSegInfoG { get; set; }

            public class ReflowTCSegInfo
            {
                public ReflowTCSegInfo()
                {
                    this.TCIndex = 0;//tinyint
                    this.Distance = 0;//float(7,2)
                    this.ProbesRate = 0;
                }

                public int TCIndex { get; set; }

                public double Distance { get; set; }

                public double ProbesRate { get; set; }
            }
        }


        public class WarningInfo
        {
            public WarningInfo() { }

            /// <summary>
            /// PISIndex Warning Information
            /// </summary>
            public SinWarningInfo PISIndexWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo OvenTempWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo SpeedWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo CPKWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo ErrorSNCodeWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo LostSNCodeWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo LostBoardWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo RTOvenTempWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo RTSpeedWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo RTPolarizeWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo RTCPKWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo EnvTempWInfo { get; set; } = new SinWarningInfo();

            public SinWarningInfo EnvHumidityWInfo { get; set; } = new SinWarningInfo();
        }

        public class SinWarningInfo
        {
            public SinWarningInfo()
            {
            }

            public bool IsWarnnig { get; set; } = false;

            public double WarningLimit { get; set; } = 0;

            public bool IsAlarm { get; set; } = false;

            public double AlarmLimit { get; set; } = 0;
        }

    }    
}
