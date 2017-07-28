using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web.Script.Serialization;

namespace PS
{

    public static class ExtensionMethods
    {

        private static readonly System.Type typeDateTime = typeof(DateTime);
        private static readonly System.Type typeDateTimeOffset = typeof(DateTimeOffset);
        private static readonly System.Type typeFloat = typeof(float);
        private static readonly System.Type typeDouble = typeof(double);


        /// <summary>
        /// DataTable 对象 转换为Json 字符串
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        public static string ToJson(this DataTable dt, string datetimeFormat, string floatFormat)
        {
            JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
            javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
            return javaScriptSerializer.Serialize(ToArrayList(dt, datetimeFormat, floatFormat));  //返回一个json字符串
        }

        /// <summary>
        /// DataTable 对象 转换为Json 字符串
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        public static string ToJson(this DataTable dt, string datetimeFormat)
        {
            JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
            javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
            return javaScriptSerializer.Serialize(ToArrayList(dt, datetimeFormat, ""));  //返回一个json字符串
        }
        public static ArrayList ToArrayList(this DataTable dt, string datetimeFormat)
        {
            return ToArrayList(dt, datetimeFormat, "");
        }
        public static ArrayList ToArrayList(this DataTable dt, string datetimeFormat, string floatFormat)
        {
            ArrayList arrayList = new ArrayList();
            foreach (DataRow dataRow in dt.Rows)
            {
                Dictionary<string, object> dictionary = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);  //实例化一个参数集合
                
                foreach (DataColumn dataColumn in dt.Columns)
                {
                    if (dataColumn.DataType == typeDateTime || dataColumn.DataType == typeDateTimeOffset)
                        dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName].ToStr(datetimeFormat));
                    else if (dataColumn.DataType == typeFloat || dataColumn.DataType == typeDouble)
                        dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName].ToStr(floatFormat));
                    else
                        dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName]);
                }
                arrayList.Add(dictionary); //ArrayList集合中添加键值
            }
            return arrayList;
        }

        //public static InsensitiveArray ToInsensitiveArrayList(this string json)
        //{
        //    return (new JavaScriptSerializer()).Deserialize<InsensitiveArray>(json);
        //}

        public static ArrayList ToArrayList(this string json)
        {
            return (new JavaScriptSerializer()).Deserialize<ArrayList>(json);
        }
        /// <summary>
        /// Json 字符串 转换为 DataTable数据集合
        /// </summary>
        /// <param name="json"></param>
        /// <returns></returns>
        public static DataTable ToDataTable(this string json)
        {
            DataTable dataTable = new DataTable();  //实例化
            DataTable result;
            try
            {
                JavaScriptSerializer javaScriptSerializer = new JavaScriptSerializer();
                javaScriptSerializer.MaxJsonLength = Int32.MaxValue; //取得最大数值
                ArrayList arrayList = javaScriptSerializer.Deserialize<ArrayList>(json);
                if (arrayList.Count > 0)
                {
                    foreach (Dictionary<string, object> dictionary in arrayList)
                    {
                        if (dictionary.Keys.Count == 0)
                        {
                            result = dataTable;
                            return result;
                        }
                        if (dataTable.Columns.Count == 0)
                        {
                            foreach (string current in dictionary.Keys)
                            {
                                dataTable.Columns.Add(current, dictionary[current].GetType());
                            }
                        }
                        DataRow dataRow = dataTable.NewRow();
                        foreach (string current in dictionary.Keys)
                        {
                            dataRow[current] = dictionary[current];
                        }

                        dataTable.Rows.Add(dataRow); //循环添加行到DataTable中
                    }
                }
            }
            catch
            {
            }
            result = dataTable;
            return result;
        }

        /// <summary>
        ///  转换为string字符串类型
        /// </summary>
        /// <param name="s">获取需要转换的值</param>
        /// <param name="format">需要格式化的位数</param>
        /// <returns>返回一个新的字符串</returns>
        public static string ToStr(this object s, string format)
        {
            string result = "";
            try
            {
                if (format == "")
                {
                    result = s.ToString();
                }
                else
                {
                    result = string.Format("{0:" + format + "}", s);
                }
            }
            catch
            {
            }
            return result.Trim();
        }


        public static string escape(this string str)
        {
            string str2 = "0123456789ABCDEF";
            int length = str.Length;
            StringBuilder builder = new StringBuilder(length * 2);
            int num3 = -1;
            while (++num3 < length)
            {
                char ch = str[num3];
                int num2 = ch;
                if ((((0x41 > num2) || (num2 > 90)) &&
                     ((0x61 > num2) || (num2 > 0x7a))) &&
                     ((0x30 > num2) || (num2 > 0x39)))
                {
                    switch (ch)
                    {
                        case '@':
                        case '*':
                        case '_':
                        case '+':
                        case '-':
                        case '.':
                        case '/':
                            goto Label_0125;
                    }
                    builder.Append('%');
                    if (num2 < 0x100)
                    {
                        builder.Append(str2[num2 / 0x10]);
                        ch = str2[num2 % 0x10];
                    }
                    else
                    {
                        builder.Append('u');
                        builder.Append(str2[(num2 >> 12) % 0x10]);
                        builder.Append(str2[(num2 >> 8) % 0x10]);
                        builder.Append(str2[(num2 >> 4) % 0x10]);
                        ch = str2[num2 % 0x10];
                    }
                }
                Label_0125:
                builder.Append(ch);
            }
            return builder.ToString();
        }


        public static Dictionary<string, object> ToDictionary(this DataRow dataRow, string DatetimeFormat)
        {
            Dictionary<string, object> dictionary = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);  //实例化一个参数集合
            foreach (DataColumn dataColumn in dataRow.Table.Columns)
            {
                if (dataColumn.DataType == typeDateTime)
                    dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName].ToStr(DatetimeFormat));
                else
                    dictionary.Add(dataColumn.ColumnName, dataRow[dataColumn.ColumnName].ToStr(""));
            }

            return dictionary;
        }
    }
}
