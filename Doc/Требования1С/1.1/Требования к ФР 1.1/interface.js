
//----Core----//

function createElemLinks() {
	
	var hash=document.location.hash.split(':')
	var dbId = document.getElementById('dbId');
	var pageElems = {
		hash: document.location.hash,
		host: document.location.host,
		dbid: dbId ? dbId.innerHTML : null,
		mode: hash.shift()
	}
	switch(pageElems.mode)
	{
	case '#browse':
		{
			pageElems.activecl=hash.shift()
			if(pageElems.activecl=='-1')
			{
				pageElems.activecl=document.getElementById('clinfo-1').firstChild.innerHTML
			}
			var clid = 'clinfo-'+getClassNumber(pageElems.activecl);
			var clinfonode = document.getElementById(clid);
			if(clinfonode)
			{
				var clinfo = clinfonode.childNodes;
				pageElems.clinfo = {
					clid: clinfo.item(0).innerHTML,
					cltab: clinfo.item(1).innerHTML,
					clroot: clinfo.item(2).innerHTML,
					clactive: clinfo.item(3).innerHTML
				}
			}
			pageElems.clpath=hash
		}
		break
	case '#content':
		{
			pageElems.docid=hash.shift()
			if(!hash.length)
			{
				document.location.hash.replace(document.location.hash+':9');
				pageElems.doctab = '9';
				return pageElems;
			}
			pageElems.doctab=hash.shift()
			if(hash.length!=0)
				pageElems.docanchor=hash.shift()
		}
		break
	case '#search':
		{
			if(hash.length > 0)
			{
				pageElems.searchstr=hash[0]
			}
			else
			{
				pageElems.searchstr = false
			}
		}
		break
	case '#enhanced_search':
		{
			
		}
		break
	}
	return pageElems
	
}

// Google Analytics
var ga_last_page = '';

function ga_get_dbpage(path, hash)
{
	arHash = hash.split(':');
	switch(arHash[0])
	{
	case '#browse':
	case '#search':
	case '#enhanced_search':
		arHash[0] = arHash[0].substr(1);
		return path+'/'+arHash.join('/');
	case '#content':
		return (g_bAllow?'':'/noaccess')+path+'/content/'+arHash[1]+'/'+arHash[2];
	default:
		return path+hash;
	}
}
// ----

