function init_popup(parent)
{
	if(document.getElementById('popup_container'))
	{
		var popup = document.getElementById('popup_container').firstChild;
		if(popup.childNodes.length > 1)
		{
			var controls = popup.firstChild;
			popup.innerHTML = '';
			popup.appendChild(controls);
		}
		return popup;
	}
	
	var container = document.createElement('DIV');
	container.id = 'popup_container';
	container.style.backgroundImage = 'url(/images/popup/tableinput_bg.png)';
	
	container.style.position = 'absolute';
	if(typeof parent == 'object')
	{
		container.style.top = parent.offsetTop + 'px';
		container.style.left = parent.offsetLeft + 'px';
	}
	else
	{
		container.style.top = 0;
		container.style.left = 0;
	}
	
	container.style.zIndex = 10;
	
	var popup = document.createElement('DIV');
	popup.style.backgroundColor = '#FFFDE8';
	popup.style.margin = 'auto';
	popup.style.position = 'relative';
	popup.style.zIndex = 998;
	
	var controls = document.createElement('DIV');
	controls.id = 'popup_controls';
	controls.style.backgroundColor = '#F5EEB7';
	controls.style.borderBottom = 'solid 1px #ffe289';
	controls.style.height = '22px';
	controls.style.lineHeight = 0;
	controls.style.textAlign = 'right';
	
	var close_button = document.createElement('IMG');
	close_button.src = '/images/popup/close.gif';
	close_button.style.cursor = 'pointer';
	close_button.style.margin = '3px';
	addHandler(close_button, 'click', close_popup);
	
	container.appendChild(popup);
	popup.appendChild(controls);
	controls.appendChild(close_button);
	if(typeof parent == 'undefined')
		document.body.appendChild(container);
	else
		parent.appendChild(container);
	
	return popup;
}

function display_popup(content, mode, parent)
{
	if(this.frameElement)
	{
		parent = window.top.document.getElementById('__mainspace__') || this.frameElement.parentNode;
		window.top.display_popup(content, mode, parent);
		return false;
	}
	if(typeof content == 'undefined')
		return;
	
	if(!mode)
		mode = 'node';
	
	if(typeof(parent) == 'string')
		parent = document.getElementById(parent) || document.body;
	
	var popup = init_popup(parent);
	
	switch(mode)
	{
		case 'frame':
		{
			var frame = document.createElement('IFRAME');
			frame.frameBorder = 'no';
			frame.style.border = '0';
			frame.style.width = '100%';
			popup.appendChild(frame);
			try
			{
				frame.contentWindow.location = content.toString();
			}
			catch(e)
			{
				frame.location = content.toString();
			}
		}
		break;
		case 'video':
		{
			var player = document.createElement('DIV');
			player.id = 'player';
			player.style.textAlign = 'center';
			
			player.innerHTML = '<p style="margin-top:10%">' +
							   '<a href="http://get.adobe.com/flashplayer/" target="_blank">' +
							   '<img src="/images/popup/flash.jpg"></a></p>' +
							   '<p>Для просмотра видеоролика необходимо установить<br>' +
							    '<a href="http://get.adobe.com/flashplayer/" target="_blank">Adobe Flash Player</a></p>';
			
			popup.appendChild(player);
			
			if(!content.match(/^(?:\/|http[s]?:\/\/)/))
			{
				var base_url = document.location.pathname;
				base_url = base_url.replace(/[^\/]*$/, '');
				content = base_url + content;
			}
			
			window.flashvars = {
				"m": "video",
				"uid": "player",
				"st": document.location.protocol + "//" + document.location.host + "/video/st.php?file=" + encodeURI(content)
			};
			
			window.flashparams = {
				"bgcolor": "#FFFDE8", 
				"allowFullScreen": "true",
				"allowScriptAccess": "always",
				"id": "player"
			};
			
			if(IsAndroid() || IsIOS())
			{
				window.flashvars.file = content;
				new Uppod(flashvars);
			}
			else
				new swfobject.embedSWF(
					"/swf/uppod.swf?1.2.2", // UPPOD_VER
					flashparams.id,
					'100%',
					(typeof parent == 'undefined') ? get_viewport_size().height - popup.firstChild.offsetHeight
												   : parent.clientHeight - popup.firstChild.offsetHeight,
					"9.0.115",
					"/swf/expressInstall.swf",
					flashvars,
					flashparams,
					false,
					swfobject_callback
				);
			
		}
		break;
		default:
		{
			var node = document.createElement('DIV');
			switch(typeof content)
			{
				case 'object':
				{
					if('nodeType' in content)
						node.appendChild(content);
					else
						node.innerHTML = content.toString();
				}
				break;
				default:
				{
					node.innerHTML = content.toString();
				}
			}
			popup.appendChild(node);
		}
	}
	
	addHandler(document.body, 'keydown', on_body_keydown);
	addHandler(window, 'resize', adjust_popup);
	
	if(mode == 'video')
	{
		if(window.addEventListener)
			window.addEventListener('DOMMouseScroll', on_body_mousewheel, false);
		else
		{
			document.attachEvent('onmousewheel', on_body_mousewheel);
			window.attachEvent('onmousewheel', on_body_mousewheel);
		}
	}
	
	if(popup.parentNode.parentNode.tagName == 'BODY')
		popup.parentNode.parentNode.style.overflow = 'hidden';
	
	popup.parentNode.style.display = 'block';
	adjust_popup();
}

