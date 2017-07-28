<%@ Page Language="c#" CodeFile="Login.aspx.cs" Inherits="loginForm" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="css/LoginStyle.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .FailText
        {
            color: #FF0000;
        }
    </style>

    <script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>

    <script type="text/javascript">

        $(function ()
        {
            LoginForm.iptUser.focus();
        });

        var bVerifyCodeOK = false;

        function f_Check()
        {
            var obj = LoginForm.iptUser;
            var str = "" + obj.value;
            if (str.length <= 0)
            {
                errorInfoLable.innerText = "<% =LangHelper.GetText("Pls Enter Your User Name !") %>";
                obj.focus();
                return false;
            }
            obj = LoginForm.iptPwd;
            str = "" + obj.value;
            if (str.length <= 0)
            {
                errorInfoLable.innerText = "<% =LangHelper.GetText("Pls Enter Your Password !") %>";
                obj.focus();
                return false;
            }

            obj = LoginForm.iptNewPwd;
            if (LoginForm.chkChangePwd.checked && obj.value.length == 0)
            {
                errorInfoLable.innerText = "<% =LangHelper.GetText("Pls Enter Your New Password !") %>";
                obj.focus();
                return false;
            }

            obj = LoginForm.iptConfirmPwd;
            if (LoginForm.chkChangePwd.checked && obj.value.length == 0)
            {
                errorInfoLable.innerText = "<% =LangHelper.GetText("Pls Confirm Your New Password!") %>";
                obj.focus();
                return false;
            }

            if (LoginForm.chkChangePwd.checked && LoginForm.iptNewPwd.value != LoginForm.iptConfirmPwd.value)
            {
                errorInfoLable.innerText = "<%  =LangHelper.GetText("Password is difference On Twice Enter !") %>";
                obj.focus();
                return false;
            }

//            obj = LoginForm.iptCheckCode;
//            if (!bVerifyCodeOK)
//            {
//                errorInfoLable.innerText = "<%  =LangHelper.GetText("Enter Verify Code Is Incorrect !") %>";
//                obj.focus();
//                return false;
//            }

            return true;
        }

        function f_CheckUser()
        {
            if (LoginForm.iptUser.value.length > 0)
            {
                errorInfoLable.innerHTML = "&nbsp;";
                $.ajax({
                    type: 'post',
                    url: 'FetchData.ashx?fn=GetUserInfo',
                    data: { sUserName: LoginForm.iptUser.value },
                    cache: false,
                    dataType: 'json',
                    success: function (data)
                    {
                        if (!data)
                        {
                            errorInfoLable.innerText = "<% =LangHelper.GetText("User Is NOT Existing !") %>"
                            return;
                        }

                        if (data.sErrMsg)
                        {
                            errorInfoLable.innerText = data.sErrMsg;
                            return;
                        }

                        LoginForm.chkChangePwd.disabled = data.Change_Pwd_When_Next_Login || data.Use_AD_Login;
                        LoginForm.chkChangePwd.checked = data.Change_Pwd_When_Next_Login && (!data.Use_AD_Login);
                        f_chkChangePwd(LoginForm.chkChangePwd);
                    },
                    error: function (XMLHttpRequest, textStatus)
                    {
                        errorInfoLable.innerText = XMLHttpRequest.responseText;
                    }
                });
            }
        }

        function f_CheckVerifyCode()
        {
            if (LoginForm.iptCheckCode.value.length > 0)
            {
                errorInfoLable.innerHTML = "&nbsp;";
                $.ajax({
                    type: 'post',
                    url: 'FetchData.ashx?fn=CheckVerifyCode',
                    data: { VerifyCode: LoginForm.iptCheckCode.value },
                    cache: false,
                    dataType: 'json',
                    success: function (data)
                    {
                        if (!data)
                            return;

                        if (data.sErrMsg)
                        {
                            errorInfoLable.innerText = data.sErrMsg;
                            return;
                        }
                        if(data.Result)
                            bVerifyCodeOK = true;
                    },
                    error: function (XMLHttpRequest, textStatus)
                    {
                        errorInfoLable.innerText = XMLHttpRequest.responseText;
                    }
                });
            }
        }

        function f_chkChangePwd(chk)
        {
            LoginForm.bChangePwd.value = chk.checked;
  
            var sDpy = "none";
            if (chk.checked)
                sDpy = "block";
            document.getElementById("divLblNewPwd").style.display = sDpy;
            document.getElementById("divEdtNewPwd").style.display = sDpy;
            document.getElementById("divLblConfirmPwd").style.display = sDpy;
            document.getElementById("divEdtConfirmPwd").style.display = sDpy;

        }
        
    </script>

