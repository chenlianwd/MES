function htmlEncode(s)
{
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(s));
    return div.innerHTML;
}
function htmlDecode(s)
{
    var div = document.createElement('div');
 
    div.innerHTML = s;
    return div.innerText || div.textContent;
}
function trim(s)
{
    return s.replace(/^\s+|\s+$/g, ''); 
}
function ltrim(s)
{
    return s.replace(/^\s+/, ''); 
}
function rtrim(s)
{
    return s.replace(/\s+$/, ''); 
}
function fulltrim(s)
{
    return s.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g, '').replace(/\s+/g, ''); 
}

function SetMouseOverColor(element)
{
    element.style.textDecoration = "underline";
}
function SetMouseLeaveColor(element)
{
    element.style.textDecoration = "none";
}