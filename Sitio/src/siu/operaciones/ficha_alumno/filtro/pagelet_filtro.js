kernel.renderer.registrar_pagelet('filtro', function(info) {
	var id = '#' + info.id;
	var menu_reportes_in_transition = false;

	function filtro_autocomplete() {
		$('#formulario_filtro-cuadro_busqueda').autocomplete({
			source: info.url_autocomplete_filtro,
            appendTo: id,
			minLength: 3,
			search: function() {
				kernel.ui.show_loading();
			},
			open: function() {
			},
			response: function(event, ui) {
				kernel.ui.hide_loading();
				if (ui.content.length === 0) {
					kernel.ui.show_mensaje(info.mensajes.no_se_encontraron_alumnos, {tipo: 'alert-error'});
				}
			},
			select: function( event, ui ) {
				guarani.cambiar_op({
					href: ui.item.id
				});
			}
		});
			
		$('#formulario_filtro-cuadro_busqueda').keypress(function(event){
			if(event.keyCode == 13){
				event.preventDefault();
			}
		})
	}
	
	function menu_desplegable() {
		$('#cuadro_menu_reportes').on('click', '#js-btn_esconder', function (event){

            if(!menu_reportes_in_transition){

                menu_reportes_in_transition = true;

                if ($('#menu_reportes:visible').length > 0){
                    $("#menu_reportes").fadeOut('slow', function(){
                        $('#reporte_contenido').addClass('completo');
                        $('#js-btn_esconder i').removeClass('icon-chevron-left');
                        $('#js-btn_esconder i').addClass('icon-chevron-right');
                        $('#js-btn_esconder').tooltip('destroy');
                        $('#js-btn_esconder').tooltip({title: info.mensajes.mostrar_menu});
                        menu_reportes_in_transition = false;
                    });

                } else {
                    $("#menu_reportes").fadeIn('slow', function(){
                        $('#reporte_contenido').removeClass('completo');
                        $('#js-btn_esconder i').removeClass('icon-chevron-right');
                        $('#js-btn_esconder i').addClass('icon-chevron-left');
                        $('#js-btn_esconder').tooltip('destroy');
                        $('#js-btn_esconder').tooltip({title: info.mensajes.esconder_menu});
                        menu_reportes_in_transition = false;
                    });
                }
            }
			event.preventDefault();
		});
	}
	
	function menu_links() {
		$('#menu_reportes').on('click', 'a:not(.accordion-toggle)', function (event){

            kernel.ajax.load($(this).attr('href'), '#reporte', {
				success: function() {
					menu_desplegable();
					menu_links();
					$('#js-btn_esconder').tooltip('destroy');
					$('#js-btn_esconder').tooltip({title: info.mensajes.esconder_menu});
                    menu_reportes_in_transition = false;
					kernel.renderer.pagelet(info.id).onload();
				}
			});

            event.preventDefault();
			return false;
		});
	}
	
	return {
		onload: function() {
			filtro_autocomplete();
			menu_desplegable();
			menu_links();
			$('#js-btn_esconder').tooltip('destroy');
			$('#js-btn_esconder').tooltip({title: info.mensajes.esconder_menu});
			
			$('#reporte').on('click', 'table tbody tr.detalle', function(){
				$("#detalle-"+$(this).data('linea')).toggle();
			});
		}
	}
})