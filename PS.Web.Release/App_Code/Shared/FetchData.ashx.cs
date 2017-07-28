using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using System.Threading;
using System.Collections;
using System.Data;
using System.Diagnostics;
using Newtonsoft.Json;

using PS;
using AutoSolder.BLL;
using System.IO;
using System.ServiceProcess;
using System.Text;
using Newtonsoft.Json.Converters;

public partial class FetchData : IHttpHandler, IRequiresSessionState
{
    private class tagErrMsg
    {
        public tagErrMsg(string s)
        {
            sErrMsg = s;
        }
        public string sErrMsg;
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string sFun = context.Request["fn"];
        try
        {
            LanguageHelper langHelper = GetLanguageHelper(context.Session);

            switch (sFun)//操作函数调用
            {
                case "VerifyCode":
                    context.Session["VerifyCode"] = UserMgr.CreateVerifyCodePicture(context.Response.OutputStream);
                    context.Response.ContentType = "image/jpeg";
                    break;
                case "CheckVerifyCode":
                    Thread.Sleep(500); //通过ajax每500毫秒只能对比一次校验码，防止暴力刷新
                    if (string.IsNullOrEmpty(context.Request["VerifyCode"])
                        || string.Equals((string)context.Session["VerifyCode"], context.Request["VerifyCode"], StringComparison.OrdinalIgnoreCase) == false)
                        throw new Exception(langHelper.GetText("Verify Code Is Incorrect !"));
                    else
                        context.Response.Write(new JavaScriptSerializer().Serialize(new { Result = true }));
                    break;
                case "GetUserInfo":
                    //context.Response.Write(new JavaScriptSerializer().Serialize(BLL.LoadEmployeeInfo(context.Request["sUserName"])));
                    context.Response.Write(ExtendedJavaScriptConverter<EmployeeInfo>.ToJson(UserMgr.LoadEmployeeInfo(context.Request["sUserName"]), "yyyy-MM-dd HH:mm:ss"));
                    Thread.Sleep(500); //通过ajax每500毫秒只能取得一次用户信息，防止暴力刷新
                    break;
                case "GetLogedUserName":
                    EmployeeInfo empInfo = context.Session["LogonEmployee"] as EmployeeInfo;
                    if (empInfo != null)
                        context.Response.Write(new JavaScriptSerializer().Serialize(empInfo));
                    break;
                case "logout":
                    context.Session["LogonEmployee"] = null; break;
                case "TableEdit":
                    TableEdit(context);                    
                    break;
                case "GetPISData":
                    GetPISData(context);
                    break;
                case "GetAutoSolderData":
                    GetAutoSolderData(context);
                    break;
                case "GetConnection":
                    //GetConnection(context);
                    break;
                case "GetProductLineData":
                    GetProductLineData(context);
                    break;
                case "GetAutoSolderData_Grid":
                    GetAutoSolderData_Grid(context);
                    break;
                case "SaveNetSetting":
                    SaveNetSetting(context);
                    break;
                case "ExportExcel":
                    ExportExcel(context);
                    break;
                case "GetReflowerProfile_Grid":
                    GetReflowerProfile_Grid(context);
                    break;
                case "GetCommonProductLine":
                    GetCommonProductLine(context);
                    break;
                case "GetAllDeviceData":
                    GetAllDeviceData(context);
                    break;
                case "GetAllDeviceDataChart":
                    GetAllDeviceDataChart(context);
                    break;
            }
        }
        catch (Exception err)
        {
            string sJson = new JavaScriptSerializer().Serialize(new tagErrMsg(err.Message));
            switch (sFun)
            {
                default:
                    context.Response.Write(sJson); break;
            }
        }
    }
    /// <summary>
    /// 获取当前产线所有设备图表数据(即最近一天时间数据)
    /// </summary>
    /// <param name="context"></param>
    private void GetAllDeviceDataChart(HttpContext context)
    {
        string line = context.Request["line"];
        //DateTime dtEnd = DateTime.Now, dtStart;
        //if (!DateTime.TryParse(context.Request["StartTime"], out dtStart))
        //    dtStart = DateTime.Now;
        //if (!DateTime.TryParse(context.Request["EndTime"], out dtEnd))
        //    dtEnd = dtStart;

        //DataSet Ds = Common.DAL.GetAllDeviceDataChart(line, dtStart, dtEnd);
        DataSet Ds = Common.DAL.GetAllDeviceDataChart(line);
        var iso = new IsoDateTimeConverter();
        iso.DateTimeFormat = "yyyy-MM-dd HH:mm:ss";
        string jsonstr = JsonConvert.SerializeObject(Ds, iso);
        context.Response.Write(jsonstr);
    }

