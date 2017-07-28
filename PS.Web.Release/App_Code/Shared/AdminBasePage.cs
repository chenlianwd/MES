using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using PS;

/// <summary>
///前台所有需要验证是否登录页面的基类
/// </summary>
public class AdminBasePage : Page
{
    public AdminBasePage()
    {
        //定义所有子类在加载时验证用户是否登录
        Load += new EventHandler(AdminBasePage_Load);
    }

    void AdminBasePage_Load(object sender, EventArgs e)
    {
        //当系统配置没有初始化时，先显示配置参数设定页
        if (string.IsNullOrEmpty(Common.readConfig("DBServer", "")))
        {
            string sPage = this.AppRelativeVirtualPath;
            if( (!sPage.Equals("~/Pages/Admin/Preferences.aspx", StringComparison.OrdinalIgnoreCase))
                && (!sPage.Equals("~/Pages/Admin/fileupload.aspx", StringComparison.OrdinalIgnoreCase))
                )
                Response.Redirect("~/Pages/Admin/Preferences.aspx");
            return;
        }

#if !WEB_DEBUG
        if (Session["LogonEmployee"] == null)
        {
            string target = Request.Url.ToString();

            if (string.IsNullOrEmpty(target))
            {
                Response.Redirect("~/Pages/Login.aspx");
            }
            else
            {
                Response.Redirect("~/Pages/Login.aspx?target=" + Server.UrlEncode(target));
            }
        }
#endif
    }
}
