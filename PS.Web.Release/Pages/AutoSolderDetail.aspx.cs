
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_AutoSolderDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime dtEnd = DateTime.Now;
        string sTime = Request["time"];
        if (!string.IsNullOrEmpty(sTime))
            dtEnd = DateTime.Parse(sTime).AddMinutes(1);

        DateTime dtStart = dtEnd.AddDays(-30);
            //dtEnd.AddHours(-2);
            //

        edtStartTime.Text = dtStart.ToString("yyyy-MM-dd HH:mm");
        edtEndTime.Text = dtEnd.ToString("yyyy-MM-dd HH:mm");
        edtStation.Text = Request["line"];

        string test = Request["Remain"];
    }

    
    

   
}