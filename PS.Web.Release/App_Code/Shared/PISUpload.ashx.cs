using PS;
using PS.Reflow.Codes;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

/// <summary>
/// PISUpload 的摘要说明
/// </summary>
public class PISUpload : IHttpHandler, IRequiresSessionState
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
        context.Response.ContentType = "application/json";
        string sFun = context.Request["fn"];
        try
        {
           
            switch (sFun)
            {
                case "AddRecipeCollectProfile":
                    AddRecipeCollectProfile(context);
                    break;
                case "AddActualProfile":
                    AddActualProfile(context);
                    break;
                case "AddEventProfile":
                    AddEventProfile(context);
                    break;
                case "UpdateRTMonitorData":
                    UpdateRTMonitorData(context);
                    break;
              
            }
            #region before


            /*
                       PISModel PisModel = new PISModel();
                       PisModel.ProLine = context.Request["ProLine"];
                       PisModel.SN = context.Request["SN"];
                       PisModel.Model = context.Request["Model"];
                       PisModel.StartTime = Convert.ToDateTime(context.Request["StartTime"]);
                       PisModel.EndTime = Convert.ToDateTime(context.Request["EndTime"]);
                       PisModel.Flag = context.Request["Flag"];
                       PisModel.CPK = Convert.ToDouble(context.Request["CPK"]);
                       PisModel.Result = context.Request["Result"];
                       PisModel.DateNo = Convert.ToDateTime(context.Request["DateNo"]);
                       PisModel.HourNo = Convert.ToDateTime(context.Request["HourNo"]);
                       PisModel.LineNo = context.Request["LineNo"];
                       PisModel.TheSN = context.Request["TheSN"];
                       PisModel.PISFileName = context.Request["PISFileName"];

                       StringBuilder pisFileName = new StringBuilder(context.Request["PISFileName"]);
                       StringBuilder proLine = new StringBuilder(context.Request["ProLine"]);
                       foreach (char rInvaildChar in Path.GetInvalidFileNameChars())
                       {
                           pisFileName.Replace(rInvaildChar.ToString(), string.Empty);
                           proLine.Replace(rInvaildChar.ToString(), string.Empty);
                       }
                       PisModel.ProLine = proLine.ToString();
                       PisModel.PISFileName = pisFileName.ToString();          
                       long row = 0;
                       bool f = Common.DAL.InsertPISData(PisModel, out row);            
                       if (!f)
                       {
                           context.Response.Write(new JavaScriptSerializer().Serialize(new { StatusCode = "fail on insert data" }));
                           return;
                       }
                       var files = context.Request.Files;

                       var strs = files[0].FileName.Split('.');
                       var path = context.Request.PhysicalApplicationPath + @"upload/pispdfinfo/" + PisModel.ProLine + @"/";
                       if (!Directory.Exists(path))
                       {
                           Directory.CreateDirectory(path);
                       }
                       string fileName = path + row + "." + strs[1].ToLower();
                       files[0].SaveAs(fileName);
                       context.Response.Write(new JavaScriptSerializer().Serialize(new { StatusCode = "success" }));
            */
            #endregion

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

    private void UpdateRTMonitorData(HttpContext context)
    {
        throw new NotImplementedException();
    }

    private void AddEventProfile(HttpContext context)
    {
        throw new NotImplementedException();
    }

    private void AddActualProfile(HttpContext context)
    {
        throw new NotImplementedException();
    }

    private void AddRecipeCollectProfile(HttpContext context)
    {
        
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    
}