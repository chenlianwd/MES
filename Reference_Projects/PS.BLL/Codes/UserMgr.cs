using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Threading;
using System.Drawing;
using System.Drawing.Imaging;
using System.DirectoryServices;
using System.Security.Cryptography;

namespace PS
{
    public partial class UserMgr : BLL
    {
        public static EmployeeInfo LoadEmployeeInfo(string sUserName)
        {
            DataTable tbl = Common.DAL.GetUseInfo(sUserName);
            if (tbl.Rows.Count > 0)
            {
                DataRow dataRow = tbl.Rows[0];
                EmployeeInfo empInfo = new EmployeeInfo();
                empInfo._Employee = Cvt.ToInt64(dataRow["_Employee"]);
                empInfo.Use_AD_Login = Cvt.ToBoolean(dataRow["Use_AD_Login"]);
                empInfo.Change_Pwd_When_Next_Login = Cvt.ToBoolean(dataRow["Change_Pwd_When_Next_Login"]);
                empInfo.AD_Account = Cvt.ToString(dataRow["AD_Account"]);

                empInfo._Status = (Status)Enum.Parse(typeof(Status), Cvt.ToString(dataRow["_Status"]), true);
                empInfo.Name = Cvt.ToString(dataRow["Name"]);
                empInfo.HashPassword = Cvt.ToString(dataRow["Password"]);
                empInfo.Language = Cvt.ToString(dataRow["Language"]);
                empInfo.Login_Attempt = Cvt.ToInt32(dataRow["Login_Attempt"]);

                empInfo.Update_Time = Cvt.ToDateTime(dataRow["Update_Time"]);
                empInfo._Attachment_Gravatar = Cvt.ToInt64(dataRow["_Attachment_Gravatar"]);
                empInfo.Fullname = Cvt.ToString(dataRow["Fullname"]);
                empInfo.Description = Cvt.ToString(dataRow["Description"]);
                empInfo.Email_Address = Cvt.ToString(dataRow["Email_Address"]);
                empInfo.Telphone_Number = Cvt.ToString(dataRow["Telphone_Number"]);

                empInfo.Login_Time = Cvt.ToDateTime(dataRow["Login_Time"]);
                empInfo.lastLoginFrom_IP = Cvt.ToString(dataRow["From_IP"]);
                empInfo.lastLoginFrom_MAC = Cvt.ToString(dataRow["From_MAC"]);
                empInfo.lastLoginFrom_Host = Cvt.ToString(dataRow["From_Host"]);
                empInfo.lastLoginResult = (LoginResult)Enum.Parse(typeof(LoginResult), Cvt.ToNumString(dataRow["_Login_Result"], "1"), true); ;

                return empInfo;
            }
            return null;
        }
        public static List<int> GetUserInGroup(long _Employee_ID)
        {
            DataTable tblUserInGroup = Common.DAL.GetUseInGroup(_Employee_ID);
            List<int> grpList = new List<int>();
            foreach (DataRow row in tblUserInGroup.Rows)
            {
                grpList.Add(Cvt.ToInt32(row["_Employee_Group_ID"]));
            }
            return grpList;
        }
        public static EmployeeInfo CheckLoginAuthenticate(LanguageHelper langHelper,string sUserName, string sPwd, string sNewPwd, string sStation,string sFromIP,string sFromMAC,string sFromHost)
        {
            EmployeeInfo userInfo = UserMgr.CheckLoginAuthenticateInternal(langHelper, sUserName, sPwd, sNewPwd, sStation, sFromIP, sFromMAC, sFromHost);

            if (userInfo == null)//无记录返回                    
            {
                throw new Exception(langHelper.GetText("Invalid User name!"));
            }
            else
            {
                if (userInfo.lastLoginResult == LoginResult.Locked || userInfo._Status == Status.Locked)
                {
                    throw new Exception(langHelper.GetText("Your account is Locked !"));
                }
                else if (userInfo.lastLoginResult == LoginResult.Reject)
                {
                    throw new Exception(langHelper.GetText("Your password is wrong !"));
                }
            }
            return userInfo;
        }
        private static EmployeeInfo CheckLoginAuthenticateInternal(LanguageHelper langHelper, string sUserName, string sPwd, string sNewPwd, string sStation, string sFromIP, string sFromMAC, string sFromHost)
        {
            EmployeeInfo emp = LoadEmployeeInfo(sUserName);           
            string FullName = "", MailAddress = "";
            if (emp != null)
            {
                string sHashPwd = HashPassword(emp._Employee, sPwd);
                LoginResult LoginResult = LoginResult.Reject;

                if (emp.lastLoginResult != LoginResult.Locked
                    || (emp.lastLoginResult == LoginResult.Locked && (Common.DAL.TimeOfDBServer - emp.Login_Time).TotalMinutes > gLock_Minutes_After_Max_Login_Attempt)
                    )
                {
                    if ((emp.Use_AD_Login && UseADAuthenticate(emp.AD_Account, sPwd, ref FullName, ref MailAddress))
                        || (emp.Use_AD_Login == false && emp.HashPassword.Equals(sHashPwd, StringComparison.OrdinalIgnoreCase))
                        )
                    {
                        LoginResult = LoginResult.OK;
                    }
                }

                if (LoginResult != LoginResult.OK)
                {
                    if (emp.Login_Attempt >= gMaxLogin_Attempt)
                        LoginResult = LoginResult.Locked;
                    Thread.Sleep(30);//登录失败挂住3秒，加大暴力破解难度
                    emp.Login_Attempt++;
                }
                emp.lastLoginFrom_IP = sFromIP;
                emp.lastLoginFrom_MAC = sFromMAC;
                emp.lastLoginFrom_Host = sFromHost;
                emp.lastLoginResult = LoginResult;
                Common.DAL.AddLoginHistory(emp, LoginResult);

                if (LoginResult == LoginResult.OK)
                {
                    if (emp.Use_AD_Login)
                        Common.DAL.UpdateUserInfo(langHelper, emp._Employee, sHashPwd, emp._Employee, FullName, MailAddress);
                    else if (sNewPwd.Length > 0)
                        Common.DAL.ChangeUserPassword(langHelper, emp._Employee, HashPassword(emp._Employee, sNewPwd), emp);

                    emp.GroupList = GetUserInGroup(emp._Employee);
                }
            }
            //检查是否允许访问当前站位

            return emp;
        }
        /// <summary>
        /// 使用AD验证账号和密码
        /// </summary>
        /// <param name="username">AD账号名称</param>
        /// <param name="pwd">用户的密码</param>
        /// <param name="FullName">如果验证成功，返回用户的全名</param>
        /// <returns>验证成功返回true,验证失败返回false</returns>
        private static bool UseADAuthenticate(string username, string pwd, ref string FullName, ref string MailAddress)
        {
            try
            {
                DirectoryEntry entry = new DirectoryEntry(gLADPUrl, username, pwd);
                Object obj = entry.NativeObject;
                DirectorySearcher search = new DirectorySearcher(entry);
                search.Filter = "(SAMAccountName=" + username + ")";
                search.PropertiesToLoad.Add("cn");
                SearchResult result = search.FindOne();
                if (null != result)
                {
                    // Update the new path to the user in the directory
                    FullName = (String)result.Properties["cn"][0];
                    MailAddress = (String)result.Properties["mail"][0];
                    return true;
                }
            }
            catch (Exception)
            {
            }
            return false;
        }
        private static string HashPassword(long EmployeeID, string sPwd)
        {
            string sHash = EmployeeID + sPwd;
            MD5 md5Hasher = MD5.Create();
            sHash = HexBytes(md5Hasher.ComputeHash(Encoding.Default.GetBytes(sHash)));
            return sHash;
        }
        public static string HexBytes(byte[] bytes)
        {
            string str = "";
            if ((bytes != null) && (bytes.Length != 0))
            {
                for (int i = 0; i < bytes.Length; i++)
                    str += bytes[i].ToString("x2");
            };
            return str;
        }

