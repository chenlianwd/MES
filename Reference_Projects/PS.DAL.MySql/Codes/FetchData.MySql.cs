using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using MySql.Data.MySqlClient;
using AutoSolder.DAL;
using PS.Reflow.Codes;

namespace PS
{
    public partial class DAL_MySql : DALBase
    {
        public override DataTable GetPISData(long nStationID, DateTime dtStart, DateTime dtEnd)
        {
            DataTable Dt = ExecuteDataTable("usp_Get_PIS_LastProfileData", CommandType.StoredProcedure
                , new MySqlParameter[] { new MySqlParameter("@begintime", dtStart)
                    , new MySqlParameter("@overtime", dtEnd)
                    , new MySqlParameter("@StationID", nStationID == -1 ? (object)DBNull.Value : nStationID) });
            //查询详细的时候不使用存储过程试试
            //if (nStationID != -1)
            //{
            //    Dt = ExecuteDataTable("select * from pisreflowdata where StartTime >= @beginTime and StartTime <= @overTime and LineNoSHA = @stationID ORDER BY id DESC limit 0,100", CommandType.Text, new MySqlParameter[] { new MySqlParameter(@"beginTime", dtStart), new MySqlParameter(@"overTime", dtEnd), new MySqlParameter(@"stationID", nStationID) });
              
            //    DataColumn DCx = new DataColumn("x", System.Type.GetType("System.Int32"), "starttime");
            //    DataColumn DCy = new DataColumn("y", System.Type.GetType("System.Decimal"), "cpk");
            //    DataColumn DCName = new DataColumn("name", System.Type.GetType("System.DateTime"), "starttime");
            //    Dt.Columns.Add(DCx);
            //    Dt.Columns.Add(DCy);
            //    Dt.Columns.Add(DCName);
            //}     
            return Dt;
           
        }
        public override DataTable GetPISProductlLine()
        {
            //DISTINCT去重
            DataTable Dt = ExecuteDataTable("SELECT DISTINCT(proline) From pisreflowdata");
            DataColumn Dc = new DataColumn("id", typeof(System.Int32));
            //Dc.AutoIncrement = true;
            //Dc.AutoIncrementSeed = 1;
            //Dc.AutoIncrementStep = 1;
            Dt.Columns.Add(Dc);
            Dc.SetOrdinal(0);
            for (int i = 0; i < Dt.Rows.Count; i++)
            {
                Dt.Rows[i]["id"] = i + 1;
            }
 
            return Dt;
        }
        
