using AutoSolder.DAL;
using ReflowerTester.DAL;
using ReflowerTester.Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace ReflowerTester
{
    public enum result { fail, success, notFoundMySql };
    public class RTDBOperation
    {
        #region 新增

       
        /// <summary>
        /// 新增数据 ，若不存在直接建表建库
        /// </summary>
        /// <param 数据对象="baseProfile"></param>
        /// <param 表名="tableName"></param>
        /// <returns></returns>
        public result AddReflowerTesterProfile(ReflowerTesterProfile baseProfile, string tableName)
        {
            if (baseProfile == null)
            {
                return result.fail;
            }
            if (!AccessDBBase.ExistMysqlDB())
            {
                return result.notFoundMySql;
            }
            if (RTDBApply.CreateTable(tableName))
            {
                if (RTDBApply.InsertBaseProfile(tableName, baseProfile.Line, baseProfile.ReflowerName, baseProfile.ProductName, baseProfile.StartTime, baseProfile.EndTime, baseProfile.TechnologyType, baseProfile.TechnologyName, baseProfile.ProcessName, baseProfile.ReflowerTechName, baseProfile.SolderName, baseProfile.PtsFileName, baseProfile.PtsFilePath, baseProfile.ImgPath))
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
        #endregion

        #region 查询


        /// <summary>
        /// 查询所有的产线（去重）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 结果集="listStr"></param>
        /// <returns></returns>
        public bool ReadAllLineData(string tableName, out List<string> listStr)
        {
            listStr = RTDBApply.SelectAllLineData(tableName, "Line");
            if (listStr == null || listStr.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 查询所有的产名（去重）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 结果集="listStr"></param>
        /// <returns></returns>
        public bool ReadAllProductName(string tableName, out List<string> listStr)
        {
            listStr = RTDBApply.SelectAllLineData(tableName, "ProductName");
            if (listStr == null || listStr.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        public bool ReadDataTable_baseProfile_t(string tableName, string beginTime, string overTime, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfile_t(tableName, beginTime, overTime);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 按条件查询数据（条件：产线/产品）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线名或产品名="lineOrProductName"></param>
        /// <param 是产线还是产品的布尔值="isLine"></param>
        /// <param 结果集="dt"></param>
        /// <returns></returns>
        public bool ReadDataTable_baseProfile(string tableName, string lineOrProductName, bool isLine, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfile(tableName, lineOrProductName, isLine);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 按条件查询数据（条件：产线、产品）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线名="line"></param>
        /// <param 产品名="productName"></param>
        /// <param 结果集="dt"></param>
        /// <returns></returns>
        public bool ReadDataTable_baseProfile(string tableName, string line, string productName, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfile(tableName, line, productName);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 按条件查询数据（条件：产线/产品、查询起始时间、结束时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线或产品="lineOrProductName"></param>
        /// <param 产线还是产品的布尔值="isLine"></param>
        /// <param 查询开始时间="beginTime"></param>
        /// <param 查询结束时间="overTime"></param>
        /// <param 结果集="dt"></param>
        /// <returns></returns>
        public bool ReadDataTable_baseProfile(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfile(tableName, lineOrProductName, isLine, beginTime, overTime);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        /// <summary>
        /// 按条件查询数据（条件：产线、产品、查询起始时间、结束时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线="line"></param>
        /// <param 产品="productName"></param>
        /// <param 查询起始时间="beginTime"></param>
        /// <param 查询结束时间="overTime"></param>
        /// <param 结果集="dt"></param>
        /// <returns></returns>
        public bool ReadDataTable_baseProfile(string tableName, string line, string productName, string beginTime, string overTime, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfile(tableName, line, productName, beginTime, overTime);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        #endregion

        #region 分页查询（预留）
        public bool ReadDataTable_baseProfileUsePage(string tableName, string lineOrProductName, bool isLine, string beginIndex, string num, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfileUsePage(tableName, lineOrProductName, isLine, beginIndex, num);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        public bool ReadDataTable_baseProfileUsePage(string tableName, string line, string productName, string beginIndex, string num, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfileUsePage(tableName, line, productName, beginIndex, num);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        public bool ReadDataTable_baseProfileUsePage(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime, string beginIndex, string num, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfileUsePage(tableName, lineOrProductName, isLine, beginTime, overTime, beginIndex, num);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        public bool ReadDataTable_baseProfileUsePage(string tableName, string line, string productName, string beginTime, string overTime, string beginIndex, string num, out DataTable dt)
        {
            dt = RTDBApply.SelectDataTable_baseProfileUsePage(tableName, line, productName, beginTime, overTime, beginIndex, num);
            if (dt == null || dt.Rows.Count == 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        #endregion

        #region 删除
        public bool RemoveData_baseProfile(string tableName, string lineOrProductName, bool isLine)
        {
            if (RTDBApply.DeleteData_baseProfile(tableName, lineOrProductName, isLine))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public bool RemoveData_baseProfile(string tableName, string line, string productName)
        {
            if (RTDBApply.DeleteData_baseProfile(tableName, line, productName))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public bool RemoveData_baseProfile(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime)
        {
            if (RTDBApply.DeleteData_baseProfile(tableName, lineOrProductName, isLine, beginTime, overTime))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public bool RemoveData_baseProfile(string tableName, string line, string productName, string beginTime, string overTime)
        {
            if (RTDBApply.DeleteData_baseProfile(tableName, line, productName, beginTime, overTime))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        #endregion
    }





}
