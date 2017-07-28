using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.DirectoryServices;
using System.Security.Cryptography;
using System.Data;
using System.Threading;
using System.Drawing;
using System.Drawing.Imaging;

using PS;

namespace PS
{    
    public partial class BLL
    {
        private static readonly byte[] rgbIV = { 210, 213, 218, 219, 160, 182, 186, 188 };
        private static readonly byte[] rgbKey = { 156, 159, 133, 132, 146, 147, 158, 162 };

        public static int gMaxLogin_Attempt = 10, gLock_Minutes_After_Max_Login_Attempt = 30;
        public static bool gMust_Login = false;
        public static string gDefault_Language = "chs", gHome_Page_Title = "Dashboard", gLogo_Picture = "images/Logo.png";

        protected static string gLADPUrl = "", gLADPUser = "", gLADPPwd = "";
        private static MailServerType gMailServerType = MailServerType.SMTP;
        private static string gMailServerAddress = "", gMailServerUser = "", gMailServerPassword = "";
        public BLL()
        {
            LoadGolbalConfig();
        }
        public static void LoadGolbalConfig()
        {
            try
            {
                gMaxLogin_Attempt = Cvt.ToInt32(ConfigurationManager.AppSettings["MaxLogin_Attempt"]);
                gLock_Minutes_After_Max_Login_Attempt = Cvt.ToInt32(ConfigurationManager.AppSettings["Lock_Minutes_After_Max_Login_Attempt"]);
                gMust_Login = Cvt.ToBoolean(ConfigurationManager.AppSettings["Must_Login"]);
                gDefault_Language = ConfigurationManager.AppSettings["Default_Language"];
                gHome_Page_Title = ConfigurationManager.AppSettings["Home_Page_Title"];
                gLogo_Picture = ConfigurationManager.AppSettings["Logo_Picture"];

                gLADPUrl = ConfigurationManager.AppSettings["LADPUrl"];
                gLADPUser = ConfigurationManager.AppSettings["LADPUser"];
                gLADPPwd = ConfigurationManager.AppSettings["LADPPwd"];

                string sMailServerType = ConfigurationManager.AppSettings["MailServerType"];            
                gMailServerAddress = ConfigurationManager.AppSettings["MailServerAddress"];
                gMailServerUser = ConfigurationManager.AppSettings["MailServerUser"];
                gMailServerPassword = ConfigurationManager.AppSettings["MailServerPassword"];

                DataTable tbl = Common.DAL.GetPreferencesSetttings();
                foreach (DataRow row in tbl.Rows)
                {
                    string sKey = Cvt.ToString(row["key"]).Trim(), sValue = Cvt.ToString(row["value"]).Trim();
                    if (sKey.Length > 0 && sValue.Length > 0)
                    {
                        if (sKey.Equals("Max_Login_Attempt", StringComparison.OrdinalIgnoreCase))
                            gMaxLogin_Attempt = Cvt.ToInt32(sValue);
                        else if (sKey.Equals("Lock_Minute_After_Max_Login_Attempt", StringComparison.OrdinalIgnoreCase))
                            gLock_Minutes_After_Max_Login_Attempt = Cvt.ToInt32(sValue);
                        else if (sKey.Equals("Must_Login", StringComparison.OrdinalIgnoreCase))
                            gMust_Login = Cvt.ToBoolean(sValue);
                        else if (sKey.Equals("Default_Language", StringComparison.OrdinalIgnoreCase))
                            gDefault_Language = sValue;
                        else if (sKey.Equals("Home_Page_Title", StringComparison.OrdinalIgnoreCase))
                            gDefault_Language = sValue;
                        else if (sKey.Equals("Logo_Picture", StringComparison.OrdinalIgnoreCase))
                            gLogo_Picture = sValue;
                        else if (sKey.Equals("LADPUrl", StringComparison.OrdinalIgnoreCase))
                            gLADPUrl = sValue;
                        else if (sKey.Equals("LADPUser", StringComparison.OrdinalIgnoreCase))
                            gLADPUser = sValue;
                        else if (sKey.Equals("LADPPwd", StringComparison.OrdinalIgnoreCase))
                            gLADPPwd = sValue;
                        else if (sKey.Equals("MailServerType", StringComparison.OrdinalIgnoreCase))
                            sMailServerType = sValue;
                        else if (sKey.Equals("MailServerAddress", StringComparison.OrdinalIgnoreCase))
                            gMailServerAddress = sValue;
                        else if (sKey.Equals("MailServerUser", StringComparison.OrdinalIgnoreCase))
                            gMailServerUser = sValue;
                        else if (sKey.Equals("MailServerPassword", StringComparison.OrdinalIgnoreCase))
                            gMailServerPassword = sValue;
                    }
                }
                
                 if (!string.IsNullOrEmpty(sMailServerType))
                     gMailServerType = (MailServerType)Enum.Parse(typeof(MailServerType), sMailServerType, true);

                if (!string.IsNullOrEmpty(gLADPPwd))
                    gLADPPwd = Common.DecryptDES(gLADPPwd, rgbIV, rgbKey);
                if (!string.IsNullOrEmpty(gMailServerPassword))
                    gMailServerPassword = Common.DecryptDES(gMailServerPassword, rgbIV, rgbKey);
            }
            catch(Exception)
            {

            }
        }

        

    }
}