        public static string CreateVerifyCodePicture(Stream stream)
        {
            string codeSource = "23456789ABCDEFGHJKLMNPQRSTUVWXY";//定义校验码中的验证字符集
            const int width = 100, height = 36;
            Random random = new Random();
            string code = "";
            int number = 0;
            for (int i = 0; i < 4; i++)
            {
                number = random.Next(DateTime.Now.Millisecond) % codeSource.Length;
                code += codeSource.Substring(number, 1);
            }
            Bitmap image = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(image);

            Color color = AllColorList[random.Next(DateTime.Now.Millisecond) % AllColorList.Length];
            g.Clear(color);
            float emSize = (float)width / code.Length;
            Font font = new Font("Arial", emSize, (System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic));

            #region 画图片的背景噪音线
            color = AllColorList[random.Next(DateTime.Now.Millisecond) % AllColorList.Length];
            Pen pen = new Pen(color, 3);
            int x1, y1, x2, y2;

            for (int i = 0; i < 25; i++)
            {
                x1 = random.Next(image.Width);
                y1 = random.Next(image.Height);
                x2 = random.Next(image.Width);
                y2 = random.Next(image.Height);
                g.DrawLine(pen, x1, y1, x2, y2);
            }
            #endregion

            Brush brush = AllBrushList[(random.Next(DateTime.Now.Millisecond) * 47) % AllBrushList.Length];
            g.DrawString(code, font, brush, 2, 2);

            #region 画图片的前景噪音点
            for (int i = 0; i < 100; i++)
            {
                x1 = random.Next(image.Width);
                y1 = random.Next(image.Height);

                color = AllColorList[random.Next(DateTime.Now.Millisecond) % AllColorList.Length];
                image.SetPixel(x1, y1, color);
                Thread.Sleep(5);//挂住累计500毫秒，防止暴力刷新
            }
            #endregion

            #region 画图片的前景干扰线
            //color = AllColorList[random.Next(DateTime.Now.Millisecond) % AllColorList.Length];
            //pen = new Pen(color, 2.5f);
            //for (int i = 0; i < 5; i++)
            //{
            //    x1 = random.Next(image.Width);
            //    y1 = random.Next(image.Height);
            //    x2 = random.Next(image.Width);
            //    y2 = random.Next(image.Height);
            //    g.DrawLine(pen, x1, y1, x2, y2);
            //}
            #endregion
            
            g.Dispose();
            image.Save(stream, ImageFormat.Jpeg);

            return code;
        }



