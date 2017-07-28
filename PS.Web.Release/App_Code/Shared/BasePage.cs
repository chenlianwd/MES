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
public class BasePage:Page
{
    public BasePage()
    {
        //定义所有子类在加载时验证用户是否登录
        Load += new EventHandler(BasePage_Load);
    }

    void BasePage_Load(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(Common.readConfig("DBServer", "")))
        {
            Response.Redirect("~/Pages/Admin/Preferences.aspx");
            return;
        }

        if (Session["LogonEmployee"] == null && BLL.gMust_Login)
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
    }
}
