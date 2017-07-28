using System;
using System.Collections.Generic;
using System.Text;
using PS;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace PS
{
    public sealed partial class DAL_SqlServer : DALBase
    {
        public DAL_SqlServer()
        {
           
        }
        /// <summary>
        /// 让DAL实现类重建连接串
        /// </summary>
        public override void RebuidConnectionString()
        {
            string sConn = "Data Source=" + this.Source;

            string ss = this.Port;
            if ((!string.IsNullOrEmpty(ss)) && ss.Trim().Length > 0)
                sConn += "," + ss;

            ss = this.User;
            if ((!string.IsNullOrEmpty(ss)) && ss.Trim().Length > 0)
                sConn += ";User Id=" + ss;

            //this.Password = "Root123456";
            //this.Password = "Zx147258";

            ss = this.DbPassword;
            if ((!string.IsNullOrEmpty(ss)) && ss.Trim().Length > 0)
                sConn += ";Password=" + ss;

            ss = this.Catalog;
            if ((!string.IsNullOrEmpty(ss)) && ss.Trim().Length > 0)
                sConn += ";Initial Catalog=" + ss;

            this.ConnectionString = sConn;
        }

        public override string DALName
        {
            get
            {
                return "SqlServer";
            }
        }
        //TimeSpan _nTimeZone = TimeSpan.MinValue;
        //public override TimeSpan TimeZone
        //{
        //    set { _nTimeZone = value; }
        //    get
        //    {
        //        if (_nTimeZone == TimeSpan.MinValue)
        //        {
        //            DataTable tbl = ExecuteDataTable("SHOW VARIABLES WHERE Variable_Name='time_zone';");
        //            string sTimeZone = Cvt.ToString(tbl.Rows[0]["value"]);
        //            _nTimeZone = TimeSpan.Parse(sTimeZone);
        //        }
        //        return _nTimeZone;
        //    }
        //}

        protected override DbConnection getNewConnection(string sConnectionString)
        {
            return new SqlConnection(sConnectionString);
        }
        protected override DbDataAdapter getNewAdapter(string commandText, DbConnection dbConnection)
        {
            return new SqlDataAdapter(commandText, dbConnection as SqlConnection);
        }
        protected override DbDataAdapter getNewAdapter(DbCommand command)
        {
            return new SqlDataAdapter(command as SqlCommand);
        }
        protected override DbDataAdapter getNewAdapter(string commandText, string sConnectionString)
        {
            return new SqlDataAdapter(commandText, sConnectionString);
        }
        protected override DbCommand getNewCommand(string commandText, DbConnection dbConnection)
        {
            return new SqlCommand(commandText, dbConnection as SqlConnection);
        }
        public override DateTime TimeOfDBServer
        {
            get
            {
                return Cvt.ToDateTime(this.ExecuteScalar("select SYSDATETIMEOFFSET()"));
            }
        }
        /// <summary>
        /// 数据库中当前时间的获取函数
        /// </summary>
        public override string FuncCurrentTimestamp
        {
            get
            {
                //return "current_timestamp()";//mySql
                return "SYSDATETIMEOFFSET()";//"SQL server"
            }
        }
        /// <summary>
        /// 数据库中最新自动增长值的获取函数
        /// </summary>
        public override string FuncLastInsertId { get { return "SCOPE_IDENTITY()"; } }
   
        /// <summary>
        /// 构造一个数据库的数值引用
        /// </summary>
        /// <param name="sValue">字符型的数值</param>
        /// <returns>带引用前后符号的数值</returns>
        public override string QuoteValue(string sValue)
        {
            return "'" + sValue.Replace("'", "''") + "'";
        }
        /// <summary>
        /// 构造一个数据库的字段引用
        /// </summary>
        /// <param name="sValue">字符型的字段</param>
        /// <returns>带引用前后符号的字段</returns>
        public override string QuoteField(string sField)
        {
            return "[" + sField.Replace("'", "''") + "]";
        }

        /// <summary>
        /// 数据库中的NULL引用
        /// </summary>
        public override string QuoteNull { get { return "NULL"; } }

        public override DataTable GetPreferencesSetttings()
        {
            return this.ExecuteDataTable("SELECT * FROM ps_Preferences");
        }

        public override DataTable GetUseInfo(string sUserName)
        {
            return this.ExecuteDataTable("SELECT tblHistory.*,Login_Attempt,Login_Time,From_IP,From_MAC,From_Host,_Login_Result FROM ps_Employee tblEmp INNER JOIN ps_Employee_History tblHistory ON tblEmp._Last_History=tblHistory._ID \n"
                + "	LEFT JOIN ps_Login_History tblLogin ON tblEmp._Last_Login_History=tblLogin._ID \n"
                + "	WHERE  tblEmp.Name='" + sUserName + "';");
        }
        public override DataTable GetUseInGroup(long _Employee)
        {
            return this.ExecuteDataTable("SELECT tblGrp.* FROM ps_Employee_In_Group tblGrp INNER JOIN "
    + "(SELECT _Group,_Employee,Max(_ID) AS MaxID FROM ps_Employee_In_Group WHERE _Employee=2 GROUP BY _Group,_Employee) tblMax ON tblGrp._ID=tblMax.MaxID AND tblGrp._Status=" + _Employee + ";");
        }

        private SqlParameter NullableParameter<T>(string parameterName, SqlDbType parameterType, T value, T nullValue) where T : IComparable
        {
            SqlParameter par = new SqlParameter();
            par.ParameterName = parameterName;
            par.SqlDbType = parameterType;
            par.Direction = ParameterDirection.Input;

            if (value == null || nullValue.Equals(value))
            {
                par.IsNullable = true;
                par.Value = DBNull.Value;
                par.SourceColumnNullMapping = true;
            }
            else
            {
                par.IsNullable = false;
                par.Value = value;
            }
            return par;
        }
        private void Update_Employee_Info(long _EmpID, string sPwd, long _EmpID_Update, byte[] blobGravatar, string sFullName, string sDescription, string sMailAddress
            , int nLogin_Result_ID, int nLogin_Attempt, string sFrom_IP, string sFrom_MAC, string sFrom_Host)
        {
            DbTransaction objTrans = this.BeginTransaction();
            //this.ExecuteNonQuery(objTrans, "Update_Employee_Info", CommandType.StoredProcedure, new SqlParameter[]{
            //    new SqlParameter("_EmpID",_EmpID),new SqlParameter("sPwd",sPwd) ,new SqlParameter("_EmpID_Update",_EmpID_Update)
            //    ,BlobNullableParameter("@blobGravatar",null),NullableParameter("@sFullName",MySqlDbType.String,sFullName,"") ,NullableParameter("@sDescription",MySqlDbType.String,sDescription,"")
            //    ,NullableParameter("@sMailAddress",MySqlDbType.String,sMailAddress,""),NullableParameter("@nLogin_Result_ID",MySqlDbType.Int32, nLogin_Result_ID,-1) ,NullableParameter("@nLogin_Attempt",MySqlDbType.Int32,nLogin_Attempt,-1)
            //    ,NullableParameter("@sFrom_IP",MySqlDbType.String,sFrom_IP,""),NullableParameter("@sFrom_MAC",MySqlDbType.String,sFrom_MAC,"") ,NullableParameter("@sFrom_Host",MySqlDbType.String,sFrom_Host,"")
            //});
            objTrans.Commit();
        }
        public override void ChangeUserPassword(LanguageHelper langHelper, long _Employee, string sHashPassword, EmployeeInfo emp)
        {
            //检查用户的密码与最近5次的密码不相同
            string sSql = "SELECT TOP 5 * FROM ps_Employee_History WHERE _Employee=" + _Employee + " ORDER BY _ID;";
            DataTable tbl = ExecuteDataTable(sSql);

            foreach (DataRow row in tbl.Rows)
            {
                if (sHashPassword.Equals(row["Password"] as string, StringComparison.OrdinalIgnoreCase))
                    throw new ArgumentException(langHelper.GetText("Can't Use Same Password within recently 5 times !"));
            }

            SubmitEditableChange(emp, changeStatus.AddHistory, true, "_Employee", new ExDictionary(new KV[] {
                new KV("_Employee", emp._Employee)
                ,new KV("Password", sHashPassword)
                ,new KV("_Employee_Update", emp._Employee)                
                ,new KV("Change_Pwd_When_Next_Login", false)
            }));
        }
        public override void UpdateUserInfo(LanguageHelper langHelper, long _Employee, string sHashPwd, long _Employee_Update, string FullName, string MailAddress)
        {
            Update_Employee_Info(_Employee, sHashPwd, _Employee_Update, null, FullName, null, MailAddress, -1, -1, null, null, null);
        }
        public override void AddLoginHistory(EmployeeInfo emp, LoginResult LoginResult)
        {
            SubmitEditableChange(emp, changeStatus.Add, false, "loginHistory", new ExDictionary(new KV[] {
                new KV("_Employee", emp._Employee)
                ,new KV("Login_Attempt", emp.Login_Attempt)
                ,new KV("From_IP", emp.lastLoginFrom_IP)
                ,new KV("From_MAC", emp.lastLoginFrom_MAC)
                ,new KV("From_Host", emp.lastLoginFrom_Host)
                ,new KV("_Login_Result", LoginResult)
            }));
        }

        public override DataTable GetPageList(long _Employee)
        {
            return this.ExecuteDataTable("");
        }
        public override DataTable GetStationGroupList(long _Employee)
        {
            return this.ExecuteDataTable("");
        }

    }
}
