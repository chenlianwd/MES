using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoSolder.DAL;
using MySql.Data.MySqlClient;
using System.IO;
using ReflowerTestr.DAL;
using System.Data;

namespace ReflowerTester.DAL
{
    public class RTDBApply
    {
        //建表
        /// <summary>
        /// Create Table
        /// </summary>
        /// <returns></returns>
        public static bool CreateTable(string tableName)
        {
            bool issuc = true;
            try
            {
                //**判断数据库是否存在，以及数据库是否创建成功*/
                
                if (!AccessDBBase.ExistDB("reflowertester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    if (!AccessDBBase.CreateDB("reflowertester", "root", "pempenn"))
                        LogClass.WriteLogFile("创建数据库失败->");
                    return false;
                }
                
                //**建表*/
                if (!AccessDBBase.ExecuteCommand("reflowertester", "root", "pempenn", GlobalData.MySqlPort, SqlCmd_baseProfile_m(tableName)))//sqlCmd_baseProfile
                {
                    // LogClass.WriteLogFile("创建表baseprofile失败");
                    LogClass.WriteLogFile("创建表RTfile失败->" + tableName);
                    return false;
                }

            }
            catch (MySqlException ex)
            {
                // LogClass.WriteLogFile(ex.Message);
                LogClass.WriteLogFile(ex.Message);
                return false;
            }
            return issuc;
        }
        /// <summary>
        /// 插入数据
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 生产线="Line"></param>
        /// <param 回流炉名称="ReflowerName"></param>
        /// <param 产品名="ProductName"></param>
        /// <param 开始时间="StartTime"></param>
        /// <param 结束时间="EndTime"></param>
        /// <param 工艺类型="TechnologyType"></param>
        /// <param 工艺名称="TechnologyName"></param>
        /// <param 制程工艺名称="ProcessName"></param>
        /// <param 炉子工艺名称="ReflowerTechName"></param>
        /// <param 锡膏名称="SolderName"></param>
        /// <param 测试仪数据名称="PtsFileName"></param>
        /// <param 报表图片路径="ImgPath"></param>
        /// <returns></returns>
        public static bool InsertBaseProfile(string tableName, string Line, string ReflowerName, string ProductName, DateTime StartTime, DateTime EndTime, string TechnologyType, string TechnologyName, string ProcessName, string ReflowerTechName, string SolderName, string PtsFileName, string PtsFilePath, string ImgPath)
        {
            string startTime = string.Format("{0:yyyy-MM-dd HH:mm:ss}", StartTime);
            string endTime = string.Format("{0:yyyy-MM-dd HH:mm:ss}", EndTime);
            string getCommandInsert = string.Format(BaseProfil_insertFormat(tableName), "'" + Line + "'", "'" + ReflowerName + "'", "'" + ProductName + "'", "'" + startTime + "'", "'" + endTime + "'", "'" + TechnologyType + "'", "'" + TechnologyName + "'", "'" + ProcessName + "'", "'" + ReflowerTechName + "'", "'" + SolderName + "'", "'" + PtsFileName + "'", "'" + PtsFilePath + "'", "'" + ImgPath + "'");
            try
            {
                if (AccessDBBase.ExecuteCommand("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort, getCommandInsert))
                {
                    return true;
                }
                else
                {
                    LogClass.WriteLogFile("Reflower Tester:baseProfile插入数据失败");
                    return false;
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:baseProfile插入数据失败" + ex.Message);
                return false;
            }


        }
        /// <summary>
        /// 去重查询字段下数据（只限字符字段）
        /// </summary>
        /// <param name="field"></param>
        /// <returns></returns>
        public static List<string> SelectAllLineData(string tableName, string field)
        {
            List<string> listStr = new List<string>();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    MySqlCommand cmd = new MySqlCommand(SqlCmd_selectAllLine(tableName, field), connection);
                    MySqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        listStr.Add(reader[0].ToString());
                    }
                    reader.Close();
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:去重查询Line或者ProductName数据失败" + ex.Message);
                listStr = null;
            }

            return listStr;
        }
        #region 查询所有数据

        public static DataTable SelectDataTable_baseProfile_t(string tableName, string beginTime, string overTime)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable_time(tableName), new MySqlParameter(@"beginTime", beginTime), new MySqlParameter(@"overTime", overTime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:按时间查询DataTable数据失败" + ex.Message);
                Dt = null;
            }

            return Dt;
        }

       

        /// <summary>
        /// 按条件查询数据（条件：产线/产品）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线名或产品名="lineOrProductName"></param>
        /// <param 是产线还是产品的布尔值="isLine"></param>
        /// <returns></returns>
        public static DataTable SelectDataTable_baseProfile(string tableName, string lineOrProductName, bool isLine)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable1(tableName, lineOrProductName, isLine));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据1失败" + ex.Message);
                Dt = null;
            }

