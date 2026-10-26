kernel.renderer.registrar_pagelet('envio_mensajes', function(info) {
	var id = '#' + info.id;
	var indice_archivos = 1;
	
	function init_upload() {
		$('#js-btn-agregar-archivo').click(function() {
			indice_archivos++;
			var control_group = $('<div class="control-group">');
			var id = 'archivos[' + indice_archivos + ']';
			var controls = $('<div class="controls archivo">');
			var input = $('<input type="file" id="'+ id +'" name="'+ id +'" />');
			var borrar = $('<a class="pull-right" href="#"><i class="icon-remove"></i></a>').click(function() {
				control_group.remove();
				return false;
			});
			control_group.append(borrar);
			controls.append(input);
			control_group.append(controls);
			
			$('.js-adjuntos').after(control_group);
			
			return false;
		});
	}

	return {
		onload: function() {
			
			if(info.hubo_error)
			{
				drops($('input[type=radio][name="tipo"][checked=checked]').val());
				//var tipo = $('input[type=radio][name="tipo"][checked=checked]').val();
				var todos_algunos = $('input[name="todos_algunos"]:checked').val(); //'AA'= Algunos Alumnos  - 'AD'= Algunos Docentes
				var clase = "";
				var nombre = "";

				if(info.tipo_anuncio == 'com'){
					var comision = $("#js-comision").val();
					if(todos_algunos == 'AA')
					{
						clase = 'alumnos_comision_'+comision;
						nombre = 'alumno[]';
					}
					else if (todos_algunos == 'AD')
					{
						clase = 'docentes_comision_'+comision;
						nombre = 'docente[]';
					}
					
				
				}
				else if(info.tipo_anuncio == 'mesa'){
					var mesa = $("#js-mesa").val();
					if(todos_algunos == 'AA')
					{
						clase = 'alumnos_mesa_'+mesa;
						nombre = 'alumno[]';
					}
					else if (todos_algunos == 'AD')
					{
						clase = 'docentes_mesa_'+mesa;
						nombre = 'docente[]';
					}					
				}

				$.each(info.enviar_a, function( key, value ) {
					var selector ='input[name="'+nombre+'"][value="'+value+'"].'+clase; 
					$(selector).prop("checked", true);
				});

			}
			
			$(id).delegate('input[type=radio]', 'click', function() {
				drops($(this).val());
			});
			
			$('#js-form-enviar').submit(function() {
				var error = false;
				
				$(".contenedor_personas").removeClass('error');

				var fecha_desde = $('#fecha_desde');
				var fecha_hasta = $('#fecha_hasta');
				fecha_desde.removeClass('error');
				fecha_hasta.removeClass('error');
				var fecha_val = "";

				if (fecha_desde.val() == "" || fecha_desde.val() == null){
					fecha_desde.addClass('error');
					error = true;
				} else {
					fecha_val = fecha_desde.val();
					var f_desde = new Date(fecha_val.substr(3, 2)+'/'+fecha_val.substr(0, 2)+'/'+fecha_val.substr(6, 4));
				}

				if (fecha_hasta.val() == "" || fecha_hasta.val() == null){
					fecha_hasta.addClass('error');
					error = true;
				} else {
					fecha_val = fecha_hasta.val();
					var f_hasta = new Date(fecha_val.substr(3, 2)+'/'+fecha_val.substr(0, 2)+'/'+fecha_val.substr(6, 4));
				}

				if (f_desde >= f_hasta & !error){
					fecha_hasta.addClass('error');
					fecha_desde.addClass('error');
					error = true;
				}
				
				var tipo_anuncio = $('input[type=radio][name=tipo]:checked').val();
				var comision = $("#js-comision").val();
				var mesa = $("#js-mesa").val();
				var todos_algunos = $('input[name="todos_algunos"]:checked').val();
				
				if(! $('input[name="alumno[]"]').is(':checked') && todos_algunos == 'AA') {
					if(tipo_anuncio == 'com')
					{
						//$("#contenedor_alumnos_comision_"+comision).removeClass('js-obligatorio');
						$("#contenedor_alumnos_comision_"+comision).addClass('error');
					}
					if(tipo_anuncio == 'mesa')
					{
						//$("#contenedor_alumnos_mesa_"+mesa).removeClass('js-obligatorio');
						$("#contenedor_alumnos_mesa_"+mesa).addClass('error');							
					}
					error = true;
				}
				
				if(! $('input[name="docente[]"]').is(':checked') && todos_algunos == 'AD') {
					if(tipo_anuncio == 'com')
					{
						//$("#contenedor_docentes_comision_"+comision).removeClass('js-obligatorio');
						$("#contenedor_docentes_comision_"+comision).addClass('error');						
					}
					if( tipo_anuncio == 'mesa')
					{
						//$("#contenedor_docentes_mesa_"+mesa).removeClass('js-obligatorio');
						$("#contenedor_docentes_mesa_"+mesa).addClass('error');						
					}
					error = true;
				}	

				$('.js-obligatorio').each(function() {
					if ($(this).val() == "" || $(this).val() == null) {
						$(this).addClass('error');
						error = true;
					} else {
						$(this).removeClass('error');
					}
				});

				return !error;
			});

			$('#js-comision').change(function() {
				$('#js-desc-comision li').hide();
				$('#O'+$(this).val()).show();
				if ($(this).val() ==""){
					$('#js-descripcion').hide();
				} else {
					$('#js-descripcion').show();
					$('#M'+$(this).val()).show();
				}
				mostrar_ocultar_destinatarios();
			});

			$('#js-mesa').change(function() {
				$('#js-desc-mesa li').hide();
				if ($(this).val() ==""){
					$('#js-descripcion').hide();
				} else {
					$('#js-descripcion').show();
					$('#M'+$(this).val()).show();
				}
				mostrar_ocultar_destinatarios();
			});

			$(id).find('input[type=date]').datepicker({minDate: 0});
			$('#fecha_desde').datepicker({defaultDate: info.default_fecha_desde});
			$('#fecha_hasta').datepicker({defaultDate: info.default_fecha_hasta});
			init_upload();

			if (info.comision) {
				$('#js-comision').val(info.comision);
				$('#js-comision').change();
				$('#titulo').focus();
			}
		}
	}

	function drops(valor){
		if (valor == "mesa"){
			// oculto comisiones
			$('#js-comisiones').hide();
			$('#js-comision').removeClass('js-obligatorio');
			$('#js-comision').removeClass('error');
			$('#js-desc-comision li').hide();
			$('#js-desc-comision').hide();

			$('#js-mesas').show();
			$('#js-mesa').addClass('js-obligatorio');
			$('#js-desc-mesa').show();
			$('#M'+$('#js-mesa').val()).show();
		}
		if (valor == "com"){
			// oculto mesas
			$('#js-mesas').hide();
			$('#js-mesa').removeClass('js-obligatorio');
			$('#js-mesa').removeClass('error');
			$('#js-desc-mesa li').hide();
			$('#js-desc-mesa').hide();

			$('#js-comisiones').show();
			$('#js-comision').addClass('js-obligatorio');
			$('#js-desc-comision').show();
			$('#O'+$('#js-comision').val()).show();
		}
		mostrar_ocultar_destinatarios();
	}
	
	function mostrar_ocultar_destinatarios() {

		var tipo = $('input[name="tipo"]:checked').val();
		var comision = $("#js-comision").val();
		var mesa = $("#js-mesa").val();
		var todos_algunos = $('input[name="todos_algunos"]:checked').val();

		$(".contenedor_personas").hide();
		$(".contenedor_personas").removeClass('error');
		$(".personas").prop('disabled', true);
		
		if (tipo == "com") {
			
			if(todos_algunos == "AA"){
				$("#contenedor_alumnos_comision_" + comision).show();
				$(".alumnos_comision_" + comision).prop('disabled', false);
			}
			else if(todos_algunos == "AD"){
				$("#contenedor_docentes_comision_" + comision).show();
				$(".docentes_comision_" + comision).prop('disabled', false);
			}
			
		}
		else if (tipo == "mesa") {
			
			if(todos_algunos == "AA"){
				$("#contenedor_alumnos_mesa_" + mesa).show();
				$(".alumnos_mesa_" + mesa).prop('disabled', false);
			}
			else if(todos_algunos == "AD"){
				$("#contenedor_docentes_mesa_" + mesa).show();
				$(".docentes_mesa_" + mesa).prop('disabled', false);
			}
			
		}


	}
	
})