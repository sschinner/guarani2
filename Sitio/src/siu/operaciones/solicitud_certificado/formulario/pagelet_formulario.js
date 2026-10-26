kernel.renderer.registrar_pagelet('formulario', function(info) {
    var id = '#' + info.id;

	function registrar_eventos() {
		$(id+' .js-btn-solicitar').click(function (){
			var data = $('#js-form-certificado').serializeArray();

			kernel.ajax.load($('#js-form-certificado').attr('action'), "#kernel_contenido", {
				type: 'post',
				data: data,
				historia: false,
				reemplazar_nodo: false,
				success: function(data) {
					if(!data.hubo_error){
						kernel.ui.show_mensaje(data.nro_solicitud_certificado,{
							until_interaction: true
						});

						$(".js-btn-solicitar").prop( "disabled", true );
					}
				}
			});
		})
    }
	
    return {
		onload: function() {
//			registrar_listeners();
			registrar_eventos();
			
			$(function () {
				$('[data-toggle="tooltip"]').tooltip()
			});
		}
	}
})
