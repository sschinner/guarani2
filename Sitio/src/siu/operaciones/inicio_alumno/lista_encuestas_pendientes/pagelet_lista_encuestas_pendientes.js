kernel.renderer.registrar_pagelet('lista_encuestas_pendientes', function(info) {
	var id = '#' + info.id;
	
	return {
		onload: function() {
			$(id).on('click', '.colapsar',function (){
				$(this).parent('div').find('ul').toggle();
				return false;
			});
			
			$('#js-btn_esconder').tooltip('destroy');
			$('#js-btn_esconder').tooltip({title: info.mensajes.msj_ancho_completo});
			
			$(id).on('click', '#js-btn_esconder',function (){
				var $pagelet_encuestas = $('#lista_encuestas_pendientes').parent('div');
				var $periodos_lectivos = $('#lista_carreras').parent('div');
				
				if ($pagelet_encuestas.hasClass('span6')){
					$periodos_lectivos.fadeOut('slow', function(){
						$pagelet_encuestas.removeClass('span6');
						$pagelet_encuestas.addClass('span12');
						$('#js-btn_esconder i').removeClass('icon-chevron-left');
						$('#js-btn_esconder i').addClass('icon-chevron-right');
						$('#js-btn_esconder').tooltip('destroy');
						$('#js-btn_esconder').tooltip({title: info.mensajes.msj_ancho_3col});
					});
				} else {
					$periodos_lectivos.fadeIn('slow', function(){
						$pagelet_encuestas.removeClass('span12');
						$pagelet_encuestas.addClass('span6');
						$('#js-btn_esconder i').removeClass('icon-chevron-right');
						$('#js-btn_esconder i').addClass('icon-chevron-left');
						$('#js-btn_esconder').tooltip('destroy');
						$('#js-btn_esconder').tooltip({title: info.mensajes.msj_ancho_completo});
					});
				}
				event.preventDefault();
			});
		}
	}
})