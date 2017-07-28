using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PS;
using System.Data.SqlClient;
using System.IO;
using System.Xml;
using System.Data;
using System.ServiceProcess;
using Microsoft.Win32;
using ReflowerTestr.DAL;
using System.Diagnostics;
using AutoSolder.DAL;
using MySql.Data.MySqlClient;
using WebSocket4Net;
//using System.Net.WebSockets;
//using WebSocketSharp;

namespace testPrj
{
    class Program
    {
        //private static readonly byte[] rgbIV = { 210, 213, 218, 219, 160, 182, 186, 188 };
        //private static readonly byte[] rgbKey = { 156, 159, 133, 132, 146, 147, 158, 162 };
        private static readonly byte[] rgbIV = { 182, 186, 218, 219, 190, 182, 186, 188 };
        private static readonly byte[] rgbKey = { 223, 226, 225, 132, 146, 147, 206, 213 };
        static void Main(string[] args)
        {
#if TEST
            Common.LanguageHelper.GetText("new The \n T\x016est\t&Get<Infomation's> OK.");
            //Common.DAL.AddLoginHistory(1, LoginResult.OK);

            //Stream stream = null;
            //string sCode = UserMgr.CreateVerifyCodePicture(stream);

            //DALBase dal = Common.DAL;
            //EquipmentBase[] allEqupments = Common.LoadAllAssembly<EquipmentBase>();
            string sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
            sPath =Path.Combine(sPath, "config");
            if (!Directory.Exists(sPath))
                Directory.CreateDirectory(sPath);

            DataTable tbl = new DataTable();
            sPath = Path.Combine(sPath, "Language.xml");
            if (File.Exists(sPath))
            {
                tbl.ReadXml(sPath);
                DataRow[] sel=tbl.Select("stringName='lblHomePage''Title'");
                string sTitle=null;
                if (sel != null && sel.Length > 0)
                    sTitle = sel[0]["chsText"] as string;
                return;
            }
            else
            {
                tbl.TableName = "Language";
                DataColumn col = tbl.Columns.Add("stringName", typeof(System.String));
                col.Unique = true;
                tbl.Columns.Add("engText", typeof(System.String));
                tbl.Columns.Add("chsText", typeof(System.String));

                tbl.Rows.Add(new object[] { "lblHomePage'Title","Title of Homepage:","首页标题：" });
                tbl.Rows.Add(new object[] { "lblHomePageLogo", "Logo of Homepage:", "首页Logo：" });

                tbl.WriteXml(sPath, XmlWriteMode.WriteSchema);

                //XmlWriterSettings settings = new XmlWriterSettings();
                //settings.Indent = true;                
                //XmlWriter writer = XmlWriter.Create(sPath, settings);
                //tbl.WriteXml(writer);
                //writer.Flush();
                //writer.Close(); 
            }

            

            //XmlElement langEle = xmlDoc.SelectSingleNode("/language") as XmlElement;
            //if (langEle == null)
            //    langEle = xmlDoc.AppendChild(xmlDoc.CreateElement("language")) as XmlElement; 

            //XmlElement itm = langEle.SelectSingleNode("lblHomePageTitle") as XmlElement;
            //if(itm==null)
            //{
            //    itm = langEle.AppendChild(xmlDoc.CreateElement("lblHomePageTitle")) as XmlElement; 
            //}
            //itm.SetAttribute("chs", "Test1\nTest2");
            //xmlDoc.Save(sPath);

            return;
#endif

            // Console.WriteLine(Common.DecryptDES("5dTxSJstjnMwU0DFBimfbw==", rgbIV, rgbKey));
            Console.WriteLine(Common.EncryptDES("pempenn", rgbIV, rgbKey));
            //File.Move(@"D:\\AutosolderNet\\LOGFile.txt", @"D:\\AutosolderNet\\" + DateTime.Now.ToString("yyyyMMdd") + "LogFile.txt");

            //Console.WriteLine(Directory.GetCurrentDirectory() + "\\" + DateTime.Now.ToString("yyyyMMdd") + "\\LogFile.txt");
            //ServiceIsExisted("Autosolder");
            //if (path != "")
            //{
            //    Console.WriteLine(path);
            //    Console.ReadKey();
            //}
            //LogClass.WriteLogFile("test111111111111111111111111");

            //bool i = InsertBaseProfile("rthosttable", "1", "2", "3", new DateTime(11111), new DateTime(222), "4", "5", "6", "7", "8", "9", "10","11");
            //Console.WriteLine(sqlCmd_baseProfile_m("testTwo"));
            //Console.WriteLine(i.ToString());
            //List<string> listStr = new List<string>();
            //listStr = selectAllLineData("testTwo", "Line");
            //foreach (string s in listStr)
            //{
            //    Console.WriteLine(s);
            //}
            //Console.WriteLine("------------------分隔符----------------");
            //listStr = selectAllLineData("testTwo", "ProductName");
            //foreach (string s in listStr)
            //{
            //    Console.WriteLine(s);
            //}
            //DataTable dt1 = SelectDataTable_baseProfile("testtwo", "1", true);
            //DataTable dt2 = SelectDataTable_baseProfile("testtwo", "1", false);
            //DataTable dt3 = SelectDataTable_baseProfile("testtwo", "3", "43");
            //DataTable dt4 = SelectDataTable_baseProfile("testtwo", "4", true, new DateTime(2017, 6, 23).ToString(), new DateTime(2017, 6, 28).ToString());
            //DataTable dt5 = SelectDataTable_baseProfile("testtwo", "4", false, new DateTime(2017, 6, 1).ToString(), new DateTime(2017, 6, 29).ToString());
            //DataTable dt6 = SelectDataTable_baseProfile("testtwo", "et", "brbr", new DateTime(2017, 6, 1, 1, 1, 1).ToString(), new DateTime(2017, 6, 29).ToString());
            //Console.WriteLine("删除第一行数据" + DeleteData_baseProfile("testtwo", "1", true));//id=1
            //Console.WriteLine("删除第二行数据" + DeleteData_baseProfile("testtwo", "42", false));//id=2
            //Console.WriteLine("删除第三行数据" + DeleteData_baseProfile("testtwo", "3", "43"));//id=3
            //Console.WriteLine("删除第四行数据" + DeleteData_baseProfile("testtwo", "2", true, new DateTime(2017, 6, 1, 8, 8, 8).ToString(), new DateTime(2017, 6, 21).ToString()));//id=4
            //Console.WriteLine("删除第五行数据" + DeleteData_baseProfile("testtwo", "brbr", false, new DateTime(2017, 6, 1, 8, 8, 8).ToString(), new DateTime(2017, 6, 21).ToString()));//id=5
            //Console.WriteLine("删除第六行数据" + DeleteData_baseProfile("testtwo", "et", "ghf", new DateTime(2017, 6, 1, 8, 8, 8).ToString(), new DateTime(2017, 6, 21).ToString()));//id=6
            //string strFileName = "a: b / c; d* e?f < >|\"g.txt";

            //StringBuilder rBuilder = new StringBuilder(strFileName);
            //foreach (char rInvalidChar in Path.GetInvalidFileNameChars())
            //{
            //    rBuilder.Replace(rInvalidChar.ToString(), string.Empty);
            //}
            //strFileName = rBuilder.ToString();
            //Console.WriteLine(CreateTable("RTHostTable"));
            //using (var ws = new WebSocket("ws://121.40.165.18:8088"))
            //{

            //    ws.OnMessage += (sender, e) =>
            //      Console.WriteLine("Laputa says: " + e.Data);

            //    ws.Connect();
            //    ws.Send("BALUS");
            //    Console.ReadKey(true);
            //}

            //WebSocket websocket = new WebSocket("ws://121.40.165.18:8088");
            //websocket.Opened += new EventHandler(websocket_Opened);
            //websocket.Error += new EventHandler<SuperSocket.ClientEngine.ErrorEventArgs>(websocket_Error);
            //websocket.Closed += new EventHandler(websocket_Closed);
            //websocket.MessageReceived += new EventHandler<MessageReceivedEventArgs>(websocket_MessageReceived);
            //websocket.Open();         
            // websocket.Send(Console.ReadLine());
            Console.ReadKey();
            
            
            
        }

