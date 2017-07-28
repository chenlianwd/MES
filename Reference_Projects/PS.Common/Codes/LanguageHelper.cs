using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.IO;

namespace PS
{
    public class LanguageHelper
    {
        string _Language = "chs",_sPath="";
        DataTable _langTable = null;
        bool _bChanged = false;
        public LanguageHelper()
        {
            _langTable = new DataTable();
            _sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
            _sPath = Path.Combine(Path.Combine(_sPath, "config"), "Language.xml");
            if (File.Exists(_sPath))
                _langTable.ReadXml(_sPath);
            else
            {
                _langTable.TableName = "Language";
                DataColumn col = _langTable.Columns.Add("stringName", typeof(System.String));
                col.Unique = true;
                _langTable.Columns.Add("engText", typeof(System.String));
                _langTable.Columns.Add("chsText", typeof(System.String));
                _bChanged = true;
            }
        }
        ~LanguageHelper()
        {
            if(_bChanged && _langTable!=null)
                _langTable.WriteXml(_sPath, XmlWriteMode.WriteSchema);
        }
        public string Language
        {
            get
            {
                return _Language;
            }
            set
            {
                bool bNewLang = true;
                 string sFld =value+"Text";
                foreach(DataColumn col in _langTable.Columns)
                {
                    if(string.Compare(col.ColumnName,sFld,StringComparison.OrdinalIgnoreCase)==0)
                    {
                        bNewLang = false;
                        break;
                    }
                }
                if(bNewLang)
                {
                    _bChanged = true;                   
                    _langTable.Columns.Add(sFld, typeof(System.String));
                    foreach (DataRow row in _langTable.Rows)
                        row[sFld] = row["engText"];
                }
                _Language = value;
            }
        }
        public string GetText(string StringID)
        {
            string sText = null;
            string sFld = _Language + "Text";
            if (!_langTable.Columns.Contains(sFld))
                throw new FieldAccessException("Can found field " + sFld + "!");

            DataRow[] sel = _langTable.Select("stringName='" + StringID.Replace("'","''") + "'");
            if (sel != null && sel.Length > 0)
                sText = sel[0][sFld] as string;

            if (sText == null)
            {
                //如果没有找到记录，添加新记录
                lock (_langTable)
                {
                    _langTable.Rows.Add(new object[] { StringID, StringID, StringID });
                    _langTable.WriteXml(_sPath, XmlWriteMode.WriteSchema);
                }
                sText = StringID;
            }

            return sText;
        }
        public Dictionary<string, string> GetLanguageList()
        {
            Dictionary<string, string> lst = new Dictionary<string, string>();
            foreach (DataColumn col in _langTable.Columns)
            {
                string ss=col.ColumnName;
                if (string.Compare(ss, "stringName", StringComparison.OrdinalIgnoreCase) != 0)
                {
                    if (string.Compare(ss.Substring(ss.Length - 4), "Text", StringComparison.OrdinalIgnoreCase) == 0)
                        ss = ss.Substring(0, ss.Length - 4);
                    lst.Add(ss, this.GetText(ss));
                }
            }

            return lst;
        }
    }
}
