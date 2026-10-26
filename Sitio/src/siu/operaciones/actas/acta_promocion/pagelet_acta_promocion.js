kernel.renderer.registrar_pagelet('acta_promocion', function(info) {
	var id = '#' + info.id;

	return {
		onload: function() {
			$(id + ' #js-filtro_folio').on('change', function () {
				if ($(this).val() != ""){
					$(id+' table.js-folio').hide();
					$('table.js-folio[data-folio="'+$(this).val()+'"]').show();
				} else {
					$(id+' table.js-folio').show();
				}
			});
			
			$(id + ' .js-detalle_evaluaciones').on('click', function () {
				var $destino = $('#'+$(this).data('destino'));
				if ($destino.hasClass('completo')){
					console.log($destino.css("display"));
					if ($destino.css("display") != 'none'){
						$('.js-cuadro_evaluaciones').hide();
					} else {
						$('.js-cuadro_evaluaciones').hide();
						$destino.show();
					}
				} else {
					$('.js-cuadro_evaluaciones').hide();
					kernel.ajax.call($(this).data('link'), {
						type: 'post',
						success: function(paquete) {
							$destino.html(paquete.cont);
							$destino.show();
							$destino.addClass('completo');
						}
					});
				}
				return false;
			});
		}
	}
})