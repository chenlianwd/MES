using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PS.Reflow.Codes
{
    public class PISModel
    {


        public string ProLine { get; set; } = "";
        public string SN { get; set; } = "";
        public string Model { get; set; } = "";
        public DateTime StartTime { get; set; } = new DateTime();
        public DateTime EndTime { get; set; } = new DateTime();
        public string Flag { get; set; } = "1";
        public Double CPK { get; set; } = 0.0d;
        public string Result { get; set; } = "1";
        public DateTime DateNo { get; set; } = new DateTime();
        public DateTime HourNo { get; set; } = new DateTime();
        public string LineNo { get; set; } = "";
        public string LineNoSHA { get; set; } = "";
        public string TheSN { get; set; } = "";
        public string PISFileName { get; set; } = "";
    }
   
}
