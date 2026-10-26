kernel.renderer.registrar_pagelet('reporte', function(info) {
	var id = '#' + info.id;

	function registrar_disparadores() {
	}

	function registrar_listeners() {
	}

	return {
		onload: function() {
			if ($(id + ' #filtro_anio').val() != ""){
				buscar_periodos($(id + ' #filtro_anio').val());
			}

			$(id + ' #filtro_anio').on('change', function () {
				buscar_periodos($(this).val());
			});

			function buscar_periodos(valor_anio){
				$.ajax({
					url: info.url_periodos_lectivos,
					dataType: 'json',
					data: {anio: valor_anio},
					type: 'post',
					success: function(data) {
						$('#filtro_per_lectivo').children().remove();
						$('#filtro_per_lectivo').append(
							$('<option></option>').val('').html('Todos')
						);
						$.each(data, function(key, value) {
							$('#filtro_per_lectivo').append(
								$('<option></option>').val(value['ID']).html(value['DESC'])
							);
						});

						if (info.hash_periodos_lectivos != ""){
							$('#filtro_per_lectivo option').each(function(){
								if ($(this).val() == info.hash_periodo_lectivo){
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