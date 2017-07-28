using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
using System.Threading;


namespace AutoSolder.BLL
{
    public class INI : ILDO
    {
        public string LDOPath
        { get;set; }

        public void WriteFun(string line, string ip, string port)
        {
            if (LDOPath == string.Empty || LDOPath == null)
            {
                return;

            }
            getLDOFile();

            //Thread writeINI_Thread = new Thread(() =>
            //{
                writeINI_File(line, ip, port);
            //});
            //writeINI_Thread.Start();


        }

       
        public List<NetConfig> ReadFun()
        {
            List <NetConfig> netList= new List<NetConfig>();
            if (LDOPath == string.Empty || LDOPath == null)
            {
                return null;

            }
           
                if (!File.Exists(LDOPath))
                {
                    File.Create(LDOPath);
                }

            
            
            //getLDOFile();
           

            //Thread ReadINI_Thread = new Thread(() =>
            //{
            //    ReadINI_File();
            //});
            //ReadINI_Thread.Start();
            string[] section = new string[100];
            if (INIHelper.GetAllSectionNames(out section, LDOPath) == -1)
            {
                return null;
            }
            
            for (int i = 0; i < section.Length; i++)
            {
                NetConfig netC = new NetConfig();
                netC.Ip = INIHelper.Read(section[i], "ip", LDOPath);
                netC.Port = INIHelper.Read(section[i], "port", LDOPath);
                netC.Line = INIHelper.Read(section[i], "line", LDOPath);
                netList.Add(netC);
            }
            return netList;
            
        }

        
        private void getLDOFile()
        {
            try
            {
                if (!File.Exists(LDOPath))
                {

                    if (!Directory.Exists(Path.GetDirectoryName(LDOPath)))
                    {
                        Directory.CreateDirectory(Path.GetDirectoryName(LDOPath));
                    }
                    FileStream fs = new FileStream(LDOPath, FileMode.Create);
                    fs.Close();
                }
            }
            catch (Exception)
            {

                throw;
            }
           


        }



        private void writeINI_File(string line, string ip, string port)
        {
            INIHelper.Write(line, "ip", ip, LDOPath);
            INIHelper.Write(line, "port", port, LDOPath);
            INIHelper.Write(line, "line", line, LDOPath);

            //FileStream fs = new FileStream(LDOPath, FileMode.Append);
            //StreamWriter sw = new StreamWriter(fs);
            //sw.WriteLine(line);
            //sw.WriteLine(ip);
            //sw.WriteLine(port);
            //sw.Close();
            //fs.Close();


        }

       


       

       

        
    }
    public class NetConfig
    {
        public NetConfig()
        {
            Ip = "192.168.0.0";
            Port = "8080";
            Line = "";
        }
        private string ip;
        private string port;
        private string line;

        public string Ip
        {
            get
            {
                return ip;
            }

            set
            {
                ip = value;
            }
        }

        public string Port
        {
            get
            {
                return port;
            }

            set
            {
                port = value;
            }
        }

        public string Line
        {
            get
            {
                return line;
            }

            set
            {
                line = value;
            }
        }
    }
}
