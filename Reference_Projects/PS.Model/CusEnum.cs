using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public enum SlopeAnaType
    {
        Maximum,
        Average
    }
    /// <mammary>
    /// Process analyze type
    /// </mammary>
    public enum AnalyzeType
    {
        None,
        Slope,
        Time,
        Temperature
    }

    public enum ProcessType : long
    {
        None = 0,
        // 回流焊
        MaxRisingSlope = 0x2000000000,
        MaxFallingSlope = 0x4000000000,
        PreheatTime = 0x01,
        PreheatSlope = 0x02,
        SoakTime = 0x040,
        SoakSlope = 0x080,
        ReflowTime = 0x1000,
        ReflowUpSlope = 0x2000,
        ReflowDownSlope = 0x4000,
        AboveTime = 0x200000,
        AboveUpSlope = 0x400000,
        AboveDownSlope = 0x800000,
        RangeTime = 0x40000000,
        RangeSlope = 0x80000000,

        Preheat2Time = 0x04,
        Preheat2Slope = 0x08,
        Soak2Time = 0x100,
        Soak2Slope = 0x200,
        Reflow2Time = 0x8000,
        Reflow2UpSlope = 0x10000,
        Reflow2DownSlope = 0x20000,
        Above2Time = 0x1000000,
        Above2UpSlope = 0x2000000,
        Above2DownSlope = 0x4000000,
        Range2Time = 0x100000000,
        Range2Slope = 0x200000000,

        Preheat3Time = 0x010,
        Preheat3Slope = 0x020,
        Soak3Time = 0x400,
        Soak3Slope = 0x800,
        Reflow3Time = 0x40000,
        Reflow3UpSlope = 0x80000,
        Reflow3DownSlope = 0x100000,
        Above3Time = 0x8000000,
        Above3UpSlope = 0x10000000,
        Above3DownSlope = 0x20000000,
        Range3Time = 0x400000000,
        Range3Slope = 0x800000000,

        PeakTemp = 0x1000000000,

        // 波峰焊
        Wave1Time = 0x10000000000,
        Wave1MaxTemperature = 0x20000000000,
        Wave2Time = 0x40000000000,
        Wave2MaxTemperature = 0x80000000000,
        WaveTotalTime = 0x100000000000,
        WaveMaxTemperature = 0x200000000000
    }

    public enum TechType
    {
        SMT,
        Wave
    }

    public enum EventImfType
    {
        NoDefine = 0,
        /// <summary>
        /// This icon is displayed when Virtual profiling is enabled.
        /// </summary>
        APStart = 1,
        /// <summary>
        /// This icon is displayed when Virtual Profiliing is disabled.
        /// </summary>
        APStop = 2,

        PISIndex = 3,

        PISIndexCPK = 4,

        ReflowOvenTemp = 5,

        ReflowOvenTempCPK = 6,

        ConverySpeed = 7,

        ConverySpeedCPK = 8,

        LostCode = 9,

        ErrorCode = 10,

        OffPCB = 11,

        RTReflowOvenTemp = 12,

        RTReflowOvenTempCPK = 13,

        RTConverySpeed = 14,

        RTConverySpeedCPK = 15,

        PolarizeL = 16,

        PolarizeLCPK = 17,

        PolarizeR = 18,

        PolarizeRCPK = 19,

        PISHardNetLink = 20,

        PISExtendLink = 21,

        PISTCSLink = 22,

        EnvTemperature = 23,

        EnvHumidity = 24
    }

    public enum EventImfLevel
    {
        NoDefine,
        Warning,
        Alarm,
        ControlSignal
    }
}
