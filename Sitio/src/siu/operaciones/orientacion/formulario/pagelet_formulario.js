kernel.renderer.registrar_pagelet('formulario', function(info) {
	var id = '#' + info.id;
	var titulo_seleccionado = "";
	
    return {
        onload: function() {
			$('.btn_ver_orient_titulo').click(function() {
				$('#data_orientaciones').removeClass('hide');
				titulo_seleccionado = $(this).data("titulo");
				$('.orient').hide();
				$('.data_orient-'+titulo_seleccionado).show();
				$('#resultado_cambio').hide();
			});			
			
			$('.btn_cambiar_o').click(function() {
				titulo_seleccionado = $(this).data("titulo");
				$('.o_disponibles'+titulo_seleccionado).toggle();
				$('#resultado_cambio').hide();
			});
			
			$('.btn_eliminar_o').click(function() {
				titulo_seleccionado = $(this).data("titulo");
				$('.formulario_eliminacion'+titulo_seleccionado).toggle();
				$('.texto_motivo'+titulo_seleccionado).removeClass('error');
				$('.btn-eliminar'+titulo_seleccionado).toggle();
			});
			
			$('.btn_cancelar_eliminar_o').click(function() {
				titulo_seleccionado = $(this).data("titulo");
				$('.texto_motivo'+titulo_seleccionado).val('');
				$('.formulario_eliminacion'+titulo_seleccionado).toggle();
				$('.btn-eliminar'+titulo_seleccionado).toggle();
			});
			
			$('.btn_aceptar_eliminar_o').click(function() {
				titulo_seleccionado = $(this).data("titulo");
				if ($('.texto_motivo'+titulo_seleccionado).val() != ""){
					// ajax
					kernel.ajax.call(info.url_eliminar_orientacion, {
						dataType: 'json',
						type: 'post',
						data: {
							motivo: $('.texto_motivo'+titulo_seleccionado).val(),
							titulo: titulo_seleccionado
						},
						success: function() {
							$('.texto_motivo'+titulo_seleccionado).val('');
							$('.formulario_eliminacion'+titulo_seleccionado).toggle();
							$('.btn-eliminar'+titulo_seleccionado).toggle();
							return true;
						}
					});
					return false;
				} else {
					$('.texto_motivo'+titulo_seleccionado).addClass('error');
					kernel.ui.show_mensaje('Ingrese un motivo de la eliminación', {tipo: 'alert-error'});
					return false;
				}
			});
			
			$('tr.data').click(function() {
				$('#id_orientacion').val($(this).attr('data-link'));
				$('#id_titulo').val($(this).attr('data-id_titulo'));
				kernel.ui.prompt({
					title: info.confirmacion,
					msg: info.mensaje_cambio_orientacion,
					msg_ok: info.aceptar,
					msg_cancel: info.cerrar,
					icon_question: false,
					ok: function() {
						$('#form_orientacion').submit();
					}
				});
				return false;
			});
        }
    }
})