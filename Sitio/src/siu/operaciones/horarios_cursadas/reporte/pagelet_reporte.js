kernel.renderer.registrar_pagelet('reporte', function(info) {
	var id = '#' + info.id;
	
	return {
		onload: function() {
			$(id).on('click', '#js-colapsar-filtro', function() {
				$('.filtros').toggle(500);
			});
			
			}
		}
})