            return Dt;
        }
      
        /// <summary>
        /// 按条件查询数据（条件：产线、产品）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线名="line"></param>
        /// <param 产品名="productName"></param>
        /// <returns></returns>
        public static DataTable SelectDataTable_baseProfile(string tableName, string line, string productName)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable2(tableName, line, productName));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据2失败" + ex.Message);
                Dt = null;
            }

            return Dt;
        }

        /// <summary>
        /// 按条件查询数据（条件：产线/产品、查询起始时间、结束时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线或产品="lineOrProductName"></param>
        /// <param 产线还是产品的布尔值="isLine"></param>
        /// <param 查询开始时间="beginTime"></param>
        /// <param 查询结束时间="overTime"></param>
        /// <returns></returns>
        public static DataTable SelectDataTable_baseProfile(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable3(tableName, lineOrProductName, isLine), new MySqlParameter(@"beginTime", beginTime), new MySqlParameter(@"overTime", overTime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据3失败" + ex.Message);
                Dt = null;
            }

            return Dt;
        }


        /// <summary>
        /// 按条件查询数据（条件：产线、产品、查询起始时间、结束时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线="line"></param>
        /// <param 产品="productName"></param>
        /// <param 查询起始时间="beginTime"></param>
        /// <param 查询结束时间="overTime"></param>
        /// <returns></returns>
        public static DataTable SelectDataTable_baseProfile(string tableName, string line, string productName, string beginTime, string overTime)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable4(tableName, line, productName), new MySqlParameter(@"beginTime", beginTime), new MySqlParameter(@"overTime", overTime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据4失败" + ex.Message);
                Dt = null;
            }

            return Dt;
        }
        #endregion

        #region 分页查询(预留)

        public static DataTable SelectDataTable_baseProfileUsePage(string tableName, string lineOrProductName, bool isLine, string beginIndex, string num)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable1UsePage(tableName, lineOrProductName, isLine, beginIndex, num));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据1失败(分页)" + ex.Message);
                Dt = null;
            }

            return Dt;
        }
        public static DataTable SelectDataTable_baseProfileUsePage(string tableName, string line, string productName, string beginIndex, string num)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable2UsePage(tableName, line, productName, beginIndex, num));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据2失败（分页）" + ex.Message);
                Dt = null;
            }

            return Dt;
        }
        public static DataTable SelectDataTable_baseProfileUsePage(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime, string beginIndex, string num)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable3UsePage(tableName, lineOrProductName, isLine, beginIndex, num), new MySqlParameter(@"beginTime", beginTime), new MySqlParameter(@"overTime", overTime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据3失败(分页)" + ex.Message);
                Dt = null;
            }

            return Dt;
        }

        public static DataTable SelectDataTable_baseProfileUsePage(string tableName, string line, string productName, string beginTime, string overTime, string beginIndex, string num)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    Dt = AccessDBBase.GetDataTable(connection, SqlCmd_selectDataTable4UsePage(tableName, line, productName, beginIndex, num), new MySqlParameter(@"beginTime", beginTime), new MySqlParameter(@"overTime", overTime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:查询成DataTable数据4失败（分页）" + ex.Message);
                Dt = null;
            }

            return Dt;
        }

        #endregion
        #region 删除
        /// <summary>
        /// 按条件删除（条件：产线/产名）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线/产名="lineOrProductName"></param>
        /// <param 是产线还是产名="isLine"></param>
        /// <returns></returns>
        public static bool DeleteData_baseProfile(string tableName, string lineOrProductName, bool isLine)
        {
            try
            {
                if (!AccessDBBase.ExecuteCommand("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort, SqlCmd_deleteData_baseprofile1(tableName, lineOrProductName, isLine)))
                {
                    LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败1");
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_1" + ex.Message);
                return false;
            }
            return true;
        }
        /// <summary>
        /// 按条件删除（条件：产线、产名）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线="line"></param>
        /// <param 产名="productName"></param>
        /// <returns></returns>
        public static bool DeleteData_baseProfile(string tableName, string line, string productName)
        {
            try
            {
                if (!AccessDBBase.ExecuteCommand("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort, SqlCmd_deleteData_baseprofile2(tableName, line, productName)))
                {
                    LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败2");
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_2" + ex.Message);
                return false;
            }
            return true;
        }
        /// <summary>
        /// 按条件删除（条件：产线/产名、起始时间、终止时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线/产名="lineOrProductName"></param>
        /// <param 产线还是产名的布尔值="isLine"></param>
        /// <param 起始时间="beginTime"></param>
        /// <param 终止时间="overTime"></param>
        /// <returns></returns>
        public static bool DeleteData_baseProfile(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime)
        {
            try
            {
                if (!AccessDBBase.ExecuteCommand("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort, SqlCmd_deleteData_baseprofile3(tableName, lineOrProductName, isLine, beginTime, overTime)))
                {
                    LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_3");
                    return false;
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_3" + ex.Message);
                return false;
            }
            return true;
        }
        /// <summary>
        /// 按条件删除（条件：产线、产名、起始时间、结束时间）
        /// </summary>
        /// <param 表名="tableName"></param>
        /// <param 产线="line"></param>
        /// <param 产名="productName"></param>
        /// <param 起始时间="beginTime"></param>
        /// <param 结束时间="overTime"></param>
        /// <returns></returns>
        public static bool DeleteData_baseProfile(string tableName, string line, string productName, string beginTime, string overTime)
        {
            try
            {
                if (!AccessDBBase.ExecuteCommand("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort, SqlCmd_deleteData_baseprofile4(tableName, line, productName, beginTime, overTime)))
                {
                    LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_4");
                    return false;
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Reflower Tester:清除时间段内数据失败_4" + ex.Message);
                return false;
            }
            return true;
        }

        #endregion


        /**```````````````````````````````````分隔线```````````````````````````````````*/
        /**********************************   sql语句   ******************************/
        private static string SqlCmd_selectDataTable_time(string tableName)
        {
            return "select * from `" + tableName + "` where StartTime >= @beginTime and StartTime <= @overTime";
        }

        private static string SqlCmd_deleteData_baseprofile4(string tableName, string line, string productName, string beginTime, string overTime)
        {
            return "delete from `" + tableName + "` where Line = '" + line + "' and ProductName ='" + productName + "' and StartTime >= '" + beginTime + "' and StartTime <= '" + overTime + "'";
        }

        private static string SqlCmd_deleteData_baseprofile3(string tableName, string lineOrProductName, bool isLine, string beginTime, string overTime)
        {
            return "delete from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " ='" + lineOrProductName + "' and StartTime >= '" + beginTime + "' and StartTime <= '" + overTime + "'";
        }
        private static string SqlCmd_deleteData_baseprofile2(string tableName, string line, string productName)
        {
            return "delete from `" + tableName + "` where Line = '" + line + "' and ProductName = '" + productName + "'";
        }
        private static string SqlCmd_deleteData_baseprofile1(string tableName, string lineOrProductName, bool isLine)
        {
            return "delete from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " = '" + lineOrProductName + "'";
        }
        private static string SqlCmd_selectDataTable4UsePage(string tableName, string line, string productName, string beginindex, string num)
        {
            return "select * from `" + tableName + "` where Line = '" + line + "' and ProductName = '" + productName + "' and StartTime >= @beginTime and StartTime <= @overTime limit " + beginindex + "," + num;
        }
        private static string SqlCmd_selectDataTable3UsePage(string tableName, string lineOrProductName, bool isLine, string beginindex, string num)
        {
            return "select * from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " = '" + lineOrProductName + "' and StartTime >= @beginTime and StartTime <= @overTime limit " + beginindex + "," + num;
        }
        private static string SqlCmd_selectDataTable2UsePage(string tableName, string line, string productName, string beginIndex, string num)
        {
            return "select * from `" + tableName + "` where Line = '" + line + "' and ProductName = '" + productName + "' limit " + beginIndex + "," + num;
        }
        private static string SqlCmd_selectDataTable1UsePage(string tableName, string lineOrProductName, bool isLine, string beginIndex, string num)
        {
            return "select * from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " = '" + lineOrProductName + "' " + "limit " + beginIndex + "," + num;
        }

        private static string SqlCmd_selectDataTable4(string tableName, string line, string productName)
        {
            return "select * from `" + tableName + "` where Line = '" + line + "' and ProductName = '" + productName + "' and StartTime >= @beginTime and StartTime <= @overTime";
        }

        private static string SqlCmd_selectDataTable3(string tableName, string lineOrProductName, bool isLine)
        {
            return "select * from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " = '" + lineOrProductName + "' and StartTime >= @beginTime and StartTime <= @overTime";
        }
        private static string SqlCmd_selectDataTable2(string tableName, string line, string productName)
        {
            return "select * from `" + tableName + "` where Line = '" + line + "' and ProductName = '" + productName + "'";
        }

        private static string SqlCmd_selectDataTable1(string tableName, string lineOrProductName, bool isLine)
        {
            return "select * from `" + tableName + "` where " + (isLine ? "Line" : "ProductName") + " = '" + lineOrProductName + "'";
        }

        private static string SqlCmd_selectAllLine(string tableName, string field)
        {
            return "select distinct " + field + " from `" + tableName + "`";
        }
        private static string BaseProfil_insertFormat(string tableName)
        {
            return "insert into `" + tableName + "` (" +
              "Line, ReflowerName, ProductName, StartTime, EndTime, TechnologyType, TechnologyName, ProcessName, ReflowerTechName, SolderName, PtsFileName, PtsFilePath, ImgPath)values({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        }

        private static string SqlCmd_baseProfile_m(string tableName)
        {
            return "CREATE TABLE if not exists `" + tableName + "`"+
           "(id int not null primary key auto_increment," +
           "Line varchar(50) not null," +
           "ReflowerName varchar(50) not null," +
           "ProductName varchar(50) not null," +
           "StartTime datetime not null," +
           "EndTime datetime not null," +
           "TechnologyType varchar(50) not null," +
           "TechnologyName varchar(50) not null," +
           "ProcessName varchar(50) not null," +
           "ReflowerTechName varchar(50) not null," +
           "SolderName varchar(50) not null," +
           "PtsFileName varchar(50) not null," +
           "PtsFilePath varchar(200) not null," +
           "ImgPath varchar(200) not null," +
           "INDEX select_Index (StartTime,ProductName,Line)" +
           ")";
        }
    }
}
