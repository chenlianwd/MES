using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Security.Cryptography;
using System.Configuration;
using System.Runtime.InteropServices;
using System.IO;
using System.Web.Script.Serialization;
using System.Text.RegularExpressions;


using PS;
public partial class fileUpload : AdminBasePage
{
    enum UploadPurpose
    {
        LogoOfHome = 1
    , LogoOfProject = 2
        , DocumentOfPart = 3
    , PictureOfAction = 4
    , AudioOfAction = 5
        , VideoOfAction = 6
    }


    /// <summary>
    /// 取得网站的根目录的URL
    /// </summary>
    /// <param name="Req"></param>
    /// <returns></returns>
    public static string GetRootURI(HttpRequest Req)
    {
        string AppPath = "";
        if (Req != null)
        {
            string UrlAuthority = Req.Url.GetLeftPart(UriPartial.Authority);
            if (Req.ApplicationPath == null || Req.ApplicationPath == "/")
                //直接安装在 Web 站点 
                AppPath = UrlAuthority;
            else
                //安装在虚拟子目录下 
                AppPath = UrlAuthority + Req.ApplicationPath;
        }
        return AppPath;
    }

    /// <summary>
    /// 取得网站根目录的物理路径
    /// </summary>
    /// <returns></returns>
    public static string GetRootPath()
    {
        string AppPath = "";
        HttpContext HttpCurrent = HttpContext.Current;
        if (HttpCurrent != null)
        {
            AppPath = HttpCurrent.Server.MapPath("~");
        }
        else
        {
            AppPath = AppDomain.CurrentDomain.BaseDirectory;
            if (Regex.Match(AppPath, @"\\$", RegexOptions.Compiled).Success)
                AppPath = AppPath.Substring(0, AppPath.Length - 1);
        }
        return AppPath;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string sNewFileName = "",sRootPath="";
        string g_sPurpose = ""; int g_nStatus = 2;string g_sErrMsg = ""; long g_nObjectID = 0, g_nFileID = 0;string g_sNewFileUrl="";
        int nPos = -1;
        try
        {
            g_sPurpose = Request["Purpose"];
            if (g_sPurpose == null)
                g_sPurpose = "";

            if (string.IsNullOrEmpty(Purpose.Value))
                Purpose.Value = g_sPurpose;

            if (fileUploadArea.HasFile)
            {              
                UploadPurpose nPurpose = (UploadPurpose)Enum.Parse(typeof(UploadPurpose), g_sPurpose, true); ;

                sRootPath =Request.PhysicalApplicationPath;
                DateTime dtNow = DateTime.Now;

                string path = string.Format(@"{0}\Upload\{1}\{2}", sRootPath, nPurpose, dtNow.ToString(@"yyyy\\MM\\dd\\"));
                nPos = 0;
                while ((nPos = path.IndexOf('\\', nPos+1)) != -1)
                {
                    if (!Directory.Exists(path.Substring(0, nPos)))
                        Directory.CreateDirectory(path.Substring(0, nPos));
                }

                string sFileName = fileUploadArea.FileName;
                sNewFileName = path + sFileName;
                string sFileNameWithoutExtension = Path.GetFileNameWithoutExtension(sFileName);
                string sFileExtension = Path.GetExtension(sFileName);
                int nCount = 1;
                while (File.Exists(sNewFileName))
                {
                    sNewFileName = path + sFileNameWithoutExtension + "(" + nCount + ")" + sFileExtension;
                    nCount++;
                }

                fileUploadArea.SaveAs(sNewFileName);

                g_sNewFileUrl = sNewFileName.Substring(sRootPath.Length+1).Replace('\\', '/');

                g_nStatus = 1;
            }
        }
        catch (Exception excep)
        {
            g_sErrMsg = excep.Message;
        }
        finally
        {

            try
            {
                //System.Threading.Thread.Sleep(1000);
                if (g_sErrMsg != "" && sNewFileName != "")
                    System.IO.File.Delete(sNewFileName);
            }
            catch (Exception excep)
            {
                g_sErrMsg += excep.Message;
            }
        }
        if (g_sErrMsg.Length > 0)
            g_nStatus = 0;

        Response.Write("<script language='javascript' type='text/javascript'>\n"
            + "var g_sPurpose=\"" + g_sPurpose.escape() + "\";\n"
            + "var g_nStatus=" + g_nStatus + ";\n"
            + "var g_sErrMsg=\"" + g_sErrMsg.escape() + "\";\n"
            + "var g_nObjectID=" + g_nObjectID + ";\n"
            + "var g_nFileID=" + g_nFileID + ";\n"
            + "var g_sNewFileUrl=\"" + HttpUtility.UrlEncode(g_sNewFileUrl) + "\";\n"
            + "</script>"
        );
    }
}
