kernel.renderer.registrar_pagelet('lista_materias', function(info) {
    var id = '#' + info.id;
	
	
	function cambiar_nombre_boton_comision(elemento)
	{
		var boton = elemento.parents('.comision').find('.mostrar');
		if (boton.hasClass('mostrando-clases')) {
			boton.text(info.mostrar_clases);
			boton.removeClass('mostrando-clases');
		} else {
			boton.text(info.ocultar_clases);
			boton.addClass('mostrando-clases');
		}
		
	}
	
	function limpiar_autocompletar(elemento)
	{
		if(elemento == 'materia')
		{
			$("#filtro_nombre_materia").val('Todas');
			$("#filtro_materia").val('');
		}
		if(elemento == 'docente')
		{
			$("#filtro_docente").val('Todos');
			$("#filtro_docente_legajo").val('');
		}	
	}
	
	return {
        onload: function() {
			$("#filtro_nombre_materia").autocomplete({
                source: info.url_autocomplete_materia,
				select: function (event, ui)
					{
						var id = ui.item.id;
						var label = ui.item.label;
						
						$("#filtro_nombre_materia").val(label);
						$("#filtro_materia").val(id);
						event.preventDefault();
					}
            });
						
			$("#filtro_docente").autocomplete({
                source: info.url_autocomplete_docente,
				select: function (event, ui)
					{
						var id = ui.item.id;
						var label = ui.item.label;
						
						$("#filtro_docente").val(label);
						$("#filtro_docente_legajo").val(id);
						event.preventDefault();
					}
            });
						
			$("#filtro_form").submit(function( event ) {
				var $form  = $("#filtro_form");
				var url = $form.attr('action');
				var params = 'filtro_per_lectivo='+$("#filtro_per_lectivo").val()+'&filtro_materia='+$("#filtro_materia").val()+'&filtro_docente_legajo='+$("#filtro_docente_legajo").val();
				
				kernel.ajax.load(url + '?' + params, id, {
					historia: true,
					type: 'get',
					show_loading: true,
					forzar_cambio_op: true
				});

				return false;
			});

			$(id).on('click', '#limpiar_materia',function (){
				limpiar_autocompletar('materia');
            });
			$(id).on('click', '#limpiar_docente',function (){
				limpiar_autocompletar('docente');
            });

				$(id + ' .mostrar').click(function() {
				var comision_id = $(this).parents('.comision').data('comision-id');
				var elemento = $(this);
				
				if (!elemento.parents('.comision').find('.js-clases-comision').hasClass('con_datos') ) {
					
					kernel.ajax.call(info.url_mostrar_clases, {
						type: 'post',
						data: {comision_id: comision_id, cant: 3},
						success: function(paquete) {
							elemento.parents('.comision').find('.js-clases-comision').addClass('con_datos');
							elemento.parents('.comision').find('.js-clases-resumen').html(paquete.cont);
							elemento.parents('.comision').find('.js-clases-comision').toggle(400);
							cambiar_nombre_boton_comision(elemento);
						}

					});
				} else {
					elemento.parents('.comision').find('.js-clases-comision').toggle(400);
					cambiar_nombre_boton_comision(elemento);
					
				}
				
			});

				$(id + ' .subco').click(function() {
				var comision_id = $(this).parents('.comision').data('comision-id');
				var elemento = $(this);
					if (!elemento.parents('.comision').find('.js-subcomisiones-comision').hasClass('con_datos') ) {
						kernel.ajax.call(info.url_mostrar_subcomisiones, {
							type: 'post',
							data: {comision_id: comision_id},
							success: function(paquete) {
								elemento.parents('.comision').find('.js-subcomisiones-comision').addClass('con_datos');
								elemento.parents('.comision').find('.js-subcomisiones').html(paquete.cont);
								elemento.parents('.comision').find('.js-subcomisiones-comision').toggle(400);						
							}

						});	
					} else {
						elemento.parents('.comision').find('.js-subcomisiones-comision').toggle(400);
					}
								
			});
			$(id).on('click', ' .mostrar_todas', function() {
				var comision_id = $(this).parents('.comision').data('comision-id');
				var elemento = $(this);
					if (!elemento.parents('.comision').find('.js-clases-completo').hasClass('completo') ) {
						kernel.ajax.call(info.url_mostrar_clases, {
							type: 'post',
							data: {comision_id: comision_id, cant: 0},
							success: function(paquete) {
								elemento.parents('.comision').find('.js-clases-resumen').toggle();
								elemento.parents('.comision').find('.js-clases-completo').html(paquete.cont);
								elemento.parents('.comision').find('.js-clases-completo').addClass('completo');
								elemento.parents('.comision').find('.js-clases-completo').find('.mostrar_todas').text(info.ver_ultimas);
							}

						});
					} else {
						elemento.parents('.comision').find('.js-clases-resumen').toggle();
						elemento.parents('.comision').find('.js-clases-completo').toggle();
					}		
					
				
			});
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
			
			
			$(id + ' button.alumnos_libres').on('click',function() {
				guarani.cambiar_op({
					href: $(this).data('link')
				});
			});
        }
    }
})