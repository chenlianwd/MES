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
        
        var sPath = context.Request.PhysicalApplicationPath + @"config\CreateTablesProc.sql";
        string json = ParseToJson(context);
        PostRecipeDataClass responseobj = JsonConvert.DeserializeObject<PostRecipeDataClass>(json);       
        Image Img = Common.Base64StringToImage(responseobj.ImgData);
        if (responseobj.BaseProfileDS.ProLine == "" || responseobj.BaseProfileDS.ProName == "" || responseobj.BaseProfileDS.BaseName == "")
        {
            context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success", ErrorMsg = "BaseProfileDS参数Proline、ProName、BaseName不能为空"}));
        }
        var path = context.Request.PhysicalApplicationPath + @"upload\RecipeProfiles\" + responseobj.BaseProfileDS.ProLine + @"\" + responseobj.BaseProfileDS.ProName + @"\";
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        string fileName = path + responseobj.BaseProfileDS.BaseName + ".png";
       
        Img.Save(fileName);
              
        //File.WriteAllText("D://test.txt", responseobj.StartTime.ToString());
        bool result = Common.DAL.InsertRecipeCollectProfile(responseobj.BaseProfileDS, responseobj.RecipeName, responseobj.StartTime, sPath);
        if (result == false)
        {
            context.Response.Write(new JavaScriptSerializer().Serialize(new tagErrMsg("插入数据失败")));
        }
        else
        {
            context.Response.Write(JsonConvert.SerializeObject(new { StatusCode = "success" }));
        }
       


        
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
        public BaseProfileDS BaseProfileDS { get; set; }

    }

    
}