kernel.renderer.registrar_pagelet('filtros', function (info) {
    var id = '#' + info.id;
    var $formulario_filtro;

    return {
        onload: function () {

            $formulario_filtro = $('#formulario_filtro').formulario();

            function set_solo_lectura(elemId, solo_lectura) {
                if (solo_lectura) {
                    $('#' + elemId).prop('readonly', true);
                } else {
                    $('#' + elemId).prop('readonly', false);
                }
            }
            
            buscar_periodos_y_turnos($('#formulario_filtro-anio_academico').val());

            $('#formulario_filtro-anio_academico').change(function () {
                info.anio_academico_hash = false;
                info.turno = false;
                info.periodo = false;
                buscar_periodos_y_turnos($(this).val());
            });

            if (info.anio_academico_hash) {
                $("#formulario_filtro-anio_academico option[value=" + info.anio_academico_hash + "]").attr("selected", true);
            }

            $(id).on("click", '#limpiar_materia', function () {
                limpiar_materia();
                $('#formulario_filtro-materia_descr').focus();
            });

            /* Autocomplete de Materia */

            $("#formulario_filtro-materia_descr").autocomplete({
                source: function (request, response) {
                    kernel.ui.show_loading();
                    $.ajax({
                        url: info.url_buscar_materias,
                        dataType: "json",
                        data: {
                            term: request.term
                        },
                        success: function (data) {
                            kernel.ui.hide_loading();
                            response(data);
                        }
                    });
                },
                appendTo: id,
                minLength: 3,
                select: materia_seleccionada,
                focus: materia_foco,
                change: function (event, ui) {
                    if ($("#formulario_filtro-materia").val() == '') {
                        $("#formulario_filtro-materia_descr").val("");
                    }
                },
                search: function (event, ui) {
                    kernel.ui.show_loading();
                },
                response: function (event, ui) {
                    kernel.ui.hide_loading();
                }

            });

            function limpiar_materia() {
                $('#formulario_filtro-materia').val('');
                $('#formulario_filtro-materia_descr').val('');
                set_solo_lectura("formulario_filtro-materia_descr", false);
            }

            function materia_seleccionada(event, ui) {
                var id = ui.item.id;
                var label = ui.item.label;

                $("#formulario_filtro-materia").val(id);
                $("#formulario_filtro-materia_descr").val(label);
                set_solo_lectura("formulario_filtro-materia_descr", true);
                event.preventDefault();
            }

            function materia_foco(event) {
                event.preventDefault();
            }

            //Si hay una materia seleccionada la pongo como "solo lectura"
            if ($('#formulario_filtro-materia').val())
                set_solo_lectura("formulario_filtro-materia_descr", true);
            
             /* Submit del formulario */

            $(id).on("submit", '#formulario_filtro', function (event) {
                event.preventDefault();
                
                //Saco la descripción de la materia por si contienen caracteres especiales que rompan la URL.
                kernel.ajax.load(info.url_filtrar + '?' + $formulario_filtro.find("select, input[id!=formulario_filtro-materia_descr]").serialize(), id, {
                    historia: true,
                    type: 'get',
                    show_loading: true,
                    forzar_cambio_op: true
                });

                return false;
            });
        }
    };


    function buscar_periodos_y_turnos(anio_academico) {

        kernel.ajax.call(info.url_buscar_periodos_lectivos_turnos_examen, {
            data: {anio_academico: anio_academico},
            type: 'GET',
            success: function (data) {
                var $elem_periodos = $('#formulario_filtro-periodo');
                var $elem_turnos = $('#formulario_filtro-turno');
                $elem_periodos.children().remove();
                $elem_turnos.children().remove();

                $elem_periodos.append($('<option></option>').val('').html(info.mensaje_seleccione));
                $elem_turnos.append($('<option></option>').val('').html(info.mensaje_seleccione));

                $.each(data.cont.periodos, function (key, value) {
                    $elem_periodos.append($('<option></option>').val(value['ID']).html(value['DESC']));
                });
                
                if (info.periodo) {
                    $("#formulario_filtro-periodo option[value=" + info.periodo + "]").attr("selected", true);
                }
            
                $.each(data.cont.turnos, function (key, value) {
                    $elem_turnos.append($('<option></option>').val(value['ID']).html(value['DESC']));
                });
                
                if (info.turno) {
                    $("#formulario_filtro-turno option[value=" + info.turno + "]").attr("selected", true);
                }
                
            }
        });
    }
});