        static readonly Brush[] AllBrushList = { Brushes.AliceBlue
,Brushes.AntiqueWhite
,Brushes.Aqua
,Brushes.Aquamarine
,Brushes.Azure
,Brushes.Beige
,Brushes.Bisque
,Brushes.Black
,Brushes.BlanchedAlmond
,Brushes.Blue
,Brushes.BlueViolet
,Brushes.Brown
,Brushes.BurlyWood
,Brushes.CadetBlue
,Brushes.Chartreuse
,Brushes.Chocolate
,Brushes.Coral
,Brushes.CornflowerBlue
,Brushes.Cornsilk
,Brushes.Crimson
,Brushes.Cyan
,Brushes.DarkBlue
,Brushes.DarkCyan
,Brushes.DarkGoldenrod
,Brushes.DarkGray 
,Brushes.DarkGreen
,Brushes.DarkKhaki
,Brushes.DarkMagenta
,Brushes.DarkOliveGreen
,Brushes.DarkOrange
,Brushes.DarkOrchid
,Brushes.DarkRed
,Brushes.DarkSalmon
,Brushes.DarkSeaGreen
,Brushes.DarkSlateBlue
,Brushes.DarkSlateGray
,Brushes.DarkTurquoise
,Brushes.DarkViolet
,Brushes.DeepPink
,Brushes.DeepSkyBlue
,Brushes.DimGray
,Brushes.DodgerBlue
,Brushes.FloralWhite
,Brushes.ForestGreen
,Brushes.Fuchsia
,Brushes.Gainsboro
,Brushes.GhostWhite
,Brushes.Gold
,Brushes.Goldenrod
,Brushes.Gray 
,Brushes.Green
,Brushes.GreenYellow
,Brushes.Honeydew
,Brushes.HotPink
,Brushes.IndianRed
,Brushes.Indigo
,Brushes.Ivory
,Brushes.Khaki
,Brushes.Lavender
,Brushes.LavenderBlush
,Brushes.LawnGreen
,Brushes.LemonChiffon
,Brushes.LightBlue
,Brushes.LightCoral
,Brushes.LightCyan
,Brushes.LightGoldenrodYellow
,Brushes.LightGreen
,Brushes.LightGray
,Brushes.LightPink
,Brushes.LightSalmon
,Brushes.LightSeaGreen
,Brushes.LightSkyBlue
,Brushes.LightSlateGray
,Brushes.LightSteelBlue
,Brushes.LightYellow
,Brushes.Lime
,Brushes.LimeGreen
,Brushes.Linen
,Brushes.Magenta
,Brushes.Maroon
,Brushes.MediumAquamarine
,Brushes.MediumBlue
,Brushes.MediumOrchid
,Brushes.MediumPurple
,Brushes.MediumSeaGreen
,Brushes.MediumSlateBlue
,Brushes.MediumSpringGreen
,Brushes.MediumTurquoise
,Brushes.MediumVioletRed
,Brushes.MidnightBlue
,Brushes.MintCream
,Brushes.MistyRose
,Brushes.Moccasin
,Brushes.NavajoWhite
,Brushes.Navy
,Brushes.OldLace
,Brushes.Olive
,Brushes.OliveDrab
,Brushes.Orange
,Brushes.OrangeRed
,Brushes.Orchid
,Brushes.PaleGoldenrod
,Brushes.PaleGreen
,Brushes.PaleTurquoise
,Brushes.PaleVioletRed
,Brushes.PapayaWhip
,Brushes.PeachPuff
,Brushes.Peru
,Brushes.Pink
,Brushes.Plum
,Brushes.PowderBlue
,Brushes.Purple
,Brushes.Red
,Brushes.RosyBrown
,Brushes.RoyalBlue
,Brushes.SaddleBrown
,Brushes.Salmon
,Brushes.SandyBrown
,Brushes.SeaGreen
,Brushes.SeaShell
,Brushes.Sienna
,Brushes.Silver
,Brushes.SkyBlue
,Brushes.SlateBlue
,Brushes.SlateGray
,Brushes.Snow
,Brushes.SpringGreen
,Brushes.SteelBlue
,Brushes.Tan
,Brushes.Teal
,Brushes.Thistle
,Brushes.Tomato
,Brushes.Turquoise
,Brushes.Violet
,Brushes.Wheat
,Brushes.White
,Brushes.WhiteSmoke
,Brushes.Yellow
,Brushes.YellowGreen
 };

