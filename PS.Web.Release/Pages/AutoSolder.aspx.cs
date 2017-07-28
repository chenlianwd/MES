using PS;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_AutoSolder : System.Web.UI.Page
{
    protected LanguageHelper LangHelper = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        //查看是否有用户级语言辅助器，没有则用公共的
        LangHelper = FetchData.GetLanguageHelper(Session);
    }

    protected void settingbtn1_Click(object sender, EventArgs e)
    {

    }
}