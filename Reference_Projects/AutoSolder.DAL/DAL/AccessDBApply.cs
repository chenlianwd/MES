
using AutoSolder.Model;
using MySql.Data.MySqlClient;
using PISLog;
using ReflowerTestr.DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace AutoSolder.DAL
{
    //**这种数据查询编写将sql语句放在最底层，实则是不方便，在改动或者新增方法的情况，就必须增加一个方法及接口等等。*/
    //**需要改成sql语句作为参数放在最上层的逻辑层中的方式*/
    /*待改---*/
    class AccessDBApply:AccessDBBase
    {

        //建表
        /// <summary>
        /// Create Table
        /// </summary>
        /// <returns></returns>
         private static DbConfig dbConfig = new DbConfig();
        public static bool CreateTable(string tableName)
        {
            bool issuc = true;
            try
            {
                //**判断数据库是否存在，以及数据库是否创建成功*/
                if (!ExistDB(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    if (!CreateDB(dbConfig.Catalog, dbConfig.User, dbConfig.Password))
                        return false;
                }
                //**建表*/
                if (!ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), sqlCmd_baseProfile_m(tableName)))//sqlCmd_baseProfile
                {
                    LogClass.WriteLogFile("Web Solution;Class-AccessDBApply;Fun-CreatTable;创建表"+ tableName +"失败");
                    return false;
                }

            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - CreatTable;"  + ex.Message);
                return false;
            }
            return issuc;
        }
        //*******************************************************************insert
        /// <summary>
        /// insert into data
        /// </summary>
        /// <param 温度="Temperature"></param>
        /// <param 湿度="Humidity"></param>
        /// <param 生产线="ProductLine"></param>
        /// <param 时间点="TimePoint"></param>
        /// <returns></returns>
        /// 
        public static bool InsertBaseProfile(string tableName, double Temperature,double Humidity,string ProductLine, DateTime TimePoint)
        {
            string timePoint = string.Format("{0:yyyy-MM-dd HH:mm:ss}", TimePoint);
            string getCommandInsertInto_Baseprofile = string.Format(baseProfile_insertFormat_m(tableName), Temperature, Humidity, "'" +ProductLine+ "'", "'" +timePoint+ "'");//baseProfile_insertFormat

            try
            {
                if (ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), getCommandInsertInto_Baseprofile))
                {
                    return true;
                }
                else
                {
                    LogClass.WriteLogFile("Web Solution;Class-AccessDBApply;Fun-InsertBaseProfile;"+ tableName +"插入数据失败");
                    return false;
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution;Class-AccessDBApply;Fun-InsertBaseProfile;" + ex.Message);
                return false;
            }
        }
        //***************************************************************delete
        //**清除所有历史记录---主动*/
        //即删除表中所有数据
        //public static bool DropTable()
        //{
        //    try
        //    {
        //        //使用drop而不使用truncate的原因是truncate不能跟if exists...
        //        if (ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), sqlCmd_dropTable) && CreateTable())
        //        {
        //            return true;
        //        }
        //        else
        //        {
        //            LogClass.WriteLogFile("清除所有历史数据失败");
        //            return false;
        //        }
        //    }
        //    catch (MySqlException ex)
        //    {
        //        LogClass.WriteLogFile(ex.Message);
        //        return false;
        //    }
        //}

        //**清除某个时间段数据或者某条数据---*/
        public static bool deleteData_TimeToTime(string startTime, string endTime, string tableName)
        {
            try
            {
                if (!ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), sqlCmd_deleteData_TimeToTime(startTime, endTime, tableName)))
                {
                    LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - deleteData_TimeToTime; 清除某个时间段数据失败");
                    return false;
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - deleteData_TimeToTime;清除某个时间段数据失败" + ex.Message);
                return false;
            }
            return true;
        }

       

        //**清除超过一段时间的数据（三个月或者多少天之前）---被动/
        //创建定时任务
        /// <summary>
        /// 定时事件
        /// </summary>
        /// <param 设置默认删除多少天前的数据="timeRange"></param>
        public static bool AutoCleanData(string timeRange, string tableName)
        {
            try
            {
                if (ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), sqlCmd_event_scheduler)&& ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), sqlCmd_drop_oldevent))
                {
                    if (!ExecuteCommand(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port), AutoDeleteSqlStr(timeRange, tableName)))
                    {
                        LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - AutoCleanData;定时事件创建失败");
                        return false;
                    }
                    else
                    {
                        return true;
                    }
                }
                else
                {
                    return false;
                }
                
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - AutoCleanData;定时事件创建失败:" + ex.Message);
                return false;
            }
        }
        //*************************************************************select
        //查询单条数据
        public static BaseProfile select_baseprofile(string timePoint, string tableName)
        {
            BaseProfile baseProfile = new BaseProfile();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    MySqlCommand command = connection.CreateCommand();
                    command.CommandText = sqlCmd_selectOne(timePoint, tableName);
                    using (MySqlDataReader reader = command.ExecuteReader())
                    {
                        if (reader.HasRows)
                        {
                            while (reader.Read())
                            {
                                baseProfile.Temperature = reader.GetDouble("Temperature");
                                baseProfile.Humidity = reader.GetDouble("Humidity");
                                baseProfile.ProductLine = reader.GetString("ProductLine");
                                baseProfile.TimePoint = reader.GetDateTime("TimePoint");
                            }
                        }
                        else
                        {
                            baseProfile = null;
                        }
                    }
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - select_baseprofile查询单条数据失败:" + ex.Message);
                baseProfile = null;
            }

            return baseProfile;
        }

        
        /// <summary>
        /// 查询时间范围内数据,(实际上查询单条时间点的数据也包含在其中了)并返回对象数组
        /// </summary>
        /// <param name="starttime"></param>
        /// <param name="endtime"></param>
        /// <returns></returns>
        public static List<BaseProfile> selectList_baseprofile(string starttime, string endtime, string tableName)
        {
            List<BaseProfile> listBaseProfile = new List<BaseProfile>();
           
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    //MySqlCommand command = connection.CreateCommand();
                    listBaseProfile = MakeTableToPackage(new BaseProfile(), connection, sqlCmd_selectData_timeToTime_m(tableName), new MySqlParameter("@starttime", starttime), new MySqlParameter("@endtime", endtime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectList_baseprofile查询时间范围内数据出错:" + ex.Message);
                listBaseProfile = null;
            }
            return listBaseProfile;
        }
        /// <summary>
        /// 查询时间范围内数据,(实际上查询单条时间点的数据也包含在其中了)并返回DataTable
        /// </summary>
        /// <param name="starttime"></param>
        /// <param name="endtime"></param>
        /// <returns></returns>
        public static DataTable selectDataTable_baseprofile(string starttime, string endtime, string tableName)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    //MySqlCommand command = connection.CreateCommand();
                    Dt = GetDataTable(connection, sqlCmd_selectData_timeToTime_m(tableName), new MySqlParameter("@starttime", starttime), new MySqlParameter("@endtime", endtime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectDataTable_baseprofile查询时间范围内数据出错:" + ex.Message);
                Dt = null;
            }

            return Dt;
        }
        public static DataTable selectDataTable_baseprofileWithChart(string starttime, string endtime, string tableName)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password, int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    //MySqlCommand command = connection.CreateCommand();
                    Dt = GetDataTable(connection, sqlCmd_selectData_timeToTime_mWithChart(tableName), new MySqlParameter("@starttime", starttime), new MySqlParameter("@endtime", endtime));
                }
            }
            catch (MySqlException ex)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectDataTable_baseprofileWithChart查询时间范围内数据出错:" + ex.Message);
                Dt = null;
            }

            return Dt;
        }

      

        /// <summary>
        /// 弃用
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="LineName"></param>
        /// <returns></returns>
        public static DataTable selectCurrentBaseprofileWithLineName(string tableName, string LineName)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password, int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    Dt = GetDataTable(connection, SqlCmd_selectCurrentDataWithLine(tableName, LineName), null);
                }
            }
            catch (MySqlException x)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectCurrentBaseprofileWithLineName查询currentData数据失败：" + x.Message);
                Dt = null;
            }
            return Dt;
        }
        /// <summary>
        /// 读取最近记录
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public static DataTable selectCurrentBaseprofile(string tableName)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    Dt = GetDataTable(connection, SqlCmd_selectCurrentData(tableName), null);
                }
            }
            catch (MySqlException x)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectCurrentBaseprofile查询currentData数据失败：" + x.Message);
                Dt = null;
            }
            return Dt;
        }
        public static DataTable selectDataTable_baseprofileUsePage(string starttime, string endtime, string tableName, string beginIndex, string num)
        {
            DataTable Dt = new DataTable();
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    Dt = GetDataTable(connection, sqlCmd_selectData_timeToTime_UsePage(tableName, beginIndex, num), new MySqlParameter(@"starttime", starttime), new MySqlParameter(@"endtime", endtime));

                }
            }
            catch (MySqlException x)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun - selectDataTable_baseprofileUsePage分页查询数据失败：" + x.Message);
                Dt = null;
            }

            return Dt;
        }
        public static long selectTotalNum_baseprofile(string tableName)
        {
            long num = 0;
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    MySqlCommand command = connection.CreateCommand();
                    command.CommandText = SqlCmd_selectTotolNum(tableName);
                    num = Convert.ToInt32(command.ExecuteScalar());
                }
            }
            catch (Exception x)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun -selectTotalNum_baseprofile查询count失败：" + x.Message);
                num = 0;
            }
            return num;
        }
        public static long selectTimeToTimeNum_baseprofile(string tableName, string starttime, string endtime)
        {
            long num = 0;
            try
            {
                using (MySqlConnection connection = getMySqlCon(dbConfig.Catalog, dbConfig.User, dbConfig.Password,int.Parse(dbConfig.Port)))
                {
                    connection.Open();
                    MySqlCommand command = connection.CreateCommand();
                    command.CommandText = SqlCmd_selectTimeToTimeNum(tableName, starttime, endtime);
                    num = Convert.ToInt32(command.ExecuteScalar());
                }

            }
            catch (Exception x)
            {
                LogClass.WriteLogFile("Web Solution; Class - AccessDBApply; Fun -selectTimeToTimeNum_baseprofile查询时间范围内count失败：" + x.Message);
                num = 0;
            }
            return num;
        }
       

        //*****************sqlCmd********************//

        //开启事件调度器
        private static readonly string sqlCmd_event_scheduler = "SET GLOBAL event_scheduler = ON";
        //删除旧事件
        private static readonly string sqlCmd_drop_oldevent = "drop event if exists auto_delete";
        private static string SqlCmd_selectTotolNum(string tableName)
        {
            return "select count(id) from `" + tableName + "`"; 
        }
       private static string SqlCmd_selectTimeToTimeNum(string tableName, string starttime, string endtime)
        {
            return "select count(TimePoint) from `" + tableName + "` where TimePoint >= '" + starttime + "' and TimePoint <= '"+ endtime + "'";
        }
        private static string SqlCmd_selectCurrentDataWithLine(string tableName, string LineName)
        {
            return "select * from `" + tableName + "` where id = (select MAX(id) from `" + tableName + "` where productline = '"+ LineName + "')";
        }
        private static string SqlCmd_selectCurrentData(string tableName)
        {
            return "select * from `" + tableName + "` where id = (select MAX(id) from `" + tableName + "`)";
        }
        private static string AutoDeleteSqlStr(string timeRange, string tableName)
        {
            string sqlCmd_AutoDelete = "create event `auto_delete" + tableName + "` " +
               "on schedule " +
               "every 1 day starts now() " +
               "ON COMPLETION  PRESERVE ENABLE " +
               "do " +
               "delete from `" + tableName + "` where timepoint < date_sub(now(), interval " + timeRange + " day)";

            return sqlCmd_AutoDelete;
        }
        private static string sqlCmd_deleteData_TimeToTime(string startTime, string endTime, string tableName)
        {
            string sqlCmd_deleteData = "delete from `"+ tableName +"` where TimePoint between '" + startTime + "' and " + "'" + endTime + "'";
            return sqlCmd_deleteData;
        }
        /**\*/
        private static string sqlCmd_baseProfile_m(string tableName)
        {
            return "CREATE TABLE if not exists `"  + tableName +            
            "`(id int not null primary key auto_increment," +
            "Temperature double(7,3) not null," +
            "Humidity double(7,3) not null," +
            "ProductLine varchar(25)," +
            "TimePoint datetime not null)";
        }
       
        /**\*/

        /**\*/
        private static string baseProfile_insertFormat_m(string tableName)
        {
            return "insert into `" +
            tableName +
            "`(Temperature, Humidity, ProductLine, TimePoint)values({0},{1},{2},{3})";
        }

        
        
        /**\*/



        //truncate table删数据不删表结构，delete table一样，且不释放空间，即自增id继续加载后面。
        //drop table删数据且删表结构，删的话就不能在重新建表之前操作了；
        //但是遗憾的是查了很多资料truncate table 后面没办法跟if exists
        //但是有必须要有判断，所以只好用drop后在新建表的办法了。
        //注意：不同的数据库if exists的位置可能不一样
       // private static readonly string sqlCmd_dropTable = "drop table if exists baseprofile";


        //这里的语法要注意
        private static string sqlCmd_selectData_timeToTime_m(string tableName)
        {
            return "select * from `" + tableName + "` where TimePoint >= @starttime and TimePoint <= @endtime";

        }
        private static string sqlCmd_selectData_timeToTime_mWithChart(string tableName)
        {
            return "select UNIX_TIMESTAMP(TimePoint + INTERVAL 8 HOUR) * 1000 AS x, Temperature AS y, Humidity AS y2 from `" + tableName + "` where TimePoint >= @starttime and TimePoint <= @endtime";
        }

        private static string sqlCmd_selectOne(string timePoint, string tableName)
        {
            string sqlCmd_selectone = "select * from `" + tableName + "` where TimePoint = '" + timePoint + "'";
            return sqlCmd_selectone;
        }
        private static string sqlCmd_selectData_timeToTime_UsePage(string tableName, string beginindex, string num)
        {
            return "select * from `" + tableName + "` where TimePoint >= @starttime and TimePoint <= @endtime limit " + beginindex + "," + num;
        }

    }
}
