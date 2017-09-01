using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS
{
    public class EventInfoDS
    {
        public EventInfoDS()
        {
            this.EventIndex = 0;
            this.EventImftype = EventImfType.NoDefine;
            this.StartTime = new DateTime();
            this.EndTime = null;
            this.InvolvedArea = 0;
            this.MaxDeltaValue = 0;
            this.StartBoardIndex = null;
            this.EndBoardIndex = null;
            this.LastBoardCode = "";
            this.LastBoardIndex = null;
            this.CurrentBoardCode = "";
            this.IsHandHandle = false;
            this.HandHandleTime = new DateTime();
            EventHandleStat = false;
            this.EventLevel = EventImfLevel.NoDefine;
        }

        public EventInfoDS(EventInfoDS eventinfo)
        {
            this.EventIndex = eventinfo.EventIndex;
            this.EventImftype = eventinfo.EventImftype;
            this.StartTime = eventinfo.StartTime;
            this.EndTime = eventinfo.EndTime;
            this.InvolvedArea = eventinfo.InvolvedArea;
            this.MaxDeltaValue = eventinfo.MaxDeltaValue;
            this.StartBoardIndex = eventinfo.StartBoardIndex;
            this.EndBoardIndex = eventinfo.EndBoardIndex;
            this.LastBoardCode = eventinfo.LastBoardCode;
            this.LastBoardIndex = eventinfo.LastBoardIndex;
            this.CurrentBoardCode = eventinfo.CurrentBoardCode;
            this.EventHandleStat = eventinfo.EventHandleStat;
            this.IsHandHandle = eventinfo.IsHandHandle;
            this.HandHandleTime = eventinfo.HandHandleTime;
            this.EventLevel = eventinfo.EventLevel;
        }
        /// <summary>
        /// Event Index
        /// </summary>
        public int EventIndex { get; set; }

        /// <summary>
        /// Event imformation type
        /// </summary>
        public EventImfType EventImftype { get; set; }
        /// <summary>
        /// The Simpling Start Time and Last modified Time)
        /// </summary>
        public DateTime StartTime { get; set; }
        /// <summary>
        /// The Simpling End Time
        /// </summary>
        public DateTime? EndTime { get; set; }
        /// <summary>
        /// Involved area
        /// </summary>
        public Int64 InvolvedArea { get; set; }
        /// <summary>
        /// Max Dleta Value
        /// </summary>
        public double MaxDeltaValue { get; set; }
        /// <summary>
        /// 开始的板子索引
        /// </summary>
        public int? StartBoardIndex { get; set; }
        /// <summary>
        /// 结束的板子索引
        /// </summary>
        public int? EndBoardIndex { get; set; }
        /// <summary>
        /// 上一片板子索引
        /// </summary>
        public int? LastBoardIndex { get; set; }
        /// <summary>
        /// 上一片板子条码
        /// </summary>
        public string LastBoardCode { get; set; }
        /// <summary>
        /// 当前板子条码
        /// </summary>
        public string CurrentBoardCode { get; set; }
        /// <summary>
        /// Event Handle Station
        /// true:处理、false:未处理
        /// </summary>
        public bool EventHandleStat { get; set; }
        /// <summary>
        /// 是否手动处理
        /// true:手动消除、false:未手动消除
        /// </summary>
        public bool IsHandHandle { get; set; }

        public DateTime HandHandleTime { get; set; }
        /// <summary>
        /// 警告级别
        /// </summary>
        public EventImfLevel EventLevel { get; set; }
    }
}
