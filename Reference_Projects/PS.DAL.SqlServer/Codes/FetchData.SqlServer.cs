using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using System.Data.SqlClient;
using AutoSolder.DAL;
namespace PS
{
    public partial class DAL_SqlServer : DALBase
    {
        public override DataTable GetPISData(long nStationID, DateTime dtStart, DateTime dtEnd)
        {
            string sSql = string.Format("EXEC usp_Get_PIS_LastProfileData @StartTime='{0}',@EndTime='{1}',@StatinID={2}"
                , dtStart.ToString("yyyy-MM-dd HH:mm:ss"), dtEnd.ToString("yyyy-MM-dd HH:mm:ss"), nStationID <= 0 ? "NULL" : nStationID.ToString());
            return ExecuteDataTable(sSql);
        }
        public override DataTable GetPISProductlLine()
        {
            DataTable Dt = new DataTable();
            return Dt;
        }
        public override DataSet GetAllDeviceData(string line)
        {
            DataSet Ds = new DataSet();
            return Ds;
        }
        public override DataSet GetAllDeviceDataChart(string line)
        {
            DataSet Ds = new DataSet();
            return Ds;
        }
        public override DataTable GetAutoSolderData(string line, DateTime dtStart, DateTime dtEnd)
        {
            IOperationBase IOb = new DataStoreBase();
            DataTable dt = new DataTable();

            string tableName = line;//"Solder" + nStationID.ToString();
            
            
            IOb.ReadBaseProfile_dataTable(line, dtStart.ToString(), dtEnd.ToString(), out dt);
           
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
    }
}