        public override DataSet GetAllDeviceData(string line)
        {
            //因为两个数据库查询方法中的连接分开写的，分两次查出

            DataTable DtSolder = new DataTable();
            IOperationBase IOb = new DataStoreBase();
            IOb.ReadCurrentBaseprofileToDataTable(line, out DtSolder);

            if (DtSolder == null)
            {
                DtSolder = new DataTable();
            }
            //DbDataReader Dr = ExecuteReader("select * from pisreflowdata where id = (select max(id) where pisreflowdata)");
            //if (Dr.Read())
            //{
            //}
            //Dr.Close();

            //与pis页面类似 采用存储过程查询
            // DataTable DtPis = ExecuteDataTable("select * from pisreflowdata where id = (select max(id) from pisreflowdata where proline = '" + line + "')");
            DataTable DtPis = GetPISData(-1, new DateTime(), new DateTime());
            //取出当前所需结果
            DataRow[] rows = DtPis.Select("proline = '" + line + "'");
            DataTable DtPisResult = new DataTable();
            DtPisResult = DtPis.Clone();
            foreach (DataRow row in rows)
            {
                DtPisResult.ImportRow(row);
            }

            DataSet Ds = new DataSet();
            DtSolder.TableName = "soldertable";
            DtPisResult.TableName = "pistable";
            Ds.Tables.AddRange(new DataTable[] {DtSolder, DtPisResult });

            return Ds;
        }
        /// <summary>
        /// 现改为查询最近数据中一天内的数据
        /// </summary>
        /// <param name="line"></param>
        /// <returns></returns>
        public override DataSet GetAllDeviceDataChart(string line)
        {
            //查询最近一条数据的时间，再往前推一天，获取起止时间


            DateTime dtEnd = DateTime.Now;
            DateTime dtStart = dtEnd.AddDays(-1);
            string dtEndString = dtEnd.ToString();
            string dtStartString = dtStart.ToString();
            IOperationBase IOb = new DataStoreBase();
            DataTable DtCurrent = new DataTable();
            IOb.ReadCurrentBaseprofileToDataTable(line,out DtCurrent);

            if (DtCurrent != null)
            {
                dtEndString = DtCurrent.Rows[0]["timepoint"].ToString();
                dtStartString = Convert.ToDateTime(dtEndString).AddDays(-1).ToString();
            }
            DataTable DtSolder = new DataTable();          
            IOb.ReadBaseProfile_dataTableWithChart(line, dtStartString, dtEndString, out DtSolder);
            if (DtSolder == null)
            {
                DtSolder = new DataTable();
            }
            string pisMaxTResult = ExecuteScalar("select starttime from pisreflowdata where id = (select max(id) from pisreflowdata where proline='"+ line +"')").ToString();
            if (pisMaxTResult != null)
            {
                dtEndString = pisMaxTResult;
                dtStartString = Convert.ToDateTime(pisMaxTResult).AddDays(-1).ToString();
            } 

            DataTable DtPis = ExecuteDataTable("select UNIX_TIMESTAMP(starttime + INTERVAL 8 HOUR) * 1000 AS x, Convert(cpk,decimal(9,3)) AS y from pisreflowdata where proline = @line and starttime >= @begintime and starttime <= @endtime", CommandType.Text, new MySqlParameter[] {new MySqlParameter(@"line", line), new MySqlParameter(@"begintime", dtStartString), new MySqlParameter(@"endtime", dtEndString) });

            DataSet Ds = new DataSet();
            DtSolder.TableName = "soldertable";
            DtPis.TableName = "pistable";
            Ds.Tables.AddRange(new DataTable[] { DtSolder, DtPis });

            return Ds;
        }
        public override DataTable GetAutoSolderData(string line, DateTime dtStart, DateTime dtEnd)
        {
            IOperationBase IOb = new DataStoreBase();
            DataTable dt = new DataTable();

            string tableName = line;

            IOb.ReadBaseProfile_dataTable(tableName, dtStart.ToString(), dtEnd.ToString(), out dt);

            return dt;
        }
        public override List<DataTable> GetAutoSolderCurrentData(List<string> lineList)
        {
            IOperationBase IOb = new DataStoreBase();
            List<DataTable> listTable = new List<DataTable>();
            if (lineList == null)
            {
                return null;
            }
            foreach (string tableName in lineList)
            {
                DataTable dt = new DataTable();
                IOb.ReadCurrentBaseprofileToDataTable(tableName, out dt);
                listTable.Add(dt);
            }
            return listTable;
        }
       
