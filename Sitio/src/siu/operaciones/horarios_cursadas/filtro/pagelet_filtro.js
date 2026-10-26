kernel.renderer.registrar_pagelet('filtro', function (info) {
	var id = '#' + info.id;
	
	return {
        onload: function () {
            var $filtro = $('form').formulario();
			$('#boton_buscar').on('click', function () {
				guarani.cambiar_op({
					href: info.url_buscar_horarios + '?' + $filtro.serialize()
				});
				return false;
			});
			

			
			$('#formulario_filtro-anio_academico').change(function(){
				cascadaAnioAcademico($(this).val());
			});
			
			cascadaAnioAcademico($('#formulario_filtro-anio_academico').val());
			
			
			 if(($("#formulario_filtro-materia_descr").val() != "") && ($("#formulario_filtro-materia").val() != "")){
                set_solo_lectura("formulario_filtro-materia_descr", true);
            }
            else{
                $("#formulario_filtro-materia_descr").val("");
                $("#formulario_filtro-materia").val("");
            }

            $("#formulario_filtro-materia_descr").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: info.url_buscar_materias,
                        dataType: "json",
                        data: {
                            term : request.term,
                            carrera : $('#formulario_filtro-carrera').val(),
                            plan : ""
                        },
                        success: function(data) {
                            response(data);
                        }
                    });
                },
                appendTo: id,
                minLength: 2,
                select: materia_seleccionada,
                focus: materia_foco,
                change: function( event, ui ) {
                    if($("#formulario_filtro-materia").val()==''){
                        $("#formulario_filtro-materia_descr").val("");
                    }
                },
                search: function( event, ui ) {
                    kernel.ui.show_loading();
                },
                response: function( event, ui ) {
                    kernel.ui.hide_loading();
                }

            });
			
            $('#limpiar_materia').on('click', function () {
                limpiar_materia();
                $('#formulario_filtro-materia_descr').focus();
            });	
			
        }
		
    };
	
	
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
			buscarPeriodos(anio_academico);
	}

    function limpiar_materia(){
        $('#formulario_filtro-materia').val('');
        $('#formulario_filtro-materia_descr').val('');
        set_solo_lectura("formulario_filtro-materia_descr", false);
    }
	
    function materia_seleccionada(event, ui)
    {
        var id = ui.item.id;
        var label = ui.item.label;

        $("#formulario_filtro-materia").val(id);
        $("#formulario_filtro-materia_descr").val(label);
        set_solo_lectura("formulario_filtro-materia_descr", true);
        event.preventDefault();
    }

    function materia_foco(event)
    {
        event.preventDefault();
    }

    function set_solo_lectura(elemId, solo_lectura) {
        if (solo_lectura) {
            $('#'+elemId).attr('readonly', 'readonly');
        } else {
            $('#'+elemId).removeAttr("readonly");
        }
    }	
});