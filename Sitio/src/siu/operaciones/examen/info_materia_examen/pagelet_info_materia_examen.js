kernel.renderer.registrar_pagelet('info_materia_examen', function(info) {
    var id = '#' + info.id;
    
	function registrar_listeners() {
        kernel.evts.escuchar('seleccion_materia', cargar_materia);
    }
	
	function cargar_materia(params) {        
		kernel.ajax.load(params.href, id, {
			success: function() {
                registrar_eventos();
				kernel.evts.disparar('info_materia_cargada', params);
				reload_pagelet();
                                $('#materia-nombre').focus();
			}
		});
    }
	
	function registrar_eventos() {
		registrar_eventos_inscripcion();
		registrar_eventos_baja();
		registrar_eventos_baja_inicial();
		registrar_loader_comprobante();
	}
	
	function registrar_eventos_inscripcion() {
		$(id).on('click', '.js-regular', function() {
			$(this).siblings('[name=tipo_insc]').val('R');
		});
		
		$(id).on('click', '.js-libre', function() {
			$(this).siblings('[name=tipo_insc]').val('L');
		});
		
		$(id).on('submit', '.form_inscribir', function() {
			var url = $(this).attr('action');
			kernel.ajax.load(url, id, {
				historia: false,
				type: 'POST',
				data: $(this).serializeArray(),
				success: function(paquete) {
					kernel.evts.disparar('info_examen_inscripto', []);
					/* Nuevo */
					kernel.ui.show_mensaje(paquete.mensaje_mesa_alta,{
							until_interaction: true
					});			
				
					/* */
					reload_pagelet();
				},
				error: function(paquete) {
					$(id).find('[name=__csrf]').val(paquete.csrf_token);
				}
			});
			return false;
		});
	}
	
    function registrar_eventos_baja() {
        $(id).on('submit', '.form_baja', function () {
            var form = $(this);
            kernel.ui.prompt({
                msg: info.msg_baja,
                msg_ok: info.msg_confirmar_baja,
                msg_cancel: 'Cancelar',
                ok: function () {
                    var url = form.attr('action');
                    kernel.ajax.load(url, id, {
                        historia: false,
                        type: 'POST',
                        data: form.serializeArray(),
                        success: function (paquete) {
                            
                            kernel.evts.disparar('info_examen_baja', {
                                cant_inscripciones: $(id).find('.llamado_mesa.inscripto').length
                            });
                            
                            kernel.ui.show_mensaje(paquete.msg_baja_con_comprobante, {
                                until_interaction: true
                            });
                            
                            reload_pagelet();
                        },
                        error: function (paquete) {
                            $(id).find('[name=__csrf]').val(paquete.csrf_token);
                        }
                    });
                    return false;
                }
            });
            return false;
        });
    }

    function registrar_eventos_baja_inicial() {
        $(id).find('.js-baja-inicial').click(function () {
            var materia = $(this).data('materia');
            var mesa = $(this).data('mesa');
            kernel.ui.prompt({
                msg: info.msg_baja,
                msg_ok: info.msg_confirmar_baja,
                msg_cancel: 'Cancelar',
                ok: function () {
                    kernel.ajax.load(info.url_baja_inicial, id, {
                        historia: false,
                        type: 'POST',
                        data: {
                            '__csrf': $(id).find('.js-csrf').data('csrf'),
                            'materia': materia,
                            'mesa': mesa
                        },
                        success: function (paquete) {
                            
                            kernel.evts.disparar('info_examen_baja', {
                                cant_inscripciones: $(id).find('.llamado_mesa.inscripto').length,
                                materia: materia
                            });
                            
                            var inscripciones = $(id).find('.js-mis-inscripciones button').filter(function () {
                                return $(this).data("materia") == materia
                            }).length;

                            kernel.ui.show_mensaje(paquete.msg_baja_con_comprobante, {
                                until_interaction: true
                            });

                            reload_pagelet();
                        },
                        error: function (paquete) {
                            $(id).find('.js-csrf').data('csrf', paquete.csrf_token);
                        }
                    });
                }
            });
        });
        
        $(id).on('click', '.js-detalle-insc', function() {
            $('.detalle-insc[linea="'+$(this).data('linea')+'"]').toggle();
            if($(this).text() === info.msg_mostrar_detalle){
               $(this).text(info.msg_ocultar_detalle);
            } else {
                $(this).text(info.msg_mostrar_detalle);
            }
        });
	}
	
	function reload_pagelet() {
		kernel.evts.dejar_de_escuchar('seleccion_materia', cargar_materia);
		$(id).unbind();
		kernel.renderer.pagelet('info_materia_examen').onload();		
	}
	
	function toggle_msg_comprobante(placeholder) {
		var original_msg = placeholder.find('a').html();
		var nuevo_msg = placeholder.data('msg-toggle');
		placeholder.find('a:first').html(nuevo_msg);
		placeholder.data('msg-toggle', original_msg);
	}
	
	function registrar_loader_comprobante() {
		$(id).on('click', '.comprobante-examen', function() {
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
				});
			} else {
				toggle_msg_comprobante(placeholder_comprobante);
				placeholder_comprobante.find('.img-placeholder').toggle();
			}

			return false;
		});

		// Ver: http://www.gembalabs.com/2015/09/18/cross-browser-print-image-javascript/
		// http://stackoverflow.com/questions/2742144/how-to-print-a-image-file-in-printer
		$(id).on('click', '.js-print-comprobante', function() {

			var content = '<!DOCTYPE html>' +
				'<html>' +
				'<head><title>Comprobante de inscripción a examen</title></head>' +
				'<body onload="window.focus(); window.print(); window.close();">' +
				'<img src="' + $(this).data('img') + '" />' +
				'</body>' +
				'</html>';
			var options = "toolbar=no,location=no,directories=no,menubar=no,scrollbars=yes";
			var printWindow = window.open('', 'print', options);
			printWindow.document.open();
			printWindow.document.write(content);
			printWindow.document.close();
			printWindow.focus();

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

    return {
        onload: function() {
			$('#info_materia_examen').attr('role','alert');
			registrar_listeners();
			registrar_eventos();
			if (info.estado != 'inicial') {
				var params = {
					href: window.location.pathname + window.location.search
				}
				kernel.evts.disparar('info_materia_cargada', params);
			}
        }
    }
})
