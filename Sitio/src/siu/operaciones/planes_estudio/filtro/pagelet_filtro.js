kernel.renderer.registrar_pagelet('filtro', function (info) {
	var id = '#' + info.id;
	
	return {
        onload: function () {
			
			var $filtro = $('form').formulario();
			
			$("#formulario_filtro-planes").parents('.control-group').hide();
			$("#formulario_filtro-versiones").parents('.control-group').hide();
			
			$('#formulario_filtro-carreras').change(function(){
				
				if($(this).val()){
					buscarPlanes($(this).val());
				}
				
			});
			
			$('#formulario_filtro-planes').change(function(){
				
				if($(this).val()){
					buscarVersiones($(this).val());
				}
				
			});
			
			$('#formulario_filtro-versiones').change(function(){
				
				$("#formulario_filtro").submit();
				
			});
			
			$("#formulario_filtro").submit(function(event){
				event.preventDefault();
				
				kernel.ajax.call($(this).attr('action'), {
				type: 'POST',
				data: {
					carrera: $("#formulario_filtro-carreras").val(),
					carrera_nombre: $("#formulario_filtro-carrera_nombre").val(),
					plan: $("#formulario_filtro-planes").val(),
					version: $("#formulario_filtro-versiones").val()
				},
				success: function(paquete) {
					$("#columna_1").html(paquete.cont);
					kernel.renderer.pagelet('info_plan').onload();
					return false;
				},
				error: function() {
					$("#columna_1").html(paquete.cont);
				}
				});
				return false;
			});
			
        }
	}
	
	function buscarPlanes(carrera){
		$.ajax({
			url: info.url_buscar_planes,
			dataType: 'json',
			data: {carrera: carrera},
			type: 'get',
			success: function(data) {
				
				var $elem_planes = $('#formulario_filtro-planes');
				$elem_planes.children().remove();
				
				$.each(data.planes, function(key, value) {
					$elem_planes.append(
						$('<option></option>').val(value['_ID_']).html(value['PLAN'])
					);
				});
				
				var $elem_versiones = $('#formulario_filtro-versiones');
				$elem_versiones.children().remove();
				
				$.each(data.versiones, function(key, value) {
					$elem_versiones.append(
						$('<option></option>').val(value['_ID_']).html(value['VERSION'])
					);
				});
				
				$("#formulario_filtro-carreras option[value='']").remove();
				$("#formulario_filtro-planes").parents('.control-group').show();
				$("#formulario_filtro-versiones").parents('.control-group').show();
				$("#formulario_filtro").submit();
			}
		});
	}
	
	function buscarVersiones(plan){
		$.ajax({
			url: info.url_buscar_versiones,
			dataType: 'json',
			data: {
				carrera: $('#formulario_filtro-carreras').val(),
				plan: plan
			},
			type: 'get',
			success: function(data) {
				
				var $elem_versiones = $('#formulario_filtro-versiones');
				$elem_versiones.children().remove();
				
				$.each(data, function(key, value) {
					$elem_versiones.append(
						$('<option></option>').val(value['_ID_']).html(value['VERSION'])
					);
				});
				$("#formulario_filtro-versiones").parents('.control-group').show();
				$("#formulario_filtro").submit();
			}
		});
	}
	
});