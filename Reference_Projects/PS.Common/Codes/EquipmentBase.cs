using System;
using System.Collections.Generic;
using System.Text;
using System.Web;

namespace PS
{
    public enum EquipmentStatus
    {
        /// <summary>
        /// 空闲状态
        /// </summary>
        Idle = 0x0,
        /// <summary>
        /// 正常状态
        /// </summary>
        Good = 0x01,
        /// <summary>
        /// 断开无法连接状态
        /// </summary>        
        Disconnected = 0x02,
        /// <summary>
        /// 停止状态
        /// </summary>
        Stopped = 0x04,
        /// <summary>
        /// 告警状态
        /// </summary>
        Warning = 0x08,
        /// <summary>
        /// 失败状态
        /// </summary>
        Failed = 0x10,
    }
    public enum DatePart
    {
        None = 0x0,
        Hour = 0x01,
        Shift = 0x02,
        Day = 0x04,
        Week = 0x08,
        Month = 0x10,
        Year = 0x20
    }
    public enum GroupField
    {
        None = 0x0,
        DatePart = 0x01,
        PartNumber = 0x02,
        PartFaimily = 0x04,
        Fixture = 0x08,
        Station = 0x10,
        StationType = 0x20,
        Operator = 0x40,
        ProductLine = 0x80,
        BusinessUnit = 0x100,
        WorkSite = 0x200
    }
    public enum StatisticsType
    {
        None = 0,
        FirstPassYield = 0x01,
        FinalPassYield = 0x02,
        CPK = 0x04,
        TotalElapsedTime=0x08,
        TotalWastedTime=0x10,
        TotalUnits=0x20,
        TotalTestTimes=0x40,
        TotalFirtstPassedUnits=0x80,
        TotalFirtstFailedUnits = 0x100,
        TotalFinalPassedUnits = 0x200,
        TotalFinalFailedUnits = 0x400,
    }
    public abstract class EquipmentBase
    {
        public abstract EquipmentStatus Status { get; }
        /// <summary>
        /// 同一类中的当前设备的唯一标识ID
        /// </summary>
        public abstract Int32 EquipmentID { get; }
        /// <summary>
        /// 设备的名称
        /// </summary>
        public abstract string Name { get; }
        /// <summary>
        /// 设备描述
        /// </summary>
        public abstract string Description { get; }
        /// <summary>
        /// 设备图标文件
        /// </summary>
        public abstract string IconPic { get; }
        /// <summary>
        /// 设备参数设置
        /// </summary>
        public abstract Dictionary<string, string> Settings { get; set; }
        /// <summary>
        /// 当前设备显示在页面上表示状态的图块内容
        /// </summary>
        public abstract System.Web.UI.Control WebStatusIcon { get; }
        /// <summary>
        /// 当前设备显示在页面上表示状态的图表内容
        /// </summary>
        public abstract System.Web.UI.Control WebStatusChart { get; }
        /// <summary>
        /// 所有当前类型的设备清单
        /// </summary>
        public abstract EquipmentBase[] AllEquipments { get; }
        /// <summary>
        /// 获得设备的历史数据表
        /// </summary>
        /// <param name="StartTime">需要查询的开始时间</param>
        /// <param name="EndTime">需要查询的结束时间</param>
        /// <param name="HistoryChart">如果有必要，可以通过这个引用返回一个历史数据的统计图表</param>
        /// <returns>历史数据的DataTable</returns>
        public abstract System.Data.DataTable GetHistoryData(DateTime StartTime, DateTime EndTime, ref System.Web.UI.Control HistoryChart);
        /// <summary>
        /// 获得指定历史数据的明细
        /// </summary>
        /// <param name="HistoryDataID">历史数据的主键ID</param>
        /// <param name="ChartData">如有必须，可以通过这个引用返回图表形式的数据</param>
        /// <returns>历史明细数据的DataTable</returns>
        public abstract System.Data.DataTable GetHistoryDetailData(Int64 HistoryDataID, ref System.Web.UI.Control ChartData);
        /// <summary>
        /// 获得统计数据
        /// </summary>
        /// <param name="statisticsType">统计类型的一个或多个组合</param>
        /// <param name="groupFields">统计分组字段的一个或多个组合</param>
        /// <param name="datePart">统计分组周期一个或多个组合</param>
        /// <param name="StartTime">统计的开始时间</param>
        /// <param name="EndTime">统计的结束时间</param>
        /// <param name="StatisticsChart">如有必须，可以通过这个引用返回图表形式的统计数据</param>
        /// <returns>统计数据的DataTable</returns>
        public abstract System.Data.DataTable GetStatisticsReport(StatisticsType statisticsType, GroupField groupFields, DatePart datePart, DateTime StartTime, DateTime EndTime, ref System.Web.UI.Control StatisticsChart);
        /// <summary>
        /// 返回当前设备支持的统计方式
        /// </summary>
        /// <param name="statisticsType">支持的统计类型的一个或多个组合</param>
        /// <param name="groupFields">支持的统计分组字段的一个或多个组合</param>
        /// <param name="datePart">支持的统计分组周期一个或多个组合</param>
        public abstract void GetSupportedStatistics(ref StatisticsType statisticsType, ref GroupField groupFields, ref DatePart datePart);
    }
}
