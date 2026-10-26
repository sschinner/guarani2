kernel.renderer.registrar_pagelet('lista_forms', function(info) {
	var id = '#' + info.id;
	var mensajes = info.mensajes;

	function registrar_disparadores() {
		$(id).on('click', 'a.censo', function () {
			
			$("input#input_form_id").val($(this).attr('form'));
			
			kernel.evts.disparar('seleccion_formulario', {
				href: $(this).attr('href'),
				form: $(this).attr('form')
			});
			return false;
		});
	}

	function registrar_listeners() {
		kernel.evts.escuchar('info_formulario_cargado', info_formulario_cargado);
	}

	function info_formulario_cargado(params) {
		var anchors = id + ' a';

		$(anchors).removeClass('active');
		$(anchors).attr('aria-pressed', 'false');
		var anchor_seleccionado = anchors + '[href$="' + params.href + '"]';

		$(anchor_seleccionado).addClass('active');
		$(anchor_seleccionado).attr('aria-pressed', 'true');
		if (info.modo_reinscripcion){
			$(anchor_seleccionado).addClass('visitado');
		}

		mensaje_reinscripcion ($(anchors).length == $(anchors+'.visitado').length);
	}

	return {
		onload: function() {
			registrar_listeners();
			registrar_disparadores();
			var anchors = id + ' a';
			mensaje_reinscripcion ($(anchors).length == $(anchors+'.visitado').length);
			
			if($('.js-error').length > 0) {
				deshabilitar_boton_confirmar();
			}

			if($('.js-error').length === 0) {
				habilitar_boton_confirmar();
			}

			
			$("body").on('submit', '#form_confirmar', function (event) {
				event.preventDefault();
				kernel.ajax.call($(this).attr('action'), {
						data: {form_id: $(this).find('input#input_form_id').val()},
						type: 'POST',
						success: function(paquete) {
							if(paquete.cont.ok)
							{
								kernel.ui.show_mensaje(paquete.cont.msg);
								var f = new Date();
								$("#ultima_actualizacion").text(f.getDate() + "/" + ( '0' + (f.getMonth()+1) ).slice( -2 ) + "/" + f.getFullYear());
								$("#msj_datos_vigentes").removeClass('hidden');
								$("#msj_datos_no_vigentes").addClass('hidden');
							}
							else
							{
								kernel.ui.show_mensaje(paquete.cont.msg, {tipo: 'alert-error'});
							}
						}
				});
			});
		
		}
	}
	

	function deshabilitar_boton_confirmar()
	{
		$('#btnConfirmar').prop('disabled', true);
	}

	function habilitar_boton_confirmar()
	{
		$('#btnConfirmar').prop('disabled', false);
	}

	function mensaje_reinscripcion (activo){
		if (activo){
			$('#mensaje_reinscripcion').html(info.reinscripcion_verificacion_completa);
			$('#btn-reinscripcion').click(function() {
				reinscripcion();
			});
		} else {
			$('#mensaje_reinscripcion').html(info.reinscripcion_mensaje);
		}
	}

	function reinscripcion(){
		$.ajax({
			url: info.url_reinscripcion,
			dataType: 'json',
			type: 'post',
			success: function() {
				$('#mensaje_reinscripcion').html(info.reinscripcion_completa);
			}
		});
		return true;
	}
})