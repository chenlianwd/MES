using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReflowerTester.Model
{
    public class ReflowerTesterProfile
    {
        public ReflowerTesterProfile()
        {
            Line = "";
            ReflowerName = "";
            ProductName = "";
            StartTime = new DateTime();
            EndTime = new DateTime();
            TechnologyType = "";
            TechnologyName = "";
            ProcessName = "";
            ReflowerTechName = "";
            SolderName = "";
            PtsFileName = "";
            PtsFilePath = "";
            ImgPath = "";
        }
        /// <summary>
        /// 生产线
        /// </summary>
        public string Line { get; set; }
        /// <summary>
        /// 回流炉名称
        /// </summary>
        public string ReflowerName { get; set; }
        /// <summary>
        /// 产品名
        /// </summary>
        public string ProductName { get; set; }
        /// <summary>
        /// 开始时间
        /// </summary>
        public DateTime StartTime { get; set; }
        /// <summary>
        /// 结束时间
        /// </summary>
        public DateTime EndTime { get; set; }
        /// <summary>
        /// 工艺类型 
        /// </summary>
        public string TechnologyType { get; set; }
        /// <summary>
        /// 工艺名称 
        /// </summary>
        public string TechnologyName { get; set; }
        /// <summary>
        /// 制程工艺名称
        /// </summary>
        public string ProcessName { get; set; }
        /// <summary>
        /// 炉子工艺名称
        /// </summary>
        public string ReflowerTechName { get; set; }
        /// <summary>
        /// 锡膏名称
        /// </summary>
        public string SolderName { get; set; }
        /// <summary>
        /// 测试仪数据文件名称
        /// </summary>
        public string PtsFileName { get; set; }
        /// <summary>
        /// 保存的文件路径
        /// </summary>
        public string PtsFilePath { get; set; }
        /// <summary>
        /// 报表图片路径
        /// </summary>
        public string ImgPath { get; set; }

    }
}
