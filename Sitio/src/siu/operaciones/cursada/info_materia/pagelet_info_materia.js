kernel.renderer.registrar_pagelet('info_materia', function(info) {
	var id = '#' + info.id;
	var mensajes = info.mensajes;

	// Filtros
	function init_filtros() {
		$('#filtro_comisiones li').on({
			click: function() {
				accionar_multifiltro($(this));
			},
			keypress: function(e) {
				if (e.keyCode == 13) {
					$(this).trigger('click');
				}
			}
		});
		
		$('#filtro_sedes').change(function() {
			filtrar();
		});
	}
	
	function accionar_multifiltro($elem) {
		if (!$elem.hasClass('seleccionado')) {
			$elem.addClass('seleccionado');
			$elem.children('span').attr('aria-checked','true');
		} else {
			// Cuando se clickea sobre un filtro seleccionado este se desactiva
			$elem.removeClass('seleccionado');
			$elem.children('span').attr('aria-checked','false');
		}
		filtrar();
	}
	
	function filtrar() {
		// comisiones que no tienen inscripciones
		var comisiones = $('#comisiones li.comision.no-inscripto');
		comisiones.hide();

		// Filtros
		// Días chequeados
		var filtro_dias = $('#filtro_dias li.seleccionado span');
		
		var string_filtro_dias = "";
		if (filtro_dias.length > 0){
			filtro_dias.each(function(j, f){
				if (j > 0) {
					string_filtro_dias = string_filtro_dias + ',';
				}
				string_filtro_dias = string_filtro_dias + '.horario:containsi('+ $(f).prop('class') +')';
			});
		}
		
		// Turnos chequeados
		var filtro_turnos = $('#filtro_turnos li.seleccionado span');
		
		
		
		var string_filtro_turnos = "";
		if (filtro_turnos.length > 0){
			filtro_turnos.each(function(j1, f1){
				if (j1 > 0) {
					string_filtro_turnos = string_filtro_turnos + ',';
				}
				string_filtro_turnos = string_filtro_turnos + '.turno.'+ $(f1).prop('class');
			});
		}
		// Sedes
        if($('#filtro_sedes').length > 0){
            var filtro_sede = $('#filtro_sedes').val();
            var string_filtro_sede = "";
            if(filtro_sede != "todas"){
                string_filtro_sede = '.sede:containsi('+filtro_sede+')';
                comisiones = comisiones.has(string_filtro_sede);
            }
        }

		if (string_filtro_turnos.length > 0){
            comisiones = comisiones.has(string_filtro_turnos);

            if (string_filtro_dias.length > 0){
                comisiones = comisiones.has(string_filtro_dias);
                comisiones.show();
            }
		}
	}
	// Fin Filtros
	
	
	function submit_comisiones(e)
	{
		var $form = $(e.target);
		var url = $form.attr('action');
		submit_inscripcion(url, $form);
	}

	function submit_subcomisiones(e)
	{
		var $form = $(e.target);
		var url = $form.attr('action');

		var error = false;
		$form.children('fieldset').each(function() {
			var $this = $(this);

			$this.next('.alert-error').remove();
			var val = $this.find('input').serialize();
			if (val == '') { // no seleccionó ninguna subcomisión
				var mensaje = mensajes.error_subcomision;
				$this.after("<div class='alert alert-error locura'>" + mensaje + "</div>");
				error = true;
			}
		});

		if (! error) {
			submit_inscripcion(url, $form);
		}
	}

	function submit_inscripcion(url, $form) {
		kernel.ajax.load(url, id, {
			historia: false,
			type: 'POST',
			data: $form.serializeArray(),
			success: function(paquete) {
				kernel.evts.disparar('info_materia_inscripto', []);
				/* Nuevo */
				kernel.ui.show_mensaje(paquete.mensaje_cert_alta,{
							until_interaction: true
						});
				/* */
				reload_pagelet();
			},
			error: function(paquete) {
				$(id).find('[name=__csrf]').val(paquete.csrf_token);
			}
		});
	}

	function registrar_eventos_comisiones() {
		init_filtros();
		$(id + ' .form_inscribir_subcomisiones').submit(function(e) {
			submit_subcomisiones(e);
			return false;
		});
		$(id + ' .form_inscribir').not('.form_inscribir_subcomisiones').submit(function(e) {
			submit_comisiones(e);
			return false;
		});
	}

	function registrar_eventos_info_catedras() {
		$(".toggle_info_catedra").hide();

		$('span.catedra_ver_info').click(function() {
			$(this).toggleClass("activo").parent().next().slideToggle("fast");
			return false;
		});
	}

	function registrar_eventos() {
		registrar_eventos_comisiones();
		registrar_eventos_info_catedras();
		registrar_loader_comprobante();
		registrar_eventos_inscripto();
		registrar_eventos_baja_inicial();
	}

	function cargar_materia(params) {
		kernel.ajax.load(params.href, id, {
			success: function(paquete) {
				$('.titulo_operacion .notificaciones').remove();
				kernel.evts.disparar('info_materia_cargada', params);
				//reload_pagelet();
				$('#materia-nombre').focus();
			},
			complete: function() {
				reload_pagelet();
			}
		});
	}

	function registrar_listeners() {
		var id_evento = 'seleccion_materia';
		kernel.evts.escuchar(id_evento, cargar_materia);
	}

	function registrar_eventos_inscripto() {
		$(id + ' .form_baja').submit(function() {
			var $form = $(this);
			var url = $form.attr('action');

			submit_baja(url, $form);
			return false;
		});
	}

	function toggle_msg_comprobante(placeholder)
	{
		var original_msg = placeholder.find('a').html();
		var nuevo_msg = placeholder.data('msg-toggle');
		placeholder.find('a:first').html(nuevo_msg);
		placeholder.data('msg-toggle', original_msg);
	}

	function registrar_loader_comprobante() {
		$(id).on('click', '.comprobante-cursada', function() {
			var placeholder_comprobante = $(this);
			var url_img = placeholder_comprobante.data('img');
			if (! placeholder_comprobante.data('loaded')) {
				kernel.ui.show_loading(placeholder_comprobante, 'small', {
					my: 'center',
					at: 'right center',
					offset: '10 0',
					of: placeholder_comprobante
				});
				$('<img />').attr('src', url_img).load(function() {
					$(this).appendTo(placeholder_comprobante.find('.img-placeholder'));
					kernel.ui.hide_loading();
					toggle_msg_comprobante(placeholder_comprobante);
					placeholder_comprobante.find('.img-placeholder').toggle();
					placeholder_comprobante .data('loaded', true);
					$(this).attr('alt',"Imagen de comprobante");
				});
			} else {
				toggle_msg_comprobante(placeholder_comprobante);
				placeholder_comprobante.find('.img-placeholder').toggle();
			}
			return false;
		});

		$(id).on('click', '.js-print-comprobante', function() {
			var w = window.open($(this).data('img'), '_blank', 'menubar=0,scrollbars=0,location=0');
			w.document.title = 'Imprimir comprobante de cursada';
			w.onload = function() {
				w.print();
			};
			return false;
		});

		$(id).on('click', '.js-mail-comprobante', function() {
			var href = $(this).attr('href');
			var fn_ok = function() {
				kernel.ajax.call(href, {
					type: 'get',
					success: function() {
						kernel.ui.show_mensaje(info.envio_mail_exitoso);
					}
				});
			};

			kernel.ui.prompt({
				title: info.msg_titulo_enviar,
				msg: (info.falta_mail) ? info.msg_falta_mail : info.msg_enviar,
				msg_ok: info.msg_enviar_boton,
				ok: (info.falta_mail) ? false : fn_ok
			});

			return false;
		});
	}

	function submit_baja(url, $form) {
		kernel.ui.prompt({
			msg: info.msg_baja,
			msg_ok: info.msg_confirmar_baja,
			msg_cancel: 'Cancelar',
			ok: function() {
				kernel.ajax.load(url, id, {
					historia: false,
					type: 'POST',
					data: $form.serializeArray(),
					success: function(response) {
						kernel.evts.disparar('info_materia_baja', {
							cant_inscripciones: $(id).find('.comision.inscripto').length
						});
						kernel.ui.show_mensaje(response.mensaje_cert_baja, {
							until_interaction: true
						});
						reload_pagelet();
					},
					error: function(paquete) {
						$(id).find('[name=__csrf]').val(paquete.csrf_token);
					}
				});
			}
		});
	}

	function registrar_eventos_baja_inicial() {
		$(id).find('.js-baja-inicial').click(function() {
			var materia = $(this).data('materia');
			var comision = $(this).data('comision');
			kernel.ui.prompt({
				msg: info.msg_baja,
				msg_ok: info.msg_confirmar_baja,
				msg_cancel: 'Cancelar',
				ok: function() {
					kernel.ajax.load(info.url_baja_inicial, id, {
						historia: false,
						type: 'POST',
						data: {
							'__csrf': $(id).find('.js-csrf').data('csrf'),
							'materia': materia,
							'comision': comision
						},
						success: function(response) {
							var inscripciones = $(id).find('.js-mis-inscripciones button').filter(function() {
								return $(this).data("materia") == materia 
							}).length;
							// cuando se ejecuta el onload se registra el listener de nuevo
							kernel.evts.disparar('info_materia_baja', {
								cant_inscripciones: inscripciones,
								materia: materia
							});
							kernel.ui.show_mensaje(response.mensaje_cert_baja, {
								until_interaction: true
							});
							reload_pagelet();
						},
						error: function(paquete) {
							$(id).find('.js-csrf').data('csrf', paquete.csrf_token);
						}
					});
				}
			});
		});
	}

	function reload_pagelet()
	{
		kernel.evts.dejar_de_escuchar('seleccion_materia', cargar_materia);
		$(id).unbind();
		kernel.renderer.pagelet('info_materia').onload();
	}

	return {
		onload: function() {
			registrar_listeners();
			registrar_eventos();
			if (info.estado !== 'inicial') {
				var params = {
					href: window.location.pathname + window.location.search
				}
				kernel.evts.disparar('info_materia_cargada', params);
			}
		}

	}
})
