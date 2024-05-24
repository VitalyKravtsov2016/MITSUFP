//	JavaScript API 2.0 for Uppod 1+
//  http://uppod.ru/js

	// Events
	
	function uppodEvent(playerID,event) { 
		
		if(typeof window.top.console != 'undefined')
			window.top.console.log(event);
		
		switch(event){
		
			case 'init': 
				
				break;
				
			case 'start': 
				
				break;
			
			case 'play': 
				
				break;
				
			case 'pause': 
				
				break;
				
			case 'stop': 
				
				break;
				
			case 'seek': 
							
				break;
				
			case 'loaded':
				
				break;
				
			case 'end':
				
				break;
				
			case 'download':
				
				break;
				
			case 'quality':
				
				break;
			
			case 'error':
				
				break;
					
			case 'ad_end':
				
				break;
				
			case 'pl':
				
				break;
		}
		
		if(typeof get_popup_active_mode == 'function')
		{
			var full = parseInt(uppodGet('player', getfull));
			if(!full)
			{
				window.top.document.activeElement.blur();
				window.top.document.body.focus();
			}
		}
	}
	
	// Commands
	
	function uppodSend(playerID,com,callback) {
		var player = document.getElementById(playerID);
		if(player && typeof player.sendToUppod == 'function')
			player.sendToUppod(com);
	}
	
	// Requests
	
	function uppodGet(playerID,com,callback) {
		var player = document.getElementById(playerID);
		if(player && typeof player.getUppod == 'function')
			return player.getUppod(com);
	}

