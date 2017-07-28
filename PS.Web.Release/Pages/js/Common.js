Date.prototype.Format = function (fmt)
{ //author: meizz
    var o = {
        "M+": this.getMonth() + 1, //月份
        "d+": this.getDate(), //日
        "H+": this.getHours(), //小时
        "m+": this.getMinutes(), //分
        "s+": this.getSeconds(), //秒
        "q+": Math.floor((this.getMonth() + 3) / 3), //季度
        "S": this.getMilliseconds() //毫秒
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}
//V1 method
String.prototype.format = function ()
{
    var args = arguments;
    return this.replace(/\{(\d+)\}/g,
        function (m, i)
        {
            return args[i];
        });
}

//V2 static
String.format = function ()
{
    if (arguments.length == 0)
        return null;

    var str = arguments[0];
    for (var i = 1; i < arguments.length; i++)
    {
        var re = new RegExp('\\{' + (i - 1) + '\\}', 'gm');
        str = str.replace(re, arguments[i]);
    }
    return str;
}

var errorLable = null;


function f_Setting(item, grid)
{
}

function f_onBeforeSetData(data)
{
    errorLable.innerText = (data && data.sErrMsg) ? data.sErrMsg : "";
    var o = this.options;
    gList[o.HoldFld] = data;
    return;
}

function f_renderSelect(rowdata, rowindex, value, column)
{
    for (var i = 0; i < gList[column.columnname].length; i++)
    {
        if (gList[column.columnname][i]['ID'] == rowdata[column.columnname])
            return gList[column.columnname][i]['Name'];
    }
    return rowdata[column.columnname];
}

function f_Submit(item, grid)
{
    var grd = this;

    errorLable.innerText = "";
    lblInfo.innerText = "";

    grid.endEdit();

    var Changes = grid.getChanges();
    $.ajax({
        type: 'post',
        url: grid.options.upUrl,
        data: { Changes: JSON.stringify(Changes) },
        cache: false,
        dataType: 'json',
        success: function (data)
        {
            if (data && data.sErrMsg)
            {
                errorLable.innerText = data.sErrMsg;
                return;
            }
            grid.loadServerData();
            lblInfo.innerText = "Submit Sucess.";
        },
        error: function (XMLHttpRequest, textStatus)
        {
            errorLable.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
        }
    });
}


function f_Filter(itm, grd)
{
    grd.options.data = $.extend(true, {}, grd.data.AllPO);
    grd.showFilter();
}

function f_OnLoaded(grid)
{
    try
    {
        if (grid.data.sStartTime && grid.data.sStartTime.length > 0)
            $("#edtStartDate").ligerGetDateEditorManager().setValue(grid.data.sStartTime);
        if (grid.data.sEndTime && grid.data.sEndTime.length > 0)
            $("#edtEndDate").ligerGetDateEditorManager().setValue(grid.data.sEndTime);
        grid.toggleLoading.ligerDefer(grid, 10, [false]);
    }
    catch (err)
    {

    }
    return false;
}

function chkRefreshClick()
{
    var bChk = document.getElementById("chkRefresh").checked;
    if (!bChk)
    {
        window.clearInterval(g_timerRefreshPage);
        g_timerRefreshPage = null;
    }
    else
    {
        if (g_timerRefreshPage == null)
        {
            g_timerRefreshPage = window.setInterval(f_Query, 300000);
        };
    };
};

function f_collapse(item, grid)
{
    var selectedRows = grid.getSelectedRows();
    for (var i = 0; i < selectedRows.length; i++)
        grid.collapseDetail(selectedRows[i]);
    return;
}

function f_expand(item, grid)
{
    var selectedRows = grid.getSelectedRows();
    for (var i = 0; i < selectedRows.length; i++)
        grid.extendDetail(selectedRows[i]);
    //var ownerRow = detailGrid.options.ownerRow;
    return;
}

function f_renderWithNA(rowdata, rowindex, value, column)
{
    if (rowdata[column.columnname] == -1)
        return "N/A";
    else
        return rowdata[column.columnname];
}

function f_render(rowdata, rowindex, value, column)
{
    if (rowdata.bStop == 1)
        return "<span class='Stop'>" + rowdata.UsedTimes + "</span>";
    else if (rowdata.bAlarm == 1)
        return "<span class='Alarm'>" + rowdata.UsedTimes + "</span>";
    else
        return "<span class='Normal'>" + rowdata.UsedTimes + "</span>";
}
function f_OnError(data, grid)
{
    if (data && data.sErrMsg)
        errorLable.innerText = data.sErrMsg;

    return;
}
function f_onSuccess(data, grid)
{
    errorLable.innerText = (data && data.sErrMsg) ? data.sErrMsg : "";
    return;
}


function f_Detail_onSuccess(data, grid)
{
    grid.options.usePager = data.Total > 10;
}



function f_Operate(rowdata, rowindex, value)
{
    var h = "";
    if (rowdata._editing)
    {
        h += "<a href='javascript:f_EndEdit(" + rowindex + ")'>OK</a> ";
        h += "<a href='javascript:f_cancelEdit(" + rowindex + ")'>Cancel</a> ";
    }
    return h;
}

function f_renderDisabled(rowdata, rowindex, value, column)
{
    if (rowdata.bDisabled == 1)
        return "Disabled";
    else
        return "Enabled";
}

function f_renderUsed(rowdata, rowindex, value, column)
{
    if (rowdata.bUsed == 1)
        return "Yes";
    else
        return "No";
}
function f_onSuccess(data, grid)
{
    f_OnError(data, grid);

    return;
}

function f_EndEdit(rowid)
{
    grdMain.endEdit(rowid);
}
function f_cancelEdit(rowid)
{
    grdMain.cancelEdit(rowid);
}
function f_onAfterEdit(rowdata)
{
    return;
}
function f_AddNewRow()
{
    grdMain.addEditRow();
}