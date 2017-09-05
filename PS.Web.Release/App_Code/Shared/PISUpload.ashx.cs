using Newtonsoft.Json;
using PS;
using PS.Reflow.Codes;
using System;
using System.Collections.Generic;
using System.Drawing;
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
        public string StatusCode = "fail";

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
        string json = ParseToJson(context);
        context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success" }));
    }

    private void AddEventProfile(HttpContext context)
    {
        string json = ParseToJson(context);
        context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success" }));
    }

    private void AddActualProfile(HttpContext context)
    {
        string json = ParseToJson(context);
        PostActualDataClass responsobj = JsonConvert.DeserializeObject<PostActualDataClass>(json);
        Image Img = Common.Base64StringToImage(responsobj.ImgData);


        context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success" }));
    }

    private void AddRecipeCollectProfile(HttpContext context)
    {

        string json = ParseToJson(context);
        PostRecipeDataClass responseobj = JsonConvert.DeserializeObject<PostRecipeDataClass>(json);
        Image Img = Common.Base64StringToImage(responseobj.ImgData);

        //测试完毕，数据库操作待写
        var path = context.Request.PhysicalApplicationPath + @"upload/RecipeProfiles/" + responseobj.baseprofile.ProLine + "/" + responseobj.baseprofile.ProName + "/";
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        string fileName = path + responseobj.baseprofile.BaseName + ".png";
        Img.Save(fileName);
        //File.WriteAllText("D://test.txt", responseobj.StartTime.ToString());
        context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success"}));


        //string BaseProfileDSStr =  context.Request["BaseProfileDS"];
        //string RecipeNameStr = context.Request["RecipeName"];

        //DateTime DtStartTime;
        //DateTime.TryParse(context.Request["StartTime"], out DtStartTime);

        //string base64Str = context.Request["ImgData"];

        //BaseProfileDS bpDS = JsonConvert.DeserializeObject<BaseProfileDS>(BaseProfileDSStr);

        ////测试
        //var responsestr = new { BaseProfileDS = BaseProfileDSStr, RecipeName = RecipeNameStr, StartTime = DtStartTime, ImhData = base64Str };

        //context.Response.Write(JsonConvert.SerializeObject(responsestr));
        //存入数据库
    }
    private string ParseToJson(HttpContext context)
    {
        Stream stream = context.Request.InputStream;
        string json;
        if (stream.Length == 0)
        {
            return "";
        }
        StreamReader reader = new StreamReader(stream);
        json = reader.ReadToEnd();

        return json;
    }


    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    private class PostActualDataClass
    {
        public string ImgData { get; set; }
        public RecipeProfileDS recipeprofile { get; set; }
    }
    private class PostRecipeDataClass
    {
        public string RecipeName { get; set; }
        public DateTime StartTime { get; set; }
        public string ImgData { get; set; }
        public BaseProfileDS baseprofile { get; set; }

    }

    
}