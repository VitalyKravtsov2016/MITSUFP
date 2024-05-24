var bPageLoadad = false;
function InitPage()
{
	bPageLoadad = true;
	LayoutPage();
	
	if(document.getElementById('tsc'))
		SetTitleSearch(document.getElementById('tsc').value == 1);
	
	var hash = document.location.hash.replace('#','');
	if(hash != '')
	{
		var anchors = document.getElementsByName(hash);
		if(anchors.length)
			anchors[0].scrollIntoView();
	}
	
	var mainspace = document.getElementById('__mainspace__');
	if(mainspace && mainspace.className != 'mainspace-tabbed')
		mainspace.focus();
	
	for(var nAdj = 0; nAdj < TabAdj.arAdj.length; nAdj++)
	{
		var adj = document.getElementById(TabAdj.arAdj[nAdj].id);
		if(adj.parentNode.className == 'tabspace' &&
			adj.parentNode.style &&
			adj.parentNode.style.display == 'block')
		{
			var arDiv = TabAdj.arAdj[nAdj].ardiv;
			if(arDiv.length)
			{
				for(var nDiv = 0; nDiv < arDiv.length; nDiv++)
				{
					var mDiv = document.getElementById(arDiv[nDiv]);
					if(mDiv.parentNode.className == 'tabspace' &&
						mDiv.parentNode.style &&
						mDiv.parentNode.style.display == 'block' &&
						mDiv.className == 'docframe')
					{
						mDiv.getElementsByTagName('IFRAME')[0].focus();
						break;
					}
				}
			}
			else
				adj.focus();
			break;
		}
	}
}

var g_bInLayout = false;

function TabAdjInfo(sAdj, arDiv)
{
	this.id = sAdj;
	this.ardiv = arDiv;
}

var TabAdj = 
{
	arAdj:[],
	
	AddTab: function(sAdj, arDiv)
	{
		this.arAdj[this.arAdj.length] = new TabAdjInfo(sAdj, arDiv);
	}
}

var arResizeHandlers = new Array();
function addResizeHandler(h)
{
	arResizeHandlers.push(h);
}

function LayoutPage()
{
	if(!bPageLoadad)
		return;
	if(g_bInLayout)
		return;
	g_bInLayout = true;

	var footer, mainSpace, nMainHeight;

	footer = document.getElementById('__footer__');
	mainSpace = document.getElementById('__mainspace__');
	if(footer && mainSpace)
	{
		nMainHeight = mainSpace.offsetHeight + document.documentElement.clientHeight - footer.offsetTop - footer.offsetHeight;
		if(nMainHeight < 0)
			nMainHeight = 0;
		mainSpace.style.height = nMainHeight + 'px';
	}

	var tabfooter, nBottomSpace;

	tabfooter = document.getElementById('__tabs_footer__');
	nBottomSpace = (tabfooter) ? tabfooter.offsetHeight : 0;

	var adj, nAdjHeight, mDiv, nHeight;
	
	//for(nAdj in TabAdj.arAdj)
	for(var nAdj = 0; nAdj < TabAdj.arAdj.length; nAdj++)
	{
		adj = document.getElementById(TabAdj.arAdj[nAdj].id);
		nAdjHeight = nMainHeight - (adj.offsetTop - mainSpace.offsetTop) - nBottomSpace;
		if(nAdjHeight < 0)
			nAdjHeight = 0;
		adj.style.height = nAdjHeight + 'px';
		
		var arDiv = TabAdj.arAdj[nAdj].ardiv;
		for(var nDiv = 0; nDiv < arDiv.length; nDiv++)
		{
			mDiv = document.getElementById(arDiv[nDiv]);
			nHeight = nAdjHeight - mDiv.offsetTop;
			if(nHeight < 0)
				nHeight = 0;
			mDiv.style.height = nHeight + 'px';
			var children = mDiv.childNodes;
			if(IsIE())
				for(var i = 0; i < mDiv.childNodes.length; i++)
					if(mDiv.childNodes[i].tagName == 'IFRAME')
					{
						mDiv.childNodes[i].style.height = nHeight + 'px';
						if(mDiv.childNodes[i].contentWindow.document && mDiv.childNodes[i].contentWindow.document.body)
							mDiv.childNodes[i].contentWindow.document.body.style.height = '100%';
						break;
					}
		}
	}
	
	for(h in arResizeHandlers)
	{
		try {arResizeHandlers[h]()} catch(e){}
	}

	g_bInLayout = false;
}

function _getTabEl(obj, get, sTag)
{
	var oTabEl;
	
	oTabEl = obj[get];
	while(oTabEl && (oTabEl.tagName != sTag) && (oTabEl.className.substr(0,3) != 'tab'))
		oTabEl = oTabEl[get];
	
	return oTabEl;
}

function getPreviousTabEl(obj)
{
	return _getTabEl(obj, 'previousSibling', 'SPAN');
}

function getNextTabEl(obj)
{
	return _getTabEl(obj, 'nextSibling', 'SPAN');
}

