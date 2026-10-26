var kernel = kernel || {};
kernel.ui = function() {
	var loading_count = 0;
	return {
		show_loading: function(elem, size, position) {
			if (!position) { 
				// por defecto se muestra en el medio del elemento especificado
				position = {
					my: 'top',
					at: 'center top',
					of: $('body')
				};
				$('#_msg_placeholder').hide();
				$('#loading_top').show().position(position);
				$('#loading_top').css('top', '0px');
			} else {
				var loading = $('#loading');
				if (!size) {
					size = 'big';
				}
				loading.addClass(size);
				loading.css('z-index', 101); // uno más que facebox

				loading.show().position(position);
			}
			
		},
		show_mensaje: function(mensaje, options) {
			var options_default = {
				tipo: 'alert-success',
				until_interaction: false,
				timeout: 5000,
				fadeout: 2000
			}
			options = $.extend(options_default, options);
			
			var position = {
				my: 'top',
				at: 'center top',
//				offset: '0 ' + $(window).scrollTop(),
				of: $('body')
			};
			
			$('#_msg_placeholder').removeClass('alert-success').removeClass('alert-error');
			$('#_msg_placeholder').removeClass('alert-info');
			$('#_msg_placeholder').addClass(options.tipo);
			$('#_msg_placeholder').html(mensaje).show().position(position);
			$('#_msg_placeholder').css('top', '0px');
			if (options.until_interaction) {
				var fn = function() {
					if(typeof cargando_dev_bar === 'undefined' || cargando_dev_bar === false) {
						$('#_msg_placeholder').hide();
						$('#_msg_placeholder').unbind('ajaxStart', fn);
					}
				};
				$('#_msg_placeholder').bind('ajaxStart', fn);
			} else {
				setTimeout(function() {
					$('#_msg_placeholder').fadeOut(options.fadeout);
				}, options.timeout);
			}
		},
		
		add_show_loading_count: function(val) {
			loading_count++;
			if (loading_count == 1) {
				kernel.ui.show_loading();
			}
		},
		
		substract_show_loading_count: function(val) {
			loading_count--;
			if (loading_count <= 0) {
				kernel.ui.hide_loading();
			}
		},
		
		hide_loading: function() {
			$('#loading').removeClass().hide();
			$('#loading_top').removeClass().hide();
		},
		
		mostrar_notificaciones: function(titulo, mensajes) {
			var notifs = kernel.ui.armar_notificaciones(titulo, mensajes);
			var button = $("<input type='button' value='Cerrar'>").click(function() {
				$(document).trigger('close.facebox');
			});
			notifs.append(button);
			$.facebox(notifs);
		},
		armar_notificaciones: function (titulo, mensajes) {
			var cont = $('<div class="cont_mensajes">');
			if (titulo != '') {
				cont.append($('<h3>').html(titulo));
			}
			
			var mensaje, clase;
			$.each(mensajes, function(i, elem) {
				switch (elem.mtipo) {
					case 'E': clase = 'alert-error'; break;
					case 'A': clase = 'alert-warning'; break;
					case 'M': clase = 'alert-info'; break;
				}
				mensaje = $('<div>').addClass('alert').addClass(clase);
				mensaje.html(elem.mcuerpo);
				cont.append(mensaje);
			});

			return cont;	
		},
		modal: function(mensaje) {
			var mensaje_default = {
				mensaje: '',
				titulo: false,
				tipo: 'warning',
				nuevo_intento: false
			}
			mensaje = $.extend(mensaje_default, mensaje);
			var titulo = (mensaje.titulo) ? "<h2>"+mensaje.titulo+"</h2>" : '';
			var div = $("<div class='kernel-modal "+mensaje.tipo+"'>"+ titulo +"<span class='mensaje_modal'>" + mensaje.mensaje + "</span><br/></div>");

			if (mensaje.nuevo_intento !== false) {
				var texto = mensaje.nuevo_intento.texto;
				var button = $("<input type='button' value='"+texto+"'>").click(mensaje.nuevo_intento.fn);
				div.append(button);
			}
			
			$.facebox(div);
		},
		pagelet_modal: function(url) {
			var place_holder = $('<div>');

			kernel.ajax.load(url, place_holder, {
				historia: false,
				type: 'get',
				reemplazar_nodo: false,
				success: function() {
					$.facebox(place_holder);
				}
			});
		},
		prompt: function(options) {
			var defaults = {
				title: '',
				msg: '',
				msg_ok: 'ok',
				msg_cancel: 'Cancelar',
				text_box: false,
				icon_question: true,
				ok: function() {
					if (console) {
						console.log('no handler for ok');
					}
				}
			};

			options = $.extend(defaults, options);

			var text_box = false;
			if (options.text_box) {
				text_box = $('<textarea class="textarea">');
			}

			var b_cancel = $('<a href="#">').html(options.msg_cancel).click(function() {
				$(document).trigger('close.facebox');
			});
			
			var div = $('<div class="controls">');
			if (options.title != '') {
				div.append('<h3>' + options.title + '</h3>');
			}

			div.append('<p>' + options.msg + '</p>');
			
			if (text_box) {
				div.append(text_box);
			}
			
			var wrapper =  $('<div class="clearfix">');
			
			var botonera = $('<div class="pull-left">');
			
			var icono = $('<div class="pull-right">').append('<span style="position:relative; top: 6px; right: 13px;" class="icon-question-sign"></span>');

			if (options.ok !== false) {
				var b_ok = $('<button role="link" type="button" class="btn btn-small btn-ok">').html(options.msg_ok).click(function() {
					$(document).trigger('close.facebox');
					if (text_box) {
						options.ok(text_box.val());
					} else {
						options.ok();
					}
				});
				botonera.append(b_ok);
			}

			botonera.append(b_cancel);
			
			if (options.icon_question == true){
				wrapper.append(botonera).append(icono);
			} else {
				wrapper.append(botonera);
			}
			
			div.append(wrapper);

			$.facebox(div, 'prompt');
			$('#facebox button.btn-ok').focus();
		}
	}
}();
