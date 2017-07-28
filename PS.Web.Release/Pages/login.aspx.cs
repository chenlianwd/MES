using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Web.UI.WebControls;
using System.Drawing;
using System.DirectoryServices;
using System.Security.Cryptography;
using System.Configuration;
using PS;

public partial class loginForm : System.Web.UI.Page
{
    protected LanguageHelper LangHelper = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        //查看是否有用户级语言辅助器，没有则用公共的
        LangHelper = FetchData.GetLanguageHelper(Session);

        lblUser.Text = LangHelper.GetText("User Name:");
        lblPwd.Text = LangHelper.GetText("Password:");
        lblChangePwd.Text = LangHelper.GetText("Change Password");
        lblNewPwd.Text = LangHelper.GetText("New Password:");
        lblConfirmPwd.Text = LangHelper.GetText("Confirm New Password:");
        lblCheckCode.Text = LangHelper.GetText("Verify Code:");
        btnSubmit.Text = LangHelper.GetText("Login");
        imgVerifyCode.ToolTip = LangHelper.GetText("Click For New Picture.");
        imgVerifyCode.AlternateText = LangHelper.GetText("Verify Code");
        btnSubmit.Text = LangHelper.GetText("Login");
        imgVerifyCode.ImageUrl = "FetchData.ashx?fn=VerifyCode&k=" + (new System.Random().Next());

        if (Request["iptUser"] != null)
        {

            string sErrInfo = null;

#if !WEB_DEBUG
            try
            {
                if (string.Equals((string)Session["VerifyCode"], Request["iptCheckCode"], StringComparison.OrdinalIgnoreCase) == false)
                    throw new Exception(LangHelper.GetText("Verify Code Is Incorrect !"));
#endif
                string userName = Request["iptUser"];
                string password = Request["iptPwd"];

                Session["LogonEmployee"] = null;

                bool bChangePwd = Cvt.ToBoolean(Request["bChangePwd"]);
                string sNewPwd = Request["iptNewPwd"];
                string sConfirmPwd = Request["iptConfirmPwd"];
                if ((!bChangePwd) || sNewPwd != sConfirmPwd || string.IsNullOrEmpty(sNewPwd))
                    sNewPwd = "";

                string sStation = "", sFromIP = Request.ServerVariables["HTTP_X_FORWARDED_FOR"], sFromHost = Request.UserHostName, sFromMAC = "";
                if (string.IsNullOrEmpty(sFromIP)) sFromIP = Request.ServerVariables["REMOTE_ADDR"];
                if (string.IsNullOrEmpty(sFromIP)) sFromIP = Request.UserHostAddress;
                if (string.IsNullOrEmpty(sFromHost)) sFromHost = Common.GetHostName(sFromIP);
                sFromMAC = Common.GetCustomerMacByArp(sFromIP);

                EmployeeInfo Employee = UserMgr.CheckLoginAuthenticate(LangHelper, userName, password, sNewPwd, sStation, sFromIP, sFromMAC, sFromHost);

                if (Employee != null)
                {
                    Session["LogonEmployee"] = Employee;
                    //如果父框架有方法f_LoginAuthenticated方法，则调用它
                    string sHtml = "<script type=\"text/javascript\">"
                        //+ "if(parent.LoginDlg) parent.LoginDlg.close();"
                        + "if(parent.f_LoginAuthenticated) parent.f_LoginAuthenticated();"
                        + "</script>";
                    errorInfoLable.Controls.Add(new LiteralControl(sHtml));

                    string sTarget = Request["target"];
                    if (!string.IsNullOrEmpty(sTarget))
                        Response.Redirect(Server.UrlDecode(sTarget));
                };
#if !WEB_DEBUG
            }
            catch (Exception excep)
            {
                sErrInfo = excep.Message;
            }
#endif
            if (sErrInfo != null)
                errorInfoLable.Controls.Add(new LiteralControl(Server.HtmlEncode(sErrInfo)));
        };
    }
}
