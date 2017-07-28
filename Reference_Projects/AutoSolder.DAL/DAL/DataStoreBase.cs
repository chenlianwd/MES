using AutoSolder.Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;


namespace AutoSolder.DAL
{
    public class DataStoreBase : IOperationBase
    {
       
        /// <summary>
        /// 建表以及新增数据
        /// </summary>
        /// <param 数据对象="baseProfile"></param>
        /// <returns></returns>
        public result AddBaseProfile(BaseProfile baseProfile, string tableName)
        {
            if (baseProfile == null)
            {
                return result.fail;
            }
            //在这之前先判断是否安装了mysql数据库，并作出相应提示
            if (!AccessDBBase.ExistMysqlDB())
            {
                return result.notFoundMySql;
            }
            if (AccessDBApply.CreateTable(tableName))
            {
                if (AccessDBApply.InsertBaseProfile(tableName, baseProfile.Temperature, baseProfile.Humidity, baseProfile.ProductLine, baseProfile.TimePoint))
                {
                    return result.success;
                }
                else
                {
                    return result.fail;
                }
            }
            else
            {
                return result.fail;
            }
           
        }
        

        /// <summary>
        /// 查询历史记录（单条）
        /// </summary>
        /// <param 查询时间点="timePoint"></param>
        /// <param 返回数据对象="baseprofile"></param>
        /// <returns></returns>
        public bool ReadBaseProfile(string timePoint,string tableName, out BaseProfile baseprofile)
        {
            baseprofile = AccessDBApply.select_baseprofile(timePoint, tableName);
            if (baseprofile == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询历史记录（可选范围）返回对象list
        /// </summary>
        /// <param 起始时间点="startTimePoint"></param>
        /// <param 结束时间点="endTimePoint"></param>
        /// <param 返回数据对象数组="baseProfileGroup"></param>
        /// <returns></returns>
        public bool ReadBaseProfile_list(string tableName, string startTimePoint, string endTimePoint, out List<BaseProfile> baseProfileGroup)
        {
            baseProfileGroup = AccessDBApply.selectList_baseprofile(startTimePoint, endTimePoint, tableName);
            if (baseProfileGroup == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询历史记录（可选范围）返回DataTable
        /// </summary>
        /// <param 起始时间点="startTimePoint"></param>
        /// <param 结束时间点="endTimePoint"></param>
        /// <param 返回数据="Dt"></param>
        /// <returns></returns>
        public bool ReadBaseProfile_dataTable(string tableName, string startTimePoint, string endTimePoint, out DataTable Dt)
        {
            Dt = AccessDBApply.selectDataTable_baseprofile(startTimePoint, endTimePoint, tableName);
            if (Dt == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询历史记录成图标数据格式(x,y1,y2)
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startTimePoint"></param>
        /// <param name="endTimePoint"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        public bool ReadBaseProfile_dataTableWithChart(string tableName, string startTimePoint, string endTimePoint ,out DataTable Dt)
        {
            Dt = AccessDBApply.selectDataTable_baseprofileWithChart(startTimePoint, endTimePoint, tableName);
            if (Dt == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询某一条线下的最新一条数据
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="lineName"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        public bool ReadCurrentBaseprofileToDataTableWithLine(string tableName, string lineName, out DataTable Dt)
        {
            Dt = AccessDBApply.selectCurrentBaseprofileWithLineName(tableName, lineName);
            if (Dt == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询最新一条数据
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        public bool ReadCurrentBaseprofileToDataTable(string tableName, out DataTable Dt)
        {
            Dt = AccessDBApply.selectCurrentBaseprofile(tableName);
            if (Dt == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 分页查询数据
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startTimePoint"></param>
        /// <param name="endTimePoint"></param>
        /// <param name="Dt"></param>
        /// <param name="beginIndex"></param>
        /// <param name="num"></param>
        /// <returns></returns>
        public bool ReadBaseProfile_dataTableUsePage(string tableName, string startTimePoint, string endTimePoint, out DataTable Dt, string beginIndex, string num)
        {
            Dt = AccessDBApply.selectDataTable_baseprofileUsePage(startTimePoint, endTimePoint, tableName, beginIndex, num);
            if (Dt == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询表内总数
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="num"></param>
        /// <returns></returns>
        public bool ReadBaseProfile_totalNum(string tableName, out long num)
        {
            try
            {
                num = AccessDBApply.selectTotalNum_baseprofile(tableName);
            }
            catch (Exception e)
            {
                PISLog.PISTrace.WriteStrLine(e.Message);
                num = 0;
                return false;
            }

            return true;

        }
        public bool ReadBaseProfile_TimeToTimeNum(string tableName, string startTime, string endTime, out long num)
        {
            try
            {
                num = AccessDBApply.selectTimeToTimeNum_baseprofile(tableName, startTime, endTime);
            }
            catch (Exception e)
            {
                num = 0;
                return false;
            }
            return true;
        }
        /// <summary>
        /// 清除某个时间点的数据
        /// </summary>
        /// <param 时间点="timePoint"></param>
        /// <returns></returns>
        public bool RemoveBaseProfile(string starttime, string endtime, string tableName)
        {
            if (AccessDBApply.deleteData_TimeToTime(starttime, endtime, tableName))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        /// <summary>
        /// 清空所有历史数据
        /// </summary>
        /// <returns></returns>
        //public bool RemoveAllData()
        //{
        //    if (AccessDBApply.DropTable())
        //    {
        //        return true;
        //    }
        //    else
        //    {
        //        return false;
        //    }
        //}
        /// <summary>
        /// 开启事件调度器,在调用时务必设置全局bool值让他只执行一次，另可在设置中重置bool值
        /// </summary>
        /// <param 时间范围="timerange"></param>
        /// <returns></returns>
        public bool SettingEventScheduler(string timerange, string tableName)
        {
            if (AccessDBApply.AutoCleanData(timerange, tableName))
            {
                return true;
            }
            else
            {
                return false;
            }
            

        }

       
    }
}
