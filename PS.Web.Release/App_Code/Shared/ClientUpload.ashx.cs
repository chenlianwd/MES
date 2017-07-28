using PS;
using ReflowerTester;
using ReflowerTester.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using ReflowerTestr;

/// <summary>
/// 客户端post上传数据处理
/// </summary>
public class ClientUpload:IHttpHandler, IRequiresSessionState
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
        ReflowerTesterProfile RTProfile = new ReflowerTesterProfile();
        try
        {            
            RTProfile.Line = context.Request["Line"];
            RTProfile.ReflowerName = context.Request["ReflowerName"];
            RTProfile.ProductName = context.Request["ProductName"];
            RTProfile.StartTime = Convert.ToDateTime(context.Request["StartTime"]);
            RTProfile.EndTime = Convert.ToDateTime(context.Request["EndTime"]);
            RTProfile.TechnologyType = context.Request["TechnologyType"];
            RTProfile.TechnologyName = context.Request["TechnologyName"];
            RTProfile.ProcessName = context.Request["ProcessName"];
            RTProfile.ReflowerTechName = context.Request["ReflowerTechName"];
            RTProfile.SolderName = context.Request["SolderName"];
            //剔除文件名中不合法字符
            StringBuilder rBPtsFileName = new StringBuilder(context.Request["PtsFileName"]);
            StringBuilder rBLine = new StringBuilder(context.Request["Line"]);
            StringBuilder rBProductName = new StringBuilder(context.Request["ProductName"]);
            foreach (char rInvalidChar in Path.GetInvalidFileNameChars())
            {
                rBPtsFileName.Replace(rInvalidChar.ToString(), string.Empty);
                rBLine.Replace(rInvalidChar.ToString(), string.Empty);
                rBProductName.Replace(rInvalidChar.ToString(), string.Empty);
            }
            RTProfile.PtsFileName = rBPtsFileName.ToString();
            RTProfile.Line = rBLine.ToString();
            RTProfile.ProductName = rBProductName.ToString();

            var files = context.Request.Files;
            if (files != null && files.Count > 0)
            {
                for (int i = 0; i < files.Count; i++)
                {
                    var strs = files[i].FileName.Split('.');
                    //var path = Server.MapPath(@"/upload/ReflowerTester File/");
                    var path = context.Request.PhysicalApplicationPath + @"upload/ReflowerTester File/" + RTProfile.Line + @"/" + RTProfile.ProductName + @"/";
                   

                    //判断目录是否存在
                    if (!Directory.Exists(path))
                    {
                        //如果不存在，创建它
                        Directory.CreateDirectory(path);
                    }
                    string fileName = path + RTProfile.PtsFileName + strs[1].ToLower();//Guid.NewGuid().ToString()
                    files[i].SaveAs(fileName);
                    if (strs[1].ToLower() == "pts")
                    {
                        RTProfile.PtsFilePath = fileName;
                    }else if(strs[1].ToLower() == "svg")
                    {
                        RTProfile.ImgPath = fileName;
                    }
                    
                }
                context.Response.Write(new JavaScriptSerializer().Serialize(new { StatusCode = "success", profile = RTProfile }));
            }

            //数据库操作
            RTDBOperation Rtdb = new RTDBOperation();

            context.Response.Write(Rtdb.AddReflowerTesterProfile(RTProfile, "RTHostTable"));

        }
        catch (Exception err)
        {
            string sJson = new JavaScriptSerializer().Serialize(new {ErrorMsg = err.Message, StatusCode = "fail" });          //new tagErrMsg(err.Message)
            context.Response.Write(sJson);
            return;
            
        }
       


    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}