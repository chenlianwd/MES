using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace PS
{
    public enum LoginResult
    {
        Locked = 0,
        OK = 1,
        Reject = 2
    }
    public enum Status
    {
        Locked = 0,
        Normal = 1
    }
    public enum MailServerType
    {
        SMTP = 1,
        Exchange = 2
    }
    public class EmployeeInfo
    {
        public EmployeeInfo()
        {
            _Employee = 0;
            _Employee_Update = 0;
            Use_AD_Login = false;
            _Status = Status.Locked;
            Change_Pwd_When_Next_Login = false;

            GroupList = new List<int>();
            Name = "";
            HashPassword = ""; Language = "";
            Login_Attempt = 0;
            this.TimeZone = 800;

            //Update_Time;
            //Gravatar;
            //Fullname, Description, Email_Address, Telphone_Number, AD_Account;

            //DateTime Login_Time;
            //lastLoginFrom_IP, lastLoginFrom_MAC, lastLoginFrom_Host;
            lastLoginResult = LoginResult.Reject;
        }
        public long _Employee { get; set; }
        public long _Employee_Update { get; set; }
        public bool Use_AD_Login { get; set; }
        public Status _Status { get; set; }
        public bool Change_Pwd_When_Next_Login { get; set; }

        public List<int> GroupList { get; set; }
        public string Name { get; set; }
        public string HashPassword { get; set; }
        public string Language { get; set; }
        public int Login_Attempt { get; set; }
        public int TimeZone { get; set; }

        public DateTime Update_Time { get; set; }
        public long _Attachment_Gravatar { get; set; }
        public string Fullname { get; set; }
        public string Description { get; set; }
        public string Email_Address { get; set; }
        public string Telphone_Number { get; set; }
        public string AD_Account { get; set; }

        public DateTime Login_Time { get; set; }
        public string lastLoginFrom_IP { get; set; }
        public string lastLoginFrom_MAC { get; set; }
        public string lastLoginFrom_Host { get; set; }
        public LoginResult lastLoginResult { get; set; }

        public int _Site_Working { get; set; }
        public int _Project_Working { get; set; }
    }
}


public class KV
{
    public string Key { get; set; }
    public object Value { get; set; }
    public KV(string s, object obj)
    {
        Key = s;
        Value = obj;
    }
}

public class ExDictionary : Dictionary<string, object>
{
    public ExDictionary()
        : base(StringComparer.OrdinalIgnoreCase)
    {
    }
    public ExDictionary(KV[] Fileds)
        : base(StringComparer.OrdinalIgnoreCase)
    {
        foreach (KV p in Fileds)
            this.Add(p.Key, p.Value);
    }
}


public class InsensitiveDictionary<V> : Dictionary<string, V>
{
    public InsensitiveDictionary()
        : base(StringComparer.OrdinalIgnoreCase)
    {
    }
}

public class InsensitiveArray : InsensitiveDictionary<InsensitiveDictionary<object>>
{
}



//public class InsensitiveComparer<T> : IEqualityComparer<T>
//{
//    public bool Equals(T x, T y)
//    {
//        if ((x != null && x.GetType() == typeof(string))
//        || (y != null && y.GetType() == typeof(string))
//            )
//            return string.Equals(x as string, y as string, StringComparison.OrdinalIgnoreCase);
//        else
//            return object.Equals(x, y);
//    }
//    public int GetHashCode(T obj)
//    {
//        return obj.GetHashCode();
//    }
//    //public static implicit operator IEqualityComparer<string>(InsensitiveComparer v)
//    //{
//    //    return v as IEqualityComparer<string>;
//    //}
//}
//public class ExDictionary<TKey, TValue, TEqualityComparer> : Dictionary<TKey, TValue>
//    where TEqualityComparer : IEqualityComparer, new()
//{
//    public ExDictionary()
//        : base((new TEqualityComparer()) as IEqualityComparer<TKey>)
//    {
//    }
//}

