
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AutoSolder.BLL
{
    public interface ILDO
    {
        string LDOPath { get; set; }

        void WriteFun(string line, string ip, string port);
        List<NetConfig> ReadFun();
    }
}
