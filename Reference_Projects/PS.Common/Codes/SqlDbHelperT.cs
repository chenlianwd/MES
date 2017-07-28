using System;
using System.Data;
using System.Data.Common;
using System.Configuration;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace PS
{
    /// <summary>
    /// 针对数据库操作的通用模板类
    /// </summary>
    public abstract partial class DALBase 
        //<ConnectT, AdapterT, ParameterT, CommandT>
        //where ConnectT : DbConnection, new()
        //where AdapterT : DbDataAdapter, new()
        //where ParameterT : DbParameter, new()
        //where CommandT : DbCommand, new()
    {
        /// <summary>
        /// 设置数据库连接字符串
        /// </summary>
        protected string ConnectionString     {set;get; }
        ///// <summary>
        ///// 构造函数
        ///// </summary>
        //public SqlDbHelperT()
        //{

        //}
        ///// <summary>
        ///// 构造函数
        ///// </summary>
        ///// <param name="connectionString">数据库连接字符串</param>
        //public SqlDbHelperT(string connectionString)
        //{
        //    this.connectionString = connectionString;
        //}
        protected abstract DbConnection getNewConnection(string sConnectionString);
        protected abstract DbDataAdapter getNewAdapter(string commandText, DbConnection dbConnection);
        protected abstract DbDataAdapter getNewAdapter(DbCommand command);
        protected abstract DbDataAdapter getNewAdapter(string commandText, string sConnectionString);
        protected abstract DbCommand getNewCommand(string commandText, DbConnection dbConnection);

        protected virtual DbTransaction BeginTransaction()
        {
            DbConnection connection = getNewConnection(ConnectionString);
            connection.Open();//打开数据库连接
            return connection.BeginTransaction() as DbTransaction;
        }
        protected virtual DbTransaction BeginTransaction(IsolationLevel iso)
        {
            DbConnection connection = getNewConnection(ConnectionString);
            connection.Open();//打开数据库连接
            return connection.BeginTransaction(iso) as DbTransaction;
        }
        /// <summary>
        /// 执行一个查询，并返回结果集 
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataSet ExecuteDataSet(DbTransaction objTrans, string commandText)
        {
            return ExecuteDataSet(objTrans, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 执行一个查询，并返回结果集
        /// </summary>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        public virtual DataSet ExecuteDataSet(string commandText)
        {
            return ExecuteDataSet(null, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataSet ExecuteDataSet(DbTransaction objTrans, string commandText, CommandType commandType)
        {
            return ExecuteDataSet(objTrans, commandText, commandType, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataSet ExecuteDataSet(string commandText, CommandType commandType)
        {
            return ExecuteDataSet(null, commandText, commandType, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataSet ExecuteDataSet(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteDataSet(null, commandText, commandType, parameters);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters"></param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataSet ExecuteDataSet(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters)
        {
            Debug.WriteLine(commandText);

            DataSet data = new DataSet();//实例化DataTable，用于装载查询结果集
            if (objTrans == null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    using (DbCommand command = getNewCommand(commandText, connection))
                    {
                        command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                        //如果同时传入了参数，则添加这些参数
                        if (parameters != null)
                        {
                            foreach (DbParameter parameter in parameters)
                                command.Parameters.Add(parameter);
                        }
                        //通过包含查询SQL的SqlCommand实例来实例化SqlDataAdapter
                        DbDataAdapter adapter = getNewAdapter(command);
                        connection.Open();//打开数据库连接
                        adapter.Fill(data);//填充DataTable
                    }
                }
            }
            else
            {
                using (DbCommand command = getNewCommand(commandText, objTrans.Connection))
                {
                    command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                    //如果同时传入了参数，则添加这些参数
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                            command.Parameters.Add(parameter);
                    }
                    //通过包含查询SQL的SqlCommand实例来实例化SqlDataAdapter
                    command.Transaction = objTrans;
                    DbDataAdapter adapter = getNewAdapter(command);
                    adapter.Fill(data);//填充DataTable
                }
            }
            return data;
        }

        /// <summary>
        /// 执行一个查询，并返回结果集 
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(DbTransaction objTrans, string commandText)
        {
            return ExecuteDataTable(objTrans, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 执行一个查询，并返回结果集
        /// </summary>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(string commandText)
        {
            return ExecuteDataTable(null, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(DbTransaction objTrans, string commandText, CommandType commandType)
        {
            return ExecuteDataTable(objTrans, commandText, commandType, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(string commandText, CommandType commandType)
        {
            return ExecuteDataTable(null, commandText, commandType, null);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteDataTable(null, commandText, commandType, parameters);
        }
        /// <summary>
        /// 执行一个查询,并返回查询结果
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters"></param>
        /// <returns>返回查询结果集</returns>
        protected virtual DataTable ExecuteDataTable(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters)
        {
            Debug.WriteLine(commandText);

            DataTable data = new DataTable();//实例化DataTable，用于装载查询结果集
            if (objTrans==null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    using (DbCommand command = getNewCommand(commandText, connection))
                    {
                        command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                        //如果同时传入了参数，则添加这些参数
                        if (parameters != null)
                        {
                            foreach (DbParameter parameter in parameters)
                                command.Parameters.Add(parameter);
                        }
                        //通过包含查询SQL的SqlCommand实例来实例化SqlDataAdapter
                        DbDataAdapter adapter = getNewAdapter(command);
                        connection.Open();//打开数据库连接
                        adapter.Fill(data);//填充DataTable
                    }
                }
            }
            else
            {
                using (DbCommand command = getNewCommand(commandText, objTrans.Connection))
                {
                    command.Connection = objTrans.Connection;
                    command.CommandText = commandText;
                    command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                    //如果同时传入了参数，则添加这些参数
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                            command.Parameters.Add(parameter);
                    }
                    //通过包含查询SQL的SqlCommand实例来实例化SqlDataAdapter
                    DbDataAdapter adapter = getNewAdapter(command);
                    command.Transaction = objTrans;
                    adapter.SelectCommand = command;
                    adapter.Fill(data);//填充DataTable
                }
            }
            return data;
        }
        protected virtual DbDataReader ExecuteReader(DbTransaction objTrans, string commandText)
        {
            return ExecuteReader(objTrans, commandText, CommandType.Text, null, CommandBehavior.Default);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(string commandText)
        {
            return ExecuteReader(null, commandText, CommandType.Text, null, CommandBehavior.CloseConnection);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(DbTransaction objTrans, string commandText, CommandType commandType)
        {
            return ExecuteReader(objTrans, commandText, commandType, null, CommandBehavior.Default);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(string commandText, CommandType commandType)
        {
            return ExecuteReader(null, commandText, commandType, null, CommandBehavior.CloseConnection);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteReader(objTrans, commandText, commandType, null, CommandBehavior.Default);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteReader(null, commandText, commandType, null, CommandBehavior.CloseConnection);
        }
        /// <summary>
        /// 将 CommandText 发送到 Connection 并生成一个 MySqlDataReader。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns></returns>
        protected virtual DbDataReader ExecuteReader(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters, CommandBehavior commandBehavior)
        {
            Debug.WriteLine(commandText);
            DbConnection connection = objTrans != null ? objTrans.Connection: getNewConnection(ConnectionString);

            DbCommand command = getNewCommand(commandText, connection);
            //如果同时传入了参数，则添加这些参数
            if (parameters != null)
            {
                foreach (DbParameter parameter in parameters)
                    command.Parameters.Add(parameter);
            }
            if (objTrans == null)
                connection.Open();
            //CommandBehavior.CloseConnection参数指示关闭Reader对象时关闭与其关联的Connection对象
            command.Transaction = objTrans;
            return command.ExecuteReader(commandBehavior);
        }
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(DbTransaction objTrans, string commandText)
        {
            return ExecuteScalar(objTrans, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(string commandText)
        {
            return ExecuteScalar(null,commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(DbTransaction objTrans, string commandText, CommandType commandType)
        {
            return ExecuteScalar(objTrans,commandText, commandType, null);
        }
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(string commandText, CommandType commandType)
        {
            return ExecuteScalar(null,commandText, commandType, null);
        }
      
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteScalar(null,commandText, commandType, null);
        }
        /// <summary>
        /// 从数据库中检索单个值（例如一个聚合值）。
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns></returns>
        protected virtual Object ExecuteScalar(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters)
        {
            Debug.WriteLine("ExecuteScalar:\n" + commandText);

            object result = null;
            if (objTrans == null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    using (DbCommand command = getNewCommand(commandText, connection))
                    {
                        command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                        //如果同时传入了参数，则添加这些参数
                        if (parameters != null)
                        {
                            foreach (DbParameter parameter in parameters)
                                command.Parameters.Add(parameter);
                        }
                        connection.Open();//打开数据库连接
                        result = command.ExecuteScalar();
                    }
                }
            }
            else
            {
                using (DbCommand command = getNewCommand(commandText, objTrans.Connection))
                {
                    command.CommandText = commandText;
                    command.Connection = objTrans.Connection;
                    command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                    //如果同时传入了参数，则添加这些参数
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                            command.Parameters.Add(parameter);
                    }
                    command.Transaction = objTrans;
                    result = command.ExecuteScalar();
                }
            }
            return result;//返回查询结果的第一行第一列，忽略其它行和列
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(string commandText)
        {
            return ExecuteNonQuery(null, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的查询SQL文本命令</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(DbTransaction objTrans, string commandText)
        {
            return ExecuteNonQuery(objTrans, commandText, CommandType.Text, null);
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(string commandText, CommandType commandType)
        {
            return ExecuteNonQuery(null, commandText, commandType, null);
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(DbTransaction objTrans, string commandText, CommandType commandType)
        {
            return ExecuteNonQuery(objTrans,commandText, commandType, null);
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(string commandText, CommandType commandType, DbParameter[] parameters)
        {
            return ExecuteNonQuery(null,commandText, commandType, null);
        }
        /// <summary>
        /// 对数据库执行增删改操作
        /// </summary>
        /// <param name="objTrans">已经开始的Transaction事务对象</param>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <returns>返回执行操作受影响的行数</returns>
        protected virtual int ExecuteNonQuery(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters)
        {
            Debug.WriteLine("ExecuteNonQuery:\n" + commandText);

            int count = 0;
            if (objTrans == null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    using (DbCommand command = getNewCommand(commandText, connection))
                    {
                        command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                        //如果同时传入了参数，则添加这些参数
                        if (parameters != null)
                        {
                            foreach (DbParameter parameter in parameters)
                                command.Parameters.Add(parameter);
                        }
                        connection.Open();//打开数据库连接                        
                        count = command.ExecuteNonQuery();
                    }
                }
            }
            else
            {
                using (DbCommand command = getNewCommand(commandText, objTrans.Connection))
                {
                    command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                    //如果同时传入了参数，则添加这些参数
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                            command.Parameters.Add(parameter);
                    }
                    command.Transaction = objTrans;
                    count = command.ExecuteNonQuery();
                }
            }
            return count;//返回执行增删改操作之后，数据库中受影响的行数
        }
        /// <summary>
        /// 对数据库执行增删改操作,此方法仅适合向数据增加一条记录并返回该记录的主键编号（该主键必须是自动递增的）
        /// </summary>
        /// <param name="commandText">要执行的SQL语句</param>
        /// <param name="commandType">要执行的查询语句的类型，如存储过程或者SQL文本命令</param>
        /// <param name="parameters">Transact-SQL 语句或存储过程的参数数组</param>
        /// <param name="outParameterName">要输出的参数值的参数名</param>
        /// <returns>返回整数类型的参数值</returns>
        protected virtual int ExecuteNonQueryReturnOutParameterValue(string commandText, CommandType commandType, DbParameter[] parameters, string outParameterName)
        {
            return ExecuteNonQueryReturnOutParameterValue(null, commandText, commandType, parameters, outParameterName);
        }
        protected virtual int ExecuteNonQueryReturnOutParameterValue(DbTransaction objTrans, string commandText, CommandType commandType, DbParameter[] parameters, string outParameterName)
        {
            Debug.WriteLine("ExecuteNonQueryReturnOutParameterValue:\n" + commandText);

            int value = 0;
            if (objTrans == null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    using (DbCommand command = getNewCommand(commandText, connection))
                    {
                        command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                        //如果同时传入了参数，则添加这些参数
                        if (parameters != null)
                        {
                            foreach (DbParameter parameter in parameters)
                            {
                                command.Parameters.Add(parameter);
                            }
                        }
                        connection.Open();//打开数据库连接
                        command.Transaction = objTrans;
                        if (command.ExecuteNonQuery() > 0)
                            value = int.Parse(command.Parameters[outParameterName].Value.ToString());
                    }
                }
            }
            else
            {
                using (DbCommand command = getNewCommand(commandText, objTrans.Connection))
                {
                    command.CommandType = commandType;//设置command的CommandType为指定的CommandType
                    //如果同时传入了参数，则添加这些参数
                    if (parameters != null)
                    {
                        foreach (DbParameter parameter in parameters)
                            command.Parameters.Add(parameter);
                    }
                    if (command.ExecuteNonQuery() > 0)
                        value = int.Parse(command.Parameters[outParameterName].Value.ToString());
                }
            }
            return value;//返回执行增删改操作之后，数据库中受影响的行数
        }
        /// <summary>
        /// 返回当前连接的数据库中所有由用户创建的数据库
        /// </summary>
        /// <returns></returns>
        protected virtual DataTable GetTables()
        {
            return GetTables(null);
        }
        /// <summary>
        /// 返回当前连接的数据库中所有由用户创建的数据库
        /// </summary>
        /// <returns></returns>
        protected virtual DataTable GetTables(DbTransaction objTrans)
        {
            Debug.WriteLine("GetTables");

            DataTable data = null;
            if (objTrans == null)
            {
                using (DbConnection connection = getNewConnection(ConnectionString))
                {
                    connection.Open();//打开数据库连接
                    data = connection.GetSchema("Tables");
                }
            }
            else
            {
                data = objTrans.Connection.GetSchema("Tables");
            }
            return data;
        }
        /// <summary>
        /// 将List&lt;int&gt;这样的整数集合转换成(1,3,5)这样的形式,以便在SQL语句中使用in
        /// </summary>
        /// <param name="intList">整数集合</param>
        /// <returns></returns>
        internal string ListToString(List<int> intList)
        {
            string result = " (";
            if (intList == null || intList.Count == 0)
            {
                //因为数据库中id字段都是自增的，所以不可能存在-1这样的id
                //下面的做法只是为了让执行SQL语句时不报错
                result = result + "-1";
            }
            else
            {
                int count = intList.Count;
                for (int i = 0; i < count - 1; i++)
                {
                    result = result + intList[i].ToString() + ",";
                }
                result = result + intList[count - 1].ToString();
            }
            result = result + ")";
            //最终将返回类似于" (1,3,4)"或者" (-1)"这样的结果
            return result;
        }

        /// <summary>
        /// 分页查询方法，适用于任何表或者视图
        /// </summary>
        /// <param name="tableName">要查询的表名或者视图名</param>
        /// <param name="where">查询的where条件</param>
        /// <param name="selectColumnName">要在in语句中查询的字段</param>
        /// <param name="orderColumnName">要排序的字段名</param>
        /// <param name="orderBy">排序方式</param>
        /// <param name="startIndex">返回记录的起始位置</param>
        /// <param name="size">返回的最大记录条数</param>
        /// <param name="parameters">查询中用到的参数集合</param>
        /// <returns>返回分页查询结果</returns>
        protected virtual DataTable GetPagedDataTable(string tableName, string where, string selectColumnName, string orderColumnName, OrderBy orderBy, int startIndex, int size, DbParameter[] parameters)
        {
            string orderByString = orderBy == OrderBy.ASC ? " ASC " : " DESC ";
            StringBuilder buffer = new StringBuilder(1024);
            buffer.AppendFormat("select top {0} * from {1} where {2} not in(", size, tableName, selectColumnName);
            buffer.AppendFormat("select top {0} {1} from {2} where {3} order by {4} {5}", startIndex, selectColumnName, tableName, where, orderColumnName, orderByString);
            buffer.AppendFormat(") and {0} order by {1} {2}", where, orderColumnName, orderByString);
            string commandText = buffer.ToString();
            return ExecuteDataTable(commandText, CommandType.Text, parameters);
        }

    }
}