</head>
<body scroll="no" unselectable="on" leftmargin="0" topmargin="0" rightmargin="0"
    style="background-color: #FFFFFF;">
    <form method="post" action="" id="LoginForm" onsubmit="return f_Check();" runat="server">
    <table class="table-main" style="border-collapse: collapse; text-align: center;"
        align="center">
        <tbody>
            <tr>
                <td align="right" colspan="3">
                    <asp:Panel ID="errorInfoLable" runat="server" CssClass="FailText">
                        &nbsp;
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <div style="width: 160px">
                        <asp:Label ID="lblUser" runat="server" for="iptUser" Text="User Name:" />
                    </div>
                </td>
                <td align="left">
                    <input id="iptUser" name="iptUser" type="text" class="ipt" onfocus="this.className='ipt-focus'"
                        onblur="this.className='ipt';f_CheckUser();" />
                </td>
                <td>
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <div style="width: 160px">
                        <asp:Label ID="lblCheckCode" runat="server" for="iptCheckCode" Text="Verify Code:" />
                    </div>
                </td>
                <td align="left">
                    <input id="iptCheckCode" name="iptCheckCode" type="text" class="ipt" onfocus="this.className='ipt-focus'"
                        onblur="this.className='ipt';f_CheckVerifyCode();" />
                </td>
                <td>
                </td>
                <td>
                    <asp:Image ID="imgVerifyCode" runat="server" onclick="bVerifyCodeOK=false;this.src='FetchData.ashx?fn=VerifyCode&k='+Math.random()" />
                </td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Label ID="lblPwd" runat="server" for="iptPwd" Text="Password:" />
                </td>
                <td align="left">
                    <input id="iptPwd" name="iptPwd" type="password" class="ipt" onfocus="this.className='ipt-focus'"
                        onblur="this.className='ipt';" />
                </td>
                <td align="right">
                    <input id="chkChangePwd" name="chkChangePwd" type="checkbox" value="1" onclick="f_chkChangePwd(this);" />
                    <input id="bChangePwd" name="bChangePwd" type="hidden" />
                </td>
                <td align="left">
                    <asp:Label ID="lblChangePwd" name="bChangePwd" runat="server" for="chkChangePwd"
                        Text="Change Password:" />
                </td>
            </tr>
            <tr>
                <td align="right">
                    <div style="display: none;" id="divLblNewPwd">
                        <asp:Label ID="lblNewPwd" runat="server" for="iptNewPwd" Text="New Password:" />
                    </div>
                </td>
                <td align="left">
                    <div style="display: none;" id="divEdtNewPwd">
                        <input id="iptNewPwd" name="iptNewPwd" type="password" class="ipt" onfocus="this.className='ipt-focus'"
                            onblur="this.className='ipt';" />
                    </div>
                </td>
                <td>
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <div style="display: none;" id="divLblConfirmPwd">
                        <asp:Label ID="lblConfirmPwd" runat="server" for="iptConfirmPwd" Text="Confirm New Password:" />
                    </div>
                </td>
                <td align="left">
                    <div style="display: none;" id="divEdtConfirmPwd">
                        <input id="iptConfirmPwd" type="password" class="ipt" onfocus="this.className='ipt-focus'"
                            onblur="this.className='ipt';" name="iptConfirmPwd" />
                    </div>
                </td>
                <td>
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td colspan="3" align="center">
                    <asp:Button ID="btnSubmit" runat="server" UseSubmitBehavior="true" Text="Login" class="btn" />
                </td>
            </tr>
        </tbody>
    </table>
    </form>
</body>
</html>
