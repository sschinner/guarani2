var kernel = kernel || {};

kernel.evts = function() {
	var eventos = {};

	function buscar_listeners(evt) {
		if (eventos[evt]) {
			return eventos[evt];
		} else {
			return [];
		}
	}

	return {
		dejar_de_escuchar: function(nombre, fn) {
			var listeners = buscar_listeners(nombre);
			if (listeners.length == 0) {
				return;
			}
			
			for (var i = 0; i < listeners.length; i++) {
				if (fn == listeners[i].fn) {
					listeners.splice(i, 1);
					return;
				}
			}
		},
		escuchar: function(nombre, fn, global) {
			if (global === undefined) {
				global = false;
			}

			if (!eventos[nombre]) {
				eventos[nombre] = [];
			}

			eventos[nombre].push({
				fn: fn,
				global: global
			});
		},
		cleanup: function() {
			var new_eventos = {};
			$.each(eventos, function(i) {
//					if (i.indexOf('menu') == 0 || i.indexOf('kernel.') == 0) {
//						new_eventos[i] = this;
//					}
				var listeners_globales = [];
				$.each(eventos[i], function() {
					if (this.global) {
						listeners_globales.push(this);
					}
				});
				if (listeners_globales.length > 0) {
					new_eventos[i] = listeners_globales;
				}
			});
			eventos = new_eventos;
		},

		disparar: function(nombre, params) {
			var listeners = buscar_listeners(nombre);
			if (listeners.length == 0) {
				return;
			}

			for (var i = 0; i < listeners.length; i++) {
				listeners[i].fn(params);
			}
		}
	}
}();