function setView() {
	
	window.pageElems=createElemLinks()
	switch(pageElems.mode)
	{
		case '#browse':
		{
			this.loadStack=pageElems.clpath
			this.interval=setInterval("processStack()",50)
			SetTab(document.getElementById('__tab1-1'))
			document.getElementById('__tab1-1').firstChild.href=document.location.hash
			document.getElementById('__tab2-1-'+getClassNumber(pageElems.activecl)).firstChild.href=document.location.hash
			SetTab(document.getElementById('__tab2-1-'+getClassNumber(pageElems.activecl)))
		}
		break
		case '#content':
		{
			updateDocTitle('Загрузка...');
			var reg = /#content:([^:]+)(?::([^:]+))?.*/i;
			if(document.getElementById('tabs2container') && (ids = document.location.hash.match(reg)))
			{
				var curdocid = (document.getElementById('__tab1-2').firstChild.href != '') ? document.getElementById('__tab1-2').firstChild.href.split('#')[1].split(':')[1] : false;
				var newdocid = ids[1];
				var newtabid = ids[2];
				if(newdocids = newdocid.match(/^(-?\d+)(,-?\d+)?$/) && (!curdocid || newdocid != curdocid))
				{
					window.top.current_clpath = false;
					var urlDoc='/db/its.gateway.php?db='+document.getElementById('dbId').innerHTML + '&action=getxml&query=doc__' + newdocid
					jsAjaxUtil.LoadData(urlDoc,displayDoc)
					if(newdocids[2])
						return
				}
				else if(curdocid && newtabid)
					openDoc(document.getElementById('__tab2-2-' + newtabid),'tab')
				else if(newdocid.length)
					openDoc(newdocid,'orphan')
			}
			document.getElementById('__tab1-2').firstChild.href=document.location.hash
			SetTab(document.getElementById('__tab1-2'))
			
			var frameDoc = get_frame_document('docframe,'+pageElems.doctab)
			
			if(frameDoc != null && frameDoc)
			{
				if(typeof pageElems.docanchor != 'undefined')
				{
					var anchors = frameDoc.getElementsByName(decodeURIComponent(pageElems.docanchor));
					if(anchors.length > 0)
						anchors[0].scrollIntoView();
				}
				else
					document.getElementById('docframe,'+pageElems.doctab).contentWindow.scrollTo(0, 0);
			}
		}
		break
		case '#search':
		{
			document.getElementById('__tab1-3').firstChild.href=document.location.hash
			if(pageElems.searchstr)
			{
				document.getElementById('searchText').value = decodeURIComponent(pageElems.searchstr)
				buildSearchRequest()
			}
			else
			{
				buildHistoryRequest()
			}
			SetTab(document.getElementById('__tab1-3'))
		}
		break
		case '#enhanced_search':
		{
			var schContainer = document.getElementById('__mdiv4-1__');
			
			if(document.getElementById('__mdiv4-1__').childNodes.length == 0)
			{
				var schCfg = document.getElementById('form');
				if(schCfg && schContainer)
				{
					schContainer.appendChild(document.createElement('BR'));
					
					for(var i = 0; i < schCfg.childNodes.length; i++)
					{
						var afmt = parseInt(schCfg.childNodes[i].className.split('_')[1]);
						var aid = schCfg.childNodes[i].id.split('_')[1];
						var atxt = schCfg.childNodes[i].firstChild.nodeValue;
						
						var tr = document.createElement('TR');
						var inputtd = document.createElement('TD');
						var labeltd = document.createElement('TD');
						var label = document.createElement('LABEL');
						
						var expander = document.createElement('IMG');
						expander.src = '/images/db/tree/plus.gif';
						expander.id = 'sch_exp_' + aid;
						expander.style.cursor = 'pointer';
						
						switch(afmt)
						{
							case 1:
							{
								var header = document.createElement('DIV');
								header.innerHTML = atxt + ' ';
								header.style.marginLeft = '10pt';
								header.style.fontWeight = 'bold';
								
								var checkbox = createInput('checkbox', {id: 'hdr_only_' + aid});
								checkbox.style.marginBottom = 0;
								//checkbox.style.border = '1px solid #FFE289';
								var label = document.createElement('LABEL');
								label.innerHTML = 'только по заголовкам';
								label.htmlFor = 'hdr_only_' + aid;
								label.style.fontWeight = 'normal';
								label.style.fontSize = '80%';
								
								var input = document.createElement('INPUT');
								input.id = 'txt_attr_' + aid;
								input.type = 'text';
								input.style.margin = '10pt';
								input.style.width = '30%';
								input.style.border = '1px solid #FFE289';
								
								addHandler(input, 'keypress', function(event)
								{
									if(event.keyCode == 13)
									{
										window.bEnhandedSearch = true;
										buildSearchRequest();
									}
								}
								);
								
								schContainer.appendChild(header);
								schContainer.appendChild(input);
								schContainer.appendChild(checkbox);
								schContainer.appendChild(label);
							}
							break;
							case 2:
							{
								continue; // статус, область поиска
							}
							break;
							case 3:
							case 31:
							{
								var header = document.createElement('DIV');
								header.appendChild(expander);
								header.appendChild(document.createTextNode(' ' + atxt));
								header.style.marginLeft = '10pt';
								header.style.fontWeight = 'bold';
								header.style.cursor = 'pointer';
								header.className = 'searchOptHeader';
								
								var selectedOpts = document.createElement('SPAN');
								selectedOpts.id = 'ftree_selection_' + aid;
								//selectedOpts.style.display = 'inline-block';
								selectedOpts.style.display = 'block';
								selectedOpts.style.fontSize = '80%';
								selectedOpts.style.fontStyle = 'italic';
								selectedOpts.style.fontWeight = 'normal';
								selectedOpts.style.paddingLeft = '16px';
								
								var selectedClear = document.createElement('SPAN');
								selectedClear.style.display = 'none';
								selectedClear.style.fontSize = '80%';
								selectedClear.style.fontWeight = 'normal';
								selectedClear.style.paddingLeft = '16px';
								selectedClear.style.cursor = 'pointer';
								selectedClear.style.color = '#C15016';
								selectedClear.innerHTML = 'Очистить';
								selectedClear.className = 'selectedClear';
								
								header.appendChild(selectedOpts);
								header.appendChild(selectedClear);
								
								addHandler(header, 'click', toggleEnhSchOpts);
								
								var container = document.createElement('DIV');
								container.id = 'ftree_sub_' + aid + '_-1';
								container.style.height = '200px';
								container.style.overflowY = 'scroll';
								container.style.backgroundColor = '#ffffff';
								container.style.margin = '10pt';
								container.style.border = '1px solid #FFE289';
								container.style.display = 'none';
								container.style.padding = '6pt';
								schContainer.appendChild(header);
								
								if(afmt == 3)
								{
									jsAjaxUtil.LoadData(
										'/db/its.gateway.php?db=' + document.getElementById('dbId').innerHTML + '&action=getxml&query=ftree__a=' + aid + ',f=-1',
										function(aid, container)
										{
											return function(data)
											{
												createFTreeBranch(data, aid, container);
											}
										}(aid, container)
									);
									
									addHandler(container, 'click', function(event)
									{
										var eventSrc = event.target || event.srcElement;
										if(!eventSrc || !eventSrc.nodeName)
											return;
										
										if(eventSrc.nodeName == 'IMG')
										{
											var src = eventSrc.src.split('/');
											if(src[src.length - 1].split('.')[0] == 'space')
												return;
											
											var aid = eventSrc.id.split('_')[2];
											var fid = eventSrc.id.split('_')[3];
											var container = document.getElementById('ftree_sub_' + aid + '_' + fid);
											var expanded = src[src.length - 1].split('.')[0] == 'minus';
											
											if(!expanded)
											{
												if(container.childNodes && container.childNodes.length == 0)
												{
													var checked = eventSrc.nextSibling.checked;
													setWindowCursor('progress');
													jsAjaxUtil.LoadData(
														'/db/its.gateway.php?db=' + document.getElementById('dbId').innerHTML + '&action=getxml&query=ftree__a=' + aid + ',f=' + fid,
														function(aid, fid, checked)
														{
															return function(data)
															{
																var container = document.getElementById('ftree_sub_' + aid + '_' + fid);
																createFTreeBranch(data, aid, container, checked);
																var exp = document.getElementById('ftree_exp_' + aid + '_' + fid);
																exp.src = exp.src.replace('plus', 'minus');
																container.firstChild.style.display = '';
																setWindowCursor('none');
															}
														}(aid, fid, checked)
													);
												}
												else
												{
													eventSrc.src = eventSrc.src.replace('plus', 'minus');
													container.firstChild.style.display = '';
												}
											}
											else
											{
												eventSrc.src = eventSrc.src.replace('minus', 'plus');
												container.firstChild.style.display = 'none';
											}
											return false;
										}
										else if(eventSrc.nodeName == 'INPUT')
										{
											var aid = parseInt(eventSrc.id.split('_')[1]);
											var fid = parseInt(eventSrc.id.split('_')[2]);
											var selectedOpts = document.getElementById('ftree_selection_' + aid);
											
											var checked = eventSrc.checked;
											if(!checked)
											{
												var curr = eventSrc;
												while(curr.nodeName == 'INPUT')
												{
													var curr_aid = curr.id.split('_')[1];
													var curr_fid = curr.id.split('_')[2];
													
													var selected = document.getElementById('selected_' + curr_aid + '_' + curr_fid);
													
													if(selected)
														selectedOpts.removeChild(selected);
													
													curr.checked = false;
													
													var curr_cont = curr.parentNode.parentNode;
													if(curr_cont.id.split('_')[3] == '-1')
														break;
													else
														curr = curr_cont.previousSibling.previousSibling;
												}
											}
											else
											{
												var selected = document.createElement('SPAN');
												selected.id = 'selected_' + aid + '_' + fid;
												selected.innerHTML = eventSrc.nextSibling.innerHTML;
												selected.style.marginLeft = '2pt';
												selected.style.marginRight = '2pt';
												selected.style.display = 'block';
												
												if(document.getElementById(selected.id) == null)
													selectedOpts.appendChild(selected);
											}
											
											var sub = eventSrc.nextSibling.nextSibling;
											
											if(sub && sub.id && sub.id.match('ftree_sub'))
											{
												var children = sub.getElementsByTagName('INPUT');
												var len = children.length;
												
												for(var i = 0; i < len; i++)
												{
													children[i].checked = checked;
													if(!checked)
													{
														var selected = document.getElementById('selected_' + children[i].id.split('_')[1] + '_' + children[i].value);
														
														if(selected)
															selectedOpts.removeChild(selected);
													}
													else
													{
														var selected = document.createElement('SPAN');
														selected.id = 'selected_' + children[i].id.split('_')[1] + '_' + children[i].value;
														selected.innerHTML = children[i].nextSibling.innerHTML;
														selected.style.marginLeft = '2pt';
														selected.style.marginRight = '2pt';
														selected.style.display = 'block';
														
														if(document.getElementById(selected.id) == null)
															selectedOpts.appendChild(selected);
													}
												}
											}
											
											selectedOpts.nextSibling.style.display = (selectedOpts.childNodes.length > 0) ? 'block' : 'none';
										}
									}
									);
								}
								else
								{
									container.style.display = 'none';
									container.style.marginTop = 0;
									
									var input = document.createElement('INPUT');
									input.type = 'text';
									input.id = 'ftree_suggest_' + aid;
									input.style.margin = '10pt';
									input.style.border = '1px solid #FFE289';
									input.style.display = 'none';
									input.style.width = '30%';
									input.value = 'Введите первые символы номера...';
									
									addHandler(input, 'focus', function(event)
									{
										var eventSrc = event.target || event.srcElement;
										if(eventSrc.value.match('Введите первые символы номера...'))
											eventSrc.value = eventSrc.value.replace('Введите первые символы номера...', '');
									}
									);
									
									addHandler(input, 'blur', function(event)
									{
										var eventSrc = event.target || event.srcElement;
										if(eventSrc.value == '')
											eventSrc.value = 'Введите первые символы номера...';
									}
									);
									
									window['g_sInputText' + aid] = '';
									window['g_timerID' + aid] = -1;
									
									addHandler(input, 'keyup', function(event)
									{
										var obj = event.srcElement || event.target || false;
										if(!obj)
											return;

										var sText = obj.value;
										var aid = obj.id.split('_')[2];
										if(window['g_sInputText' + aid] !== sText)
										{
											window['g_sInputText' + aid] = sText;
											if(window['g_timerID' + aid] != -1)
												clearTimeout(window['g_timerID' + aid]);
											
											window['g_timerID' + aid] = setTimeout(function()
											{
												return function(event)
												{
													setWindowCursor('progress');
													loadSuggestion(aid);
												}
											}(aid),
											350);
										}
									}
									);
									
									addHandler(container, 'click', function(event)
									{
										var eventSrc = event.target || event.srcElement;
										if(!eventSrc || !eventSrc.nodeName)
											return;
											
										if(eventSrc.nodeName == 'B')
											eventSrc = eventSrc.parentNode;
										
										if(eventSrc.nodeName == 'A')
										{
											var aid = parseInt(eventSrc.parentNode.id.split('_')[2]);
											document.getElementById('ftree_suggest_' + aid).value = eventSrc.innerText || eventSrc.textContent;
											if(event.stopPropagation)
												event.stopPropagation();
											if(event.preventDefault)
												event.preventDefault();
											
											toggleEnhSchOpts();
											
											return false;
										}
									}
									);
									
									schContainer.appendChild(input);
								}
								
								schContainer.appendChild(container);
							}
							break;
							case 4:
							{
								var header = document.createElement('DIV');
								header.appendChild(expander);
								header.appendChild(document.createTextNode(' ' + atxt));
								header.style.fontWeight = 'bold';
								header.style.cursor = 'pointer';
								header.className = 'searchOptHeader';
								header.style.marginLeft = '10pt';
								
								addHandler(header, 'click', toggleEnhSchOpts);
								
								var selectedOpts = document.createElement('SPAN');
								selectedOpts.id = 'ftree_selection_' + aid;
								//selectedOpts.style.display = 'inline-block';
								selectedOpts.style.display = 'block';
								selectedOpts.style.fontSize = '80%';
								selectedOpts.style.fontStyle = 'italic';
								selectedOpts.style.fontWeight = 'normal';
								selectedOpts.style.paddingLeft = '16px';
								
								var selectedClear = document.createElement('SPAN');
								//selectedClear.style.display = 'block';
								selectedClear.style.display = 'none';
								selectedClear.style.fontSize = '80%';
								selectedClear.style.fontWeight = 'normal';
								selectedClear.style.paddingLeft = '16px';
								selectedClear.style.cursor = 'pointer';
								selectedClear.style.color = '#C15016';
								selectedClear.innerHTML = 'Очистить';
								selectedClear.className = 'selectedClear';
								
								header.appendChild(selectedOpts);
								header.appendChild(selectedClear);
								
								var container = document.createElement('DIV');
								container.id = 'ftree_sub_' + aid + '_-1';
								container.style.display = 'none';
								container.style.marginLeft = '10pt';
								container.style.marginTop = '10pt';
								
								var input = document.createElement('INPUT');
								input.type = 'text';
								input.id = 'date_' + aid;
								input.name = 'date_' + aid;
								input.style.border = '1px solid #FFE289';
								//input.style.width = '30%';
								
								var calen = document.createElement('IMG');
								calen.src = '/bitrix/images/icons/calendar.gif';
								calen.style.border = 0;
								calen.style.marginLeft = '5px';
								calen.style.cursor = 'pointer';
								calen.title = 'Календарь';
								
								addHandler(input, 'click', function(aid, input)
								{
									return function(event)
									{
										if(input.value == '')
											_Calendar('name=date_' + aid + '&from=&to=&form=enhanced_search', input.value);
									}
								}(aid, input)
								);
								
								addHandler(calen, 'click', function(aid, input)
								{
									return function(event)
									{
										_Calendar('name=date_' + aid + '&from=&to=&form=enhanced_search', input.value);
									}
								}(aid, input)
								);
								
								container.appendChild(input);
								container.appendChild(calen);
								schContainer.appendChild(header);
								schContainer.appendChild(container);
								//<a title="Календарь" onclick="window.Calendar('name=ACTIVE_TO&amp;from=&amp;to=&amp;form=add_int_user', document['add_int_user']['ACTIVE_TO'].value);" href="javascript:void(0);"><img width="15" height="15" border="0" alt="Календарь" src="/bitrix/images/icons/calendar.gif"></a>
								
							}
							break;
						}
						
					}
				}
				
				if(document.getElementById('__mdiv4-1__').childNodes.length > 0)
				{
					var reset = document.createElement('INPUT');
					reset.type = 'button';
					reset.value = 'Очистить';
					reset.style.marginLeft = '10pt';
					reset.style.marginTop = '10pt';
					reset.style.border = '1px solid #FFE289';
					reset.style.backgroundColor = '#FFFFFF';
					
					addHandler(reset, 'click', function(){clearEnhSchOpts();});
					
					var submit = document.createElement('INPUT');
					submit.type = 'button';
					submit.value = 'Найти';
					submit.style.border = '1px solid #FFE289';
					submit.style.backgroundColor = '#FFFFFF';
					submit.style.marginLeft = '10pt';
					
					addHandler(submit, 'click', function(){window.bEnhandedSearch = true; buildSearchRequest();});
					
					var nobr = document.createElement('nobr');
					schContainer.appendChild(reset);
					schContainer.appendChild(submit);
				}
			}
			
			SetTab(document.getElementById('__tab1-4'));
		}
		break
	}
	window.currentState=document.location.hash
	var backUrlInputs=document.getElementsByName('backurl')
	var length=backUrlInputs.length
	if(length>0)
	{
		for(var i=0;i<length;i++)
		{
			document.getElementsByName('backurl').item(i).value=backUrlInputs.item(i).value.split('#')[0]+document.location.hash
		}
	}
	/*var logoutButton = document.getElementById('logout_button');
	if(logoutButton)
	{
		var logoutHref = document.location.href.split('#')[0];
		logoutHref += document.location.search.length ? '&' : '?';
		logoutHref += 'logout=yes';
		logoutHref += document.location.hash;
		logoutButton.href = logoutHref;
	}*/

	// Google Analytics
	try
	{
		//var pageTracker = _gaq._getAsyncTracker();
		//pageTracker._trackPageview(document.location.pathname + document.location.hash);
		var pageTracker = _gat._getTrackerByName();
		var ga_page = ga_get_dbpage(document.location.pathname, document.location.hash);
		if(ga_last_page != '')
			pageTracker._setReferrerOverride(ga_last_page);
		pageTracker._trackPageview(ga_page);
		ga_last_page = ga_page;
	}
	catch(e)
	{
		return
	}
	// ----
}

function getClassNumber(clid) {
	
	var nav=document.getElementById('nav')
	for(var i=1;i<=nav.childNodes.length;i++)
	{
		if(nav.childNodes.item(i-1).firstChild.innerHTML==clid)
		{
			var cln=i.toString()
		}
	}
	return cln
	
}

function getClassId(cln) {
	
	var clid=document.getElementById('clinfo-'+cln).firstChild.innerHTML
	return clid
	
}

function processStack() {
	
	//var pageElems=createElemLinks()
	var id=this.loadStack[0]
	if(document.getElementById('clitem,'+pageElems.activecl+','+id))
	{
		loadStack.shift()
		if(this.loadStack.length==0)
		{
			showFolder(id)
			setWindowCursor('none')
			this.interval=false
		}
	}
	else
	{
		if(document.getElementById('cli,'+pageElems.activecl+','+id) && this.requestsPending==0)
		{
			this.requestsPending++
			setWindowCursor('wait')
			document.getElementById('toLoad').innerHTML=id
			var urlMenuItem='/db/its.gateway.php?db='+document.getElementById('dbId').innerHTML+'&action=getxml&query=nav__'+id+'&cln='+getClassNumber(pageElems.activecl)+'&clid='+pageElems.activecl
			jsAjaxUtil.LoadData(urlMenuItem,buildMenuItem)
		}
	}
	
}

