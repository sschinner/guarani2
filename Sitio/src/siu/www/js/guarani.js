var guarani = function() {
	var ajax_nav_enabled = true;
	
	function init_perfiles() {
        $( document ).on( "vclick", "li.js-perfil-item", function(event) {
            event.preventDefault();
			var perfil = $(this).data('perfil');
			window.location.replace(url_cambio_perfil + "?id=" + perfil);
	    });
	}
	
	function init_carreras() {
		if ($('#js-select-carreras').length == 0) {
			return;
		}
		
		$('#js-select-carreras').change(function() {
			var carrera = $(this).val();
			window.location.replace(url_cambio_carrera + "?id=" + carrera + "&op=" + kernel_config.op_actual);
		});
	}
	
	function init_carreras_phone() {
		if ($('li.js-carrera-nombre').length == 0) {
			return;
		}

        $( document ).on( "vclick", "li.js-carrera-nombre", function(event) {
            event.preventDefault();
			var carrera = $(this).data('carrera-id');
			console.log(carrera);
			window.location.replace(url_cambio_carrera + "?id=" + carrera);
	    });
	}
	
	function init_links() {
		$('body').delegate('a', 'click', function() {
			if ($(this).hasClass('js-new-tab')) {
				window.open(this.href);
				return false;
			}
			var cambiar = ! $(this).hasClass('no-ajax') && this.href != '' && ! this.href.match(/#$/);
			if (cambiar) {
				var params = {href: this.href, cambia_op: true};
				guarani.cambiar_op(params);
				return false;
			}
		});

		$('body').delegate('.link-in-data', 'click', function(e) {
			if ($(e.target).is('a')) { // si apretó en un link lo dejamos pasar
				return true;
			}

			var url = $(this).data('link');
			var params = {href: url, cambia_op: true};
			guarani.cambiar_op(params);
			return false;
		});
		
		/* nuevo saltar a contenido ppal */
		$('#saltar_cppal').click(function(e) {
			document.location.href=this.href;
			return false;
		});		
		/* */
		
	}
	
	function listener_global(paquete) {
		if (paquete.cant_mensajes) {
			var leidos = paquete.cant_mensajes.LEIDOS;
			var total  = paquete.cant_mensajes.TOTAL;
			var no_leidos = total - leidos;
			if (no_leidos == 0) {
				$('#js-cant-mensajes').removeClass('badge-warning');
			} else {
				$('#js-cant-mensajes').addClass('badge-warning');
			}
			$('#js-cant-mensajes').text(no_leidos);
		}
	}
	
    return {
		set_ajax_nav: function(value) {
			ajax_nav_enabled = value;
		},
		set_condicion_antes_de_navegar: function(fn_condicion, mensaje) {
			kernel.historia.set_fn_mensaje_nav_condicional(fn_condicion);
			kernel.historia.set_mensaje_nav(mensaje);
		},
		cambiar_op: function(params) {
			if (! ajax_nav_enabled) {
				window.location.href = params.href;
				return false;
			}
			if (! kernel_config.historia_activa) {
				return false;
			}
			kernel.evts.disparar('guarani.beforeCambiarOp', {});
			var id = '#kernel_contenido';
			var href = params.href;
			var historia = (params.historia || params.historia === false) ? params.historia : true;
			var show_loading = (params.show_loading || params.show_loading === false) ? params.show_loading : true;
			var mensaje_post_navegacion = (params.mensaje_post_navegacion) ? params.mensaje_post_navegacion : false;
			// hack para esconder el menu
			$('.dropdown').removeClass('open');
			$('.nav-collapse').removeClass('in').css('height',0);
			
			
			kernel.ajax.load(href, id, {
				success: function(paquete) {
                    if (paquete.operacion) {
                        var menu_item = $('#'+paquete.operacion);
                        if (! menu_item.hasClass('js-menuitem-root')) {
                            menu_item = menu_item.parents('.js-menuitem-root');
                        }
                        $('#js-nav').find('.js-menuitem-root').removeClass('menu-item-seleccionado');
                        menu_item.addClass('menu-item-seleccionado');
//						clearMenus();
                    }
					kernel.evts.disparar('operacion_cambiada', {href: params.href});
					if (mensaje_post_navegacion !== false) {
						kernel.ui.show_mensaje(mensaje_post_navegacion.mensaje, mensaje_post_navegacion.options);
					}
				},
				historia: historia,
				forzar_cambio_op: true,
				show_loading: show_loading
			});
		},
		
		validar_password_debil: function (password, password_msg_box, msg_pass_requerido, msg_pass_debil, password_error_class, pattern){			
			
			var weak_pass = false;
			
			if(password.val() == ""){
				password_msg_box.fadeOut('slow');
				password.removeClass(password_error_class);
				weak_pass = false;
			}
			else{
				
				var pattern = new RegExp(pattern);
				if(pattern.test(password.val())){
					password_msg_box.fadeOut('slow');
					password.removeClass(password_error_class);
					weak_pass = false;
				}
				else{
					password_msg_box.html(msg_pass_debil);
					password_msg_box.fadeIn('slow');
					password.addClass(password_error_class);
					weak_pass = true;
				}
				
			}
			
			return weak_pass;
		},
		
		validar_password: function (apassword, npassword, rpassword, apassword_msg_box, npassword_msg_box, rpassword_msg_box, input_error_class, msg_pass_requerido, msg_pass_no_coincide, msg_pass_confirmar, is_npassword_weak, msg_pass_debil) {
				
				npassword.removeClass(input_error_class);
				npassword_msg_box.fadeOut('slow');
				rpassword.removeClass(input_error_class);
				rpassword_msg_box.fadeOut('slow');
				
				if (apassword != null) {
					apassword.removeClass(input_error_class);
					apassword_msg_box.fadeOut('slow');
					
					if (apassword.val() == ""){
					
						apassword.addClass(input_error_class);
						apassword_msg_box.html(msg_pass_requerido);
						apassword_msg_box.fadeIn('slow');
						return false;
					
					}
				
				}
				
				if (npassword.val() == ""){
					
					npassword.addClass(input_error_class);
					npassword_msg_box.html(msg_pass_requerido);
					npassword_msg_box.fadeIn('slow');
					return false;
					
				}
				else if(is_npassword_weak){
						
						npassword.addClass(input_error_class);
						npassword_msg_box.html(msg_pass_debil);
						npassword_msg_box.fadeIn('slow');
						return false;
					
				}

				if (rpassword.val() == "") {
					
					rpassword.addClass(input_error_class);
					rpassword_msg_box.html(msg_pass_confirmar);
					rpassword_msg_box.fadeIn('slow');
					return false;
					
				} else if(npassword.val() != rpassword.val()) {
					
					npassword.addClass(input_error_class);
					npassword_msg_box.html(msg_pass_no_coincide);
					npassword_msg_box.fadeIn('slow');
				
					return false;
				}
				return true;
		},
		
        init: function() {
			init_perfiles();
			init_carreras_phone();
			init_carreras();
			init_links();

            $.ui.autocomplete.prototype._renderMenu = function( ul, items ) {
                var that = this;
                var id_input = that.element.attr('id');
                $.each( items, function( index, item ) {
                    that._renderItemData( ul, item );
                });
                $( ul ).attr( "id", id_input+'-autocomplete-ul' );
            };

            //http://stackoverflow.com/questions/2435964/jqueryui-how-can-i-custom-format-the-autocomplete-plug-in-results
            /*$.ui.autocomplete.prototype._renderItem = function( ul, item) {
                var re = new RegExp($.ui.autocomplete.escapeRegex(this.term), 'gi') ;
                item.label = item.label.replace(re,"<span style='font-weight:bold;color:#0088cc;'>" +
                    "$&" +
                    "</span>");

                return $("<li></li>")
                    .data("item.autocomplete", item)
                    .append("<a>" + item.label + "</a>")
                    .appendTo(ul);

            };*/

			$('body').click(function() {
			    $('.dropdown').removeClass('open');
			});
			$('body').on('click', '.js-btn-back', function() {
				guarani.cambiar_op({href:$(this).data('url-back')});
			});
			
			$('body').on('click', '.js-history-back', function () {
				kernel.historia.back();
				return false;
			});
			
			var selector_perfil = $('#js-selector-perfiles');
			if (selector_perfil.length > 0) {
			    var perfil_actual = selector_perfil.find('.js-seleccion-perfil').data('perfilnombre');
			    selector_perfil.find('.js-texto-perfil').html('Perfil: ' + perfil_actual);
			}
			
			kernel.ajax.set_listener_response(listener_global);
			
//			kernel.evts.escuchar('cambio_operacion', guarani.cambiar_op, true);

        }
    }
}();

$(document).ready(function() {
    guarani.init();
});
	
/*function __kolla_encuesta_respondida(hab, param) {
	kernel.renderer.pagelet('encuesta').callback(hab, param);
			// alert('it worked!'); }
}*/
