function on_openid_hidden_iframe_load(event)
{
	event = event || window.event;
	var iframe = event.target || event.srcElement;
	var openid_root = (window.top.location.pathname != '/auth_openid.php') ? '/openid/' : '/openid/index_new.php';
	
	try
	{
		var iframe_doc = get_frame_document(iframe);
		var iframe_href = iframe_doc.location.href;
		if(iframe_href.match(/\/blank\.htm$/))
			if(iframe.className)
			{
				if(iframe.className == 'no_autosubmit')
					return;
				else if(iframe.className == 'logout')
					iframe_doc.location.replace(openid_root + '?logout=yes');
			}
			else
				iframe.contentWindow.location.replace(openid_root);
		return;
	}
	catch(e)
	{
		if(window.openid_form_submitted && window.top.location.pathname != '/auth_openid.php')
		{
			var new_iframe = document.createElement('IFRAME');
			new_iframe.style.display = 'none';
			new_iframe.id = iframe.id;
			new_iframe.name = iframe.name;
			new_iframe.className = iframe.className;
			new_iframe.src = openid_root + '?force_error';
			
			addHandler(new_iframe, 'load', on_openid_hidden_iframe_load);
			
			document.body.removeChild(iframe);
			document.body.appendChild(new_iframe);
		}
	}
}