
using System;
using System.Web;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System.Drawing;

public class FileDownload : IHttpHandler
{
    /// <summary>        
    ///功能说明：文件下载类--不管是什么格式的文件,都能够弹出打开/保存窗口,
    ///包括使用下载工具下载
    ///继承于IHttpHandler接口，可以用来自定义HTTP 处理程序同步处理HTTP的请求
    /// </summary>
    /// <param name="context"></param>

    public static readonly System.Reflection.Missing vtMissing = System.Reflection.Missing.Value;
    public void ProcessRequest(HttpContext context)
    {
        HttpResponse Response = context.Response;
        HttpRequest Request = context.Request;
        System.IO.Stream iStream = null;
        byte[] buffer = new Byte[10240];
        int length;
        long dataToRead;
        System.Data.OleDb.OleDbConnection dbConnection = null;
        string sFileName = Request["fn"];
        string sFilePath = HttpContext.Current.Server.MapPath("~/") + sFileName; //待下载的文件路径        
        try
        {
            if (sFileName != null)//按文件名下载指定文件
            {
                iStream = new System.IO.FileStream(sFilePath, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read);
            }
            else//下载debug报表
            {
                ExcelPackage pck = new ExcelPackage();
                BuildExcelReport(ref pck, ref dbConnection, ref context, ref  sFileName);
                iStream = new System.IO.MemoryStream(pck.GetAsByteArray());
            }

            Response.Clear();
            dataToRead = iStream.Length;
            long p = 0;
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
            Response.ContentType = "application/octet-stream";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode(
                System.Text.Encoding.GetEncoding(65001).GetBytes(System.IO.Path.GetFileName(sFileName))));
            iStream.Position = p;
            dataToRead = dataToRead - p;
            while (dataToRead > 0)
            {
                if (Response.IsClientConnected)
                {
                    length = iStream.Read(buffer, 0, 10240);
                    Response.OutputStream.Write(buffer, 0, length);
                    Response.Flush();
                    buffer = new Byte[10240];
                    dataToRead = dataToRead - length;
                }
                else
                {
                    dataToRead = -1;
                }
            }
            //Response.End();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            Response.Write("Error : " + context.Server.HtmlEncode(ex.Message));
            string sHtml = "<script type=\"text/javascript\">"
                + "if(parent.lblError) parent.lblError.innerHTML=unescape(\"" + Microsoft.JScript.GlobalObject.escape(ex.Message.Replace("\n", "<br>")) + "\");"
                + "</script>";
            Response.Write(sHtml);
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
    private static void BuildExcelReport(ref ExcelPackage pck, ref System.Data.OleDb.OleDbConnection dbConnection, ref HttpContext context, ref string sFileName)
    {
        DateTime dtEnd = new DateTime(), dtStart = new DateTime();
        System.Data.DataSet dataSetFPY = null;
        sFileName = "DebugReport_" + dtStart.ToString("yyyy-MM-dd_HH.mm.ss") + "_To_" + dtEnd.ToString("yyyy-MM-dd_HH.mm.ss") + ".xlsx";
   
        var ws = pck.Workbook.Worksheets.Add("DebugSummary");
        int nRow = 1;
        ws.Cells[nRow, 1].Value = "Failed_Station";
        //ws.Cells[nRow, 2].Value = "PartNumber";
        ws.Cells[nRow, 2].Value = "Defect Description";
        ws.Cells[nRow, 3].Value = "ReworkActionCode";
        //ws.Cells[nRow, 4].Value = "Location";
        ws.Cells[nRow, 4].Value = "FailedQty";
        ws.Cells[nRow, 5].Value = "TestedQty";
        ws.Cells[nRow, 6].Value = "Rate";
        using (var range = ws.Cells[1, 1, 1, 6])
        {
            range.Style.Font.Bold = true;
            range.Style.Font.Size = 9;
            range.Style.Fill.PatternType = ExcelFillStyle.Solid;
            range.Style.Fill.BackgroundColor.SetColor(Color.DarkGray);
        }

        foreach (System.Data.DataRow Row in dataSetFPY.Tables[1].Rows)
        {
            nRow++;
            ws.Cells[nRow, 1].Value = Row["Failed_Station"];
            //ws.Cells[nRow, 2].Value = Row["PartNumber"];
            if (Row["DefectDescription"] != System.DBNull.Value) ws.Cells[nRow, 2].Value = Row["DefectDescription"];
            if (Row["ReworkActionCode"] != System.DBNull.Value) ws.Cells[nRow, 3].Value = Row["ReworkActionCode"];
            //if (Row["Location"] != System.DBNull.Value) ws.Cells[nRow, 4].Value = Row["Location"];
            ws.Cells[nRow, 4].Value = Row["FailedQty"];
            ws.Cells[nRow, 5].Value = Row["TestedQty"];
            ws.Cells[nRow, 6].Value = Row["Rate"];          
        }
        using (var range = ws.Cells[2, 1, nRow, 7])
        {
            range.Style.Font.Size = 9;
        }
        using (var range = ws.Cells[2, 6, nRow, 6])
        {
            range.Style.Numberformat.Format = "0.00%";  
        }


        ws = pck.Workbook.Worksheets.Add("DebugReport");
        nRow = 1;
        ws.Cells[nRow, 1].Value = "Debug_Date";
        ws.Cells[nRow, 2].Value = "Station";
        ws.Cells[nRow, 3].Value = "TestFailedTime";
        ws.Cells[nRow, 4].Value = "PartNumber";
        ws.Cells[nRow, 5].Value = "PCBA_SN";
        ws.Cells[nRow, 6].Value = "FG_SN";
        ws.Cells[nRow, 7].Value = "DefectCode";
        ws.Cells[nRow, 8].Value = "DefectDescription";
        ws.Cells[nRow, 9].Value = "ReworkAction";
        ws.Cells[nRow, 10].Value = "Location";
        ws.Cells[nRow, 11].Value = "Debug_Comment";
        ws.Cells[nRow, 12].Value = "Debug_User";
        ws.Cells[nRow, 13].Value = "DebugTime";
        ws.Cells[nRow, 14].Value = "LastStatus";
        using (var range = ws.Cells[1, 1, 1, 14])
        {
            range.Style.Font.Bold = true;
            range.Style.Font.Size = 9;
            range.Style.Fill.PatternType = ExcelFillStyle.Solid;
            range.Style.Fill.BackgroundColor.SetColor(Color.DarkGray);
        }

        foreach (System.Data.DataRow Row in dataSetFPY.Tables[0].Rows)
        {
            nRow++;
            ws.Cells[nRow, 1].Value = Row["TheDate"];
            ws.Cells[nRow, 2].Value = Row["Station"];
            ws.Cells[nRow, 3].Value = Row["TestFailedTime"];
            ws.Cells[nRow, 4].Value = Row["PartNumber"];
            ws.Cells[nRow, 5].Value = Row["PCBA_SN"];
            if (Row["FG_SN"] != System.DBNull.Value) ws.Cells[nRow, 6].Value = Row["FG_SN"];
            if (Row["DefectCode"] != System.DBNull.Value) ws.Cells[nRow, 7].Value = Row["DefectCode"];
            if (Row["DefectDescription"] != System.DBNull.Value) ws.Cells[nRow, 8].Value = Row["DefectDescription"];
            if (Row["ReworkAction"] != System.DBNull.Value) ws.Cells[nRow, 9].Value = Row["ReworkAction"];
            if (Row["Location"] != System.DBNull.Value) ws.Cells[nRow, 10].Value = Row["Location"];
            if (Row["Comment"] != System.DBNull.Value) ws.Cells[nRow, 11].Value = Row["Comment"];
            if (Row["User"] != System.DBNull.Value) ws.Cells[nRow, 12].Value = Row["User"];
            if (Row["DebugTime"] != System.DBNull.Value) ws.Cells[nRow, 13].Value = Convert.ToDateTime(Row["DebugTime"]).ToString("yyyy-MM-dd HH:mm:ss");
            ws.Cells[nRow, 14].Value = Row["CurrentStatus"];
        }
        using (var range = ws.Cells[2, 1, nRow, 14])
        {
            range.Style.Font.Size = 9;
        }
        ws.Cells[1, 1, nRow, 14].AutoFilter = true;          
         
    }
}