<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DashPage.aspx.cs" Inherits="DashPage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>eDashBoard</title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet"
        type="text/css" />
    <link href="css/LoginStyle.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
        .FailText
        {
            color: #FF0000;
            text-align: left;
        }
        .gTitle
        {
            width: 100%;
            background-color: rgb(108,132,180);
            font-size: 16px;
            font-weight: bold;
            padding: 2px;
            text-align: left;
        }
        .AllBtn
        {
            padding: 0px 0px 0px 0px;
            margin: 0px 0px 0px 0px;
            height: 25px;
            border-spacing: 0px;
            border-collapse: collapse;
        }
        .iptEdt
        {
            width: 150px;
            font-size: 16px;
            font-weight: bold;
            font-family: Tahoma;
        }
        td
        {
            padding-left: 2px;
        }
        .l-button
        {
            height: 25px;
        }
        .l-grid-detailpanel-inner
        {
            width: 980px;
            overflow: hidden;
        }
        .l-grid-row-cell
        {
            white-space: nowrap;
        }
        .deletedItem
        {
            text-decoration: line-through;
        }
        .Panel
        {
            font-size: 14px;
            height: 150px;
            width: 30px;
            text-align: center;
        }
        .legend
        {
            font-size: 14px;
            height: 10px;
            width: 60px;
            text-align: center;
        }
        .legendFont
        {
            font-size: 10px;
            height: 10px;
            width: 80px;
            text-align: left;
            background: white;
        }
        .site
        {
            font-size: 14px;
            height: 80px;
            width: 150px;
            text-align: left;
            background-color: #808080;
            border-color: #808080;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
        .StationNameIE
        {
            font-weight: bold;
            text-align: justify;
            writing-mode: tb-rl;
            position: absolute;
            top: 25%;
            left: 25%;
            text-align: center;
        }
        .sitefont
        {
            height: 40px;
            text-align: left;
            border-color: White;
        }
        .StationName
        {
            text-align: justify;
            position: absolute;
            top: 35%;
            left: 2%;
            height: 40px;
            text-align: center;
        }
        .StationNameTH
        {
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            color: Black;
        }
        .ValueLable
        {
            font-size: 9px;
            text-align: left;
            color: black;
        }
        .TimeLable
        {
            font-size: 9px;
            text-align: right;
            color: Black;
        }
        .TemperatureOK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
        }
        .OK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
            color: Black;
        }
        .HumidityOK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
        }
        .TemperatureFail
        {
            font-weight: bold;
            color: red;
            font-size: 14px;
            text-align: left;
        }
        .HumidityFail
        {
            font-weight: bold;
            color: red;
            font-size: 14px;
            text-align: left;
        }
        .PressureOK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
        }
        .VacuumOK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
        }
        .PressureFail
        {
            font-weight: bold;
            color: red;
            font-size: 14px;
            text-align: left;
        }
        .VacuumFail
        {
            font-weight: bold;
            color: red;
            font-size: 14px;
            text-align: left;
        }
        .PanelTH
        {
            background-color: black;
            border-color: blue;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
        .PanelPR
        {
            background-color: DimGray;
            border-color: blue;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
        .FilterOK
        {
            background-color: #46a3ff;
            border-color: blue;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
        .FilterFail
        {
            background-color: yellow;
            border-color: blue;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
    </style>

    <script src="js/jquery-1.7.1.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDrag.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerResizable.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>

    <script src="js/settings.js" type="text/javascript"></script>

    <script type="text/javascript">

        String.prototype.bool = function()
        {
            return (/^true$/i).test(this) || (/^yes$/i).test(this) || (/^ok$/i).test(this);
        };
        
        var isIE = !!window.ActiveXObject;
        var Stations;
        var errorLable = null;

        $(function()
        {
            errorLable = document.getElementById("errorLable");
            ShowPISValues();
            setInterval("ShowPISValues()", 60000);
        });

        function ShowPISValues()
        {
            errorLable.innerText = "";
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetPISData',
                data: { Layout: "2F" },
                cache: false,
                dataType: 'json',
                success: function(data)
                {
                    if (data && data.sErrMsg)
                    {
                        errorLable.innerText = data.sErrMsg;
                        return;
                    }
                    if (data.Rows)
                        data = data.Rows;
                    // alert(Session["UserInfo"].value);
                    //var LayoutDiagramUrl = "images/bkg.png"; //data.LayoutDiagramUrl;

                    var Stations = new Array();

                    for (var i = 0; i < data.length; i++) {
                        Stations[i] = { Name: data[i].Name, Left: 100 + i % 7 * 250, Top: 250 + Math.floor(i / 7) * 200 };

                    }

                    //var Stations = [
                    // { Name: "PIS-1", Left: 250, Top: 150 }
                    //, { Name: "PIS-2", Left: 550, Top: 130 }
                    //];

                    var LayoutDiagram = $("#LayoutDiagram");
                    var LayoutImg = LayoutDiagram.find("#LayoutImg");
//                    if (LayoutImg.length == 0)
//                        LayoutDiagram.append("<img id=\"LayoutImg\" src=\"" + LayoutDiagramUrl + "\">");


                    for (var i = 0; i < Stations.length; i++)
                    {
                        var station = Stations[i];
                        var Location = null;
                        for (var j = 0; j < data.length; j++)
                        {
                            if (station.Name.toLowerCase() == data[j].Name.toLowerCase())
                            {
                                Location = data[j];
                                break;
                            }
                        }
                        if (Location)
                        {
                            var stationDiv = LayoutDiagram.find("#PIS" + Location.nStationID);
                            if (stationDiv.length == 0)
                            {
                                stationDiv = LayoutDiagram.append("<div class=\"PanelTH\" id=\"PIS" + Location.nStationID
                                   + "\" style=\"position:absolute;top:" + station.Top
                                   + "px;left:" + station.Left + "px\" />");
                                stationDiv = LayoutDiagram.find("#PIS" + Location.nStationID);
                                $('#PIS' + Location.nStationID).ligerDrag({
                                    //proxy: false
                                    onStopDrag: function (current, e) {
                                        var lastX = current.diffX + station.Left;
                                        var lastY = current.diffY + station.Top;
                                        //不必要保存控件历史位置

                                    }
                                });
                            }
                            stationDiv.html("<span class=\"StationNameTH\" >" + station.Name + "</span><br>"
                            + "<div style=\"cursor:pointer;\"  onclick=\"f_PisDetailDlg_open(" + Location.nStationID + ",'" + station.Name + "','" + Location.starttime + "');\">"
                            + "<span class=\"ValueLable\">Model:</span><span class=\"OK\">" + Location.model + "</span><br>"
                            + "<span class=\"ValueLable\">SN:</span><span class=\"OK\">" + Location.theSN + "</span><br>"
                            + "<span class=\"ValueLable\">CPK:</span><span class=\"OK\">" + Location.cpk + "</span><br>"
                            + "<span class=\"ValueLable\">Start Time:</span><span class=\"OK\">" + Location.starttime + "</span><br>"
                                + "<span class=\"ValueLable\">End Time:</span><span class=\"OK\">" + Location.endtime + "</span><br>"
                                //数据库存放换成磁盘存放
                           // + "<img src=\"getfile.ashx?tb=true&pis=" + Location.id + "\" />"
                                + "<img src=\"getfile.ashx?tb=true&fn=" + Location.id + "\" />"
                            +"</div>");

                            stationDiv.css("background", Location.result ? "yellowgreen" : "Red");
                        }
                    }

                },
                error: function(XMLHttpRequest, textStatus)
                {
                    errorLable.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                }
            });
        }


        var PisDetailDlg = null;
        function f_PisDetailDlg_open(nID, name, time)
        {
            if (PisDetailDlg != null)
                return;
            PisDetailDlg = $.ligerDialog.open({
                title: "Detail Data From PIS",
                url: "PIS.aspx?StationID=" + nID + "&name=" + name + "&time=" + time,
                width: 1300,
                height: 730,
                showMax: false,
                showToggle: false,
                showMin: false,
                isResize: false,
                slide: true,
                isHidden: false,
                onClose: function()
                {
                    PisDetailDlg = null;
                }
            });
        }

    </script>

</head>
<body style="margin-left: 0px; margin-top: 0px;">
    <div style="position: absolute; width: 100%; height: 100%; background: url(images/bkg.png) 0 0 no-repeat;">
        <table align="center" style="text-align: center; height: 100%">
            <tr>
                <td class="FailText" id="errorLable">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td align="center">
                    <div id="LayoutDiagram">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="display: none">
                    </div>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