function unloadDbg() {
	
	if(window.intervalId==null)
	{
		if(event.preventDefault)
		{
			event.preventDefault()
		}
		else if(event.stopPropagation)
		{
			event.stopPropagation()
		}
		else
		{
			window.event.cancelBubble=true
		}
		//return false
	}
	
}

function initLoad()
{
	var hl_page = get_cookie_value('hl_page')
	if(hl_page && hl_page != '')
	{
		try
		{
			if(hl_page == window.top.document.location)
			{
				var query = get_cookie_value('try_saved_search_query')
				if(query && query != '')
				{
					window.top.document.cookie = 'search_query=' + encodeURIComponent(query) + '; path=/';
					//iss_sch_hl_toggle();
				}
			}
			else
			{
				window.top.document.cookie = 'hl_page=; path=/';
			}
		}
		catch(e)
		{
		
		}
	}
	var dbId=document.getElementById('dbId')
	try
	{
		if(window.top.document.getElementById('variables').className=='empty')
		{
			var urlInit='/db/its.gateway.php?db='+dbId.innerHTML+'&action=init'
			window.currentState=''
			this.requestsPending=1
			jsAjaxUtil.LoadData(urlInit,buildInit)
		}
		if(document.location.hash.split(':')[0]=='#content')
		{
			SetTab(document.getElementById('__tab1-2'))
		}
	}
	catch(e)
	{
	
	}
	
	if(IsIOS())
	{
		/*window.mouseY = 0;
		window.mouseX = 0;
		document.body.addEventListener('touchstart', function(e){
			window.mouseY = e.targetTouches[0].pageY;
			console.log('START: window.mouseY: ' + window.mouseY);
			window.mouseX = e.targetTouches[0].pageX;
		});
		
		for(var i = 1; i <= 9; i++)
		{
			var classtree = document.getElementById('__mdiv1-1-'+(i*2-1)+'__');
			var classlist = document.getElementById('__mdiv1-1-'+(i*2)+'__');
			
			if(classtree)
				attachOnTouchMove(classtree.firstElementChild, classtree);
			if(classlist)
				attachOnTouchMove(classlist.firstElementChild, classlist);
		}*/
		
		document.body.addEventListener('orientationchange', LayoutPage);
	}
	
}

function attachOnTouchMove(content, container)
{
	if(IsIOS())
	{
		content.addEventListener('touchmove', function(e){
			e.preventDefault();
			container.scrollLeft = container.scrollLeft + window.mouseX - e.targetTouches[0].pageX;
			container.scrollTop = container.scrollTop + window.mouseY - e.targetTouches[0].pageY;
			console.log('MOVE: container.scrollTop: ' + container.scrollTop + ', window.mouseY: ' + window.mouseY + ', e.targetTouches[0].pageY: ' + e.targetTouches[0].pageY);
		});
	}
}

function buildInit(data) {

	document.getElementById('variables').innerHTML=data+'<div id="toLoad">-1</div><div id="activeTocItem"></div><div id="activeFolder">1,-1</div>'
	document.getElementById('variables').className='loaded'
	//document.getElementById('dbNameHeader').innerHTML=document.getElementById('dbName').innerHTML
	this.requestsPending--
	var nav=document.getElementById('nav')
	if(!nav)
		return;
	
	for(var i=1;i<=nav.childNodes.length;i++)
	{
		document.getElementById('__tab2-1-'+i).firstChild.innerHTML=nav.childNodes.item(i-1).childNodes.item(1).innerHTML
		document.getElementById('dbTypeHeader-'+i).firstChild.href=document.getElementById('__tab2-1-'+i).firstChild.href='#browse:'+getClassId(i)+':-1'
		document.getElementById('__tab2-1-'+i).style.display=''
		document.getElementById('dbTypeHeader-'+i).firstChild.innerHTML=nav.childNodes.item(i-1).childNodes.item(2).innerHTML
		document.getElementById('cli,'+i+',-1').id='cli,'+getClassId(i)+',-1'
	}
	if(i>2)
	{
		document.getElementById('tabs1container').style.display='block'
		document.getElementById('tabs1spacer').style.display='none'
	}
	else if(nav.childNodes.length > 0)
		ShowTab(document.getElementById('__tab1-1'), false) // ???
	
	initTabs('__tab2-1-', i-1);
	
	var initLocation;
	var dbId = document.getElementById('dbId').innerHTML;
	
	if(document.getElementById('dbStart') && document.getElementById('dbStart').innerHTML != '/db/'+dbId)
		initLocation=document.getElementById('dbStart').innerHTML.replace('&amp;', '&')
	else if(nav.childNodes.length > 0 && dbId != 'alldb')
		initLocation=document.location.pathname+'#browse:'+nav.firstChild.firstChild.innerHTML+':-1'
	else if(dbId == 'alldb')
		initLocation='/db/alldb#search'
	else
		initLocation='/404.php'
	
	if(document.location.hash.replace('#', '')=='')
	{
		document.location.replace('http://'+document.location.host+initLocation)
		setView()
	}
	else if(dbId != 'alldb')
	{
		if(nav.childNodes.length)
		{
			if(!document.location.hash.match('#browse'))
			{
				this.requestsPending++
				setWindowCursor('wait')
				document.getElementById('toLoad').innerHTML='-1'
				var urlMenuItem='/db/its.gateway.php?db='+dbId+'&action=getxml&query=nav__-1&cln=1&clid='+document.getElementById('nav').firstChild.firstChild.innerHTML
				jsAjaxUtil.LoadData(urlMenuItem,buildMenuItem)
				initLocation = '#browse:'+getClassId('1')+':-1'
				document.getElementById('__tab1-1').firstChild.href = initLocation
			}
			else
			{
				var path=document.location.hash.split(':')
				if(path[1]=='-1')
				{
					path[1]=getClassId('1')
					initLocation = path.join(':')
					document.location.replace('http://'+document.location.host+document.location.pathname+initLocation)
				}
			}
			var find_in_classifier = document.getElementById('find_in_classifier');
			if(find_in_classifier)
				find_in_classifier.style.display = '';
		}
		setView()
	}
	
	var navchain = document.getElementById('navchain-table');
	if(navchain && initLocation && dbId != 'alldb')
	{
		var navlinks = navchain.getElementsByTagName('A');
		if(navlinks.length)
			navlinks[navlinks.length-1].href = initLocation;
	}
	
	var schCfg = document.getElementById('form');
	var schContainer = document.getElementById('__mdiv4-1__');
	if(schCfg && schContainer && (dbId == 'garant' || dbId == 'garantm'))
	{
		for(var i = 0; i < schCfg.childNodes.length; i++)
		{
			var at = parseInt(schCfg.childNodes[i].className.split('_')[1]);
			
			if(!isNaN(at) && at != 0 && at != 1)
			{
				ShowTab(document.getElementById('__tab1-4'), true);
				window.bEnhancedSearch = true;
				break;
			}
		}
	}
	
	window.intervalId=setInterval(checkLocation,50)
	
}

function loadSuggestion(aid)
{
	var oList = document.getElementById('ftree_sub_' + aid + '_-1');
	if(!oList)
		return;
	oList.innerHTML = 'Загрузка...';
	var dbId = document.getElementById('dbId').innerHTML;
	jsAjaxUtil.LoadData(
		'/db/its.gateway.php?db=' + dbId + '&action=getxml&query=sugattr__a=' + aid + ',l=100,s=' + encodeURIComponent(window['g_sInputText' + aid]),
		function()
		{
			return function(data)
			{
				showItemsList(data, aid);
			}
		}(aid)
	);
}

function showItemsList(data, aid)
{
	var oList = document.getElementById('ftree_sub_' + aid + '_-1');
	if(!oList)
		return;
	
	oList.innerHTML = data;
	oList.style.display = (data.length > 0) ? '' : 'none';
	setWindowCursor('none');
}

function createInput(type, attr)
{
	if(typeof document.all == 'undefined'/* || navigator.userAgent.indexOf('MSIE 6') != -1*/)
	{
		var input = document.createElement('INPUT');
		input.type = type;
		for(a in attr)
			input[a] = attr[a];
	}
	else
	{
		var tmpNode = document.createElement('DIV');
		var adjHtml = ['input type="' + type + '"'];
		
		for(a in attr)
		{
			if(typeof attr[a] == 'boolean')
			{
				if(attr[a] == true)
					adjHtml.push(a);
			}
			else
				adjHtml.push(a + '="' + attr[a] + '"');
		}
		
		adjHtml = '<' + adjHtml.join(' ') + ' />';
		tmpNode.insertAdjacentHTML('afterBegin', adjHtml);
		
		var input = tmpNode.firstChild.cloneNode(false);
		delete tmpNode;
	}
	
	return input;
}

function createFTreeBranch(data, aid, parent, checked)
{
	var ftree = parseXML(data);
	var entries = ftree.getElementsByTagName('f');
	var branch = document.createElement('DIV');
	
	var checked = !!checked;
	for(var i = 0; i < entries.length; i++)
	{
		var ft = entries[i].getElementsByTagName('ft')[0].firstChild.nodeValue;
		var fid = parseInt(entries[i].getElementsByTagName('fid')[0].firstChild.nodeValue);
		var fe = (entries[i].getElementsByTagName('e')[0].firstChild != null) ? true : false;
		
		var checkbox = createInput('checkbox', {id: 'ftree_' + aid + '_' + fid, checked: checked, value: fid});
		
		if(checked)
		{
			var selected = document.createElement('SPAN');
			selected.id = 'selected_' + aid + '_' + fid;
			selected.innerHTML = ft;
			selected.style.marginLeft = '2pt';
			selected.style.marginRight = '2pt';
			selected.style.display = 'block';
			
			if(document.getElementById(selected.id) == null)
				document.getElementById('ftree_selection_' + aid).appendChild(selected);
		}
		
		var label = document.createElement('LABEL');
		label.innerHTML = ft;
		label.htmlFor = 'ftree_' + aid + '_' + fid;
		
		if(fe)
		{
			var container = document.createElement('DIV');
			container.id = 'ftree_sub_' + aid + '_' + fid;
			container.style.paddingLeft = '10pt';
			
			var padding = document.createElement('IMG');
			padding.src = '/images/db/tree/plus.gif';
			padding.id = 'ftree_exp_' + aid + '_' + fid;
			padding.style.cursor = 'pointer';
			branch.appendChild(padding);
			
			checkbox.style.marginLeft = '4px';
		}
		else
		{
			/*padding.src = '/bitrix/templates/its/images/space.gif';
			padding.style.height = '16px';
			padding.style.width = '16px';*/
			checkbox.style.marginLeft = '20px';
		}
		branch.appendChild(checkbox);
		branch.appendChild(label);
		
		if(fe)
			branch.appendChild(container);
		else
			branch.appendChild(document.createElement('BR'));
	}
	
	parent.appendChild(branch);
}

function checkLocation() {
	
	if(window.currentState!=document.location.hash)
	{
		if(window.intervalId!=null)
		{
			setView()
		}
	}
	
}

function setAnchor(hash) {
	
	document.location.hash=hash
	
}

function parseXML(string) {
	
	var XMLDocument;
	if(typeof DOMParser === 'function' || typeof DOMParser === 'object')
		XMLDocument = (new DOMParser()).parseFromString(string,'text/xml');
	else
	{
		var xml = document.createElement("xml");
		document.body.appendChild(xml);
		XMLDocument = xml.XMLDocument;
		document.body.removeChild(xml);
		XMLDocument.async=false
		//XMLDocument.validateOnParse=false
		XMLDocument.loadXML(string)
	}
	return XMLDocument
}

