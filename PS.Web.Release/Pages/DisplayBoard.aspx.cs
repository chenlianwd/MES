using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Pages_DisplayBoard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime dtEnd = DateTime.Now;
        //默认一天
        DateTime dtStart = dtEnd.AddDays(-1);
        edtStartTime.Text = dtStart.ToString("yyyy-MM-dd HH:mm");
        edtEndTime.Text = dtEnd.ToString("yyyy-MM-dd HH:mm");
    }
}