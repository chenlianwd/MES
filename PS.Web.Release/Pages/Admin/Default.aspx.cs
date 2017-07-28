using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PS;

public partial class AdminHomePage : AdminBasePage
{
    protected LanguageHelper LangHelper = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        //查看是否有用户级语言辅助器，没有则用公共的
        LangHelper = FetchData.GetLanguageHelper(Session);


        return;
    }
}