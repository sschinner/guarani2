var kernel = kernel || {};
kernel.util = function() {
    var intervalos = [];
    
    kernel.evts.escuchar('guarani.beforeCambiarOp', function() {
        for (var i = 0; i < intervalos.length; i++) {
            clearInterval(intervalos[i]);
        }
        intervalos = [];
    }, true);
    
	return {
		get_current_op: function() {
			return kernel_config.op_actual;
		},
        
        clear_interval: function(id_intervalo) {
            for (var i = 0; i < intervalos.length; i++) {
                if (id_intervalo == intervalos[i]) {
                   clearInterval(intervalos[i]);
                   console.log(intervalos[i]);
                   var pos = intervalos.indexOf(id_intervalo);
                   pos > -1 && intervalos.splice( pos, 1 );
                }
            }
        },
		
        set_interval: function(fn, time) {
            var id_intervalo = setInterval(fn, time);
            intervalos.push(id_intervalo);
            return id_intervalo;
        },
        
		igual_op: function(url_1, url_2) {
			var op1, op2, regexp;
			if (kernel_config.pretty_urls) {
				var alias = kernel_config.alias;
				alias = (alias == '/') ? '' : alias;
				regexp = new RegExp('//.*?' + alias + '/(.*?)(\\?|/|$)', 'i');
				op1 = url_1.split(regexp)[1];
				op2 = url_2.split(regexp)[1];
			} else {
				op1 = url_1.split(/\?o=(.*?)($|&)/gi)[1];
				op2 = url_2.split(/\?o=(.*?)($|&)/gi)[1];
			}
			return op1 == op2;
		},
		
		parse_url: function (str, component) {  
			// *     example 1: parse_url('http://username:password@hostname/path?arg=value#anchor');  
			// *     returns 1: {scheme: 'http', host: 'hostname', user: 'username', pass: 'password', path: '/path', query: 'arg=value', fragment: 'anchor'}  
			var  o   = {  
				strictMode: false,  
				key: ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"],  
				q:   {  
					name:   "queryKey",  
					parser: /(?:^|&)([^&=]*)=?([^&]*)/g  
				},  
				parser: {  
					strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,  
					loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/\/?)?((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/ // Added one optional slash to post-protocol to catch file:/// (should restrict this)  
				}  
			};  

			var m   = o.parser[o.strictMode ? "strict" : "loose"].exec(str),  
			uri = {},  
			i   = 14;  
			while (i--) uri[o.key[i]] = m[i] || "";  

			switch (component) {  
				case 'PHP_URL_SCHEME':
					return uri.protocol;  
				case 'PHP_URL_HOST':
					return uri.host;  
				case 'PHP_URL_PORT':
					return uri.port;  
				case 'PHP_URL_USER':
					return uri.user;  
				case 'PHP_URL_PASS':
					return uri.password;  
				case 'PHP_URL_PATH':
					return uri.path;  
				case 'PHP_URL_QUERY':
					return uri.query;  
				case 'PHP_URL_FRAGMENT':
					return uri.anchor;  
				default:
					var retArr = {};  
					if (uri.protocol !== '') retArr.scheme=uri.protocol;  
					if (uri.host !== '') retArr.host=uri.host;  
					if (uri.port !== '') retArr.port=uri.port;  
					if (uri.user !== '') retArr.user=uri.user;  
					if (uri.password !== '') retArr.pass=uri.password;  
					if (uri.path !== '') retArr.path=uri.path;  
					if (uri.query !== '') retArr.query=uri.query;  
					if (uri.anchor !== '') retArr.fragment=uri.anchor;  
					return retArr;  
			}  
		},
		trans: function(msg, vars) {
			if($.type(msg) == 'string') {
				if($.type(vars)=='array' && vars.length) {
					var i = 0;
					while(/%\w+%/.test(msg)) {
						if(i >= vars.length) i=0;
						msg = msg.replace(/%\w+%/, vars[i]);
						i++;
					}
				} else if($.type(vars) == 'object' && !$.isEmptyObject(vars)) {
					for(var i in vars) {
						var re = new RegExp('%'+i+'%','g');
						msg = msg.replace(re, vars[i]);
					}
				} else if($.type(vars) != "undefined" && $.type(vars) != "null") {
					msg = msg.replace(/%\w+%/g, vars);
				}
			}
			return msg;
		}
	}
}();