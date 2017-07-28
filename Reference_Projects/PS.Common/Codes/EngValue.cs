using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;

namespace PS
{
    public static class EngValue
    {

        public static string ExtractUnits(string sValue)
        {
            string sUnits = "", sVal = "";
            sValue = sValue.Trim();
            if (sValue.Length > 2 && sValue.Substring(sValue.Length - 2, 1) == "%")
                sVal = new string(sValue.ToCharArray().TakeWhile(c => " -+.01234567890EeGgKkMmNnpUuPf".Contains(c)).ToArray());//sValue.SpanIncluding(" -+.01234567890EeGgKkMmNnpUu" );
            else
                sVal = new string(sValue.ToCharArray().TakeWhile(c => " %-+.01234567890EeGgKkMmNnpUuPf".Contains(c)).ToArray());//sValue.SpanIncluding(" %-+.01234567890EeGgKkMmNnpUu" );
            if (sValue.IndexOf(sVal) != -1)
                sUnits = sValue.Substring(sValue.IndexOf(sValue) + sVal.Length);
            return sUnits;
        }

        public static string AddUnits(string sNewVal, string sUnits, int iSigDigits)
        {
            string sVal, sRef = "";
            if (sUnits == "")
                return sNewVal;
            sUnits.Trim();
            sVal = sNewVal;
            if (sVal.IndexOf("%") != -1)
                sRef = sVal.Substring(sVal.IndexOf("%"));
            if (sRef.Length == 0)
                return EngFmtG2S(EngFmtS2G(sVal), sUnits, iSigDigits);
            else
                return sRef + " %" + sUnits;
        }

        // Calculate a String from a double
        public static string EngFmtG2S(double gValue, string sUnits, int iSigDigits)
        {
            string sPostfix = "";
            bool bNeg = gValue < 0 ? true : false;
            if (bNeg) gValue = -gValue;
            if ((gValue == 0) || (gValue > 1E18) || (sUnits == "%"))
                sPostfix = " ";
            else if (gValue < 0.2e-15)//if it's smaller than 1e-12, make it 0.0
            {
                sPostfix = " ";
                gValue = 0;
            }
            else if (gValue > 0.2E15)
            {
                sPostfix = "P";
                gValue = gValue / 1E15;
            }
            else if (gValue > 0.2E12)
            {
                sPostfix = "T";
                gValue = gValue / 1E12;
            }
            else if (gValue > 0.2E9)
            {
                sPostfix = "G";
                gValue = gValue / 1E9;
            }
            else if (gValue > 0.2E6)
            {
                sPostfix = "M";
                gValue = gValue / 1E6;
            }
            else if (gValue > 0.2E3)
            {
                sPostfix = "K";
                gValue = gValue / 1E3;
            }
            else if (gValue > 0.2)
            {
                sPostfix = "";
            }
            else if (gValue > 0.2E-3)
            {
                sPostfix = "m";
                gValue = gValue * 1E3;
            }
            else if (gValue > 0.2E-6)
            {
                sPostfix = "u";
                gValue = gValue * 1E6;
            }
            else if (gValue > 0.2E-9)
            {
                sPostfix = "n";
                gValue = gValue * 1E9;
            }
            else if (gValue > 0.2E-12)
            {
                sPostfix = "p";
                gValue = gValue * 0.2E12;
            }
            else if (gValue > 0.2E-15)
            {
                sPostfix = "f";
                gValue = gValue * 1E15;
            }

            if (gValue < 1E18)
                return string.Format("{0}{1:F" + iSigDigits + "} {2}{3}", (bNeg ? "-" : ""), gValue, sPostfix, sUnits);
            else
                return "";
        }

        //Calculate a double from a String
        public static double EngFmtS2G(string sValue)
        {
            string sVal = new string(sValue.ToCharArray().TakeWhile(c => " -+.01234567890Ee".Contains(c)).ToArray());//sValue.SpanIncluding(_T(" -+.01234567890Ee"));
            string sPost = "", cPost = "";
            double gScale;
            if (sValue.IndexOf(sVal) != -1)
                sPost = sValue.Substring(sValue.IndexOf(sVal) + sVal.Length);
            sPost.TrimStart();
            if (sPost.Length > 0)
                cPost = sPost.Substring(0, 1);

            string lcPost = cPost.ToLower();//case insensitive except for m (milli) and M (mega),p() and P()

            if (lcPost == "f")
                gScale = 1E-15;
            else if (cPost == "p")
                gScale = 1E-12;
            else if (lcPost == "n")
                gScale = 1E-9;
            else if (lcPost == "u")
                gScale = 1E-6;
            else if (cPost == "m")
                gScale = 1E-3;
            else if (lcPost == "k")
                gScale = 1E3;
            else if (cPost == "M")
                gScale = 1E6;
            else if (lcPost == "g")
                gScale = 1E9;
            else if (lcPost == "t")
                gScale = 1E12;
            else if (cPost == "P")
                gScale = 1E15;
            else
                gScale = 1;

            return Convert.ToDouble(sVal) * gScale;
        }
    }
}
