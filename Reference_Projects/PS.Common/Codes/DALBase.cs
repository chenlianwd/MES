using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Security.Cryptography;
using System.Configuration;
using System.Data.Common;
using System.Web;

using PS;

namespace PS
{
    /// <summary>
    /// 查询的排序方式，如升序或者降序
    /// </summary>
    public enum OrderBy
    {
        None = 0,
        /// <summary>
        /// 按照升序排列
        /// </summary>
        ASC = 1,
        /// <summary>
        /// 按照降序排列
        /// </summary>
        DESC = 2
    }

    

    public abstract partial class DALBase
    {
        private static readonly byte[] rgbIV = { 182, 186, 218, 219, 190, 182, 186, 188 };
        private static readonly byte[] rgbKey = { 223, 226, 225, 132, 146, 147, 206, 213 };
        /// <summary>
        /// 返回继承组件的名称
        /// </summary>
        public abstract string DALName{get;}
        //public virtual TimeSpan TimeZone { get; set; }
        public DALBase()
        {
            //TimeZone = TimeSpan.MinValue;
            //TimeSpan timeZone = TimeZone.CurrentTimeZone.GetUtcOffset(DateTime.Now);
            //this.nTimeZone = timeZone.Hours * 100 + timeZone.Minutes;
            RebuidConnectionString();
        }

        /// <summary>
        /// 数据库服务器的DNS名称或IP
        /// </summary>
        public virtual string Source
        {
            get { return Common.readConfig("DBServer",""); }
            set { Common.writeConfig("DBServer", value); }
        }
        /// <summary>
        /// 默认的数据连接端口
        /// </summary>
        public virtual string Port
        {
            get { return Common.readConfig("DBPort",""); }
            set { Common.writeConfig("DBPort", value); }
        }
        /// <summary>
        /// 默认的数据库
        /// </summary>
        public virtual string Catalog
        {
            get { return Common.readConfig("DBCatalog",""); }
            set { Common.writeConfig("DBCatalog", value); }
        }
        /// <summary>
        /// 连接数据库的用户名
        /// </summary>
        public virtual string User
        {
            get { return Common.readConfig("DBUser", ""); }
            set { Common.writeConfig("DBUser", value); }
        }
        /// <summary>
        /// 用于更改数据库连接的密码
        /// </summary>
        public virtual string Password { set { Common.writeConfig("DBPwd", Common.EncryptDES(value, rgbIV, rgbKey)); } }
        /// <summary>
        /// 连接数据库密码的原文，只能从子类访问
        /// </summary>
        protected virtual string DbPassword { get { return Common.DecryptDES(Common.readConfig("DBPwd",""), rgbIV, rgbKey); } }

        /// <summary>
        /// 让DAL实现类重建连接串
        /// </summary>
        public abstract void RebuidConnectionString();

        /// <summary>
        /// 数据库服务器的当前时间
        /// </summary>
        public abstract DateTime TimeOfDBServer { get; }

        /// <summary>
        /// 构造一个数据库的数值引用
        /// </summary>
        /// <param name="sValue">字符型的数值</param>
        /// <returns>带引用前后符号的数值</returns>
        public abstract string QuoteValue(string sValue);

        /// <summary>
        /// 构造一个数据库的字段引用
        /// </summary>
        /// <param name="sValue">字符型的字段</param>
        /// <returns>带引用前后符号的字段</returns>
        public abstract string QuoteField(string sField);

        /// <summary>
        /// 数据库中的NULL引用
        /// </summary>
        public abstract string QuoteNull { get; }        
        

        /// <summary>
        /// 数据库中当前时间的获取函数
        /// </summary>
        public abstract string FuncCurrentTimestamp { get; }

        /// <summary>
        /// 数据库中最新自动增长值的获取函数
        /// </summary>
        public abstract string FuncLastInsertId { get; }
        

        /// <summary>
        /// 载入保存在数据库中的全局配置
        /// </summary>   
        public abstract DataTable GetPreferencesSetttings();

        public abstract DataTable GetUseInfo(string sUserName);
        public abstract DataTable GetUseInGroup(long _Employee);
        public abstract void ChangeUserPassword(LanguageHelper langHelper, long _Employee, string sHashPassword, EmployeeInfo emp);
        public abstract void UpdateUserInfo(LanguageHelper langHelper, long _Employee, string sHashPwd, long _Employee_Update, string FullName, string MailAddress);
        public abstract void AddLoginHistory(EmployeeInfo emp, LoginResult LoginResult);

        public abstract DataTable GetPageList(long _Employee);
        public abstract DataTable GetStationGroupList(long _Employee);

        public abstract DataTable GetPISData(long nStationID,DateTime dtStart,DateTime dtEnd);

        public abstract DataTable GetPISProductlLine();
        /// <summary>
        /// 查询当前产线所有设备首页数据
        /// </summary>
        /// <param name="line"></param>
        /// <returns></returns>
        public abstract DataSet GetAllDeviceData(string line);
        /// <summary>
        /// 查询当前产线所有设备时间段内数据（即绘制chart图表用）
        /// </summary>
        /// <param name="line"></param>
        /// <param name="dtStart"></param>
        /// <param name="dtEnd"></param>
        /// <returns></returns>
        public abstract DataSet GetAllDeviceDataChart(string line);

        /// <summary>
        /// 查询相应Line数据
        /// </summary>
        /// <param 产线名="line"></param>
        /// <param 起始时间="dtStart"></param>
        /// <param 结束时间="dtEnd"></param>
        /// <returns></returns>
        public abstract DataTable GetAutoSolderData(string line, DateTime dtStart, DateTime dtEnd);

        /// <summary>
        /// 查询当前用户下所有表中当前（最新）锡膏剩余量、当前温湿度、最近时间点等数据
        /// </summary>
        /// <param name="lineList"></param>
        /// <returns></returns>
        public abstract List<DataTable> GetAutoSolderCurrentData(List<string>lineList);

        /// <summary>
        /// 分页查询数据
        /// </summary>
        /// <param name="line"></param>
        /// <param name="dtStart"></param>
        /// <param name="dtEnd"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        public abstract DataTable GetAutoSolderDataUsePage(string line, DateTime dtStart, DateTime dtEnd, string beginindex, string num);
        /// <summary>
        /// 查询每张表的coun数
        /// </summary>
        /// <param name="num"></param>
        /// <returns></returns>
        public abstract long GetAutoSolderDataTotalNum(string line);
        /// <summary>
        /// 查询每张表范围时间内总数
        /// </summary>
        /// <param name="line"></param>
        /// <param name="dtStart"></param>
        /// <param name="dtEnd"></param>
        /// <returns></returns>
        public abstract long GetAutoSolderDataTimeToTimeNum(string line, DateTime dtStart, DateTime dtEnd);
    }
}
