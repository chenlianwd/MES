using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using System.Threading;
using System.Collections;
using System.Data;
using System.Data.Common;
using System.Diagnostics;

using PS;


public class LigerGridRows
{
    public ArrayList Rows;
    public long Total;
    public LigerGridRows(DataTable tbl)
    {
        Rows = tbl.ToArrayList("yyyy-MM-dd HH:mm");
    }
    public LigerGridRows(DataTable tbl, string datetimeFormat, string floatFormat)
    {
        Rows = tbl.ToArrayList(datetimeFormat, floatFormat);
    }
    public LigerGridRows(DataTable tbl, string sDatetimeFmt)
    {
        Rows = tbl.ToArrayList(sDatetimeFmt);
    }
    public string ToJson()
    {
        return ToJson(false);
    }
    public string ToJson(bool bFirstIsNA)
    {
        if (bFirstIsNA)
            Rows.Insert(0, new ExDictionary(new KV[] { new KV("_ID", -1), new KV("Name", "N/A") }));

        Total = Rows.Count;
        JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
        //javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
        return javaScriptSerializer.Serialize(this);
    }
    public string ToJson(bool bFirstIsNA, bool bOnlyArray)
    {
        if (!bOnlyArray)
            return ToJson(bFirstIsNA);

        if (bFirstIsNA)
            Rows.Insert(0, new ExDictionary(new KV[] { new KV("_ID", -1), new KV("Name", "N/A") }));

        JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
        //javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
        return javaScriptSerializer.Serialize(Rows);
    }
}

public partial class FetchData : IHttpHandler, IRequiresSessionState
{   
    private static void GetListInJson(HttpContext context, EditableInfo ei)
    {
        bool bForRender = false, bOnlyArray = false;
        if (!string.IsNullOrEmpty(context.Request["time"]))
            bForRender = true;
        if (!string.IsNullOrEmpty(context.Request["oa"]))
            bOnlyArray = true;

        bool bFirstIsNA = false;
        if (!string.IsNullOrEmpty(context.Request["na"]))
            bFirstIsNA = true;

        // bForRender, bOnlyArray, bFirstIsNA

        DataTable tbl = Common.DAL.GetEditableTable(ei,bOnlyArray, "");

        if (bForRender)
            context.Response.Write(ei.JsonVarName + "=");


        context.Response.Write((new LigerGridRows(tbl, "yyyy-MM-dd HH:mm:ss").ToJson(bFirstIsNA,bOnlyArray)));

        if (bForRender)
            context.Response.Write(";");
    }

    public static void TableEdit(HttpContext context)
    {
        string sRequestPurpose = context.Request["rp"];
        string sEditableInfo = context.Request["ei"];
        if (string.IsNullOrEmpty(sRequestPurpose) == false && string.IsNullOrEmpty(sEditableInfo) == false)
        {
            RequestPurpose nRequestPurpose = (RequestPurpose)Enum.Parse(typeof(RequestPurpose), sRequestPurpose, true);
            string[] sEditableList = sEditableInfo.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string sApp in sEditableList)
            {
                foreach (EditableInfo ei in Common.EditableList)
                {
                    if (sApp.Equals(ei.EditableName, StringComparison.OrdinalIgnoreCase))
                    {
                        if (nRequestPurpose == RequestPurpose.Get)
                            GetListInJson(context, ei);//使用公共的查询方法只查询第一个表,否则使用delegateBuildSelectSql自定查询
                        else if (nRequestPurpose == RequestPurpose.Update)
                            UpdateInfo(context, ei);
                    }
                }
            }

        }
    }

    public static void UpdateInfo(HttpContext context, EditableInfo ei)
    {
#if WEB_DEBUG
        EmployeeInfo empInfo = UserMgr.LoadEmployeeInfo("Admin");
#else
        EmployeeInfo empInfo = context.Session["LogonEmployee"] as EmployeeInfo;
        if (empInfo == null)
            throw new Exception("Login session expired!");
#endif
        long nEmployeeID = empInfo._Employee;

        string sJson = context.Request["Changes"];
        if (!string.IsNullOrEmpty(sJson))
        {
            //ArrayList arrayList = sJson.ToArrayList();
            List<Dictionary<string, object>> rows = (new JavaScriptSerializer()).Deserialize<List<Dictionary<string, object>>>(sJson);
            Common.DAL.SubmitEditableChange(empInfo, rows.ToArray(), ei);
        }
    }

    public static LanguageHelper GetLanguageHelper(HttpSessionState Session)
    {
        LanguageHelper langHelper = Session["LanguageHelper"] as LanguageHelper;
        if (langHelper == null)
            langHelper = Common.LanguageHelper;

        return langHelper;
    }


}