using System;
using System.Collections.Generic;
using System.Text;

namespace PS
{

    public static class Cvt
    {
        public static int CompareStringObject(object obj1, object obj2)
        {
            return string.Compare(ToString(obj1), ToString(obj2), StringComparison.OrdinalIgnoreCase);
        }
        public static string ToString(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToString(obj).Trim();
            }
            catch (Exception)
            {
            }
            return "";
        }
        public static bool IsNumerical(object obj)
        {
            try
            {
                //DBNull认为是false
                if (obj != null && obj != Convert.DBNull)
                {
                    Convert.ToDouble(obj);
                    return true;
                }
            }
            catch (Exception)
            {
            }
            return false;
        }

        public static bool ToBoolean(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToBoolean(obj);
            }
            catch (Exception)
            {
            }
            return false;
        }
        public static Double ToDouble(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToDouble(obj);
            }
            catch (Exception)
            {
            }
            return 0;
        }
        public static string ToNumString(object obj, string sUnit, string sDef, int iSigDigits)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return EngValue.EngFmtG2S(ToDouble(obj), sUnit, iSigDigits);
            }
            catch (Exception)
            {
            }
            return sDef;
        }
        public static string ToNumString(object obj, string sUnit, string sDef)
        {
            return ToNumString(obj, sUnit, sDef, 3);
        }

        public static string ToNumString(object obj, string sDef)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToString(ToInt32(obj));
            }
            catch (Exception)
            {
            }
            return sDef;
        }
        public static long ToInt64(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToInt64(obj);
            }
            catch (Exception)
            {
            }
            return 0;
        }
        public static Byte[] ToByteArray(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return (byte[])obj;
            }
            catch (Exception)
            {
            }
            return null;
        }
        public static int ToInt32(object obj)
        {
            try
            {
                if (obj != null && obj != Convert.DBNull)
                    return Convert.ToInt32(obj);
            }
            catch (Exception)
            {
            }
            return 0;
        }
        public static DateTime ToDateTime(object obj)
        {
            try
            {
                return Convert.ToDateTime(obj);
            }
            catch (Exception)
            {
            }
            return Convert.ToDateTime("1970-1-1");
        }
        public static int IndexNumericalStart(string ss)
        {
            const string NumericalCharaters = "+-.0123456789";
            for (int i = 0; i < ss.Length; i++)
            {
                if (NumericalCharaters.IndexOf(ss[i]) != -1)
                    return i;
            }
            return -1;
        }
    }



}
