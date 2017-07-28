using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Configuration;
using System.Data;
using System.Data.OleDb;
using System.Globalization;
using System.Drawing;


public partial class PisDetail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        DateTime dtEnd = DateTime.Now;
        string sTime = Request["time"];
        if(!string.IsNullOrEmpty(sTime))
            dtEnd = DateTime.Parse(sTime).AddMinutes(1);

        DateTime dtStart=dtEnd.AddDays(-60);

        edtStartTime.Text = dtStart.ToString("yyyy-MM-dd HH:mm");
        edtEndTime.Text = dtEnd.ToString("yyyy-MM-dd HH:mm");
        edtStation.Text = Request["name"];
    }
}
