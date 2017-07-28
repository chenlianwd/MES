<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="AdminHomePage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="../js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet"
        type="text/css" />
    <link href="../css/LoginStyle.css" rel="stylesheet" type="text/css" />
    <link href="../css/SuperSlide.css" type="text/css" rel="stylesheet">
    <style type="text/css">
        .l-link
        {
            display: block;
            height: 26px;
            line-height: 26px;
            padding-left: 10px;
            text-decoration: underline;
            color: #333;
        }
    </style>

    <script src="../js/jquery-1.7.1.min.js" type="text/javascript"></script>

    <script src="../js/jquery.SuperSlide.2.1.1.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerLayout.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerTab.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerAccordion.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>

    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>

    <script src="../js/settings.js" type="text/javascript"></script>

    <script type="text/javascript">
        var tab = null;
        var accordion = null;

        $(function()
        {

            $("#layout1").ligerLayout({ leftWidth: 280, topHeight: 0, height: '100%', heightDiff: -2, space: 4, onHeightChanged: f_heightChanged });
            var height = $(".l-layout-center").height();
            //Tab
            tab = $("#tabSetting").ligerTab({ height: height });
            accordion = $("#accordionMenu").ligerGetAccordionManager();

            $("#pageloading").hide();
        });

        function f_heightChanged(options)
        {
            if (tab)
                tab.addHeight(options.diff);
            //            if (accordion && options.middleHeight - 24 > 0)
            //                accordion.setHeight(options.middleHeight - 24);
        }
        function f_addTab(tabid, text, url)
        {
            tab.addTabItem({
                tabid: tabid,
                text: text,
                url: url
            });
        }      
    </script>

