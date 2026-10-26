/**
 * Requiere que los renglones tengan id #renglon_[renglon_nro]
 * los campos de fecha deben ser input[type=date]
 * el formulario debe tener clase form-renglones
 * cuando hay un error en un renglón se agrega la clase error
 */

(function ( $ ) {
	var settings = {
		nav_class: '.nav',
		validadores: {},
		highlight_renglon: false,
		mensaje_submit_con_error: 'No se puede guardar ya que hay errores',
		success: function() {
			
		},
		error: function() {
			
		}
	};
	
	var clase_form = 'form-renglones';
	var clase_error = 'error';
	var pagelet;

	var error_desc = $('<div>').addClass('info-msg').hide().click(function() {
		$(this).hide();
	}).appendTo($('body'));
	
	function get_tipo_campo(elem) {
		return elem.data('tipo');
	}
	
	/**
	 * clase_input es la clase del elemento que disparó el evento
	 */
	function move_row(renglon_actual, direccion, tipo_campo) {
		var renglon_nuevo;
		if (direccion == 'next') {
			renglon_nuevo = renglon_actual.next();
		} else {
			renglon_nuevo = renglon_actual.prev();
		}
		
		if (renglon_nuevo.length > 0) {
			renglon_nuevo.find("[data-tipo='" + tipo_campo + "']").select().focus();
		}
	}
	
	function bind_mov_listeners() {
		pagelet.delegate(settings.nav_class, 'keydown', function(e) {
			var input = $(this);
			var parent = input.parents('tr');
			var tipo  = get_tipo_campo(input);
			
			if (e.keyCode == 13) { // enter
				move_row(parent, 'next', tipo);
				e.preventDefault();
			}

			if (e.keyCode == 38) { // up
				move_row(parent, 'prev', tipo);
			}

			if (e.keyCode == 40) { // down
				move_row(parent, 'next', tipo);
			}
		});
		
		pagelet.delegate('tr', 'focus', function() {
			$(this).addClass('selected');
		});

		pagelet.delegate('tr', 'blur', function(e) {
			$(this).removeClass('selected');
		});
	}
	
	/**
	 * puede recibir un elemento tr que es el renglón o un nro
	 */
	function highlight_renglon(renglon) {
		var row = (isNaN(renglon)) ? renglon : $("#renglon_" + renglon);
		
		// se agrega este flag xq el animate hay que agregarselo a dos elementos
		// por compatibilidad crossbrowser
		var completed = false;
		$('html, body').animate({
			scrollTop: row.offset().top
		}, {
			duration: 200,
			complete: function() {
				if (completed) {
					return;
				}
				row.addClass('resultado-busqueda');
				row.find('[data-tipo=nota]').focus();
				completed = true;
			}
		});
	}
	
	function init_fechas() {
		pagelet.find("[data-tipo='fecha']").datepicker({
			onSelect: function() {
				validar($(this));
			}
		});
	}
	
	function hay_error_validacion() {
		var row = pagelet.find('.' + clase_error);
		var hay_error = row.length > 0;
		if (hay_error) {
			kernel.ui.show_mensaje(settings.mensaje_submit_con_error, {tipo: 'alert-error'});
			highlight_renglon(row);
		}
		
		return hay_error;
	}
	
	function guardar($form, data) {
		return kernel.ajax.call($form.attr('action'), {
			type: 'post',
			data: data,
			historia: false,
			success: function(paquete) {
				// en paquete.cont viene el pagelet entero, hay que agregar
				// sólo el contenido
				pagelet.empty().html($(paquete.cont).children());
				inicializar();
				validar_renglones();
				var e = pagelet.find('.error-renglon:first');
				if (e.length == 0) {
					settings.success();
				} else {
					settings.error();
				}
			}, 
			error: function(paquete) {
				kernel.ui.modal({
					mensaje: paquete.cont,
					tipo: 'alert-error'
				});
			}
		});
	}
	
	function inicializar() {
		init_paginador();
		init_ficha();
		init_fechas();
		pagelet.find('.error-renglon').tooltip();
	}
	
	
	function registrar_evento_form() {
		pagelet.delegate('.' + clase_form, 'submit', function() {
			var $form = $(this);
			var data  = $form.serializeArray();
			
			if (hay_error_validacion()) {
				return false;
			}
			
			guardar($form, data);
			return false;
		});
	}
	
	function validar_renglones() {
		pagelet.find('tbody tr').each(function() {
			var row = $(this);
			$(settings.validadores).each(function(i, validador) {
				if (validador.tipo == 'inicial') {
					validador.validar(row);
					return false;
				}
				return true;
			})
		});
	}
	
	function validar(elem) {
		var row = elem.parents('tr');
		var tipo = elem.data('tipo');

		$(settings.validadores).each(function(i, validador) {
			if ($.inArray(tipo, validador.tipo) > -1) {
				validador.validar(row, tipo);
				return false; // brake the loop
			}

			return true;
		}); 
	}

	function bind_error_listeners() {
		pagelet.delegate('input', 'keyup', function() {
			validar($(this));
		});

		pagelet.delegate('select', 'change', function() {
			validar($(this));
		});

		pagelet.delegate('select', 'click', function() {
			$(this).trigger('change');
		});
	}
	
	function init_paginador() {
		pagelet.delegate('.pager_link', 'click', function() {
			var $form = pagelet.find('.form-renglones');
			var data = $form.serializeArray();
			if (hay_error_validacion()) {
				return false;
			}
			var promise = guardar($form, data);
			var link = $(this).prop('href');
			promise.done(function(param) {
				if (pagelet.find('.error-renglon').length == 0) {
					guarani.cambiar_op({href: link});
				}
			});
			return false;
		});
	}
	
	function init_ficha() {
		pagelet.find('.ficha-alumno img').click(function() {
			var url = $(this).parent().data('url-ficha');
			kernel.ui.pagelet_modal(url);
		});
	}
	
	var methods = {
		init: function ( options ) {
			if ( options ) {
				var aux = {};
				$.extend(true, aux, settings, options);
				settings = aux;
			}

			pagelet = this;
			pagelet.find('[data-tipo=nota]:first').focus();
			registrar_evento_form();
			inicializar();
			bind_mov_listeners();
			
			bind_error_listeners();
			if (settings.highlight_renglon && settings.highlight_renglon !== false) {
				highlight_renglon(settings.highlight_renglon);
			}
			validar_renglones();
		},
		
		set_error: function (element, mensaje) {
			if (element.hasClass(clase_error)) {
				return;
			}
			element.prop('title', mensaje);
			element.tooltip();
			element.tooltip('enable');
			element.tooltip('show');
			element.addClass(clase_error);
		},
		
		remove_error: function (element) {
			if (! element.hasClass(clase_error)) {
				return;
			}

			element.tooltip('hide');
			element.tooltip('disable');
			element.removeClass(clase_error);
		}
	}
	
	$.fn.plugin_renglones = function ( method ) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return  methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' doesnt exist on jQuery.upload');
		}
	}
}) (jQuery);