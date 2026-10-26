var kernel = kernel || {};
kernel.ajax = function() {
	var error_generico = 'ocurrió un error, chequee su conexión a internet';
	var listener_response = null;
	var handler_cambio_op = null;
	var ongoing_call = false;
	return {
		set_error_generico: function(msg) {
			error_generico = msg;
		},
		nuevo_request: function(req_data) {
			if (handler_cambio_op === null) {
				window.location = req_data.url;	
			} else {
				handler_cambio_op(req_data);
			}
        },
		/**
		 * Setea el manejador de cambio de operación. Si no se setea se
		 * hará un window.location
		 * @param function fn
		 */
		set_handler_cambio_op: function(fn) {
			handler_cambio_op = fn;
		},
		set_listener_response: function(fn) {
			listener_response = fn;
		},
		
		call: function(url, options) {
			var default_options = {
				dataType: 'json',
				type: 'GET',
				async: true,
				data: {},
				show_loading: true,
				redirect: true,
				success: function() {},
                complete: function() {},
				error: false,
				undo: false
			};
			
			if (ongoing_call) {
				return false;
			}
			ongoing_call = true;
			options = $.extend(default_options, options);
			
			if (options.show_loading) {
				kernel.ui.show_loading();
			}
			
			var promise = $.ajax({
				url: url,
				dataType: options.dataType,
				data: options.data,
				async: options.async,
				type: options.type,
                contentType: options.contentType,
                processData: options.processData,
                complete: function() {
					ongoing_call = false;
                    options.complete();
					if (typeof _gaq !== "undefined" && _gaq !== null) {
						_gaq.push(['_trackPageview', url]);
					}
                },
				error: function(jqXHR, textStatus, errorThrown) {
					ongoing_call = false;
					kernel.ui.hide_loading();
					if (options.error !== false) {
						options.error(jqXHR, textStatus, errorThrown);
					} else {
						var msg;
						if (kernel_config.es_produccion) {
							msg = error_generico;
						} else {
							var msg_div = $("<div>");
							msg_div.append("<p><b>Status</b>: " + $('<div/>').text(textStatus).html() + "</p>");
							msg_div.append("<p><b>Error</b>: " + $('<div/>').text(errorThrown.type).html() + "</p>");
							msg_div.append("<p><b>Response</b>: <pre>" + $('<div/>').text(jqXHR.responseText).html() + "</pre></p>");
							msg = msg_div.html();
						}
						kernel.ui.modal({
							mensaje: msg,
							tipo: "error"
						});
					}
				},
				success: function(paquete) {
					ongoing_call = false;
					kernel.ui.hide_loading();
					
					// si hubo error y hay undo hay que mostrar el elemento
					// que se había escondido en la carga

					if (paquete.cod > 0) {
						if (paquete.titulo) {
							document.title = paquete.titulo;
						}
						if (paquete.operacion) {
							kernel_config.op_actual = paquete.operacion;
						}
						if (listener_response != null) {
							listener_response(paquete);
						}
						options.success(paquete);
						if (paquete._notif) {
							kernel.ui.mostrar_notificaciones(paquete._notif.titulo, paquete._notif.notificaciones);
						}
					} else if (paquete.cod == -1) {
						kernel.ui.modal({
							mensaje: paquete.cont,
							tipo: "error"
						});
					} else if (paquete.cod == -2) {
						if (options.redirect) {
							kernel.ajax.nuevo_request(paquete.cont);
							// no hay que ejecutar el handler de error customizado
							// porque se cambia el contexto en el que se espera
							// la respuesta
							return;
						}							
					} else if (paquete.cod == -4) {
						kernel.ui.mostrar_notificaciones(paquete.titulo, paquete.mensajes);
					}

					if (paquete.cod < 1) {
						if (options.error !== false) {
							options.error(paquete);
						}
					}

				}
			});
			
			return promise;
		},
		load: function(url, elem, options) {
			options = options || {};
			var default_options = {
				historia: true,
				url_actual: null,
				success: function(){},
				complete: function(){},
				titulo: null,
				forzar_cambio_op: false,
				show_loading: true,
				loading_pos: false,
				reemplazar_nodo: true
			};
			
			if (ongoing_call) {
				return;
			}
			
			options = $.extend(true, default_options, options);
			var undo = false;
			if (options.show_loading) {
				kernel.ui.show_loading();
			}

			if (options.historia) {
				if (kernel.util.parse_url(url_anterior, 'PHP_URL_SCHEME') != kernel.util.parse_url(url, 'PHP_URL_SCHEME')) {
					kernel.ajax.nuevo_request(url);
					return;
				}
				
				if (options.url_actual !== null) {
					kernel.historia.replace(options.url_actual);	
				}
				
				var id = Math.random();
				kernel.historia.add_callback(id, {
					success: options.success,
					complete: options.complete
				});
				
				window.History.pushState({
					id: id,
					target: elem,
					forzar_cambio_op: options.forzar_cambio_op,
					reemplazar_nodo: options.reemplazar_nodo
				}, options.titulo, url);
			} else {
				var old_fn_success = options.success;
				options.success = function(paquete) {
					kernel.ui.hide_loading();
					$(elem).empty();
					undo = false; // clear undo
					if (options.reemplazar_nodo) {
						$(elem).replaceWith(paquete.cont);
					} else {
						$(elem).html(paquete.cont);
					}
					old_fn_success(paquete);
				}
				kernel.ajax.call(url, options);
			}
		}
	}
}();