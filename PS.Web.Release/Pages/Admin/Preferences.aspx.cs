using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PS;

public partial class Preferences : AdminBasePage
{
    protected LanguageHelper LangHelper = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        //查看是否有用户级语言辅助器，没有则用公共的
        LangHelper = FetchData.GetLanguageHelper(Session);

        if (IsPostBack)
            f_Submit();


        Dictionary<string, string> langLst = Common.LanguageHelper.GetLanguageList();

        Common.Language = Common.readConfig("Default_Language", "chs");
        edtHomgePageTitle.Text = Common.readConfig("Home_Page_Title", "Dashboard");
        imgLogo.ImageUrl = Common.readConfig("Logo_Picture", "../images/logo-white-no-back.png");
        chkMustLogin.Checked = Cvt.ToBoolean(Common.readConfig("Must_Login", "false"));

        string sDBType = Common.readConfig("DAL_Assembly", "DAL_SqlServer");
        edtDbServer.Text = Common.readConfig("DBServer", "localhost");
        edtPort.Text = Common.readConfig("DBPort", "1433");
        edtUser.Text = Common.readConfig("DBUser", "sa");

        lstLanguage.Items.Clear();
        foreach (KeyValuePair<string, string> itm in langLst)
        {
            ListItem LstItm = new ListItem(itm.Value, itm.Key);
            LstItm.Selected = itm.Key.Equals(Common.Language, StringComparison.OrdinalIgnoreCase);

            lstLanguage.Items.Add(LstItm);
        }

        lstDatabaseType.Items.Clear();
        DALBase[] DalLst = Common.LoadAllSubClass<DALBase>();
        foreach (DALBase dal in DalLst)
        {
            ListItem LstItm = new ListItem(dal.DALName, dal.GetType().Name);
            LstItm.Selected = dal.GetType().Name.Equals(sDBType, StringComparison.OrdinalIgnoreCase);

            lstDatabaseType.Items.Add(LstItm);
        }
        lstDatabaseType.Enabled = false;

        lblLanguage.Text = LangHelper.GetText("Default Language:");
        lblGenericSetting.Text = LangHelper.GetText("Generic Setting:");
        lblHomePageTitle.Text = LangHelper.GetText("Home Page Title:");
        lblMustLogin.Text = LangHelper.GetText("Must Login:");
        lblHomePageLogo.Text = LangHelper.GetText("Home Page Logo:");
        lblDatabaseSetting.Text = LangHelper.GetText("Database:");
        lblDatabaseType.Text = LangHelper.GetText("Type:");
        lblDbServer.Text = LangHelper.GetText("Server:");
        lblPort.Text = LangHelper.GetText("Port:");
        lblUser.Text = LangHelper.GetText("User:");
        lblPwd.Text = LangHelper.GetText("Password:");
        lblDatabase.Text = LangHelper.GetText("Database:");
        btnInitDatabase.Text = LangHelper.GetText("Create Tables For Init Database");
        btnTestConnection.Text = LangHelper.GetText("Test Connection");
        btnSubmit.Text = LangHelper.GetText("Submit");
    }

    protected void f_Submit()
    {
        string sLang = Request["hdnLstLanguage"];
        string sDbType = Request["hdnLstDatabaseType"];
        string sChkMustLogin = Request["hdbMustLogin"];
        Common.writeConfig("Default_Language", sLang);
        Common.writeConfig("Home_Page_Title", edtHomgePageTitle.Text);
        Common.writeConfig("Logo_Picture", imgLogo.ImageUrl);
        Common.writeConfig("Must_Login", sChkMustLogin);

        Common.writeConfig("DAL_Assembly", sDbType);
        Common.writeConfig("DBServer", edtDbServer.Text);
        Common.writeConfig("DBPort", edtPort.Text);
        Common.writeConfig("DBUser", edtUser.Text);

        Common.RenewDAL();
        Common.DAL.Password = edtPwd.Text;
        Common.DAL.RebuidConnectionString();

        Response.Redirect("~/Pages/Login.aspx");
    }
}