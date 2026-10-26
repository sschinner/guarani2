kernel.renderer.registrar_pagelet('reporte', function(info) {
    var id = '#' + info.id;
    
	function registrar_disparadores() {
    }
    
    function registrar_listeners() {
    }

    return {
        onload: function() {
			if ($(id + ' #filtro_anio').val() != ""){
				buscar_turnos($(id + ' #filtro_anio').val());
			}
			
			$(id + ' #filtro_anio').on('change', function () {				
				buscar_turnos($(this).val());
			});
			
			function buscar_turnos(valor_anio){
				$.ajax({
					url: info.url_turnos_examen,
					dataType: 'json',
					data: {anio: valor_anio},
					type: 'post',
					success: function(data) {
						$('#filtro_turno_examen').children().remove();					
						$('#filtro_turno_examen').append(
							$('<option></option>').val('').html('Todos')
						);
						$.each(data, function(key, value) {
							$('#filtro_turno_examen').append(
								$('<option></option>').val(value['ID']).html(value['DESC'])								
							);
						});
						
						if (info.hash_turno != ""){
							$('#filtro_turno_examen option').each(function(){
								if ($(this).val() == info.hash_turno){
									$(this).prop('selected', true);
								}
							})							
						}
					}
				});
			}
        }
    }
})