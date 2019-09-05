var exec = require('cordova/exec');

exports.connect = function(ssid, password, isPrefix) {
		return new Promise(function(resolve, reject){
			 exec(resolve, reject, "HotspotConnect", "connect", [ssid, password, isPrefix]);
		});
};

exports.cancel = function() {
		exec(function(){}, function(){}, "HotspotConnect", "cancel");
};
