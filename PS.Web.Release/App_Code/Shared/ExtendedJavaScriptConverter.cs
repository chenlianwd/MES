using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;
using System.Reflection;
using System.Globalization;
using System.Data;


public class ExtendedJavaScriptConverter<T> : JavaScriptConverter where T : new()
{
    private string _dateFormat = "dd/MM/yyyy";

    public ExtendedJavaScriptConverter()
    {

    }
    public ExtendedJavaScriptConverter(string DateTimeFormat)
    {
        _dateFormat = DateTimeFormat;
    }
    public override IEnumerable<Type> SupportedTypes
    {
        get
        {
            return new[] { typeof(T) };
        }
    }

    public override object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer)
    {
        T p = new T();

        var props = typeof(T).GetProperties();

        foreach (string key in dictionary.Keys)
        {
            var prop = props.Where(t => t.Name == key).FirstOrDefault();
            if (prop != null)
            {
                if (prop.PropertyType == typeof(DateTime))
                {
                    prop.SetValue(p, DateTime.ParseExact(dictionary[key] as string, _dateFormat, DateTimeFormatInfo.InvariantInfo), null);

                }
                else
                {
                    prop.SetValue(p, dictionary[key], null);
                }
            }
        }

        return p;
    }

    public override IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer)
    {
        T p = (T)obj;
        IDictionary<string, object> serialized = new Dictionary<string, object>();

        foreach (PropertyInfo pi in typeof(T).GetProperties())
        {
            if (pi.PropertyType == typeof(DateTime))
            {
                serialized[pi.Name] = ((DateTime)pi.GetValue(p, null)).ToString(_dateFormat);
            }
            else
            {
                serialized[pi.Name] = pi.GetValue(p, null);
            }

        }

        return serialized;
    }

    public static JavaScriptSerializer GetSerializer()
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.RegisterConverters(new[] { new ExtendedJavaScriptConverter<T>() });

        return serializer;
    }
    public static JavaScriptSerializer GetSerializer(string DateTimeFormat)
    {
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        serializer.RegisterConverters(new[] { new ExtendedJavaScriptConverter<T>(DateTimeFormat) });

        return serializer;
    }
    public static string ToJson(object obj, string DateTimeFormat)
    {
        return GetSerializer(DateTimeFormat).Serialize(obj);
    }
}

