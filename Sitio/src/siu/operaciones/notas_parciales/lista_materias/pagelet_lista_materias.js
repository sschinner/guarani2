kernel.renderer.registrar_pagelet('lista_materias', function(info) {
    var id = '#' + info.id;
	// Se guarda la comisión sobre la cuál se abrió el popup de creación de parciales
	var comision_popup = null;

	function reformat_fecha(data) {
		var changeformat= $("#fecha").val();     
		var arraydates = changeformat.split("/");     
		var newdate = arraydates[2]+"-"+arraydates[1]+"-"+arraydates[0];
		
		$(data).each(function(i, elem) {
			if (elem.name == 'fecha') {
				elem.value = newdate;
				return false;
			}
			return true;
		})
	}
        
        function crear_tooltips() {
            $('.js-no-puede-cargar-notas').tooltip('destroy');
            $('.js-no-puede-cargar-notas').tooltip({title: info.mensajes.fecha_evaluacion_mayor_hoy});
        }

    return {
        onload: function() {
			$(id + ' .js-materia-cabecera').on('click', function () {
				$(this).next('.js-materia-contenido').toggleClass('colapsado').slideToggle(500);
			}).on('keypress', function(e) {
                         if (e.which == 13) { $(this).trigger('click'); }
                        });
			
			$(id + ' #js-toggle-all').on('click', function () {
				var accion = $(this).toggleClass('toggle');
				
				var texto_actual = accion.text();
				var texto_nuevo = accion.data('toggle-texto');
				accion.data('toggle-texto', texto_actual);
				accion.text(texto_nuevo);
				
				$('.js-materia-contenido').each(function() {
					if ( accion.hasClass('toggle') ) {
						$(this).addClass('colapsado').slideUp(500);
					} else {
						$(this).removeClass('colapsado').slideDown(500);
					}
					
				});
			});
			
			$(id + ' .comision-nombre').on('click', '.crear', function(evt) {
				comision_popup = $(this).parents('.comision').data('comision-id');
				parciales = $(this).parents('.comision').find('.parciales-comision');
				console.log(parciales);
				fecha_inicio_per_lect = $(this).parents('.comision').data('fecha-ini-per-lect');
				btn_crear = $(this);
				kernel.ui.prompt({
					title: info.titulo_crear_parcial,
					msg: info.html_popup,
					msg_ok: info.boton_crear_parcial,
					ok: function() {
						var form = $('#form-crear');
						var data = form.serializeArray();
				
						reformat_fecha(data);

						data.push({name: 'comision', value: comision_popup});
						kernel.ajax.call(info.url_crear_evaluacion, {
							type: 'post',
							data: data,
							success: function(paquete) {
								if (paquete.success)
								{
									var codigo_html = $(paquete.html);
									codigo_html.css('display', 'none');
									parciales.append(codigo_html);
									codigo_html.slideDown();
									if (paquete.completo) {
                                                                            btn_crear.hide();
                                                                        }
                                                                        crear_tooltips();
								}
								else
									kernel.ui.modal({mensaje: paquete.mensaje, tipo: 'error'});
								return;
							}
						});
						return false;
					}
				});
				// se le agrega ahora porque antes no estaba en el DOM
				$('#fecha').datepicker({ minDate: new Date(fecha_inicio_per_lect)});
				
				var evaluaciones_existentes = [];
				$(this).parent().siblings('ul:first').find('li:visible').each(function(i, elem) {
					evaluaciones_existentes.push($(elem).data('evaluacion-tipo'));
				});
				
				$('#tipo option').each(function(i, elem) {
					var val = parseInt($(this).val());
					if ($.inArray(val, evaluaciones_existentes) > -1) {
						$(this).attr('disabled', true);
					}
				});
				
				var first_enabled = $('#tipo option:enabled:first');
				if (first_enabled.length == 0) { // no se pueden crear más evaluaciones
					alert('No se pueden crear más evaluaciones');
					$(document).trigger('close.facebox');
				} else {
					first_enabled.attr('selected', true);
					$('#tipo').val(first_enabled.val());
				}
				return false;
			});

			$(id + ' .parciales-comision').on('click', '.boton-borrar', function() {
				var evaluacion_id  = $(this).data('evaluacion-id');
				var nodo_eval = $(this).parents('.evaluacion');
				var btn_crear = $(this).parents('.comision').find('.crear').first();
				
				kernel.ajax.call(info.url_borrar_evaluacion, {
					type: 'post',
					data: [{name: 'eval', value: evaluacion_id}],
					success: function(paquete) {
						nodo_eval.slideUp();
						btn_crear.show();
					}
				});
			});

			$(id + ' .comision-nombre').on('click', function() {
				var comision = $(this);
				comision.next().toggle();
				if (comision.find('.js-toggle_icon').hasClass('abierto')){
					comision.find('.js-toggle_icon').removeClass('abierto');
				} else {
					comision.find('.js-toggle_icon').addClass('abierto');
				}
			});
			
			$(id + ' #js-refresh').on('click', function () {
				//alert('refresh');
				cambia_op();
			});
                        
                        crear_tooltips();
        }
    }
})