    /// <summary>
    /// 获取当前产线所有设备首页数据（即max）
    /// </summary>
    /// <param name="context"></param>
    private void GetAllDeviceData(HttpContext context)
    {
        string line = context.Request["line"];

        DataSet Ds = Common.DAL.GetAllDeviceData(line);
        //默认是iso日期格式ddHH之间有个T
        var iso = new IsoDateTimeConverter();
        iso.DateTimeFormat = "yyyy-MM-dd HH:mm:ss";
        string jsonstr = JsonConvert.SerializeObject(Ds, iso);

        //JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
        //string jsonstr = javaScriptSerializer.Serialize(Ds);

        context.Response.Write(jsonstr);
    }

    /// <summary>
    /// 看板按产线查询，各设备采集数据的产线名应相同，以PIS为准查询对比
    /// </summary>
    /// <param name="context"></param>
    private void GetCommonProductLine(HttpContext context)
    {
        DataTable Dt = Common.DAL.GetPISProductlLine();

       
        context.Response.Write(Dt.ToJson("yyyy-MM-dd HH:mm:ss", "F2"));
    }

    //获取炉温测试仪采集数据
    private void GetReflowerProfile_Grid(HttpContext context)
    {
        
    }

    private void ExportExcel(HttpContext context)
    {
               
        string line = context.Request["line"];      

        DateTime dtEnd = DateTime.Now, dtStart;
        if (!DateTime.TryParse(context.Request["StartTime"], out dtStart))
            dtStart = DateTime.Now;
        if (!DateTime.TryParse(context.Request["EndTime"], out dtEnd))
            dtEnd = dtStart;
      
        // dtStart = new DateTime(2016, 2, 2, 22, 22, 22);
       DataTable tbl = Common.DAL.GetAutoSolderData(line, dtStart, dtEnd);
        //EPPlusForExcel.test(context);
        if (line == "" || line == null)
        {
            return;
        }
        EPPlusForExcel.DumpExcel(tbl, line, context);
        //EPPlusForExcel.ExportByEPPlus(tbl, line, context);

    }
    
    private void SaveNetSetting(HttpContext context)
    {
        string data = context.Request["data"];
        //string ip = context.Request["ip"];
        //string port = context.Request["port"];
        //string line = context.Request["line"];
        JavaScriptSerializer js = new JavaScriptSerializer();
        List<NetConfig> listnet = js.Deserialize<List<NetConfig>>(data);

        ILDO ini = new INI();
        ini.LDOPath = "D:\\AutosolderNet\\AutoSolderNetCon.ini";

        StreamWriter sw = new StreamWriter(ini.LDOPath, false);
        sw.WriteLine("");
        sw.Close();
        //using (FileStream fs = new FileStream(ini.LDOPath, FileMode.Create))
        // {
        foreach (NetConfig net in listnet)
              {
                        ini.WriteFun(net.Line, net.Ip, net.Port);
                }

        //}
        // string path =  WindowsService.GetPath("Autosolder");
        //if (path == "")
        //{
        //    context.Response.Write(new JavaScriptSerializer().Serialize("未检测到Autosolder服务存在"));
        //    return;
        //}


        //path = Path.GetDirectoryName(path);
        //string p = Path.GetDirectoryName("D:\\AutosolderNet\\test.ini");

        //AutoSolderBatMain.ExecuteBat(path + "\\AutoSolderReStart.bat");

        

        context.Response.Write(new JavaScriptSerializer().Serialize("success"));
    }
    /// <summary>
    /// 加锡机配置文件产线数据
    /// </summary>
    /// <param name="context"></param>
    private void GetProductLineData(HttpContext context)
    {
        ILDO ini = new INI();
        ini.LDOPath = "D:\\AutosolderNet\\AutoSolderNetCon.ini";
        List<NetConfig> listNet = ini.ReadFun();
        if (listNet == null)
        {
            context.Response.Write("空的数据");
            return;
        }
        DataTable tb = new DataTable();
        
        //config
        tb.Columns.Add("ip", typeof(string));
        tb.Columns.Add("port", typeof(string));
        tb.Columns.Add("line", typeof(string));
        
        //DB
        tb.Columns.Add("timepoint", typeof(string));
        tb.Columns.Add("temperature", typeof(string));
        tb.Columns.Add("humidity", typeof(string));
        tb.Columns.Add("remain", typeof(string));
        tb.Columns.Add("used", typeof(string));

        List<string> listLine = new List<string>();
        foreach (NetConfig netc in listNet)
        {
            listLine.Add(netc.Line);
        }
        List<DataTable> listDt = Common.DAL.GetAutoSolderCurrentData(listLine);


        for (int i = 0; i < listNet.Count; i++)
        {
            if (listDt[i] == null)
            {
                tb.Rows.Add(listNet[i].Ip, listNet[i].Port, listNet[i].Line, "", "", "");
            }
            else
            {
                if (listDt[i].Rows.Count == 0)
                {
                    tb.Rows.Add(listNet[i].Ip, listNet[i].Port, listNet[i].Line, "", "", "");
                }
                else
                {
                    tb.Rows.Add(listNet[i].Ip, listNet[i].Port, listNet[i].Line, listDt[i].Rows[0]["TimePoint"], listDt[i].Rows[0]["Temperature"], listDt[i].Rows[0]["Humidity"], listDt[i].Rows[0]["RemainSolderPercent"], listDt[i].Rows[0]["UsedSolderNum"]);
                }
            }
            
           
           
        }

        context.Response.Write(new LigerGridRows(tb, "yyyy-MM-dd HH:mm:ss", "F2").ToJson());

        
    }

   
    private void GetPISData(HttpContext context)
    {
        long nStationID = -1;
        string sStationID=context.Request["StationID"];
        if (!string.IsNullOrEmpty(sStationID))
            nStationID = Cvt.ToInt64(sStationID);

        DateTime dtStart = DateTime.Now, dtEnd = dtStart;
        if (!DateTime.TryParse(context.Request["StartTime"], out dtStart))
            dtStart = DateTime.Now;
        if(! DateTime.TryParse(context.Request["EndTime"],out dtEnd) )
            dtEnd = dtStart;

        DataTable tbl = Common.DAL.GetPISData(nStationID, dtStart, dtEnd);
        context.Response.Write(new LigerGridRows(tbl, "yyyy-MM-dd HH:mm:ss", "F2").ToJson());
        
    }

