//	Uppod.AJAX для плеера Uppod (http://uppod.ru/player/ajax/)  


	var uppod_instances = new Array();
	var uppod_instances_id = new Array();

	// Настройки
	var uppod_play_next=0; // 1 - включать следующий плеер по окончании


	function uppodTheEnd(playerID) {
		if(uppod_play_next==1){
			if(uppod_instances_id[playerID]<uppod_instances.length-1){
				document.getElementById(uppod_instances[uppod_instances_id[playerID]+1]).sendToUppod('play');
			}
			else{
				document.getElementById(uppod_instances[0]).sendToUppod('play');
			}
		}
	}
	function uppodStopAll(playerID) { 
		for(var i = 0;i<uppod_instances.length;i++) {
			try {
				if(uppod_instances[i] != playerID){
					document.getElementById(uppod_instances[i]).sendToUppod("stop");
				}
			}
			catch( errorObject ) {
			}
		}
	}

	function uppodPlayers(){
		var objectID;
		var objectTags = document.getElementsByTagName("object");
		for(var i=0;i<objectTags.length;i++) {
			objectID = objectTags[i].id;
			if(objectID.indexOf("player") >-1&uppod_instances.indexOf(objectID)==-1) {
				
				uppod_instances[i] = objectID;
				uppod_instances_id[objectID]=i;
			}
		}
	}

	if(!Array.indexOf){ 
		Array.prototype.indexOf = function(obj){
		for(var i=0; i<this.length; i++){
			if(this[i]==obj){
				return i;
				}
			}
			return -1;
			}
	}
	function uppodInit(playerID) {}
	//function uppodSend(playerID) {}
	//var ap_uppodID = setInterval(uppodPlayers, 1000);