        private static void websocket_MessageReceived(object sender, MessageReceivedEventArgs e)
        {
            Console.WriteLine("received" + e.Message);
        }

        private static void websocket_Closed(object sender, EventArgs e)
        {

        }
        private static void websocket_Error(object sender, SuperSocket.ClientEngine.ErrorEventArgs e)
        {
            
        }

        private static void websocket_Opened(object sender, EventArgs e)
        {
            //websocket.Send("Hello World!");
        }

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
        private static string SqlCmd_baseProfile_m(string tableName)
        {
            return "CREATE TABLE if not exists `" + tableName + "`" +
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
           "PtsFilePath varchar(50) not null," +
           "ImgPath varchar(50) not null," +
           "INDEX select_Index (StartTime,ProductName,Line)" +
           ")";
        }
        #region 删除
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
        #endregion
        #region 查询
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
        #endregion

        public static string path = String.Empty;
        private static bool ServiceIsExisted(string serviceName)
        {
            ServiceController[] services = ServiceController.GetServices();
            foreach (ServiceController s in services)
            {
                if (s.ServiceName == serviceName)
                {
                    if (FilePath(s.ServiceName) != "")
                    {
                        path = FilePath(s.ServiceName);
                    }
                    return true;
                }
            }
            return false;
        }
        public static string FilePath(string serviceName)
        {


            RegistryKey _Key = Registry.LocalMachine.OpenSubKey(@"SYSTEM\ControlSet001\Services\" + serviceName);
            if (_Key != null)
            {
                object _ObjPath = _Key.GetValue("ImagePath");
                if (_ObjPath != null) return _ObjPath.ToString();
            }
            return "";

        }
        public static bool InsertBaseProfile(string tableName, string Line, string ReflowerName, string ProductName, DateTime StartTime, DateTime EndTime, string TechnologyType, string TechnologyName, string ProcessName, string ReflowerTechName, string SolderName, string PtsFileName, string PtsFilePath, string ImgPath)
        {
            string startTime = string.Format("{0:yyyy-MM-dd HH:mm:ss}", StartTime);
            string endTime = string.Format("{0:yyyy-MM-dd HH:mm:ss}", EndTime);
            string getCommandInsert = string.Format(baseProfile_insertFormat(tableName), "'" + Line + "'", "'" + ReflowerName + "'", "'" + ProductName + "'", "'" + startTime + "'", "'" + endTime + "'", "'" + TechnologyType + "'", "'" + TechnologyName + "'", "'" + ProcessName + "'", "'" + ReflowerTechName + "'", "'" + SolderName + "'", "'" + PtsFileName + "'", "'" + PtsFilePath + "'", "'" + ImgPath + "'");
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
        public static List<string> selectAllLineData(string tableName, string field)
        {
            List<string> listStr = new List<string>();
            try
            {
                using (MySqlConnection connection = AccessDBBase.getMySqlCon("ReflowerTester", "root", "pempenn", GlobalData.MySqlPort))
                {
                    connection.Open();
                    MySqlCommand cmd = new MySqlCommand(sqlCmd_selectAllLine(tableName, field), connection);
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
                LogClass.WriteLogFile("Reflower Tester:去重查询Line数据失败" + ex.Message);
                listStr = null;
            }
            
            return listStr;
        }

        private static string sqlCmd_selectAllLine(string tableName, string field)
        {
            return "select distinct " + field + " from " + tableName;
        }

        private static string baseProfile_insertFormat(string tableName)
        {
            return "insert into `" + tableName + "` (" +
              "Line, ReflowerName, ProductName, StartTime, EndTime, TechnologyType, TechnologyName, ProcessName, ReflowerTechName, SolderName, PtsFileName, PtsFilePath, ImgPath)values({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12})";
        }
        private static string sqlCmd_baseProfile_m(string tableName)
        {
            return "CREATE TABLE if not exists `" + tableName + "`" +
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
           "PtsFilePath varchar(50) not null," +
           "ImgPath varchar(50) not null," +
           "INDEX select_Index (StartTime,ProductName,Line)" +
           ")";
        }

    }
}
