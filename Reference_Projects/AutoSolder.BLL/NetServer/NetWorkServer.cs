using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace AutoSolder.BLL
{
    public class NetWorkServer
    {
        //写成单例
        private volatile static NetWorkServer _instance = null;
        private static readonly object lockHelper = new object();
        private NetWorkServer() { }
        public static NetWorkServer CreateInstance(string ip, int port)
        {
            if (_instance == null)
            {
                lock (lockHelper)
                {
                    if (_instance == null)
                        _instance = new NetWorkServer( ip, port);
                }
            }
            return _instance;
        }


        public NetWorkServer(string ip, int port)
        {
            this.IP = ip;
            this.Port = port;

            LoadPingServer();
            LoadMonitorServer();
        }

        public void UpdataNet(string ip, int port)
        {
            this.IP = ip;
            this.Port = port;
        }

        #region NetWork Server

        private Socket clientSocket = null;
        private Thread threadRecive = null;

        private void CreateNetlink()
        {
            try
            {
                //要连接的远程IP
                IPAddress remoteHost = IPAddress.Parse(this.IP);
                //IP地址跟端口的组合
                IPEndPoint iep = new IPEndPoint(remoteHost, this.Port);
                //把地址绑定到Socket
                clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                //连接远程服务器
                clientSocket.Connect(iep);
                clientSocket.Blocking = true;

                this.NetStat = NetConnectStat.Connect;

                threadRecive = new Thread(RecMsg);
                threadRecive.IsBackground = true;
                threadRecive.Start();
            }
            catch (Exception e)
            {
                this.NetStat = NetConnectStat.DisConnect;
            }
        }
        void RecMsg()
        {
            while ((this.clientSocket != null) && (this.NetStat == NetConnectStat.Connect))
            {
                // 定义一个2M的缓存区；
                byte[] arrMsgRec = new byte[1024 * 1024 * 2];
                // 将接受到的数据存入到输入  arrMsgRec中；
                int length = -1;
                try
                {
                    length = clientSocket.Receive(arrMsgRec); // 接收数据，并返回数据的长度；
                    if (length < 0)
                    {
                        this.NetStat = NetConnectStat.DisConnect;
                        return;
                    }

                    this.ReciveBuffer = arrMsgRec;
                }
                catch
                {
                    this.NetStat = NetConnectStat.DisConnect;
                    return;
                }

                Thread.Sleep(500);
            }
        }
        #endregion

        #region Send Net Data

        public void SendDataToNet(byte[] data)
        {
            try
            {
                int len = clientSocket.Send(data); // 发送消息；
            }
            catch (SocketException)
            {
                NetStat = NetConnectStat.DisConnect;
            }
            catch (Exception)
            {
                NetStat = NetConnectStat.DisConnect;
            }
        }

        #endregion

        #region Ping Server

        private System.Timers.Timer PingTimer = null;

        private void LoadPingServer()
        {
            this.PingTimer = new System.Timers.Timer();
            this.PingTimer.Interval = 3000;
            this.PingTimer.Start();
            this.PingTimer.Elapsed += PingTimer_Elapsed;
        }

        private void PingTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if(PingServer(this.IP))
            {
                if ((this.PingTimer != null) && (this.PingTimer.Enabled))
                    this.PingTimer.Stop();

                CreateNetlink();
            }
        }
        
        private bool PingServer(string ip)
        {
            bool issuc = false;
            System.Diagnostics.Process p = new System.Diagnostics.Process();
            p.StartInfo.FileName = "cmd.exe";
            //用true试试
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardError = true;
            p.StartInfo.RedirectStandardInput = true;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.CreateNoWindow = true;

            p.Start();
            p.StandardInput.WriteLine("ping -n 1 " + ip);
            p.StandardInput.WriteLine("exit");
            string strrst = p.StandardOutput.ReadToEnd();
            if (strrst.IndexOf("0%") != -1)
            {
                issuc = true;
            }
            else
            {
                issuc = false;
            }
            p.Close();

            return issuc;
        }

        #endregion

        #region Monitor Server

        private System.Timers.Timer MonitorTimer = null;
        private int Tick = 1;

        private void LoadMonitorServer()
        {
            this.MonitorTimer = new System.Timers.Timer();
            this.MonitorTimer.Interval = 500;
            this.MonitorTimer.Enabled = false;
            this.MonitorTimer.Elapsed += MoniotrTimer_Elapsed;
        }

        private void MoniotrTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (this.Tick++ >= 5)
            {
                Tick = 1;

                this.NetStat = NetConnectStat.DisConnect;
            }
        }

        #endregion

        #region Interface Data

        private string ip = "";
        private int port = 0;

        private string IP
        {
            get { return this.ip; }
            set { this.ip = value; }
        }

        private int Port
        {
            get { return this.port; }
            set { this.port = value; }
        }

        private byte[] reciveBuffer;

        public byte[] ReciveBuffer
        {
            get { return this.reciveBuffer; }
            set
            {
                this.reciveBuffer = value;
                this.Tick = 1;

                OnReciveDataEvent(new ReciveDataArgs(value));
            }
        }

        private byte[] sendBuffer;

        public byte[] SendBuffer
        {
            get { return this.sendBuffer; }
            set
            {
                this.sendBuffer = value;
                if((value != null) && (value.Length > 0))
                    SendDataToNet(value);
            }
        }

        private NetConnectStat netStat = NetConnectStat.None;

        public NetConnectStat NetStat
        {
            get { return this.netStat; }
            set
            {
                if (this.netStat != value)
                {
                    this.netStat = value;

                    OnNetConnectChanged(new NetConnectArgs(value));
                                        
                    if (value == NetConnectStat.Connect)
                    {
                        if ((this.PingTimer != null) && (this.PingTimer.Enabled))
                            this.PingTimer.Stop();
                        if ((this.MonitorTimer != null) && (!this.MonitorTimer.Enabled))
                            this.MonitorTimer.Start();
                    }
                }
                if (value == NetConnectStat.DisConnect)
                {
                    if ((this.PingTimer != null) && (!this.PingTimer.Enabled))
                        this.PingTimer.Start();
                    if ((this.MonitorTimer != null) && (this.MonitorTimer.Enabled))
                        this.MonitorTimer.Stop();
                }
            }
        }

        #endregion

        #region Custom Define Event

        public event NetConnectHandler NetConnectChanged;

        private void OnNetConnectChanged(NetConnectArgs e)
        {
            if (this.NetConnectChanged != null)
                this.NetConnectChanged(new object(), e);
        }

        public event ReciveDataHandler ReciveDataEvent;

        private void OnReciveDataEvent(ReciveDataArgs e)
        {
            if (this.ReciveDataEvent != null)
                this.ReciveDataEvent(new object(), e);
        }

        #endregion
    }
}
