kernel.renderer.registrar_pagelet('filtro', function (info) {
	var id = '#' + info.id;
	
	return {
        onload: function () {
            var $filtro = $('form').formulario();
			$('#boton_buscar').on('click', function () {
				guarani.cambiar_op({
					href: info.url_buscar_actas + '?' + $filtro.serialize()
				});
				return false;
			});
			
            $filtro.find('input.date').datepicker( "destroy" );
            $filtro.find('input.date').datepicker({
                changeMonth: true,
                changeYear: true,
                firstDay: 0
            });
			
			
			$('#filtros #formulario_filtro-origen').change(function(){
				changeFiltros($(this).val());
				cascadaAnioAcademico($('#formulario_filtro-anio_academico').val());
			});
			
			$('#formulario_filtro-anio_academico').change(function(){
				cascadaAnioAcademico($(this).val());
			});
			
			changeFiltros($('#filtros #formulario_filtro-origen').val());
			cascadaAnioAcademico($('#formulario_filtro-anio_academico').val());
			
			$('#limpiar_materia').on('click', function () {
				$('#formulario_filtro-materia').val('-- Todas --');
				$('#formulario_filtro-materia-autocomplete').val('');
			});
			
        }
    };
	
	function changeFiltros(select_filtro_value){
		switch(select_filtro_value) {
			case 'E':
				$('.filtros_examenes').parents('.control-group').show();
				$('.filtros_cursadas').parents('.control-group').hide();
				
				var $elem_turnos = $('#formulario_filtro-turno');
				$elem_turnos.children().remove();
				$elem_turnos.append(
					$('<option></option>').val('').html(info.mensaje_seleccione)
				);

				break;
			case 'P':
			case 'R':
				$('.filtros_examenes').parents('.control-group').hide();
				$('.filtros_cursadas').parents('.control-group').show();
				
				var $elem_periodos = $('#formulario_filtro-periodo');
				$elem_periodos.children().remove();
				$elem_periodos.append(
					$('<option></option>').val('').html(info.mensaje_seleccione)
				);

				break;
			default:
		}
	}
	
	function buscarTurnos(anio_academico){
		$.ajax({
			url: info.url_buscar_turnos,
			dataType: 'json',
			data: {anio_academico: anio_academico},
			type: 'get',
			success: function(data) {
				var $elem_turnos = $('#formulario_filtro-turno');
				$elem_turnos.children().remove();
				$elem_turnos.append(
					$('<option></option>').val('').html(info.mensaje_seleccione)
				);
				$.each(data, function(key, value) {
					if (value['ID'] == info.turno){
						$elem_turnos.append($('<option selected="selected"></option>').val(value['ID']).html(value['DESC']));
					} else {
						$elem_turnos.append($('<option></option>').val(value['ID']).html(value['DESC']));
					}
				});
			}
		});
	}
	
	function buscarPeriodos(anio_academico){
		$.ajax({
			url: info.url_buscar_periodos,
			dataType: 'json',
			data: {anio_academico: anio_academico},
			type: 'get',
			success: function(data) {
				var $elem_periodos = $('#formulario_filtro-periodo');
				$elem_periodos.children().remove();
				$elem_periodos.append(
					$('<option></option>').val('').html(info.mensaje_seleccione)
				);
				$.each(data, function(key, value) {
					if (value['ID'] == info.periodo){
						$elem_periodos.append($('<option selected="selected"></option>').val(value['ID']).html(value['DESC']));
					} else {
						$elem_periodos.append($('<option></option>').val(value['ID']).html(value['DESC']));
					}
				});
			}
		});
	}
	
	function cascadaAnioAcademico(anio_academico){
		var $origen = $('#filtros #formulario_filtro-origen').val();
		if ($origen === "E") {
			buscarTurnos(anio_academico);
		} else if ($origen === "R" | $origen === "P"){
			buscarPeriodos(anio_academico);
		}
	}
});