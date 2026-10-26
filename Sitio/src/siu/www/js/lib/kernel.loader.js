var kernel = kernel || {};
kernel.loader = function() {
	// the scripts that were loaded
	var loaded_css = [];
	var loaded_js = [];
	var loading_js = [];
	var loading_css = [];

	function substract(a1, a2) {
		if (typeof a1 == 'undefined') {
			return [];
		}

		var a=[], diff=[];
		for(var i = 0; i < a1.length; i++)
			a[a1[i]]=true;
		for(var i = 0; i < a2.length; i++)
			if(a[a2[i]]) delete a[a2[i]];
		for(var k in a)
			diff.push(k);
		return diff;
	}

	return {
		load_css: function(css_list, callback) {
			// primero se sacan los que ya fueron cargados
			css_list = substract(css_list, loaded_css);
			// luego se sacan los que se están cargando
			css_list = substract(css_list, loading_css);
			if (css_list.length == 0) {
				callback();
			} else {
				loading_css = loading_css.concat(css_list);
				LazyLoad.css(css_list, function() {
					loaded_css = loaded_css.concat(css_list);
					callback();
				});
			}
		},
		load_js: function(js_list, callback) {
			// primero se sacan los que ya fueron cargados
			js_list = substract(js_list, loaded_js);

			// luego se sacan los que se están cargando
			js_list = substract(js_list, loading_js);
			if (js_list.length == 0) {
				callback();
			} else {
				loading_js = loading_js.concat(js_list);
				LazyLoad.js(js_list, function() {
					loaded_js = loaded_js.concat(js_list);
					callback();
				});
			}
		},
		cleanup: function() {
			loading_css = [];
			loading_js  = [];
//			loaded_css = [];
//			loaded_js = [];
			LazyLoad.abort();
		}
	}
}();