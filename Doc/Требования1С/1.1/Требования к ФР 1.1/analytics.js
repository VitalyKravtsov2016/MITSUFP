var bTrack = 
    	document.location.pathname != '/'
    &&	document.location.pathname.indexOf('/db/') != 0
  ;

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-9034550-2']);
  if(bTrack)
    _gaq.push(['_trackPageview']);

  var ga_script = 'ga.js';

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/'+ga_script;
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
  
  window.onerror = function(msg, url, line) {
    var preventErrorAlert = true;
    _gaq.push(['_trackEvent', 'JS Error', msg, navigator.userAgent + ' -> ' + url + " : " + line]);
    return preventErrorAlert;
  };