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
using PS.Reflow;
using System.Web;
using System.Data.Common;
using PS.Reflow.Codes;
using Newtonsoft.Json;
using AutoSolder.Model;
using Newtonsoft.Json.Linq;
using System.Collections;
using System.Drawing;
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
            // Console.WriteLine(Common.EncryptDES("SMTjhd84615789", rgbIV, rgbKey));
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
            //PISModel pisModel = new PISModel() {ProLine="testLine", SN = "testSN", Model = "testModel", StartTime = DateTime.Now.AddHours(-1), EndTime = DateTime.Now, Flag = "1", CPK = 3.0, Result = "1", DateNo = DateTime.Now, HourNo = DateTime.Now, LineNo = "testNo", LineNoSHA = "testLineNoSHA", TheSN = "testTheSN", PISFileName = "testFileName" };
            //long row = 0;
            //try
            //{
            //   row = ExecuteNonQueryReturnOutParameterValue("insert into pisreflowdata (proline, sn, model, starttime, endtime, flag, cpk, result, DateNo, HourNo, LineNo, LineNoSHA, theSN) values(@prolineV, @snV, @modelV, @starttimeV, @endtimeV, @flagV, @cpkV, @resultV, @DateNoV, @HourNoV, @LineNoV, @LineNoSHAV, @theSNV);", CommandType.Text, new MySqlParameter[] { new MySqlParameter(@"prolineV", pisModel.ProLine), new MySqlParameter(@"snV", pisModel.SN), new MySqlParameter(@"modelV", pisModel.Model), new MySqlParameter(@"starttimeV", pisModel.StartTime), new MySqlParameter(@"endtimeV", pisModel.EndTime), new MySqlParameter(@"flagV", pisModel.Flag), new MySqlParameter(@"cpkV", pisModel.CPK), new MySqlParameter(@"resultV", pisModel.Result), new MySqlParameter(@"DateNoV", pisModel.DateNo), new MySqlParameter(@"HourNoV", pisModel.HourNo), new MySqlParameter(@"LineNov", pisModel.LineNo), new MySqlParameter(@"LineNoSHAV", pisModel.LineNoSHA), new MySqlParameter(@"theSNV", pisModel.TheSN), }, "id");
            //}
            //catch (Exception e)
            //{

            //    throw;
            //}

            //Console.WriteLine(row);
            //string test = "{ 'Name': 'Jon Smith11', 'Address': { 'City': 'New York', 'State': 'NY' }, 'Age': 42 }";
            //string test1 = "{ 'Name': 'Jon Smith22', 'Address': '12', 'Age': 42 }";
            //Testob stuff1 = JsonConvert.DeserializeObject<Testob>(test1);
            //dynamic stuff = JObject.Parse(test);
            //string name = stuff.Name;
            //// string name1 = stuff1.Name;
            //Console.WriteLine(name);
            //Console.WriteLine(stuff1.Name);
            BaseProfileDS baseprofile = new BaseProfileDS();
            string recipename = "rn1";

            baseprofile.ReportImage = new Bitmap("pictureBox.png");

            long row = ExecuteNonQueryReturnOutParameterValue("CreateTablesProc", CommandType.StoredProcedure, new MySqlParameter[] { new MySqlParameter(@"anaNums", baseprofile.ProcessAnaDataG.Count), new MySqlParameter(@"ovenNums", baseprofile.OvenInfoData.SegNum), new MySqlParameter(@"lineName", baseprofile.ProLine), new MySqlParameter(@"recipeName", recipename), new MySqlParameter(@"productName", baseprofile.ProName), new MySqlParameter(@"baseName", baseprofile.BaseName), new MySqlParameter(@"processName", baseprofile.ProcessTechName), new MySqlParameter(@"ovenName", baseprofile.OvenTechName), new MySqlParameter(@"startTime", baseprofile.StartTime), new MySqlParameter(@"eventFileName", recipename + @"_EventInfo"), new MySqlParameter(@"isControlcode", baseprofile.IsControlCode), new MySqlParameter(@"controlCode", baseprofile.ControlCode) });
            Console.WriteLine(row);
            Console.ReadKey();



        }
        protected static long ExecuteNonQueryReturnOutParameterValue(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            long value = 0;
            string ConnectionString = "datasource=localhost;username=root;password=pempenn;Database=ps;Port=3306;Allow User Variables=True";
            using (MySqlConnection connection = new MySqlConnection(ConnectionString))
            {
                using (MySqlCommand command = new MySqlCommand(commandText, connection))
                {
                    command.CommandType = commandType;
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                        {
                            command.Parameters.Add(parameter);
                        }
                    }
                    connection.Open();
                    if (command.ExecuteNonQuery() > 0)
                    {
                        value = command.LastInsertedId;
                    }
                }
            }

            return value;
        }
    }
}