    private void GetAutoSolderData(HttpContext context)
    {
        string page = context.Request["Page"];
        string pagesize = context.Request["PageSize"];
        int pageN = 1, pagesizeN = 100;
        if (!int.TryParse(page, out pageN))
            pageN = 1;
        if (!int.TryParse(pagesize, out pagesizeN))
            pagesizeN = 100;

       // long nStationID = -1;
        string line = context.Request["line"];
        

        DateTime dtEnd = DateTime.Now, dtStart;
        if (!DateTime.TryParse(context.Request["StartTime"], out dtStart))
            dtStart = DateTime.Now;
        if (!DateTime.TryParse(context.Request["EndTime"], out dtEnd))
            dtEnd = dtStart;

       // dtStart = new DateTime(2016, 2, 2, 22, 22, 22);
       //DataTable tbl = Common.DAL.GetAutoSolderData(line, dtStart, dtEnd);

        //分页查询
        DataTable tbl = Common.DAL.GetAutoSolderDataUsePage(line, dtStart, dtEnd, (pageN * pagesizeN - pagesizeN).ToString(), pagesize);
        //查询total
        //long total = Common.DAL.GetAutoSolderDataTotalNum(line);
        long total = Common.DAL.GetAutoSolderDataTimeToTimeNum(line, dtStart, dtEnd);
        if (tbl == null || tbl.Rows.Count == 0)
        {
            context.Response.Write("未查询到该数据");
            return;
        }
        LigerGridRows lg = new LigerGridRows(tbl, "yyyy-MM-dd HH:mm:ss", "F2");
        //lg.Total = total;
        context.Response.Write(lg.ToJson());
           
    }
    private void GetAutoSolderData_Grid(HttpContext context)
    {
        string page = context.Request["Page"];
        string pagesize = context.Request["PageSize"];
        int pageN = 1, pagesizeN = 100;
        if (!int.TryParse(page, out pageN))
            pageN = 1;
        if (!int.TryParse(pagesize, out pagesizeN))
            pagesizeN = 100;

        // long nStationID = -1;
        string line = context.Request["line"];

        //line = "line50";
        DateTime dtEnd = DateTime.Now, dtStart;
        if (!DateTime.TryParse(context.Request["StartTime"], out dtStart))
            dtStart = DateTime.Now;
        if (!DateTime.TryParse(context.Request["EndTime"], out dtEnd))
            dtEnd = dtStart;

        //dtStart = new DateTime(2017, 2, 2, 12, 12, 12);
        //分页查询
        DataTable tbl = Common.DAL.GetAutoSolderDataUsePage(line, dtStart, dtEnd, (pageN * pagesizeN - pagesizeN).ToString(), pagesize);
        //查询total
        //long total = Common.DAL.GetAutoSolderDataTotalNum(line);
        long total = Common.DAL.GetAutoSolderDataTimeToTimeNum(line, dtStart, dtEnd);
        if (tbl == null || tbl.Rows.Count == 0)
        {
            context.Response.Write("未查询到该数据");
            return;
        }
        LigerGridRows lg = new LigerGridRows(tbl, "yyyy-MM-dd HH:mm:ss", "F2");
        //lg.Total = total;
        
        var gridData = new {Rows = lg.Rows, Total = total };

        string result = new JavaScriptSerializer().Serialize(gridData);


       // context.Response.Write(lg.ToJson());
        context.Response.Write(result);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}