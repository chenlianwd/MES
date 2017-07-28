using System;
using System.Web;

public  partial class  PSWebApplication : System.Web.HttpApplication
{
    bool curIsDebug = true;

    void Application_Start(object sender, EventArgs e)
    {
        // Code that runs on application startup
        //System.Data.Entity.Database.SetInitializer<DLSkillMgtSys.BLL.DLSkillMgtSysContext>(null);
        //System.Data.Entity.Database.SetInitializer<WAH.BLL.WarehouseContext>(null);
    }

    void Application_End(object sender, EventArgs e)
    {
        //  Code that runs on application shutdown

    }

    void Application_Error(Object sender, EventArgs e)
    {
        if (curIsDebug) return;

        Exception ex = Server.GetLastError().GetBaseException();

        string errorTime = "发生时间：" + DateTime.Now.ToString();
        string errorAddress = "发生异常页：" + Request.Url.ToString();
        string errorInfo = "异常信息：" + ex.Message;
        string errorSource = "错误源：" + ex.Source;
        string errorTrace = "堆栈信息：" + ex.StackTrace;
        Server.ClearError();

        System.IO.StreamWriter writer = null;
        try
        {
            lock (this)
            {
                //写入日志 
                string year = DateTime.Now.Year.ToString();
                string month = DateTime.Now.Month.ToString();
                string day = DateTime.Now.Day.ToString();
                string path = string.Empty;
                string filename = DateTime.Now.ToString("yyyyMMdd") + ".txt";
                path = Server.MapPath("~/Error/") + year + month + day;
                if (!System.IO.Directory.Exists(path))
                {
                    System.IO.Directory.CreateDirectory(path);
                }
                System.IO.FileInfo file = new System.IO.FileInfo(String.Format("{0}/{1}", path, filename));
                writer = new System.IO.StreamWriter(file.FullName, true);//文件不在则创建，true表示追加
                writer.WriteLine("用户IP:" + Request.UserHostAddress + ",HostName:" + Request.UserHostName);
                writer.WriteLine(errorTime);
                writer.WriteLine(errorAddress);
                writer.WriteLine(errorInfo);
                writer.WriteLine(errorSource);
                writer.WriteLine(errorTrace);
                writer.WriteLine("-------------------------------------------------------");

            }
        }
        finally
        {
            if (writer != null)
            {
                writer.Close();
            }
        }

    }

    void Session_Start(object sender, EventArgs e)
    {
        // Code that runs when a new session is started

    }

    void Session_End(object sender, EventArgs e)
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

    }
}