var arsActiveTab = new Array('','','');
var arTabState = new Array
(
	new Array(false, false, false, false), 
	new Array(false, false, false, false, false, false, false, false, false), 
	new Array(false, false, false, false, false, false, false, false, false)
);

function UpdateTabs(sTab)
{
	var nTabs = sTab.substr(0,1);
	var nTabsIdx = (sTab.substr(0,1)-1)*sTab.substr(2,1);
	var sActiveTab = arsActiveTab[nTabsIdx];
	var nActiveTab = sActiveTab.substr(2*nTabs)-1;

	var oTab, oPrev, oNext;
	var i, nFirst = -1, nLast = -1;
	for(i = 0; i < arTabState[nTabsIdx].length; i++)
	{
		oTab = document.getElementById('__tab'+sTab+(i+1));
		oPrev = getPreviousTabEl(oTab);
		oNext = getNextTabEl(oTab);

		oPrev.className = 'tab'+nTabs+'i';
		oTab.className  = 'tab'+nTabs+'t';
		oNext.className = 'tab'+nTabs+'i';

		if(arTabState[nTabsIdx][i])
		{
			oTab.style.display  = 'inline-block';
			oNext.style.display  = 'inline-block';

			if(nFirst < 0)
				nFirst = i;
			nLast = i;
		}
		else
		{
			if(i==0)
				oPrev.style.display  = 'none';
			oTab.style.display  = 'none';
			oNext.style.display  = 'none';
		}
	}

	if(nActiveTab >= 0)
	{
		oTab = document.getElementById('__tab'+sTab+(nActiveTab+1));
		oPrev = getPreviousTabEl(oTab);
		oNext = getNextTabEl(oTab);
		for(var nPA = nActiveTab-1; nPA >= 0; nPA--)
		{
			if(arTabState[nTabsIdx][nPA])
			{
				var oPTab = document.getElementById('__tab'+sTab+(nPA+1));
				oPrev = getNextTabEl(oPTab);
				break;
			}
		}
		oPrev.className = 'tab'+nTabs+'i-an';
		oTab.className  = 'tab'+nTabs+'t-a';
		oNext.className = 'tab'+nTabs+'i-ap';
	}

	if(nFirst >= 0)
	{
		oTab = document.getElementById('__tab'+sTab+(nFirst+1));
		oPrev = getPreviousTabEl(oTab);
		oPrev.style.display  = 'inline-block';
		oPrev.className += '-f';
	}

	if(nLast >= 0)
	{
		oTab = document.getElementById('__tab'+sTab+(nLast+1));
		oNext = getNextTabEl(oTab);
		oNext.className += '-l';
	}
}

function ShowTab(oTab, bVisible)
{
	if(!oTab || oTab.id.substr(0, 5) != '__tab')
		return;
	var sTab = oTab.id.substr(5);
	var nTabs = sTab.substr(0,1);
	var nTabsIdx = (sTab.substr(0,1)-1)*sTab.substr(2,1);
	var nTab = sTab.substr(2*nTabs)-1;
	
	arTabState[nTabsIdx][nTab] = bVisible;
	
	UpdateTabs(sTab.substr(0,2*nTabs));
}

function SetTab(oTab)
{
	if(oTab.id.substr(0, 5) != '__tab')
		return;

	var sTab = oTab.id.substr(5);
	var nTabs = sTab.substr(0,1);
	var nTabsIdx = (sTab.substr(0,1)-1)*sTab.substr(2,1);
	var nTab = sTab.substr(2*nTabs)-1;

	var sActiveTab = arsActiveTab[nTabsIdx];
	if(sActiveTab == sTab)
		return;
	arsActiveTab[nTabsIdx] = sTab;
	arTabState[nTabsIdx][nTab] = true;

	var oSpaceOld = document.getElementById('__tabspace'+sActiveTab);
	var oSpaceNew = document.getElementById('__tabspace'+sTab);

	UpdateTabs(sTab.substr(0,2*nTabs));

	if(oSpaceOld)
		oSpaceOld.style.display = 'none';
	if(oSpaceNew)
		oSpaceNew.style.display = 'block';

	LayoutPage();
}

function initTabs(sTab, nTab)
{
	var nTabsIdx = (sTab.substr(5,1)-1)*sTab.substr(7,1);

	for(var i = 1; i <= nTab; i++)
		arTabState[nTabsIdx][i-1] = true;

	for(; i <= 9; i++)
		arTabState[nTabsIdx][i-1] = false;

	UpdateTabs(sTab.substr(5));
	LayoutPage();
}