            public override DataTable GetAutoSolderDataUsePage(string line, DateTime dtStart, DateTime dtEnd, string beginIndex, string num)
        {
            IOperationBase IOb = new DataStoreBase();
            DataTable dt = new DataTable();

            string tablename = line;



            IOb.ReadBaseProfile_dataTableUsePage(line, dtStart.ToString(), dtEnd.ToString(), out dt, beginIndex, num);

            return dt;
        }
        public override long GetAutoSolderDataTotalNum(string line)
        {
            IOperationBase IOb = new DataStoreBase();
            long num = 0;
            IOb.ReadBaseProfile_totalNum(line, out num);

            return num;

        }
        public override long GetAutoSolderDataTimeToTimeNum(string line, DateTime dtStart, DateTime dtEnd)
        {
            IOperationBase IOb = new DataStoreBase();
            long num = 0;
            IOb.ReadBaseProfile_TimeToTimeNum(line, dtStart.ToString(), dtEnd.ToString(), out num);

            return num;
        }
        public override DateTime GetCurrentdateTime(string line)
        {
            DateTime dtime = DateTime.Now;
            DataTable dt = new DataTable();
            IOperationBase IOb = new DataStoreBase();
            IOb.ReadCurrentBaseprofileToDataTable(line, out dt);
            if (dt.Rows.Count > 0)
            {
                dtime = Convert.ToDateTime(dt.Rows[0]["TimePoint"]);
            }
            

            return dtime;
        }
        #region Insert方法
        public override bool InsertPISData(PISModel pisModel, out long row)
        {
            row = ExecuteNonQueryReturnOutParameterValue("insert into pisreflowdata (proline, sn, model, starttime, endtime, flag, cpk, result, DateNo, HourNo, LineNo, LineNoSHA, theSN) values(@prolineV, @snV, @modelV, @starttimeV, @endtimeV, @flagV, @cpkV, @resultV, @DateNoV, @HourNoV, @LineNoV, @LineNoSHAV, @theSNV)", CommandType.Text, new MySqlParameter[] { new MySqlParameter(@"prolineV", pisModel.ProLine), new MySqlParameter(@"snV", pisModel.SN), new MySqlParameter(@"modelV", pisModel.Model), new MySqlParameter(@"starttimeV", pisModel.StartTime), new MySqlParameter(@"endtimeV", pisModel.EndTime), new MySqlParameter(@"flagV", pisModel.Flag), new MySqlParameter(@"cpkV", pisModel.CPK), new MySqlParameter(@"resultV", pisModel.Result), new MySqlParameter(@"DateNoV", pisModel.DateNo), new MySqlParameter(@"HourNoV", pisModel.HourNo), new MySqlParameter(@"LineNov", pisModel.LineNo), new MySqlParameter(@"LineNoSHAV", pisModel.LineNoSHA), new MySqlParameter(@"theSNV", pisModel.TheSN), });
            if (!(row > 0))
            {
                return false;
            }
            return true;
        }
        
        public override bool InsertRecipeCollectProfile(BaseProfileDS baseprofile, string recipename, DateTime Starttime)
        {
            //执行sql脚本创建新存储过程并删除旧的存储过程
            //1、建表过程(暂时不包含base所属表)
            ExecuteMySqlScript("CreateTablesProc.sql");

            //2、插入数据过程




            //执行
            long row = ExecuteNonQueryReturnOutParameterValue("CreateTablesProc", CommandType.StoredProcedure, new MySqlParameter[] { new MySqlParameter(@"anaNums",baseprofile.ProcessAnaDataG.Count),new MySqlParameter(@"ovenNums",baseprofile.OvenInfoData.SegNum), new MySqlParameter(@"lineName", baseprofile.ProLine), new MySqlParameter(@"recipeName", recipename), new MySqlParameter(@"productName",baseprofile.ProName), new MySqlParameter(@"baseName", baseprofile.BaseName), new MySqlParameter(@"processName", baseprofile.ProcessTechName), new MySqlParameter(@"ovenName", baseprofile.OvenTechName), new MySqlParameter(@"startTime",baseprofile.StartTime), new MySqlParameter(@"eventFileName", recipename + @"_EventInfo"),new MySqlParameter(@"isControlcode", baseprofile.IsControlCode), new MySqlParameter(@"controlCode", baseprofile.ControlCode) });
            if (!(row > 0))
            {
                return false;
            }
            return true;
        }
        /// <summary>
        /// 每片板的数据
        /// </summary>
        /// <param name="recipeprofile"></param>
        /// <returns></returns>
        public override bool InsertActualProfile(RecipeProfileDS recipeprofile)
        {
            throw new NotImplementedException();
        }

        public override bool InsertEventProfile(EventInfoDS eventprofile)
        {
            throw new NotImplementedException();
        }

        public override bool InsertRTMonitorData(RTMonitorDS data)
        {
            throw new NotImplementedException();
        }

       

        


        #endregion


    }
}