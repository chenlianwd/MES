
using System;
using System.Web;
using System.Drawing;
using Microsoft.JScript;
using System.Web.SessionState;
using System.Diagnostics;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Net;

using PS;

public class getFile : IHttpHandler, IRequiresSessionState
{
    /// <summary>        
    ///功能说明：文件下载类--不管是什么格式的文件,都能够弹出打开/保存窗口,
    ///包括使用下载工具下载
    ///继承于IHttpHandler接口，可以用来自定义HTTP 处理程序同步处理HTTP的请求
    /// </summary>
    /// <param name="context"></param>

    public static readonly System.Reflection.Missing vtMissing = System.Reflection.Missing.Value;

    private string RunNetUse(string sArguments)
    {
        Process proc = new Process();
        proc.StartInfo.FileName = "net";
        proc.StartInfo.Arguments = sArguments;
        proc.StartInfo.UseShellExecute = false;
        proc.StartInfo.RedirectStandardInput = true;
        proc.StartInfo.RedirectStandardOutput = true;
        proc.StartInfo.RedirectStandardError = true;
        proc.StartInfo.CreateNoWindow = true;
        proc.Start();
        proc.WaitForExit();
        string sErr = proc.StandardError.ReadToEnd();
        sErr = sErr.Trim();
        proc.Close();
        proc.Dispose();

        return sErr.Trim();
    }
    public void ProcessRequest(HttpContext context)
    {
        HttpResponse Response = context.Response;
        HttpRequest Request = context.Request;
        System.IO.Stream iStream = null;
        System.Data.OleDb.OleDbConnection dbConnection = null;
        string sFileName = Request["fn"];
        string sSql = "";
        try
        {
            string sFilePath = HttpContext.Current.Server.MapPath("~/upload/pispdfinfo/"+ sFileName + ".png"); //待下载的文件路径      
            if (sFileName != null)//按文件名下载指定文件
            {
                iStream = new System.IO.FileStream(sFilePath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
                if (!string.IsNullOrEmpty(context.Request["tb"]))
                {
                    System.Drawing.Image img = System.Drawing.Image.FromStream(iStream);
                    img = img.GetThumbnailImage(200, (int)(img.Height / (img.Width / 200.0)), delegate () { return false; }, IntPtr.Zero);
                    iStream = new MemoryStream();
                    img.Save(iStream, System.Drawing.Imaging.ImageFormat.Png);

                }

                sFileName = System.IO.Path.GetFileName(sFileName);
                Response.AddHeader("Content-Disposition", "filename=" + System.Web.HttpUtility.UrlEncode(System.Text.Encoding.GetEncoding(65001).GetBytes(sFileName)));
                sFileName = System.IO.Path.GetExtension(sFileName);
                string mimeType = Microsoft.Win32.Registry.GetValue(@"HKEY_CLASSES_ROOT\" + sFileName, "Content Type", null) as string;
                Response.ContentType = mimeType;
            }
            else
            {
                //using (SqlConnection dbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SqlServer"].ConnectionString))
                {
                    string sPisID = context.Request["pis"];
                    if (!string.IsNullOrEmpty(sPisID))
                    {
                        sFileName = "PisChart" + sPisID;
                        sSql = "SELECT * FROM pispdf WHERE boardid=" + sPisID;
                    }
                    else
                    {
                        string sSN = context.Request["sn"];
                        sSN = string.IsNullOrEmpty(sSN) ? "NULL" : "'" + sSN.Replace("'", "''") + "'";
                        sSql = string.Format("EXEC usp_Get_Profile @Line='{0}',@StartTime='{1}',@SN={2}", context.Request["line"], context.Request["time"], sSN);
                    }

                    //DataSet dataSet = new DataSet();
                    DataSet dataSet = Common.DAL.ExecuteDataSet(sSql);
                    //dbConn.Open();
                    //SqlDataAdapter adp = new SqlDataAdapter(sSql, dbConn);
                    //adp.Fill(dataSet);

                    DataRow row = null;
                    if (dataSet.Tables.Count > 1 && dataSet.Tables[1].Rows.Count > 0)
                        row = dataSet.Tables[1].Rows[0];
                    else if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                        row = dataSet.Tables[0].Rows[0];

                    if (row != null)
                    {
                        if (!string.IsNullOrEmpty(context.Request["tb"]))
                        {
                            byte[] theBytes = (byte[])row["pdfinfo"];
                            if (theBytes == null)
                                throw new Exception("Can't get bytes form field !");

                            System.IO.MemoryStream mStream = new System.IO.MemoryStream(theBytes);
                            if (mStream == null)
                                throw new Exception("mStream Is NULL !");
                            mStream.Seek(0, SeekOrigin.Begin);

                            System.Drawing.Image img = System.Drawing.Image.FromStream(mStream);
                            img = img.GetThumbnailImage(200, (int)(img.Height / (img.Width / 200.0)), delegate() { return false; }, IntPtr.Zero);
                            iStream = new MemoryStream();
                            img.Save(iStream, System.Drawing.Imaging.ImageFormat.Png);
                        }
                        else if (!string.IsNullOrEmpty(context.Request["tm"]))
                        {
                            System.Drawing.Image img = System.Drawing.Image.FromStream(new System.IO.MemoryStream((byte[])row["pdfinfo"]));
                            img = img.GetThumbnailImage(1150, (int)(img.Height / (img.Width / 1150.0)), delegate() { return false; }, IntPtr.Zero);
                            iStream = new MemoryStream();
                            img.Save(iStream, System.Drawing.Imaging.ImageFormat.Png);
                        }
                        else
                            iStream = new MemoryStream((byte[])row["pdfinfo"]);

                        Response.ContentType = "image/png";
                        sFileName = Path.GetFileNameWithoutExtension(sFileName) + ".png";
                        //Response.ContentType = "application/octet-stream";
                        Response.AddHeader("Content-Disposition",//"attachment;"
                            "filename=" + System.Web.HttpUtility.UrlEncode(
                            System.Text.Encoding.GetEncoding(65001).GetBytes(sFileName)));
                    }
                }
            }

            Response.Clear();

            try
            {
                long p = 0;
                long dataToRead = iStream.Length;
                if (Request.Headers["Range"] != null)
                {
                    Response.StatusCode = 206;
                    p = long.Parse(Request.Headers["Range"].Replace("bytes=", "").Replace("-", ""));
                }
                if (p != 0)
                {
                    Response.AddHeader("Content-Range", "bytes " + p.ToString() + "-" + ((long)(dataToRead - 1)).ToString() + "/" + dataToRead.ToString());
                }
                Response.AddHeader("Content-Length", ((long)(dataToRead - p)).ToString());
                iStream.Position = p;
            }
            catch (Exception ex)
            {
                
            }

            //Response.ContentType = "application/pdf";
            //Response.ContentType = "application/octet-stream";
            //Response.AddHeader("Content-Disposition", "attachment;filename=" + System.Web.HttpUtility.UrlEncode(
            //    System.Text.Encoding.GetEncoding(65001).GetBytes(System.IO.Path.GetFileName(sFileName))));            
            byte[] buffer = new Byte[10240];
            int length = 0;
            while ((length = iStream.Read(buffer, 0, 10240)) > 0)
            {
                if (Response.IsClientConnected)
                {
                    Response.OutputStream.Write(buffer, 0, length);
                    Response.Flush();
                }
            }
            //Response.End();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            Response.ContentType = "text/html";
            Response.Write("<html><body>");
            Response.Write("sSql : " + context.Server.HtmlEncode(sSql));
            Response.Write("<br>Error : " + context.Server.HtmlEncode(ex.Message));
            Response.Write("<br>StackTrace : " + context.Server.HtmlEncode(ex.StackTrace).Replace("\n", "<br>"));
            //生成关闭登录窗口的脚本
            string sHtml = "<script type=\"text/javascript\">"
                + "if(parent.lblError) parent.lblError.innerHTML=unescape(\"" + Microsoft.JScript.GlobalObject.escape(ex.Message.Replace("\n", "<br>"))
                    + Microsoft.JScript.GlobalObject.escape(ex.StackTrace.Replace("\n", "<br>")) + "\");"
                + "</script>";
            Response.Write(sHtml);
            Response.Write("</body></html>");
        }
        finally
        {
            if (iStream != null) iStream.Close();
            if (dbConnection != null) dbConnection.Dispose();
        }
    }
    public bool IsReusable
    {
        get { return true; }
    }
}