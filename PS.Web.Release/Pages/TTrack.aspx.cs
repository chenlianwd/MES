using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_TTrack : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime dtEnd = DateTime.Now;
        string sTime = Request["time"];
        if (!string.IsNullOrEmpty(sTime))
            dtEnd = DateTime.Parse(sTime).AddMinutes(1);

        DateTime dtStart = dtEnd.AddDays(-30);
        //dtEnd.AddHours(-2);
        //

       

        // this.form1.Action = "ClientUpload.ashx";
        //默认接收4M以内的文件 请在web.config里面的<system.web>节点中配置  <httpRuntime maxRequestLength="20480" /> 20480 20M
        var files = Request.Files;
        if (files != null && files.Count > 0)
        {
            for (int i = 0; i < files.Count; i++)
            {
                var strs = files[i].FileName.Split('.');
                var path = Server.MapPath(@"/upload/ReflowerTester File/test/");

                //判断目录是否存在
                if (!Directory.Exists(path))
                {
                    //如果不存在，创建它
                    Directory.CreateDirectory(path);
                }

                //string t = path + Guid.NewGuid().ToString() + "." + strs[1].ToLower();
                string t = path + strs[0] + "." + strs[1].ToLower();
                files[i].SaveAs(t);
                Response.Write("<script>alert('上传成功!');window.location.href='TTrack.aspx'</script>");
            }

        }

    }

    //protected void uploadbtn_Click(object sender, EventArgs e)
    //{
    //    if (this.upload.PostedFile.ContentLength > 104857600) //单位KB
    //    {
    //        //ClientScript.RegisterStartupScript(GetType(), "提示", "alert('You select the file larger than 100MB！')", true);
    //        //ClientScript.RegisterClientScriptBlock(GetType(), "加法", "function add(n1,n2){return n1+n2;}", true);
    //        ClientScript.RegisterStartupScript(GetType(), "message", "<script>alert('You select the file larger than 100MB！！');</script>");
    //        return;
    //    }
    //    //创建一个文件夹
    //    string tempPath = "~/upload/ReflowerTester File/";
    //    //判断目录是否存在
    //    if (!Directory.Exists(Server.MapPath(tempPath)))
    //    {
    //        //如果不存在，创建它
    //        Directory.CreateDirectory(Server.MapPath(tempPath));
    //    }

    //    //取得所选文件的本地路径
    //    string pathFile = this.upload.PostedFile.FileName;
    //    //从路径中截取文件名
    //    string fileName = pathFile.Substring(pathFile.LastIndexOf(@"\") + 1);
    //    //取得文件的扩展名
    //    string fileExtension = pathFile.Substring(pathFile.LastIndexOf(".") + 1);

    //    //限定上传文件的格式
    //    string type = fileExtension;
    //    if (type == "doc" || type == "docx" || type == "xls" || type == "xlsx" || type == "ppt" || type == "pptx" || type == "pdf" || type == "jpg" || type == "bmp" || type == "gif" || type == "png" || type == "txt" || type == "zip" || type == "rar")
    //    {
    //        //将文件保存在服务器中根目录下的files文件夹中
    //        string saveFileName = Server.MapPath(@"/upload/ReflowerTester File/") + fileName;
    //        upload.PostedFile.SaveAs(saveFileName);
    //        ClientScript.RegisterStartupScript(GetType(), "message", "<script>alert('文件上传成功！');</script>");

    //        ////向数据库中存储相应通知的附件的目录
    //        //BLL.news.InsertAnnexBLL insertAnnex = new BLL.news.InsertAnnexBLL();
    //        //AnnexEntity annex = new AnnexEntity();     //创建附件的实体
    //        //annex.AnnexName = fileName;               //附件名
    //        //annex.AnnexContent = saveFileName;        //附件的存储路径
    //        //annex.NoticeId = noticeId;              //附件所属“通知”的ID在这里为已知
    //        //insertAnnex.InsertAnnex(annex);         //将实体存入数据库（其实就是讲实体的这些属性insert到数据库中的过程，具体BLL层和DAL层的代码这里不再多说）
    //    }
    //    else
    //    {
    //        //Page.ClientScript.RegisterStartupScript(Page.GetType(), "message", @" alert('请选择正确的格式')");
    //        ClientScript.RegisterStartupScript(GetType(), "message", "<script>alert('请选择正确的格式！');</script>");
    //    }
    //}
}