function addHandler(object,event,handler) {
	
	if(IsIE())
	{
		object.attachEvent('on'+event,handler)
	}
	else 
	{
		object.addEventListener(event,handler,false)
	}
	
}

function removeHandler(object,event,handler) {
	
	if(IsIE())
	{
		object.detachEvent('on'+event,handler)
	}
	else
	{
		object.removeEventListener(event,handler,false)
	}
	
}

function hasClass(elem,className) {
	
	return new RegExp('(^|\\s)'+className+'(\\s|$)').test(elem.className)
	
}

function arraySearch(objArray,strPattern) {
	
	var length=objArray.length
	var match=[]
	for(var i=length;i--;)
	{
		if(objArray[i].valueOf()==strPattern.valueOf())
		{
			match[match.length]=i
		}
	}
	if(match.length>0)
	{
		return match
	}
	else
	{
		return false
	}
	
}

function setWindowCursor(state) {

	for(var i=0; i < document.styleSheets.length; i++)
	{
		if(document.styleSheets[i].href && (document.styleSheets[i].href.match("/css/db.css") || document.styleSheets[i].href == 'http://'+document.location.host+'/css/db.css'))
		{
			var stylesheet=document.styleSheets[i]
			break
		}
	}
	if(typeof stylesheet == 'undefined')
	{
		stylesheet = document.styleSheets[document.styleSheets.length-1]
	}
	if(state=='none')
	{
		try
		{
			if(!window.opera)
			{
				stylesheet.cssRules[3].style.cursor=''
			}
			else
			{
				stylesheet.cssRules[3].style.cursor='inherit'
			}
		}
		catch(e)
		{
			try
			{
				stylesheet.rules[3].style.cursor=''
			}
			catch(e)
			{
				return
			}
		}
	}
	else
	{
		try
		{
			stylesheet.cssRules[3].style.cursor=state
		}
		catch(e)
		{
			try
			{
				stylesheet.rules[3].style.cursor=state
			}
			catch(e)
			{
				
			}
		}
	}
	return
}

function treeExpand(event) {
	
	event = event || window.event
	var clickedElem = event.target || event.srcElement
	if(hasClass(clickedElem, 'branch'))
	{
		if(hasClass(clickedElem, 'expanded'))
		{
			clickedElem.className = 'branch collapsed'
			clickedElem.nextSibling.style.display = 'none';
		}
		else
		{
			var newHash = clickedElem.firstChild.firstChild.href.split('#')[1];
			if('#' + newHash != document.location.hash)
				setAnchor(newHash);
			else
			{
				clickedElem.className = 'branch expanded';
				clickedElem.nextSibling.style.display = 'block';
			}
		}
	}
}

function tocExpand(event, clickOrigin) {
	if(typeof clickOrigin=='undefined')
	{
		event=event||window.event
		var clickedElem=event.target||event.srcElement
	}
	else
	{
		var currentDocId = pageElems.docid
		var id = 'tocitem,'+currentDocId
		if(typeof pageElems.docanchor != 'undefined')
			id += ','+decodeURIComponent(pageElems.docanchor)
		if(document.getElementById(id))
			clickedElem = document.getElementById(id)
		else if(document.getElementById('tocitem,'+currentDocId))
			clickedElem = document.getElementById('tocitem,'+currentDocId)
		else
			return
	}
	
	if(hasClass(clickedElem,'expanded'))
	{
		clickedElem.className='branch collapsed'
		clickedElem.nextSibling.style.display='none'
	}
	else if(hasClass(clickedElem,'collapsed'))
	{
		clickedElem.className='branch expanded'
		clickedElem.nextSibling.style.display='block'
	}
	else if(clickedElem.tagName=='A')
	{
		if(hasClass(clickedElem.parentNode.parentNode,'collapsed'))
		{
			clickedElem.parentNode.parentNode.className='branch expanded'
			clickedElem.parentNode.parentNode.nextSibling.style.display='block'
		}
		var lastActive=document.getElementById('activeTocItem').innerHTML
		var activeItem=document.getElementById(lastActive)
		while(activeItem.parentNode.parentNode.parentNode.className!='tree')
		{
			activeItem.parentNode.className='btext'
			activeItem=activeItem.parentNode.parentNode.parentNode.previousSibling.firstChild.firstChild
		}
		var id=clickedElem.id
		document.getElementById('activeTocItem').innerHTML=id
		activeItem=document.getElementById(id)
		if(activeItem.parentNode.parentNode.parentNode.className=='tree')
		{
			activeItem.parentNode.className='btext act1'
		}
		else
		{
			var nodeChain=[]
			var n=0
			while(document.getElementById(id).parentNode.parentNode.parentNode.className!='tree')
			{
				nodeChain[n]=id
				activeItem=document.getElementById(id)
				id=activeItem.parentNode.parentNode.parentNode.previousSibling.firstChild.firstChild.id
				n++
			}
			nodeChain.reverse()
			for(var i=0;i<n;i++)
			{
				document.getElementById(nodeChain[i]).parentNode.className='btext act'+(i+1)
				if(hasClass(document.getElementById(nodeChain[i]).parentNode.parentNode,'collapsed'))
				{
					document.getElementById(nodeChain[i]).parentNode.parentNode.className='branch expanded'
					document.getElementById(nodeChain[i]).parentNode.parentNode.nextSibling.style.display='block'
				}
			}	
		}
		clickedElem.scrollIntoView(false)
		openDoc(clickedElem,'toc',clickOrigin)
	}
}

function switchToDoc(title) {
	
	try
	{
		var docTab = window.top.document.getElementById('__tab1-2')
		SetTab(docTab)
		var newHash = docTab.firstChild.href.split('#')[1]
		if(newHash != '')
			setAnchor(newHash)
		var activeTab = window.top.location.hash.split(':')[2] || '9'
		SetTab(window.top.document.getElementById('__tab2-2-'+activeTab))
		
		if(activeTab != '9')
			updateDocTitle(window.top.doctitleheader);
		else
			updateDocTitle(title);
		
		setWindowCursor('none')
		
		document.getElementById('docframe,' + activeTab).focus();
		
		return true;
	}
	catch(e)
	{
		return false;
	}
}

function findDoc(db,path) {
	
	/*var dbid = document.getElementById('dbId').innerHTML;
	for(var i=1;i<=9;i++)
	{
		var iframe = document.getElementById('docframe,' + i);
		var p = iframe.contentWindow.location.pathname;
		p = p.replace('/db/content/' + dbid + '/', '');
		p = decodeURIComponent(p).toLowerCase();
		if(decodeURIComponent(path).toLowerCase() == p)
		{
			iframe.contentWindow.location.reload(true);
			break;
		}
	}*/
	var urlFindDoc='/db/its.gateway.php?db='+db+'&action=getxml&query=finddoc__'+path
	this.requestsPending++
	jsAjaxUtil.LoadData(urlFindDoc,getDocByPath)
	
}

function getDocByPath(data) {
	
	this.requestsPending--
	document.location.href=data
	
}

