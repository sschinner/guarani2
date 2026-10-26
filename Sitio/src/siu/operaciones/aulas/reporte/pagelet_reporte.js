kernel.renderer.registrar_pagelet('reporte', function(info) {
	var id = '#' + info.id;
	var dia = new Array();
	var actividad = "";
	
	function dias_seleccionados(){
		var i = 0;
		var dias_check = new Array();

		$('.js-filtro_dias.active').each(function(){
			dias_check[i] = $(this).attr('dia');
			i++;
		});

		dia = dias_check;
	}
	
	return {
		onload: function() {
			$(id).on('click', '#js-colapsar-filtro', function() {
				$('.filtros').toggle(500);
			});
			
			$(id).on('click', '.js-filtro_dias', function() {
				if ($(this).hasClass('active')){
					$(this).removeClass('active');
					$(this).attr('aria-pressed','false');
				} else {
					$(this).addClass('active');
					$(this).attr('aria-pressed','true')
				}
				filtrar();
			});
			
			$(id).on('change', '#js-filtro_actividades', function() {
				actividad = $(this).val();
				filtrar();
			});
			
			function filtrar(){
				dias_seleccionados();
				$('.js-resultados').show();
				$('.js-filtro').hide();
				if (dia.length > 0){
					for (i=0;i<dia.length;i++){
						if (actividad != ""){
							$('.js-filtro[dia_sem="'+dia[i]+'"][actividad="'+actividad+'"]').show();
						} else {
							$('.js-filtro[dia_sem="'+dia[i]+'"]').show();
						}
					}
				}
				
				if ($('.js-filtro').is(":visible")){
					$('#js-reporte-vacio').hide();
				} else {
					$('.js-resultados').hide();
					$('#js-reporte-vacio').show();
				}
			}
		}
	}
})