function SetTabN(oTab)
{
	if(oTab.id.substr(0, 7) != '__tabn-')
		return;
	var nTab = oTab.id.substr(7);

	var oTab1 = document.getElementById('__tabn-1');
	var oTab2 = document.getElementById('__tabn-2');
	var oTab3 = document.getElementById('__tabn-3');
	
	oTab1.className = (nTab == 1) ? 'tabnt-a' : 'tabnt';
	oTab2.className = (nTab == 2) ? 'tabnt-a' : 'tabnt';
	oTab3.className = (nTab == 3) ? 'tabnt-a' : 'tabnt';
	
	var oInt;
	oInt = getPreviousTabEl(oTab1);
	oInt.className = (nTab == 1) ? 'tabni-an-f' : 'tabni-f';
	oInt = getPreviousTabEl(oTab2);
	oInt.className = (nTab == 1) ? 'tabni-ap' : (nTab == 2) ? 'tabni-an' : 'tabni';
	oInt = getPreviousTabEl(oTab3);
	oInt.className = (nTab == 2) ? 'tabni-ap' : (nTab == 3) ? 'tabni-an' : 'tabni';
	oInt = getNextTabEl(oTab3);
	oInt.className = (nTab == 3) ? 'tabni-ap-l' : 'tabni-l';
	
	var oSpace;
	oSpace = document.getElementById('__tabnspace-1');
	oSpace.style.display = (nTab == 1) ? 'block' : 'none';
	oSpace = document.getElementById('__tabnspace-2');
	oSpace.style.display = (nTab == 2) ? 'block' : 'none';
	oSpace = document.getElementById('__tabnspace-3');
	oSpace.style.display = (nTab == 3) ? 'block' : 'none';
}


var arTimer = new Array();
function ShowObject(sObj, bShow, bImmediately)
{
	var oObj = document.getElementById(sObj);
	if(!oObj)
		return;
	
	if(bShow)
	{
		var timer = arTimer[sObj];
		if(timer)
			clearTimeout(timer);
		oObj.style.display = 'block';
	}
	else
	{
		if(bImmediately)
		{
			HideObject(sObj);
			timerHideAuth = 0;
		}
		else
			arTimer[sObj] = setTimeout("HideObject('"+sObj+"')", 1000);
	}
}

function HideObject(sObj)
{
	var oObj = document.getElementById(sObj);
	if(!oObj)
		return;

	oObj.style.display = 'none';
}

function AuthPopup()
{
	ShowObject('authpopup', true, true);
	var authformlogin = document.getElementById('authformlogin');
	var authformpassword = document.getElementById('authformpassword');
	if(authformlogin.value.length == 0)
		authformlogin.focus();
	else
		authformpassword.focus();
}

function OnPopupMouseOut(evt, oPopup)
{
	var oTo;
	
	if(evt.toElement)
		oTo = evt.toElement; // IE
	else if(evt.relatedTarget) // Moz
	{
		oTo = evt.relatedTarget;
		try
		{
			var classname = oTo.className;
		}
		catch(e)
		{
			// alert(e);
			return;
		}
	}
	else
		oTo = null;

	while(oTo)
	{
		if(oTo == oPopup)
			return;
		
		try 
		{
			oTo = oTo.parentNode;
		}
		catch(e)
		{
			oTo = null;
		}
	}

	ShowObject(oPopup.id, false, false);
}

function OnFormPopupKey(evt, sPopup, sForm)
{
	switch(evt.keyCode)
	{
	case 27:  // Esc
		ShowObject(sPopup, false, true);
		return false;
	case 13: // Enter
		if(IsIE())
		{
			document.getElementById(sForm).submit();
			window.openid_form_submitted = true;
			return false;
		}
	default:
	}
}

function SetGlobalSearch(bGS)
{
	var oSM, oST, oInput;

	oSM = document.getElementById('search_region_menu');
	oST = document.getElementById('search_region_text');
	oInput = document.getElementById('gsc');
	
	if(!oSM || !oST || !oInput)
		return;
	
	if(typeof bGS == 'string')
		bGS = parseInt(bGS);
	
	if(bGS)
	{
		oSM.style.top = '-5px';
		oST.innerHTML = '<nobr>Все&nbsp;разделы&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr>';
		window.top.document.cookie = 'ITS_GSC=1; path=/';
		oInput.value = 1;
	}
	else
	{
		oSM.style.top = '-21px';
		oST.innerHTML = '<nobr>Текущий&nbsp;справочник</nobr>';
		window.top.document.cookie = 'ITS_GSC=0; path=/';
		oInput.value = 0;
	}
	
	ShowObject('search_region_menu', false, true);
	document.getElementById('searchText').focus();
}

function SetTitleSearch(bTS)
{
	var oTS, oInput;

	ShowObject('titlesearch', false, true);

	oTS = document.getElementById('ts_option');
	if(!oTS)
		return;
	oInput = document.getElementById('tsc');
	if(!oInput)
		return;

	if(bTS)
	{
		oTS.innerHTML = 'Заголовкам &#x25bc;'; // +String.fromCharCode(0x25bc);
		oInput.value = 1;
	}
	else
	{
		oTS.innerHTML = 'Заголовкам и тексту &#x25bc;'; //+String.fromCharCode(0x25bc);
		oInput.value = 0;
	}
}
