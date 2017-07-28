using AutoSolder.Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace AutoSolder.DAL
{
    public interface IOperationBaseR
    {

       

        /// <summary>
        /// 读取单个Base Profile
        /// </summary>
        /// <param 时间点="timePoint"></param>
        /// <param 数据对象="baseprofile"></param>
        /// <returns></returns>
        bool ReadBaseProfile(string timePoint, string tableName, out BaseProfile baseprofile);
        /// <summary>
        /// 范围读取Base Profile，返回对象list
        /// </summary>
        /// <param 起始时间="startTimePoint"></param>
        /// <param 结束时间="endTimePoint"></param>
        /// <param 数据集合="baseProfileGroup"></param>
        /// <returns></returns>
        bool ReadBaseProfile_list(string tableName,string startTimePoint, string endTimePoint, out List<BaseProfile> baseProfileGroup);

        /// <summary>
        /// 范围读取Base Profile，返回DataTable
        /// </summary>
        /// <param 起始时间="startTimePoint"></param>
        /// <param 结束时间="endTimePoint"></param>
        /// <param 数据集合="Dt"></param>
        /// <returns></returns>
        bool ReadBaseProfile_dataTable(string tableName, string startTimePoint, string endTimePoint, out DataTable Dt);
        /// <summary>
        /// 范围读取Base Profile，返回含（chart数据格式的）DataTable
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startTimePoint"></param>
        /// <param name="endTimePoint"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        bool ReadBaseProfile_dataTableWithChart(string tableName, string startTimePoint, string endTimePoint, out DataTable Dt);
        /// <summary>
        /// 查询某一线下最新一条数据(注意：弃用，由于表名和表下表示产线的字段是相同的)
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="lineName"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        bool ReadCurrentBaseprofileToDataTableWithLine(string tableName, string lineName, out DataTable Dt);
        /// <summary>
        /// 查询最新一条数据
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="Dt"></param>
        /// <returns></returns>
        bool ReadCurrentBaseprofileToDataTable(string tableName, out DataTable Dt);

        /// <summary>
        /// 分页查询
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startTimePoint"></param>
        /// <param name="endTimePoint"></param>
        /// <param name="Dt"></param>
        /// <param name="page"></param>
        /// <param name="pagesize"></param>
        /// <returns></returns>
        bool ReadBaseProfile_dataTableUsePage(string tableName, string startTimePoint, string endTimePoint, out DataTable Dt, string beginIndex, string num);
        /// <summary>
        /// 查询总数
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="num"></param>
        /// <returns></returns>
        bool ReadBaseProfile_totalNum(string tableName, out long num);
        /// <summary>
        /// 查询范围时间内数据总数
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startTime"></param>
        /// <param name="endTime"></param>
        /// <param name="num"></param>
        /// <returns></returns>
        bool ReadBaseProfile_TimeToTimeNum(string tableName, string startTime, string endTime, out long num);
    }
}