function setTabAnchor(tab)
{
	
	var tabNumber=tab.id.split('-')[2]
	document.location.href=document.location.href.replace(/#content:([^:]+):[^:]+(:.*)?$/,'#content:$1:'+tabNumber)
	SetTab(tab)
}

function updateDocTitle(obj)
{
	if(typeof obj == 'object' && obj.title)
		var title = obj.title;
	else if(typeof obj == 'string')
		var title = obj;
	else
		return;
	window.top.document.title = window.top.document.getElementById('dbNameHeader').innerHTML + ' :: ' + title;
	if(!window.top.document.getElementById('tabs2container'))
		title = '';
	if(title != 'Загрузка' && title != 'Загрузка...')
		window.top.doctitleheader = title;
	window.top.document.getElementById('doctitleheader').innerHTML = title;
}

function encode_utf8(str)
{
	return unescape(encodeURIComponent(str));
}

function decode_utf8(str)
{
	return decodeURIComponent(escape(str));
}

function setClassId(tab) {
	
	document.location.href=tab.firstChild.href
	
}

function openDoc(launcher,type,bInitial) {
	//dbg('openDoc(' + launcher + ', ' + type + ')');
	if(!launcher)
		return;
	
	switch(type)
	{
		case 'tab':
		{
			var targetFrame = document.getElementById(launcher.firstChild.target)
			var newLocation = launcher.firstChild.href
			SetTab(launcher)
		}
		break
		case 'toc':
		{
			var bNotLoaded = false
			var targetFrame=document.getElementById('docframe,1')
			var targetDoc = get_frame_document(targetFrame)
			if(targetDoc == null || targetDoc.location.pathname == '/blank.htm')
				bNotLoaded = true
			var currentDocId = window.location.href.split('#')[1].split(':')[1]
			if(!launcher.href.match('/content/'))
			{
				if(bNotLoaded)
				{
					openDoc(document.getElementById('__tab2-2-' + pageElems.doctab),'tab')
					return
				}
				var anchor=encodeURIComponent(launcher.id.split(',')[2])
				arId = launcher.id.split(',')
				
				if(arId.length > 3)
					for(var i=3; i<arId.length; i++)
						anchor += ',' + arId[i]
				
				document.location.href = '/db/'+document.getElementById('dbId').innerHTML+'#content:'+launcher.id.split(',')[1]+':1:'+anchor
				//SetTab(document.getElementById('__tab2-2-' + launcher.id.split(',')[1]))
				SetTab(document.getElementById('__tab2-2-1'))
				try
				{
					targetFrame.location.hash='#'+anchor
				}
				catch(e)
				{
					try
					{
						targetDoc.location.hash='#'+anchor
					}
					catch(e)
					{
						
					}
				}
				var anchors=targetDoc.getElementsByName(decodeURIComponent(anchor))
				if(anchors.length>0)
				{
					anchors[0].scrollIntoView(true)
				}
				window.pageElems=createElemLinks()
				return
			}
			else
			{
				if(currentDocId != launcher.id.split(',')[1])
				{
					window.top.current_clpath = false;
					var urlTocTabs='/db/its.gateway.php?db='+document.getElementById('dbId').innerHTML+'&action=getxml&query=doc__'+launcher.id.split(',')[1]
					setWindowCursor('wait')
					jsAjaxUtil.LoadData(urlTocTabs,getTocTabs)
				}
				else if((typeof bInitial == 'undefined' || !bInitial) && typeof launcher.id.split(',')[2] == 'undefined')
				{
					window.top.location.href = '/db/'+document.getElementById('dbId').innerHTML+'#content:'+launcher.id.split(',')[1]+':1';
				}
				return
			}
		}
		break
		case 'folder':
		{
			var targetFrame=document.getElementById('docframe,1')
			var newLocation=launcher.href
		}
		break
		case 'orphan':
		{
			var targetFrame = document.getElementById('docframe,9')
			var newLocation = '/db/content/'+document.getElementById('dbId').innerHTML+'/'+launcher
			toggleTocDisplay(false)
			document.getElementById('toggle_toc_button').style.display = 'none';
			document.getElementById('__mdiv2-1__').innerHTML = '';
			document.getElementById('tabs2container').style.display='none'
			SetTab(document.getElementById('__tab2-2-9'))
		}
		break
		case 'link':
		{
			var newLocation=launcher.href
			launcher.ownerDocument.location.replace(newLocation)
			
			return;
		}
		break
	}
	
	updateDocTitle('Загрузка...');
	
	if(typeof targetDoc == 'undefined')
		var targetDoc = get_frame_document(targetFrame)
	
	newLocation = newLocation.replace('+','%252B')
	if(!newLocation.match('http://'))
		newLocation='http://'+document.location.host+newLocation
	
	try
	{
		var oldLocation = targetDoc.location; // || targetFrame.location
		if(
			oldLocation.toString().split('#')[0].replace(/%20/g,' ')!=newLocation.split('#')[0].replace(/%20/g,' ')
			&&
			encodeURI(oldLocation.toString().split('#')[0])!=newLocation.split('#')[0]
		)
		{
			setWindowCursor('wait')
			if(newLocation.match(/\.(xls|doc|rtf)$/))
			{
				if(!IsIE())
				{
					try
					{
						window.top.document.location.replace(newLocation)
					}
					catch(e)
					{
					
					}
				}
				else
				{
					targetDoc.write('<a href="'+newLocation+'" target="_blank" id="launcher">Сохранить документ</a>')
				}
			}
			else
			{
				oldLocation.replace(newLocation)
			}
		}
	}
	catch(e)
	{
		targetFrame.location=newLocation
		if((oldLocation==null) || (oldLocation!=newLocation))
			oldLocation = newLocation
	}
	
	if(type != 'orphan')
		updateDocTitle(window.top.doctitleheader);
	else
		updateDocTitle(targetDoc);
}

function buildMenuItem(data) {
	
	//var pageElems=createElemLinks()
	if(!pageElems.activecl)
	{
		var activecl=getClassId('1')
	}
	else
	{
		var activecl=pageElems.activecl
	}
	this.requestsPending--
	var folderitem=document.createElement('div')
	var menuitem=document.createElement('div')
	var id=activecl+','+document.getElementById('toLoad').innerHTML
	var node=document.getElementById('cli,'+id)
	folderitem.innerHTML=data.split('<separator>')[1]
	folderitem.id='folderitem,'+id
	folderitem.className='list'
	document.getElementById('classlist,'+getClassNumber(activecl)).appendChild(folderitem)
	var f=0
	var length=folderitem.firstChild.childNodes.length
	for(var i=0;i<length;i++)
	{
		if(hasClass(folderitem.firstChild.childNodes.item(i),'fldr'))
		{
			f++
		}
	}
	if(f>0)
	{
		menuitem.innerHTML=data.split('<separator>')[0]
		menuitem.className='subtree'
		node.parentNode.insertBefore(menuitem,node.nextSibling)
	}
	node.id='clitem,'+id
	showFolder(id.split(',')[1])
	if(id==activecl+',-1' && f==0)
	{
		node.className='branch'
		if(data=='<separator><ul></ul>')
		{
			ShowTab(document.getElementById('__tab1-1'), false)
			setWindowCursor('none')
			return
		}
	}
	if(f>0)
	{
		var nodeChain=[]
		var n=0
		id=id.split(',')[1]
		while(id!='-1')
		{
			nodeChain[n]=id
			activeItem=document.getElementById('clitem,'+activecl+','+id)
			id=activeItem.parentNode.previousSibling.id.split(',')[2]
			n++
		}
		nodeChain.reverse()
		for(var i=0;i<f;i++)
		{
			var link=node.nextSibling.childNodes.item(i).firstChild.firstChild
			var pfid=link.parentNode.parentNode.id.substring(4,link.parentNode.parentNode.id.toString().length)
			if(nodeChain.length>0)
			{
				document.getElementById('folder,'+pfid).href=link.href='/db/'+document.getElementById('dbId').innerHTML+'#browse:'+activecl+':-1:'+nodeChain.join(':')+':'+pfid.split(',')[1]
			}
			else
			{
				document.getElementById('folder,'+pfid).href=link.href='/db/'+document.getElementById('dbId').innerHTML+'#browse:'+activecl+':-1:'+pfid.split(',')[1]
			}
		}
	}
	setWindowCursor('none')
	ShowTab(document.getElementById('__tab1-1'), true)
}

function getTocTabs(data)
{
	var xmlString=parseXML(data)
	var tabs=xmlString.getElementsByTagName('tab')
	var targetUrl=document.getElementById(document.getElementById('activeTocItem').innerHTML).href
	targetUrl=targetUrl.split('%20').join(' ').split('%25').join('%').split('%2b').join('+')
	
	if(tabs.length == 0)
		document.location.href = '/404.php';
	else if(tabs.length == 1)
	{
		pageElems.numtab = 0;
		document.getElementById('tabs2container').style.display='none'
	}
	else
	{
		pageElems.numtab = tabs.length;
		document.getElementById('tabs2container').style.display='block'
	}
	
	var title = xmlString.getElementsByTagName('title');
	if(title.length)
		window.top.doctitleheader = title[0].firstChild.nodeValue;
	
	for(var i=0;i<tabs.length;i++)
	{
		var tab = tabs[i]
		var name = tab.getElementsByTagName('name')[0].firstChild.nodeValue
		document.getElementById('__tab2-2-'+(i+1)).firstChild.innerHTML = name
		var tabhref = tab.getElementsByTagName('href')[0].firstChild.nodeValue.toLowerCase()
		tabhref=tabhref.split('%20').join(' ').split('%25').join('%').split('%2b').join('+')
		tabhref='/db/content/'+document.getElementById('dbId').innerHTML+'/'+tabhref
		document.getElementById('__tab2-2-'+(i+1)).firstChild.href=encodeURI(tabhref)
		document.getElementById('__tab2-2-'+(i+1)).style.display=''
		
		encodedURI1 = encodeURI(tabhref);
		encodedURI2 = encodeURI('http://'+document.location.host+tabhref);
		encodedURI3 = encodedURI1.split('%20').join(' ').split('%25').join('%').split('%2b').join('+');
		encodedURI4 = encodedURI2.split('%20').join(' ').split('%25').join('%').split('%2b').join('+');

		if((targetUrl==tabhref) || (targetUrl=='http://'+document.location.host+tabhref) || (targetUrl==encodedURI1) || (targetUrl==encodedURI2) || (targetUrl==encodedURI3) || (targetUrl==encodedURI4))
		{
			if(!IsIE())
			{
				openDoc(document.getElementById('__tab2-2-'+(i+1)),'tab')
			}
			var newState='#content:'+xmlString.getElementsByTagName('doc_id').item(0).firstChild.nodeValue+':'+(i+1)
			if(!window.currentState.match(newState) && ((window.currentState.split(':')[0] == '#content') && (window.currentState.split(':')[1] != newState.split(':')[1])))
			{
				if(IsIE())
				{
					document.getElementById('__tab1-2').firstChild.href=newState
					window.location.hash=newState
				}
				else
				{
					clearInterval(window.intervalId)
					window.intervalId=null
					document.location.hash=newState
					window.currentState=newState
					document.getElementById('__tab1-2').firstChild.href=newState
					window.intervalId=setInterval(checkLocation,50)
				}
			}
		}
	}

	window.pageElems=createElemLinks()
	if(tabs.length == 1)
		pageElems.numtab = 0;
	else
		pageElems.numtab = tabs.length;
	initTabs('__tab2-2-', pageElems.numtab);

	setWindowCursor('none')
	
}

function toggleTocDisplay(show)
{
	var tocWidth;
	var docWidth;
	var docLeft;
	var currentTocWidth;
	
	for(var i = 0; i < document.styleSheets.length; i++)
	{
		if(document.styleSheets[i].href && document.styleSheets[i].href.match("/css/db.css"))
		{
			var stylesheet=document.styleSheets[i];
			break;
		}
	}
	if(typeof stylesheet == 'undefined')
	{
		stylesheet = document.styleSheets[document.styleSheets.length-1];
	}
	
	switch(show)
	{
		case false:
		{
			tocWidth = '0';
			docWidth = '98%';
			docLeft = '1%';
		}
		break;
		case true:
		{
			if(document.getElementById('__mdiv2-1__').childNodes.length > 0)
			{
				tocWidth = '29.5%';
				docWidth = '68%';
				docLeft = '31%';
			}
			else
			{
				tocWidth = '0';
				docWidth = '98%';
				docLeft = '1%';
			}
		}
		break;
		case undefined:
		{
			if(document.getElementById('__mdiv2-1__').childNodes.length > 0)
			{
				try
				{
					currentTocWidth = stylesheet.cssRules[0].style.width;
				}
				catch(e)
				{
					currentTocWidth = stylesheet.rules[0].style.width;
				}
				
				if(currentTocWidth == '29.5%')
				{
					tocWidth = '0';
					docWidth = '98%';
					docLeft = '1%';
				}
				else
				{
					tocWidth = '29.5%';
					docWidth = '68%';
					docLeft = '31%';
				}
			}
			else
			{
				tocWidth = '0';
				docWidth = '98%';
				docLeft = '1%';
			}
		}
		break;
	}
	
	try
	{
		stylesheet.cssRules[0].style.width = tocWidth;
		stylesheet.cssRules[1].style.width = docWidth;
		stylesheet.cssRules[1].style.left = docLeft;
		stylesheet.cssRules[2].style.marginLeft = docLeft;
	}
	catch(e)
	{
		stylesheet.rules[0].style.width = tocWidth;
		stylesheet.rules[1].style.width = docWidth;
		stylesheet.rules[1].style.left = docLeft;
		stylesheet.rules[2].style.marginLeft = docLeft;
	}
	
	var toggle_toc_button = document.getElementById('toggle_toc_button');
	toggle_toc_button.style.display = 'block';
	toggle_toc_button.title = (tocWidth == '0') ? 'Показать оглавление' : 'Скрыть оглавление';
	
	if(tocWidth == '0')
	{
		toggle_toc_button.style.left = '0.5%';
		toggle_toc_button.title = 'Показать оглавление';
		toggle_toc_button.firstChild.className = 'showtoc';
		document.getElementById('__mdiv2-1__').style.display = 'none';
	}
	else
	{
		toggle_toc_button.style.left = '30.5%';
		toggle_toc_button.title = 'Скрыть оглавление';
		toggle_toc_button.firstChild.className = 'hidetoc';
		document.getElementById('__mdiv2-1__').style.display = 'block';
	}
}

function displayDoc(data) {
	
	var xmlString=parseXML(data);
	var tabs=xmlString.getElementsByTagName('tab');
	var status=xmlString.getElementsByTagName('status');
	try
	{
		var doc_id=xmlString.getElementsByTagName('doc_id')[0].firstChild.nodeValue;
	}
	catch(e)
	{
		return;
	}
	
	if(!tabs.length)
	{
		document.location.href = '/404.php';
		return;
	}
	else if(tabs.length == 1 && !status.length)
	{
		pageElems.numtab = 0;
		document.getElementById('tabs2container').style.display = 'none';
	}
	else
	{
		pageElems.numtab = tabs.length;
		document.getElementById('tabs2container').style.display = 'block';
	}
	
	if(status.length)
	{
		status = status[0]
		var statusText = status.getElementsByTagName('text')[0].firstChild.nodeValue
		var docStatusHeader = document.getElementById('docStatusHeader')
		docStatusHeader.innerHTML = statusText
		docStatusHeader.style['backgroundColor'] = ''
		docStatusHeader.style['color'] = ''
		docStatusHeader.style['fontWeight'] = ''
		docStatusHeader.style['fontStyle'] = ''
		docStatusHeader.style['textDecoration'] = ''
		var statusStyle = status.getElementsByTagName('rules')
		if(statusStyle.length > 0)
		{
			var len = statusStyle[0].childNodes.length
			if(typeof len == 'undefined')
				var len = statusStyle[0].childElementCount
			for(var i = 0; i < len; i++)
			{
				var node = statusStyle[0].childNodes[i]
				if(node.nodeName == '#text' || node.firstChild.nodeValue == 'none')
					continue;
				docStatusHeader.style[node.nodeName] = node.firstChild.nodeValue
			}
		}
	}
	else
	{
		document.getElementById('docStatusHeader').innerHTML = ''
		document.getElementById('docStatusHeader').style.color = ''
		document.getElementById('docStatusHeader').style.backgroundColor = ''
		document.getElementById('docStatusHeader').style.textDecoration = ''
	}
	
	if(xmlString.getElementsByTagName('toc_id').length!=0)
	{
		var urlToc='/db/its.gateway.php?db='+document.getElementById('dbId').innerHTML+'&action=getxml&query=toc__'+xmlString.getElementsByTagName('toc_id').item(0).firstChild.nodeValue
		this.requestsPending++
		jsAjaxUtil.LoadData(urlToc,buildToc)
	}
	else
	{
		toggleTocDisplay(false)
		document.getElementById('toggle_toc_button').style.display = 'none';
		document.getElementById('__mdiv2-1__').innerHTML = '';
	}
	if(tabs.length>1)
	{
		doc_id = doc_id.split(',');
		if(doc_id.length > 1)
			var p = xmlString.getElementsByTagName('p')[0].firstChild.nodeValue;
		for(var i=0; i<tabs.length; i++)
		{
			document.getElementById('__tab2-2-'+(i+1)).firstChild.innerHTML=tabs[i].getElementsByTagName('name')[0].firstChild.nodeValue
			var href = tabs[i].getElementsByTagName('href')[0].firstChild.nodeValue;
			if(typeof p != 'undefined' && href == p)
			{
				document.location.replace('http://'+document.location.host+document.location.pathname+'#content:'+doc_id[0]+':'+(i+1))
				return
			}
			document.getElementById('__tab2-2-'+(i+1)).firstChild.href='/db/content/'+document.getElementById('dbId').innerHTML+'/'+href
		}
	}
	else
	{
		document.getElementById('__tab2-2-1').firstChild.innerHTML=tabs[0].getElementsByTagName('name')[0].firstChild.nodeValue
		var href = tabs[0].getElementsByTagName('href')[0].firstChild.nodeValue.toLowerCase()
		document.getElementById('__tab2-2-1').firstChild.href='/db/content/'+document.getElementById('dbId').innerHTML+'/'+href
		var docSectionContainer=document.getElementById('__adj2__')
		//TabAdj.AddTab("__adj2__",["__mdiv2-1__","__mdiv2-2-1__"])
	}
	
	initTabs('__tab2-2-', pageElems.numtab);

	var title = xmlString.getElementsByTagName('title');
	if(title.length)
		window.top.doctitleheader = title[0].firstChild.nodeValue;
	
	var clpath = xmlString.getElementsByTagName('clpath');
	if(clpath.length)
	{
		window.top.current_clpath = clpath[0].firstChild.nodeValue.split(',');
	}
	
	var activeTab=pageElems.doctab
	openDoc(document.getElementById('__tab2-2-'+activeTab),'tab')
	
}

function buildToc(data) {
	
	this.requestsPending--
	var tocContainer=document.getElementById('__mdiv2-1__')
	tocContainer.innerHTML=data
	//attachOnTouchMove(tocContainer.firstElementChild, tocContainer);
	toggleTocDisplay(true)
	try
	{
		document.getElementById('activeTocItem').innerHTML=tocContainer.firstChild.firstChild.firstChild.firstChild.id
	}
	catch(e)
	{
		
	}
	tocExpand(false, true)
	
}

function showFolder(id) {
	
	//var pageElems=createElemLinks()
	if(!pageElems.activecl)
	{
		pageElems.activecl=getClassId('1')
	}
	var node=document.getElementById('clitem,'+pageElems.activecl+','+id)
	document.title=document.getElementById('dbNameHeader').innerHTML+' :: '+node.firstChild.firstChild.innerHTML
	var bRoot = hasClass(node,'root')
	if(node.className!='branch') // не лист дерева
	{
		node.className='branch expanded'
		if(bRoot)
			node.className += ' root'
		node.nextSibling.style.display='block'
	}
	var lastActive=document.getElementById('activeFolder').innerHTML
	var activeItem=document.getElementById('clitem,'+lastActive)
	if(activeItem)
	{
		while(activeItem.id.split(',')[2]!='-1')
		{
			activeItem.firstChild.className='btext'
			activeItem=activeItem.parentNode.previousSibling
			
		}
		document.getElementById('folderitem,'+lastActive).style.display='none'
	}
	document.getElementById('folderitem,'+pageElems.activecl+','+id).style.display='block'
	document.getElementById('activeFolder').innerHTML=pageElems.activecl+','+id
	if(id=='-1')
	{
		node.firstChild.className='btext act1'
		return
	}
	var nodeChain=[]
	var n=0
	while(id!='-1')
	{
		nodeChain[n]=id
		activeItem=document.getElementById('clitem,'+pageElems.activecl+','+id)
		id=activeItem.parentNode.previousSibling.id.split(',')[2]
		n++
	}
	nodeChain.reverse()
	for(var i=0;i<n;i++)
	{
		document.getElementById('clitem,'+pageElems.activecl+','+nodeChain[i]).firstChild.className='btext act'+(i+1)
	}
//	var lastNode = document.getElementById('clitem,'+pageElems.activecl+','+nodeChain[n-1])
//	if(hasClass(lastNode,'expanded'))
//		lastNode.nextSibling.scrollIntoView(false)
}

function onsubmit_search_handler()
{
	var searchstr = encodeURIComponent(document.getElementById('searchText').value.replace(/[#\:]+/g,' ').replace(/[^\/\-A-Za-zА-Яа-яіїєґІЇЄҐ0-9\s\.]+/g,' '));
	if(searchstr == '')
		return;
	
	if(!document.location.href.match('db'))
	{
		document.location.href = '/db/alldb#search:' + searchstr;
		return;
	}
	var hash_current = document.location.hash.split(':')[1];
	if(hash_current != searchstr && encodeURIComponent(hash_current) != searchstr)
	{
		setAnchor('search:'+searchstr);
	}
	else
	{
		buildSearchRequest();
	}
}

function setSchOpts(options)
{
	try
	{
		if(typeof options.global != 'undefined')
		{
			document.getElementById(options.global ? 'schGlobal' : 'schLocal').style.textDecoration = 'underline';
			document.getElementById(options.global ? 'schLocal' : 'schGlobal').style.textDecoration = '';
			
			document.getElementById('gsc').value = options.global ? 1 : 0;
		}
		
		if(typeof options.hdronly != 'undefined')
		{
			document.getElementById(options.hdronly ? 'schHdr' : 'schTxtHdr').style.textDecoration = 'underline';
			document.getElementById(options.hdronly ? 'schTxtHdr' : 'schHdr').style.textDecoration = '';
			
			document.getElementById('tsc').value = options.hdronly ? 1 : 0;
		}
	}
	catch(e)
	{
		
	}
}

function collectEnhSchOpts()
{
	var opts = {};
	if(!aid)
	{
		var formAttr = document.getElementById('form').childNodes;
		for(var i = 0; i < formAttr.length; i++)
		{
			var aid = parseInt(formAttr[i].id.split('_')[1]);
			var afmt = parseInt(formAttr[i].className.split('_')[1]);
			opts[aid] = afmt;
		}
	}
	else
	{
		var afmt = parseInt(document.getElementById('aid_' + aid).className.split('_')[1]);
		opts[aid] = afmt;
	}
	
	var query = {};
	
	for(aid in opts)
	{
		switch(opts[aid])
		{
			case 1:
			{
				var str = encodeURIComponent(document.getElementById('txt_attr_' + aid).value);
				var hdr_only = document.getElementById('hdr_only_' + aid).checked ? 1 : 0;
				if(str != '')
					query[aid] = hdr_only + '+' + str;
			}
			break;
			case 3:
			{
				var inputs = document.getElementById('ftree_sub_' + aid + '_-1').getElementsByTagName('INPUT');
				var len = inputs.length;
				var checked = [];
				for(var i = 0; i < len; i++)
				{
					if(inputs[i].checked)
						checked.push(inputs[i].value);
				}
				
				if(checked.length > 0)
					query[aid] = checked;
			}
			break;
			case 31:
			{
				var str = document.getElementById('ftree_suggest_' + aid).value.replace('Введите первые символы номера...', '');
				if(str != '')
					query[aid] = encodeURIComponent(str);
			}
			break;
			case 4:
			{
				var str = document.getElementById('date_' + aid).value;
				
				if(str.match(/^[\d]{2}\.[\d]{2}\.[\d]{4}$/))
					query[aid] = str;
			}
			break;
		}
	}
	
	var request = [];
	
	var sep = encodeURIComponent('&');
	
	for(aid in query)
	{
		if(typeof query[aid] == 'string')
			request.push(aid + '=' + query[aid]);
		else if(query[aid] instanceof Array)
		{
			var part = [];
			for(var i = 0; i < query[aid].length; i++)
				part.push(aid + '=' + query[aid][i]);
			
			request.push(part.join(sep));
		}
	}
	
	var out = request.join(sep);
	
	return (out.length > 0) ? out : false;
}

function toggleEnhSchOpts(event)
{
	var schContainer = document.getElementById('__mdiv4-1__');
	
	if(typeof event != 'undefined')
	{
		var header = event.target || event.srcElement;
		
		if(header.className && header.className == 'selectedClear')
		{
			var aid = header.previousSibling.id.split('_')[2];
			clearEnhSchOpts(aid);
			return;
		}
		
		while(!header.className || (header.className != 'searchOptHeader'))
			header = header.parentNode;
		
		var expander = header.getElementsByTagName('IMG')[0];
		var path = expander.src.split('/');;
		var this_aid = expander.id.split('_')[2];
		var this_exp = (path[path.length - 1].split('.')[0] == 'minus');
	}
	else
		var this_aid = 0;
	
	for(var i = 0; i < schContainer.childNodes.length; i++)
	{
		var child = schContainer.childNodes[i];
		if(child.nodeName != 'DIV' || !child.className || child.className != 'searchOptHeader')
			continue;
		
		expander = child.getElementsByTagName('IMG')[0];
		
		var path = expander.src.split('/');
		var aid = expander.id.split('_')[2];
		var exp = (path[path.length - 1].split('.')[0] == 'minus');
		
		var sugg = document.getElementById('ftree_suggest_' + aid);
		var date = document.getElementById('date_' + aid);
		var container = document.getElementById('ftree_sub_' + aid + '_-1');
		var selectedOpts = document.getElementById('ftree_selection_' + aid)
		
		if(!exp && this_aid == aid)
		{
			expander.src = expander.src.replace('plus', 'minus');
			
			if(date)
			{
				selectedOpts.innerHTML = '';
			}
			
			if(sugg)
			{
				selectedOpts.innerHTML = '';
				sugg.style.display = '';
				if(container.childNodes.length > 0)
					container.style.display = '';
			}
			else
				container.style.display = '';
		}
		else
		{
			expander.src = expander.src.replace('minus', 'plus');
			
			if(sugg)
			{
				selectedOpts.innerHTML = document.getElementById('ftree_suggest_' + aid).value.replace('Введите первые символы номера...', '');
				sugg.style.display = 'none';
			}
			else if(date)
			{
				selectedOpts.innerHTML = date.value;
			}
			
			container.style.display = 'none';
		}
		
		selectedOpts.nextSibling.style.display = (selectedOpts.childNodes.length > 0) ? 'block' : 'none';
	}
}

function clearEnhSchOpts(aid)
{
	var opts = {};
	if(!aid)
	{
		var formAttr = document.getElementById('form').childNodes;
		for(var i = 0; i < formAttr.length; i++)
		{
			var aid = parseInt(formAttr[i].id.split('_')[1]);
			var afmt = parseInt(formAttr[i].className.split('_')[1]);
			opts[aid] = afmt;
		}
	}
	else
	{
		var afmt = parseInt(document.getElementById('aid_' + aid).className.split('_')[1]);
		opts[aid] = afmt;
	}
	
	for(aid in opts)
	{
		switch(opts[aid])
		{
			case 1:
			{
				document.getElementById('txt_attr_' + aid).value = '';
				document.getElementById('hdr_only_' + aid).checked = false;
			}
			break;
			case 3:
			{
				var inputs = document.getElementById('ftree_sub_' + aid + '_-1').getElementsByTagName('INPUT');
				var len = inputs.length;
				for(var i = 0; i < len; i++)
				{
					inputs[i].checked = false;
				}
				document.getElementById('ftree_selection_' + aid).innerHTML = '';
			}
			break;
			case 31:
			{
				document.getElementById('ftree_suggest_' + aid).value = 'Введите первые символы номера...';
				document.getElementById('ftree_sub_' + aid + '_-1').innerHTML = '';
				document.getElementById('ftree_sub_' + aid + '_-1').style.display = 'none';
				document.getElementById('ftree_selection_' + aid).innerHTML = '';
			}
			break;
			case 4:
			{
				document.getElementById('date_' + aid).value = '';
				document.getElementById('ftree_selection_' + aid).innerHTML = '';
			}
			break;
		}
		
		var selectedOpts = document.getElementById('ftree_selection_' + aid);
		if(selectedOpts)
			selectedOpts.nextSibling.style.display = (selectedOpts.childNodes.length > 0) ? 'block' : 'none';
	}
}

function buildSearchRequest() {
	
	if(!window.bEnhandedSearch && document.getElementById('searchText').value == '')
		return
	
	if(window.bEnhandedSearch)
	{
		var dbId = document.getElementById('dbId').innerHTML;
		var opts = collectEnhSchOpts();
		if(!opts)
			return;
		
		var url = '/db/its.gateway.php?db=' + dbId + '&action=getxml&query=enhfind__' + opts;
		setWindowCursor('progress');
		this.requestsPending++;
		set_search_cookie();
		jsAjaxUtil.LoadData(url, buildSearchResult);
		return;
	}
	
	var dbId=document.getElementById('dbId')
	//var inputArray=document.getElementsByTagName('INPUT')
	//var length=inputArray.length

	var schBase = 12;
	var query, qparm, requestString, urlSearch;

	switch(document.getElementById('gsc').value)
	{
	case '0':
		var formCfg = document.getElementById('form');
		if(formCfg && formCfg.childNodes && formCfg.childNodes.length > 0)
		{
			//var stdSchLabel = 'Искать в тексте';
			for(var i = 0; i < formCfg.childNodes.length; i++)
			{
				//if(formCfg.childNodes[i].innerHTML && formCfg.childNodes[i].innerHTML == stdSchLabel)
				if(parseInt(formCfg.childNodes[i].className.split('_')[1]) == 1)
				{
					schBase = formCfg.childNodes[i].id.split('_')[1];
					break;
				}
			}
		}
		query = 'find__';
		qparm = ',ns=0,nd=200';
		break
	case '1':
		query = 'globalfind__';
		qparm = ',ns=0';
		break
	}

	//requestString = schBase + '=' + document.getElementById('tsc').value + '+' + document.getElementById('searchText').value
	requestString = schBase + '=0+' + document.getElementById('searchText').value

	if(dbId)
	{
		urlSearch='/db/its.gateway.php?db='+dbId.innerHTML+'&action=getxml&query='+query+requestString+qparm;
		urlSearch='/db/its.gateway.php?db='+dbId.innerHTML+'&action=getxml&query='+query+requestString+qparm;

		setWindowCursor('wait')
		this.requestsPending++
		jsAjaxUtil.LoadData(urlSearch,buildSearchResult)
	}
}

function buildHistoryRequest() {
	
	if(document.getElementById('__mdiv3-1__').innerHTML != '')
	{
		return false;
	}
	setWindowCursor('wait')
	this.requestsPending++
	jsAjaxUtil.LoadData('/db/its.gateway.php?db=alldb&action=getxml&query=search_history',buildHistoryResult)
	
}

function buildSearchResult(data) {
	
	this.requestsPending--
	var searchResultContainer = document.getElementById('__mdiv3-1__')
	searchResultContainer.innerHTML=data
	//attachOnTouchMove(searchResultContainer.firstElementChild, searchResultContainer);
	SetTab(document.getElementById('__tab1-3'))
	if(document.getElementById('dbId').innerHTML!='alldb')
	{
		document.title=document.getElementById('dbNameHeader').innerHTML+' :: Результаты поиска'
	}
	else
	{
		document.title='Поиск :: Результаты поиска'
		document.getElementById('dbNameHeader').innerHTML='Поиск'
	}
	
	if(document.getElementById('lamp') && document.getElementById('lamp').className == 'down' && !window.bEnhandedSearch)
	{
		iss_sch_hl_toggle()
	}
	else
	{
		if(window.bEnhandedSearch)
		{
			if(document.getElementById('lamp') && document.getElementById('lamp').className == 'up')
			{
				iss_sch_hl_toggle()
				//setAnchor('search');
			}
		}
		else
		{
			set_search_cookie()
		}
	}
	
	//var last_result = document.getElementById('__mdiv3-1__').lastChild.previousSibling
	var first_result = document.getElementById('__mdiv3-1__').firstChild
	expandResults(first_result)
	//last_result.scrollIntoView()
	
	setWindowCursor('none')
}

function buildHistoryResult(data) {
	
	this.requestsPending--
	document.getElementById('__mdiv3-1__').innerHTML=data
	ShowTab(document.getElementById('__tab1-3'), true)
	
	if(document.getElementById('dbId').innerHTML!='alldb')
	{
		document.title=document.getElementById('dbNameHeader').innerHTML+' :: Результаты поиска'
	}
	else
	{
		document.title='Поиск :: Результаты поиска'
		document.getElementById('dbNameHeader').innerHTML='Поиск'
	}
	
	//var last_result = document.getElementById('__mdiv3-1__').lastChild.previousSibling
	var first_result = document.getElementById('__mdiv3-1__').firstChild
	if(first_result)
		expandResults(first_result)
	//last_result.scrollIntoView()
	
	setWindowCursor('none')
}

function usersV8Auth(a)
{
	var path = a.href.split('/');
	var page = path[path.length-1];
	if(document.cookie.match('v8_auth=1'))
		document.location.href = a.href;;
	var v8_http_form = document.getElementById('v8_http_form');
	if(v8_http_form)
		document.location.href = a.href;
	else
	{
		var data_url = '/personal/v8_auth.php?page='+encodeURIComponent(page);
		jsAjaxUtil.LoadData(data_url, usersV8SetupFrame);
	}
}

function usersV8SetupFrame(data)
{
	var result = parseXML(data);
	var status = result.getElementsByTagName('status').item(0).firstChild.nodeValue;
	var url = decodeURIComponent(result.getElementsByTagName('url').item(0).firstChild.nodeValue);
	if(status == 'ok')
	{
		var action = 'http://users.v8.1c.ru/default.jsp';
		var tempform = document.createElement('form');
		tempform.id = 'v8_http_form';
		tempform.method = 'post';
		tempform.target = '_top';
		tempform.action = action;
		tempform.style.display = 'none';
		var params = result.getElementsByTagName('param');
		for(var i=0; i < params.length; i++)
		{
			var input = document.createElement('input');
			input.type = 'text';
			input.name = params.item(i).getAttribute('name');
			input.value = params.item(i).firstChild.nodeValue;
			tempform.appendChild(input);
		}
		var enteringButton = document.createElement('input');
		enteringButton.type = 'text';
		enteringButton.name = 'enteringButton';
		enteringButton.value = 'Войти >>>>';
		tempform.appendChild(enteringButton);
		document.body.appendChild(tempform);
		var tempdiv = document.createElement('div');
		tempdiv.innerHTML = '<iframe name="v8_http_frame"' +
			' id="v8_http_frame"' +
			' style="display:none"' +
			' src="' + url + '"' +
			' onload="document.cookie=\'v8_auth=1; domain=.' + document.domain +
			'; path=/; expires=' + new Date(new Date().valueOf() + 30*60*1000).toUTCString() +
			';\';document.getElementById(\'v8_http_form\').submit();"></iframe>';
		document.body.appendChild(tempdiv.firstChild);
	}
	else
		document.location.href = url;
}

function expandResults(obj) {
	
	if(!obj)
		return
	
	var newstyle
	var newdisplay
	switch(obj.className)
	{
	case 'glresult collapsed':
		{
			newstyle='glresult expanded'
			newdisplay='block'
		}
		break
	case 'glresult expanded':
		{
			newstyle='glresult collapsed'
			newdisplay='none'
		}
		break
	}
	if(obj.nextSibling)
		obj.nextSibling.style.display=newdisplay
	obj.className=newstyle
	
	//document.getElementById('__tab1-3').firstChild.href = '#search:' + obj.title;
	document.getElementById('__tab1-3').firstChild.href = '#search';
}

function set_search_cookie(query) {
	
	if(typeof query == 'undefined' || query == null)
	{
		try
		{
			query = encodeURIComponent(document.getElementById('__tab1-3').firstChild.href.split('#')[1].split(':')[1]);
		}
		catch(e)
		{
			
		}
	}
	
	if(typeof query == 'string')
	{
		try
		{
			window.top.document.cookie = 'search_query=' + query + '; path=/';
		}
		catch(e)
		{
		
		}
	}
	
}

function strpos (haystack, needle, offset) {
	
	var i = (haystack+'').indexOf(needle, (offset ? offset : 0))
	return i === -1 ? false : i
	
}

function iss_sch_hl_toggle() {
	
	try
	{
		var lamp = window.top.document.getElementById('lamp')
	}
	catch(e)
	{
		return;
	}
	
	switch(lamp.className)
	{
		case 'up':
		{
			lamp.className = 'down'
			lamp.src = lamp.src.replace('lamp.gif','lamp_down.gif')
			window.top.document.cookie = 'search_query=; path=/'
			if(lamp.parentNode.title)
				lamp.parentNode.title = 'Включить подсветку найденного'
		}
		break
		case 'down':
		{
			lamp.className = 'up'
			lamp.src = lamp.src.replace('lamp_down.gif','lamp.gif')
			set_search_cookie()
			if(lamp.parentNode.title)
				lamp.parentNode.title = 'Выключить подсветку найденного'
		}
		break
	}
	
	if(window.top.document.location.hash.split(':')[0] == '#content')
	{
		var targetDoc = window.top.get_frame_document('docframe,'+window.top.document.location.hash.split(':')[2])
		var spans = targetDoc.getElementsByTagName('SPAN')
		var spans_hl = []
		
		for(i = 0; i < spans.length; i++)
		{
			if(spans[i].className.match('iss_sch_hl'))
			{
				spans_hl.push(i)
			}
		}
		
		for(var i = 0; i < spans_hl.length; i++)
		{
			if(spans[spans_hl[i]].style.backgroundColor == '')
			{
				if(i == 0)
				{
					spans[spans_hl[i]].className = 'iss_sch_hl current'
					spans[spans_hl[i]].style.backgroundColor = 'yellow'
					spans[spans_hl[i]].scrollIntoView(false)
				}
				else
				{
					spans[spans_hl[i]].style.backgroundColor = 'cyan'
				}
			}
			else
			{
				try
				{
					spans[spans_hl[i]].style.removeProperty("background-color")
				}
				catch(e)
				{
					spans[spans_hl[i]].style.backgroundColor = ''
				}
			}
		}
	}
	return false
}

function iss_sch_hl_scroll_to_first() {
	
	try
	{
		if(window.top.document.location.hash.split(':')[0] == '#content')
		{
			var spans = document.getElementsByTagName('SPAN')
			if(spans.length == 0)
			{
				return false
			}
			for(var i = 0; i < spans.length; i++)
			{
				if(spans[i].className == 'iss_sch_hl')
				{
					spans[i].className = 'iss_sch_hl current';
					spans[i].style.backgroundColor = 'yellow';
					spans[i].scrollIntoView(false);
					document.body.scrollLeft = 0;
					return false
				}
			}
		}
	}
	catch(e)
	{
		return;
	}
}

function iss_sch_hl_scroll_to_next(backwards) {
	
	if(document.location.hash.split(':')[0] == '#content')
	{
		if(document.getElementById('lamp').className != 'up')
			iss_sch_hl_toggle();
		
		var targetDoc = document.getElementById('docframe,'+pageElems.doctab).contentWindow.document
		var spans = targetDoc.getElementsByTagName('SPAN')
		var spans_hl = []
		var prev = -1
		var i
		
		if(spans.length == 0)
			return false
		
		for(i = 0; i < spans.length; i++)
		{
			if(spans[i].className.match('iss_sch_hl'))
			{
				spans_hl.push(i)
			}
		}
		
		if(spans_hl.length > 0)
		{
			for(i = 0; i < spans_hl.length; i++)
			{
				if(spans[spans_hl[i]].className == 'iss_sch_hl current')
				{
					spans[spans_hl[i]].className = 'iss_sch_hl'
					spans[spans_hl[i]].style.backgroundColor = 'cyan'
					prev = spans_hl[i]
					break
				}
			}
			
			if(spans_hl.length == 1)
			{
				i = spans_hl[0]
			}
			else
			{
				if(typeof backwards == 'undefined' || !backwards)
				{
					for(i = 0; i < spans_hl.length; i++)
					{
						if(spans_hl[i] > prev)
						{
							i = spans_hl[i]
							break
						}
						if(i == spans_hl.length - 1)
						{
							i = prev
							break
						}
					}
				}
				else
				{
					for(i = spans_hl.length; i >= 0; i--)
					{
						if(spans_hl[i] < prev)
						{
							i = spans_hl[i]
							break
						}
						if(i == 0)
						{
							i = prev
							break
						}
					}
				}
			}
		}
		else
			return false
		
		spans[i].className = 'iss_sch_hl current'
		spans[i].style.backgroundColor = 'yellow'
		spans[i].scrollIntoView(false)
		return false
	}
}

function print_frame() {
	
	if(document.location.hash.split(':')[0] != '#content')
		return false;
	//frames['docframe,'+document.location.hash.split(':')[2]].focus();
	//frames['docframe,'+document.location.hash.split(':')[2]].print();
	if(document.getElementById('lamp').className == 'up')
	{
		iss_sch_hl_toggle();
	}
	var url = document.getElementById('docframe,'+pageElems.doctab).contentWindow.location.toString();
	
	url = url.replace(/(?:#.*)?$/g, '?print');
	
	window.open(url, 'print', 'width=1000,height=700,toolbar=no,location=no,status=no,copyhistory=no,menubar=yes,scrollbars=yes');
}

function doc_onload_hook() {
	
	if(this.frameElement)
	{
		LayoutPage()
		try
		{
			if((window.top.document.location.hash.split(':')[0] == '#content') && (window.top.document.location.hash.split(':').length>3))
			{
				var anchor=decodeURIComponent(window.top.document.location.hash.split(':')[3])
				if(anchors=this.document.getElementsByName(anchor))
				{
					if(anchors.length>0)
					{
						anchors[0].scrollIntoView(true)
					}
				}
			}
		}
		catch(e)
		{
			
		}
		iss_sch_hl_scroll_to_first()
	}
}

function doc_immediate_hook() {
	
	if(this.frameElement)
	{
		//window.top.setView();
		if(IsIOS())
		{
			window.mouseY = 0;
			window.mouseX = 0;
			document.body.addEventListener('touchstart', function(e){
				window.mouseY = e.targetTouches[0].pageY;
				window.mouseX = e.targetTouches[0].pageX;
			});
			document.body.addEventListener('touchmove', function(e){
				e.preventDefault();
				var box = window.frameElement.parentNode;
				box.scrollLeft = box.scrollLeft + window.mouseX - e.targetTouches[0].pageX;
				box.scrollTop = box.scrollTop + window.mouseY - e.targetTouches[0].pageY;
			});
		}
	}
	
	try
	{
		var lamp = window.top.document.getElementById('lamp');
	}
	catch(e)
	{
		
	}
	
	if(this.frameElement && !window.top.switchToDoc(document.title))
		return;
	
	var query = decodeURIComponent(get_cookie_value('search_query'));
	if(query == null || query == '')
	{
		if(lamp && lamp.className == 'up')
		{
			iss_sch_hl_toggle();
		}
	}
	else
	{
		if(lamp && lamp.className == 'down')
		{
			iss_sch_hl_toggle();
		}
		try
		{
			this.onbeforeunload = function()
			{
				window.top.document.cookie = 'hl_page=' + encodeURIComponent(window.top.document.location) + '; path=/';
				window.top.document.cookie = 'try_saved_search_query=' + encodeURIComponent(query) + '; path=/';
			}
		}
		catch(e)
		{
			
		}
		window.top.document.cookie = 'search_query=; path=/';
	}
	
	window.top.pageElems = window.top.createElemLinks();
	
	if(typeof window.top.onNewDoc == 'function')
		window.top.onNewDoc();
}

function get_frame_document(frame)
{
	if(typeof frame == 'string')
		frame = document.getElementById(frame);
	if(!frame)
		return null;
	
	var doc;
	try
	{
		doc = frame.contentWindow.document
	}
	catch(e)
	{
		doc = frame.contentDocument
	}
	return doc;
}

function get_cookie_value(check_name)
{
	try
	{
		var all_cookies = window.top.document.cookie.split( ';' );
	}
	catch(e)
	{
		return null;
	}
	var temp_cookie = '';
	var cookie_name = '';
	var cookie_value = '';
	var b_cookie_found = false;

	for(var i = 0; i < all_cookies.length; i++)
	{
		temp_cookie = all_cookies[i].split('=');
		cookie_name = temp_cookie[0].replace(/^\s+|\s+$/g, '');
		
		if(cookie_name == check_name)
		{
			b_cookie_found = true;
			
			if(temp_cookie.length > 1)
			{
				cookie_value = decodeURIComponent(temp_cookie[1].replace(/^\s+|\s+$/g, ''));
			}
			return cookie_value;
			break;
		}
		temp_cookie = null;
		cookie_name = '';
	}
	if(!b_cookie_found)
	{
		return null;
	}
}

function _Calendar(params, dateVal)
{
	var left, top;
	var width = 180, height = 160;
	if('['+typeof(window.event)+']' == '[object]')
	{
		top = (window.event.screenY+20+height>screen.height-40? window.event.screenY-45-height:window.event.screenY+20);
		left = (window.event.screenX-width/2);
	}
	else
	{
		top = Math.floor((screen.height - height)/2-14);
		left = Math.floor((screen.width - width)/2-5);
	}
	window.open('/bitrix/tools/calendar.php?lang=ru&admin_section=N&'+params+'&date='+escape(dateVal)+'&initdate='+escape(dateVal),'','scrollbars=no,resizable=yes,width='+width+',height='+height+',left='+left+',top='+top);
}

function dbg(msg)
{
	if(typeof console == 'object')
		console.log(msg);
}

function IsIE()
{
	return (document.attachEvent && !IsOpera());
}

function IsOpera()
{
	return (navigator.userAgent.toLowerCase().indexOf('opera') != -1);
}

function IsAndroid()
{
	return navigator.userAgent.match(/AppleWebKit/i) && navigator.userAgent.match(/Android/i);
}

function IsIOS()
{
	return navigator.userAgent.match(/AppleWebKit/i) && navigator.userAgent.match(/iPad|iPhone/i);
}

function checkEmail(email)
{
	var reg = /^[=_.0-9a-z+~\'-]+@(([-0-9a-z_]+\.)+)([a-z]{2,10})$/;
	return (reg.exec(email.toString()) != null);
}

function get_viewport_size()
{
	var width, height;

	if(window.innerWidth)
	{
		width = window.innerWidth;
		height = window.innerHeight;
	}
	else if(document.documentElement && document.documentElement.clientWidth)
	{
		width = document.documentElement.clientWidth;
		height = document.documentElement.clientHeight;
	}
	else
	{
		width = document.getElementsByTagName('body')[0].clientWidth;
		height = document.getElementsByTagName('body')[0].clientHeight;
	}
	
	return {width: width, height: height};
}

function get_viewport_scroll()
{
	var x, y;

	if(window.pageYOffset)
	{
		x = window.pageXOffset;
		y = window.pageYOffset;
	}
	else if(document.documentElement && document.documentElement.scrollTop)
	{
		x = document.documentElement.scrollLeft;
		y = document.documentElement.scrollTop;
	}
	else
	{
		x = document.getElementsByTagName('body')[0].scrollLeft;
		y = document.getElementsByTagName('body')[0].scrollTop;
	}
	
	return {x: x, y: y};
}

function turn_calendar(href)
{
	jsAjaxUtil.LoadData(href, function(data){
		document.getElementById('rcolumn_calendar_header').innerHTML = data;
	});
}

function GA_onclick(a)
{
	var href = a.href;
	try
	{
		var path = new RegExp('https?://([^/]+)(/.*)?', 'i').exec(href);
		if(typeof path[2] != 'undefined')
		{
			var pageTracker = _gat._getTrackerByName();
			pageTracker._trackPageview(path[2]);
		}
	}
	catch(e)
	{
		
	}
}

function find_in_classifier()
{
	if(window.top.current_clpath)
		document.location.hash = '#browse:' + window.top.current_clpath.join(':');
}