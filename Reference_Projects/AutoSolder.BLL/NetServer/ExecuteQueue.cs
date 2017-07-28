
using AutoSolder.DAL;
using AutoSolder.Model;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading;
using System.Timers;

namespace AutoSolder.BLL
{
    public class ExecuteQueue
    {
        public ExecuteQueue(string IPString, int port)
        {
            setupConection(IPString, port);
        }
        //网络通讯类
        NetWorkServer netWorkServer;
        
        BaseProfile baseProfile = null;
        private NetConnectStat netstat;
        public NetConnectStat Netstat
        {
            get
            {
                return netstat;
            }

            set
            {
                netstat = value;
                if (netstat == NetConnectStat.Connect)
                {
                    T1.Start();
                    T2.Start();
                    
                }
                else
                {
                    T1.Stop();
                    T2.Stop();
                }
            }
        }


        public void setupConection(string IPString, int port)
        {
            //string IPString = ConfigurationManager.AppSettings["machineip"];
            //int port = 0;
            //int.TryParse(ConfigurationManager.AppSettings["machineport"], out port);
            //string productLine = ConfigurationManager.AppSettings["productline"];          
            netWorkServer = NetWorkServer.CreateInstance(IPString, port);
            netWorkServer.NetConnectChanged += NetWorkServer_NetConnectChanged;           
            netWorkServer.ReciveDataEvent += NetWorkServer_ReciveDataEvent;
           // DisplayDataEvent += ExecuteQueue_DisplayDataEvent;
        }

        private void ExecuteQueue_DisplayDataEvent(object sender, DisplayToUIArgs e)
        {
            OnDisplayDataEvent(e);
          
        }

        private void NetWorkServer_ReciveDataEvent(object sender, ReciveDataArgs e)
        {

            HandleReciveDataEvent(e.ReciveData);
        }
       
        private void HandleReciveDataEvent(byte[] s)
        {
            BaseProfile _baseprofile = new BaseProfile();
            _baseprofile.Temperature = (s[0] + (s[1] << 8)) / 10.0;//温度
            _baseprofile.Humidity = s[2] + (s[3] << 8);//湿度
            _baseprofile.remainSolderPercent = s[4] + (s[5] << 8);//剩余量
            _baseprofile.usedSolderNum = s[6] + (s[7] << 8);//已使用瓶数
            _baseprofile.addTimes = s[8] + (s[9] << 8);//次数
            _baseprofile.startTime = s[10] + (s[11] << 8);//启动时间
            _baseprofile.powerOffTime = s[11] + (s[12] << 8);//开机时间

            _baseprofile.TimePoint = DateTime.Now;//数据点时间

            baseProfile = _baseprofile;
        }
        private void NetWorkServer_NetConnectChanged(object sender, NetConnectArgs e)
        {
            Netstat = e.NetStat;
            OnNetConnectChanged(e);
        }
        
        //save date queue and show UI queue
        private Queue<BaseProfile> baseProfileQueue_save = new Queue<BaseProfile>();
        private Queue<BaseProfile> baseProfileQueue_show = new Queue<BaseProfile>();
        
        // 通过 _wh 给工作线程发信号
        static EventWaitHandle _whsv = new AutoResetEvent(false);
        static EventWaitHandle _whsw = new AutoResetEvent(false);
        static Thread _saveWorker;
        static Thread _showWorker;
        System.Timers.Timer T1 = new System.Timers.Timer();//显示的频率
        System.Timers.Timer T2 = new System.Timers.Timer(10000);//存入数据库的频率10s

        public  void ExecuteAddBaseProfile(int timer)
        {

            T1.Interval = timer * 1000;
            T1.Elapsed += T1_Elapsed;

            
            T2.Elapsed += T2_Elapsed;

            _saveWorker = new Thread(saveWork);
            _saveWorker.IsBackground = true;
            _saveWorker.Start();
           // Dispose_save();

            _showWorker = new Thread(showWork);
            _showWorker.IsBackground = true;
            _showWorker.Start();
           // Dispose_show();
        }      
        public void updateIntervalTime(int time)
        {
           
            T1.Interval = time * 1000;
        }
       

        private void saveWork()
        {
            while (true)
            {
                try
                {
                    
                        if (baseProfileQueue_save.Count > 0)
                        {
                            BaseProfile baseData = baseProfileQueue_save.Dequeue(); // 有任务时，出列任务

                            if (baseData == null)  // 退出机制：当遇见一个null任务时，代表任务结束
                                return;
                            else
                            SaveData(baseData);  // 任务不为null时，处理并保存数据
                         }
                    
                }
                catch 
                {
                    
                }           
                
            }
        }
        private void showWork()
        {
            while (true)
            {                
                //lock (this)
                {
                    if (baseProfileQueue_show.Count > 0)
                    {
                        BaseProfile baseData = baseProfileQueue_show.Dequeue(); // 有任务时，出列任务

                        if (baseData == null)  // 退出机制：当遇见一个null任务时，代表任务结束
                            return;
                        
                            OnDisplayDataEvent(new DisplayToUIArgs(baseData));//传给主窗体
                       
                        

                    }
                    //else
                    //    _whsw.WaitOne();   // 没有任务了，等待信号
                }
            
                   
            }
        }

       


        private void T1_Elapsed(object sender, ElapsedEventArgs e)
        {
           // lock (this)
            {
                if (baseProfile != null)
                {
                    baseProfileQueue_show.Enqueue(baseProfile);
                  //  _whsv.Set();// 给工作线程发信号
                }
                
            }
        }
        private void T2_Elapsed(object sender, ElapsedEventArgs e)
        {
           // lock (this)
            {
                if (baseProfile != null)
                {
                    baseProfileQueue_save.Enqueue(baseProfile);
                   // _whsw.Set();// 给工作线程发信号
                }
               
            }
        }
       

        /// <summary>
        /// 保存到数据库
        /// </summary>
        /// <param name="baseprofile"></param>
        private void SaveData(BaseProfile baseprofile)
        {
            DataStoreBase dataStoreBase = new DataStoreBase();
           
            dataStoreBase.AddBaseProfile(baseprofile, "baseprofile");

        }
       
        #region custom define event

        public event NetConnectHandler NetConnectChanged;

        private void OnNetConnectChanged(NetConnectArgs e)
        {
            if (this.NetConnectChanged != null)
                this.NetConnectChanged(new object(), e);
        }

        //public event ReciveDataHandler ReciveDataEvent;
        //private void OnReciveDataEvent(ReciveDataArgs e)
        //{
        //    if (this.ReciveDataEvent != null)
        //        this.ReciveDataEvent(new object(), e);
        //}

        public event DisplayToUIHandler DisplayDataEvent;
        private void OnDisplayDataEvent(DisplayToUIArgs e)
        {
            if (this.DisplayDataEvent != null)
                this.DisplayDataEvent(new object(), e);

            
        }

        #endregion
        

    }
}