</head>
<body scroll="no" style="background-position: #EAEEF5; padding: 0px; background: #EAEEF5;
    margin: 0px 0px 0px 0px">
    <div id="pageloading">
    </div>
    <form id="form1" runat="server">
    <asp:Panel ID="layout1" runat="server" Style="width: 100%; height: 100%; margin: 0 auto;
        margin-top: 0px;">
        <asp:Panel ID="accordionMenu" position="left" runat="server">
            <div style="height: 7px;">
            </div>
            <div id="sideMenu" class="sideBox">
                <div class="hd">
                    <h3>
                        <% =LangHelper.GetText("Employee Organization")%></h3>
                </div>
                <div class="bd">
                    <ul>
                        <li><a href="javascript:f_addTab('Department','<% =LangHelper.GetText("Department") %>','TableEdit.aspx?ei=_Department');">
                            <% =LangHelper.GetText("Department")%></a></li>
                        <li><a href="javascript:f_addTab('Employee','<% =LangHelper.GetText("Employee") %>','TableEdit.aspx?ei=_Employee');">
                            <% =LangHelper.GetText("Employee")%></a></li>
                        <li><a href="javascript:f_addTab('Group','<% =LangHelper.GetText("Employee Group Define") %>','TableEdit.aspx?ei=_Group');">
                            <% =LangHelper.GetText("Employee Group Define")%></a></li>
                        <li><a href="javascript:f_addTab('Employee_In_Group','<% =LangHelper.GetText("Employee In Group Assign") %>','TableEdit.aspx?ei=Employee_In_Group');">
                            <% =LangHelper.GetText("Employee In Group Assign")%></a></li>
                    </ul>
                </div>
                <div class="hd">
                    <h3>
                        <% =LangHelper.GetText("Common Organization")%></h3>
                </div>
                <div class="bd">
                    <ul>
                        <li><a href="javascript:f_addTab('Building','<% =LangHelper.GetText("Define Building") %>','TableEdit.aspx?ei=_Building');">
                            <% =LangHelper.GetText("Define Building")%></a></li>
                        <li><a href="javascript:f_addTab('Workshop','<% =LangHelper.GetText("Define Workshop") %>','TableEdit.aspx?ei=_Workshop');">
                            <% =LangHelper.GetText("Define Workshop")%></a></li>
                        <li><a href="javascript:f_addTab('Line','<% =LangHelper.GetText("Define Lines") %>','TableEdit.aspx?ei=_Line');">
                            <% =LangHelper.GetText("Define Lines")%></a></li>
                        <li><a href="javascript:f_addTab('Station_Catalog','<% =LangHelper.GetText("Station Catalog") %>','TableEdit.aspx?ei=_Station_Catalog');">
                            <% =LangHelper.GetText("Station Catalog")%></a></li>
                        <li><a href="javascript:f_addTab('Station_Type','<% =LangHelper.GetText("Station Type") %>','TableEdit.aspx?ei=_Station_Type');">
                            <% =LangHelper.GetText("Station Type")%></a></li>
                        <li><a href="javascript:f_addTab('Station','<% =LangHelper.GetText("Station") %>','TableEdit.aspx?ei=_Station');">
                            <% =LangHelper.GetText("Station")%></a></li>
                        <li><a href="javascript:f_addTab('Fixture','<% =LangHelper.GetText("Fixture") %>','TableEdit.aspx?ei=_Fixture');">
                            <% =LangHelper.GetText("Fixture")%></a></li>
                    </ul>
                </div>
                <div class="hd">
                    <h3>
                        <% =LangHelper.GetText("Business Organization")%></h3>
                </div>
                <div class="bd">
                    <ul>
                        <li><a href="javascript:f_addTab('BU','<% =LangHelper.GetText("Define BU") %>','TableEdit.aspx?ei=_BU');">
                            <% =LangHelper.GetText("Define BU")%></a></li>
                        <li><a href="javascript:f_addTab('Project','<% =LangHelper.GetText("Define Project") %>','TableEdit.aspx?ei=_Project');">
                            <% =LangHelper.GetText("Define Project")%></a></li>
                        <li><a href="javascript:f_addTab('Part_Family','<% =LangHelper.GetText("Part Family") %>','TableEdit.aspx?ei=_Part_Family');">
                            <% =LangHelper.GetText("Part Family")%></a></li>
                        <li><a href="javascript:f_addTab('Part_Number','<% =LangHelper.GetText("Part Number") %>','TableEdit.aspx?ei=_Part_Number');">
                            <% =LangHelper.GetText("Part Number")%></a></li>
                    </ul>
                </div>
                <div class="hd">
                    <h3>
                        <% =LangHelper.GetText("Indicator And Dashboard")%></h3>
                </div>
                <div class="bd">
                    <ul>
                        <li><a href="javascript:f_addTab('_Measurement_Type','<% =LangHelper.GetText("Measurement Type") %>','TableEdit.aspx?ei=_Measurement_Type');">
                            <% =LangHelper.GetText("Measurement Type")%></a></li>
                        <li><a href="javascript:f_addTab('_Measurement_Period','<% =LangHelper.GetText("Measurement Period") %>','TableEdit.aspx?ei=_Measurement_Period');">
                            <% =LangHelper.GetText("Measurement Period")%></a></li>
                        <li><a href="javascript:f_addTab('_Measurement_Limit','<% =LangHelper.GetText("Measurement Limit") %>','TableEdit.aspx?ei=_Measurement_Limit');">
                            <% =LangHelper.GetText("Measurement Limit")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Action','<% =LangHelper.GetText("Action By Indicator") %>','TableEdit.aspx?ei=_Indicator_Action');">
                            <% =LangHelper.GetText("Action By Indicator")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator','<% =LangHelper.GetText("Define Indicator") %>','TableEdit.aspx?ei=_Indicator');">
                            <% =LangHelper.GetText("Define Indicator")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Action_Value','<% =LangHelper.GetText("Action Target By Indicator") %>','TableEdit.aspx?ei=_Indicator_Action_Value');">
                            <% =LangHelper.GetText("Action Target By Indicator")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Action_Group','<% =LangHelper.GetText("Define Action Group") %>','TableEdit.aspx?ei=_Indicator_Action_Group');">
                            <% =LangHelper.GetText("Define Action Group")%></a></li>
                        <li><a href="javascript:f_addTab('Indicator_Action_Value_In_Group','<% =LangHelper.GetText("Action Group Assign") %>','TableEdit.aspx?ei=Indicator_Action_Value_In_Group');">
                            <% =LangHelper.GetText("Action Group Assign")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Level','<% =LangHelper.GetText("Alarm Level Of Indicator") %>','TableEdit.aspx?ei=_Indicator_Level');">
                            <% =LangHelper.GetText("Alarm Level Of Indicator")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Group','<% =LangHelper.GetText("Define Indicator Group") %>','TableEdit.aspx?ei=_Indicator_Group');">
                            <% =LangHelper.GetText("Define Indicator Group")%></a></li>
                        <li><a href="javascript:f_addTab('Indicator_In_Group','<% =LangHelper.GetText("Indicator Group Assign") %>','TableEdit.aspx?ei=Indicator_In_Group');">
                            <% =LangHelper.GetText("Indicator Group Assign")%></a></li>
                        <li><a href="javascript:f_addTab('_Indicator_Reason','<% =LangHelper.GetText("Explanation Reason Catalog") %>','TableEdit.aspx?ei=_Indicator_Reason');">
                            <% =LangHelper.GetText("Explanation Reason Catalog")%></a></li>
                        <li><a href="javascript:f_addTab('_Page','<% =LangHelper.GetText("Page Of Dashboard") %>','TableEdit.aspx?ei=_Page');">
                            <% =LangHelper.GetText("Page Of Dashboard")%></a></li>
                    </ul>
                </div>
            </div>

            <script type="text/javascript">                jQuery("#sideMenu").slide({ titCell: ".hd", targetCell: ".bd", effect: "slideDown", trigger: "click" });</script>

        </asp:Panel>
        <asp:Panel ID="tabSetting" runat="server" position="center">
            <div tabid="Introduce" title="Introduce">
            </div>
        </asp:Panel>
    </asp:Panel>
    </form>
</body>
</html>