        static readonly Color[] AllColorList ={Color.AliceBlue
,Color.AntiqueWhite
,Color.Aqua
,Color.Aquamarine
,Color.Azure
,Color.Beige
,Color.Bisque
,Color.Black
,Color.BlanchedAlmond
,Color.Blue
,Color.BlueViolet
,Color.Brown
,Color.BurlyWood
,Color.CadetBlue
,Color.Chartreuse
,Color.Chocolate
,Color.Coral
,Color.CornflowerBlue
,Color.Cornsilk
,Color.Crimson
,Color.Cyan
,Color.DarkBlue
,Color.DarkCyan
,Color.DarkGoldenrod
,Color.DarkGray
,Color.DarkGreen
,Color.DarkKhaki
,Color.DarkMagenta
,Color.DarkOliveGreen
,Color.DarkOrange
,Color.DarkOrchid
,Color.DarkRed
,Color.DarkSalmon
,Color.DarkSeaGreen
,Color.DarkSlateBlue
,Color.DarkSlateGray
,Color.DarkTurquoise
,Color.DarkViolet
,Color.DeepPink
,Color.DeepSkyBlue
,Color.DimGray
,Color.DodgerBlue
,Color.Firebrick
,Color.FloralWhite
,Color.ForestGreen
,Color.Fuchsia
,Color.Gainsboro
,Color.GhostWhite
,Color.Gold
,Color.Goldenrod
,Color.Gray
,Color.Green
,Color.GreenYellow
,Color.Honeydew
,Color.HotPink
,Color.IndianRed
,Color.Indigo
,Color.Ivory
,Color.Khaki
,Color.Lavender
,Color.LavenderBlush
,Color.LawnGreen
,Color.LemonChiffon
,Color.LightBlue
,Color.LightCoral
,Color.LightCyan
,Color.LightGoldenrodYellow
,Color.LightGreen
,Color.LightGray
,Color.LightPink
,Color.LightSalmon
,Color.LightSeaGreen
,Color.LightSkyBlue
,Color.LightSlateGray
,Color.LightSteelBlue
,Color.LightYellow
,Color.Lime
,Color.LimeGreen
,Color.Linen
,Color.Magenta
,Color.Maroon
,Color.MediumAquamarine
,Color.MediumBlue
,Color.MediumOrchid
,Color.MediumPurple
,Color.MediumSeaGreen
,Color.MediumSlateBlue
,Color.MediumSpringGreen
,Color.MediumTurquoise
,Color.MediumVioletRed
,Color.MidnightBlue
,Color.MintCream
,Color.MistyRose
,Color.Moccasin
,Color.NavajoWhite
,Color.Navy
,Color.OldLace
,Color.Olive
,Color.OliveDrab
,Color.Orange
,Color.OrangeRed
,Color.Orchid
,Color.PaleGoldenrod
,Color.PaleGreen
,Color.PaleTurquoise
,Color.PaleVioletRed
,Color.PapayaWhip
,Color.PeachPuff
,Color.Peru
,Color.Pink
,Color.Plum
,Color.PowderBlue
,Color.Purple
,Color.Red
,Color.RosyBrown
,Color.RoyalBlue
,Color.SaddleBrown
,Color.Salmon
,Color.SandyBrown
,Color.SeaGreen
,Color.SeaShell
,Color.Sienna
,Color.Silver
,Color.SkyBlue
,Color.SlateBlue
,Color.SlateGray
,Color.Snow
,Color.SpringGreen
,Color.SteelBlue
,Color.Tan
,Color.Teal
,Color.Thistle
,Color.Tomato
,Color.Turquoise
,Color.Violet
,Color.Wheat
,Color.White
,Color.WhiteSmoke
,Color.Yellow
,Color.YellowGreen
};

    }
}
