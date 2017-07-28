using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;
using PS;

namespace PS.Reflow
{
    public class Reflow : EquipmentBase
    {       
        EquipmentStatus _Status= EquipmentStatus.Idle;
        public override EquipmentStatus Status { get { return _Status; } }

        Int32 _EquipmentID = 0;
        /// <summary>
        /// 同一类中的当前设备的唯一标识ID
        /// </summary>
        public override Int32 EquipmentID { get { return _EquipmentID; } }
        
        string _Name = "";
        /// <summary>
        /// 设备的名称
        /// </summary>
        public override string Name { get{return _Name;} }

        string _Description = "";
        /// <summary>
        /// 设备描述
        /// </summary> 
        public override string Description { get{return _Description;} }

        string _IconPic = "";
        /// <summary>
        /// 设备图标文件
        /// </summary>        
        public override string IconPic { get{return _IconPic;} }

        Dictionary<string, string> _Settings = new Dictionary<string, string>();
        /// <summary>
        /// 设备参数设置
        /// </summary>        
        public override Dictionary<string, string> Settings
        {
            get { return _Settings; }
            set
            {
                //保存设置到数据库
                _Settings = value;                
            }
        }
        
        System.Web.UI.Control _WebStatusIcon = null;
        /// <summary>
        /// 当前设备显示在页面上表示状态的图块内容
        /// </summary>       
        public override System.Web.UI.Control WebStatusIcon
        {
            get
            {
                //创建最新的状态图标
                return _WebStatusIcon;
            }
        }
        /// <summary>
        /// 当前设备显示在页面上表示状态的图表内容
        /// </summary>
        public override System.Web.UI.Control WebStatusChart
        {
            get
            {
                return null;
            }
        }
        
        Dictionary<Int32, Reflow> _AllReflow;
        /// <summary>
        /// 所有当前类型的设备清单,Key为同一类中的当前设备的唯一标识ID
        /// </summary>
        public override EquipmentBase[] AllEquipments
        {
            get
            {
                if (_AllReflow == null)
                    _AllReflow = new Dictionary<Int32, Reflow>();
                return _AllReflow.Values.ToArray();
            }
        }
        /// <summary>
        /// 获得设备的历史数据表
        /// </summary>
        /// <param name="StartTime">需要查询的开始时间</param>
        /// <param name="EndTime">需要查询的结束时间</param>
        /// <param name="HistoryChart">如果有必要，可以通过这个引用返回一个历史数据的统计图表</param>
        /// <returns>历史数据的DataTable</returns>
        public override System.Data.DataTable GetHistoryData(DateTime StartTime, DateTime EndTime, ref System.Web.UI.Control HistoryChart)
        {
            return null;
        }
        /// <summary>
        /// 获得指定历史数据的明细
        /// </summary>
        /// <param name="HistoryDataID">历史数据的主键ID</param>
        /// <param name="ChartData">如有必须，可以通过这个引用返回图表形式的数据</param>
        /// <returns>历史明细数据的DataTable</returns>
        public override System.Data.DataTable GetHistoryDetailData(Int64 HistoryDataID, ref System.Web.UI.Control ChartData)
        {
            return null;
        }
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
        public override System.Data.DataTable GetStatisticsReport(StatisticsType statisticsType, GroupField groupFields, DatePart datePart, DateTime StartTime, DateTime EndTime, ref System.Web.UI.Control StatisticsChart)
        {
            return null;
        }
        /// <summary>
        /// 返回当前设备支持的统计方式
        /// </summary>
        /// <param name="statisticsType">支持的统计类型的一个或多个组合</param>
        /// <param name="groupFields">支持的统计分组字段的一个或多个组合</param>
        /// <param name="datePart">支持的统计分组周期一个或多个组合</param>
        public override void GetSupportedStatistics(ref StatisticsType statisticsType, ref GroupField groupFields, ref DatePart datePart)
        {
            return;
        }
    }
}
