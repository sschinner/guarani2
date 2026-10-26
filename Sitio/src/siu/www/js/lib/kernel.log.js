var kernel = kernel || {};

kernel.log = function() {
	var debug = [];
	return {
		add_debug: function(etiqueta, valor) {
			var entrada = {
				etiqueta: etiqueta,
				valor: valor
			};
			
			debug.push(entrada);
		},
		
		show: function() {
			$.each(debug, function(i, e) {
				console.log(i + ':' + e.etiqueta);
				console.log(e.valor);
			});
		}
	}
}();