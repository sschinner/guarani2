var kernel = kernel || {};
kernel.historia = function() {
	var callbacks = {};
	var h = window.History;
	var reemplazando_estado = null;
	var current_state;
	var force_mostrar_mensaje_nav = null;
	var fn_mostrar_mensaje_nav = function() {return false;};
	var mensaje_nav = '';
	var nav_from_browser = true;
	
	h.Adapter.bind(window, 'statechange', function(e) {
		var	state = h.getState(),
			id = state.data.id,
			elem = (state.data.target) ? $(state.data.target) : false,
			estado_inicial = (state.data.es_inicial) ? state.data.es_inicial : false,
			url = state.url,
			url_ajax = url,
			cambia_op = (! kernel.util.igual_op(url_anterior, url)) || state.data.forzar_cambio_op;
		
		if (reemplazando_estado === id) {
			kernel_config.historia_activa = true;
			reemplazando_estado = null;
			return;
		}

		var mostrar_mensaje = mostrar_mensaje_navegacion();
		set_bind_onbeforeunload(mostrar_mensaje);
		
		if (mostrar_mensaje) {
			if (nav_from_browser) { // se tiene que ignorar la navegación ajax para que salga el mensaje del browser
				window.location.href =url;
				return;
			}
			if (confirm(mensaje_nav)) {
				disable_mensaje_nav(); // se desactiva para el próximo request
			} else {
				kernel.historia.replace(current_state.url);
				kernel.ui.hide_loading();
				return;	
			}
		}
		
		// se deja preparado para el próximo request
		nav_from_browser = true;
		
		// actualizamos la url_anterior
		url_anterior = url;

		// Si es el estado inicial o cambia la operación se debe renderizar
		// toda la operación nuevamente. Por simplicidad el estado inicial
		// siempre renderiza toda la operación nuevamente
		if (estado_inicial || cambia_op) {
			url_ajax = url + ((url.indexOf('?') != -1) ? "&co=1" : "?co=1");
//			$('#kernel_contenido').empty();
		}
		kernel.evts.disparar('kernel.onBeforeLoad', {
			href: url
		});
		$(document).trigger('close.facebox');
		kernel.ui.show_loading();
		
		kernel.ajax.call(url_ajax, {
			success: function(paquete) {
				kernel.ui.hide_loading();
				if (estado_inicial || cambia_op) {
					kernel.renderer.cleanup();
					window.scrollTo(0,0);
					$('#kernel_contenido').html(paquete.cont);	// se renderiza toda la operación
				} else {
					if (elem) {
						if (state.data.reemplazar_nodo) {
							$(elem).replaceWith(paquete.cont);
						} else {
							$(elem).html(paquete.cont);
						}
					}
				}
				kernel.evts.disparar('kernel.afterRender', {});

				current_state = {
					data: state.data,
					title: state.title,
					url: state.url
				};
				if (callbacks[id]) {
					callbacks[id].success(paquete);	
					callbacks[id].complete(paquete);	
				}
			}
		});
	});

	function mostrar_mensaje_navegacion()
	{
		if (force_mostrar_mensaje_nav === null) {
			return fn_mostrar_mensaje_nav();
		}
		
		return force_mostrar_mensaje_nav;
	}
	
	function disable_mensaje_nav()
	{
		force_mostrar_mensaje_nav = null;
		fn_mostrar_mensaje_nav = function() {return false;};
	}
	
	function set_bind_onbeforeunload(activo)
	{
		if (activo) {
				window.onbeforeunload = function() {
					return mensaje_nav;
				}
		} else {
			window.onbeforeunload = null;
		}
	}

	return {
		back: function() {
			if (mostrar_mensaje_navegacion() && confirm(mensaje_nav)) {
				disable_mensaje_nav(); // se desactiva para el próximo request
				nav_from_browser = false;
				h.back();
				return;
			}
			if (! mostrar_mensaje_navegacion()) {
				nav_from_browser = false;
				h.back();
				return;
			}
		},

		replace: function(url) {
			nav_from_browser = false;
			reemplazando_estado = current_state.data.id;
			h.replaceState(current_state.data, current_state.title, url);
		},
		
		push: function(params, titulo, url) {
			nav_from_browser = false;
			h.pushState(params, titulo, url);
		},
		
		get_current_state: function() {
			return current_state;
		},
		/**
		 * @param {type} id
		 * @param object fns objeto con dos entradas, success y complete. Cada una es una función
		 * que será ejecutada cuando el cambio de página con id 'id' se complete
		 */
		add_callback: function(id, fns) {
			callbacks[id] = fns;
		},
				
		set_fn_mensaje_nav_condicional: function(fn) {
			fn_mostrar_mensaje_nav = fn;
		},
		
		set_mostrar_mensaje_nav: function (mostrar) {
			force_mostrar_mensaje_nav = mostrar;
		},
		set_mensaje_nav: function(mensaje) {
			mensaje_nav = mensaje;
		},
		
		set_estado_inicial: function(url) {
			var id = 'estado_inicial';
			reemplazando_estado = id;
			var estado_inicial = {
				data: {				
					id: id,
					es_inicial: true,
					target: '#kernel_contenido'
				},
				title: document.title,
				url: url
			};
			h.replaceState(estado_inicial.data, estado_inicial.title, estado_inicial.url);
			current_state = estado_inicial;
			// La librería a veces dispara el onstatechange cuando se hace
			// un replaceState y a veces no. Esto es un failsafe para evitar 
			// comportamiento extraño
			setTimeout(function() {
				kernel_config.historia_activa = true;
				reemplazando_estado = null;
			}, 1000);
		}
	}
}();

var url_anterior = document.URL.replace(/#.*$/,'');

$(document).ready(function() {
    // Extensión jquery, contains case insensitive
    $.extend($.expr[':'], {
        'containsi': function(elem, i, match, array)
        {
            return (elem.textContent || elem.innerText || '').toLowerCase()
            .indexOf((match[3] || "").toLowerCase()) >= 0;
        }
    });

	// seteamos el estado inicial de la historia
	kernel.historia.set_estado_inicial(url_anterior);
	
	// Configuración de facebox
	var alias = (kernel_config.alias == '/') ? '' : kernel_config.alias;
	$.facebox.settings.opacity = 0.7;
	$.facebox.settings.closeImage   = alias + '/img/closelabel.png';
	$.facebox.settings.loadingImage = alias + '/img/loading.gif';
});