function swfobject_callback(result)
{
	if(result.success)
	{
		adjust_popup();
		uppodPlayers();
	}
}

function video_playback_toggle()
{
	uppodSend(window.flashparams.id, 'toggle');
}

function get_popup_active_mode()
{
	var popup_container = document.getElementById('popup_container');
	var popup = popup_container.firstChild;
	if(popup.childNodes.length < 2)
		return false;
	
	var content = popup.lastChild;
	
	if(content.tagName == 'IFRAME')
		return 'frame';
	if(content.tagName == 'DIV')
		return 'frame';
	if(content.tagName == 'OBJECT' && typeof window.flashparams == 'object' && content.id == window.flashparams.id)
		return 'video';
}

function adjust_popup()
{
	var container = document.getElementById('popup_container');
	var popup = container.firstChild;
	var controls = popup.firstChild;
	var frame = popup.lastChild;
	
	var video_size = get_video_size();
	
	if(container.parentNode.tagName == 'BODY')
	{
		var vsize = get_viewport_size();
		var vscroll = get_viewport_scroll();
		container.style.left = vscroll.x + 'px';
		container.style.top = vscroll.y + 'px';
	}
	else
	{
		var vsize = {
			height: container.parentNode.clientHeight,
			width: container.parentNode.clientWidth
		};
		container.style.left = container.parentNode.offsetLeft + 'px';
		container.style.top = container.parentNode.offsetTop + 'px';
	}
	
	if(container.parentNode.tagName == 'BODY' && vsize.width < 800)
		popup.style.width = '800px';
	else
		popup.style.width = vsize.width * 0.96 + 'px';
	
	popup.style.height = vsize.height * 0.96 + 'px';
	popup.style.top = vsize.height * 0.02 +'px';
	
	container.style.height = vsize.height + 'px';
	container.style.width = vsize.width + 'px';

	frame.style.height = (vsize.height * 0.96 - controls.offsetHeight) + 'px';
	
	if(get_popup_active_mode() == 'video')
		window.top.document.body.focus();
}

function get_video_size()
{
	var size = uppodGet('player', 'get[comment]');
	if(size)
	{
		size = size.split('x');
		if(size.length > 1)
		{
			size = {
				w: size[0],
				h: size[1]
			};
		}
	}
	return size;
}

function on_overlay_click(event)
{
	var status = uppodGet(window.flashparams.id, 'getstatus');
	if(status == 1)
		uppodSend(window.flashparams.id, 'pause');
	else
		uppodSend(window.flashparams.id, 'play');
}

function on_body_keydown(event)
{
	event = event || window.event;
	if(get_popup_active_mode() == 'video')
	{
		switch(event.keyCode)
		{
			case 27: // Esc
			{
				close_popup();
			}
			break;
			case 32: // Space
			{
				video_playback_toggle();
			}
			break;
			case 38: // Up
			{
				uppodSend(window.flashparams.id, 'scale+');
			}
			break;
			case 40: // Down
			{
				uppodSend(window.flashparams.id, 'scale-');
			}
			break;
			case 37: // Left
			{
				var position = Math.round(uppodGet(window.flashparams.id, 'getime'));
				position -= 20;
				if(position < 0)
					position = 0;
				uppodSend(window.flashparams.id, 'seek:' + position.toString());
			}
			break;
			case 39: // Right
			{
				var position = Math.round(uppodGet(window.flashparams.id, 'getime'));
				var duration = Math.round(uppodGet(window.flashparams.id, 'getimed'));
				position += 20;
				if(position > duration)
					position = duration;
				uppodSend(window.flashparams.id, 'seek:' + position.toString());
			}
			break;
			default:
			{
				return true;
			}
		}
		if(event.preventDefault)
			event.preventDefault();
		event.returnValue = false;
		return false;
	}
	else if(event.keyCode == 27)
		close_popup();
}

function on_body_mousewheel(event)
{
    event = event || window.event;
	var delta = 0;
    if(event.wheelDelta)
		delta = event.wheelDelta / 120;
	else if(event.detail)
		delta = -event.detail / 3;
	if(delta)
	{
		handle_mousewheel(delta);
		if(event.preventDefault)
			event.preventDefault();
		event.returnValue = false;
	}
}

function handle_mousewheel(delta)
{
	var volume = parseInt(uppodGet(window.flashparams.id, 'getv'));
	if(delta < 0)
	{
		volume -= 5;
		if(volume < 0)
			volume = 0;
	}
	else
	{
		volume += 5;
		if(volume > 100)
			volume = 100;
	}
	uppodSend(window.flashparams.id, 'v' + volume.toString());
}

function close_popup()
{
	var popup_container = document.getElementById('popup_container');
	popup_container.style.display = 'none';
	var mode = get_popup_active_mode();
	
	if(mode == 'video')
		swfobject.removeSWF(window.flashparams.id);
	
	removeHandler(window, 'resize', adjust_popup);
	removeHandler(document.body, 'keydown', on_body_keydown);
	
	var parent = popup_container.parentNode;
	if(parent.tagName == 'BODY')
		parent.style.overflow = '';
	
	if(mode == 'video')
	{
		if(window.removeEventListener)
			window.removeEventListener('DOMMouseScroll', on_body_mousewheel, false);
		else
		{
			document.detachEvent('onmousewheel', on_body_mousewheel);
			window.detachEvent('onmousewheel', on_body_mousewheel);
		}
	}
	
	return false;
}