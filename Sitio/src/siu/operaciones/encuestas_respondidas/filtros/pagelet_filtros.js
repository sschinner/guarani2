kernel.renderer.registrar_pagelet('filtros', function(info) {
    var id = '#' + info.id;
    var $formulario_filtro;

    return {
        onload: function() {

            $formulario_filtro = $('#formulario_filtro').formulario();

            function set_solo_lectura(elemId, solo_lectura) {
                if (solo_lectura) {
                    $('#'+elemId).prop('readonly', true);
                } else {
                    $('#'+elemId).prop('readonly', false);
                }
            }

            /* Autocomplete de Materia */

            $("#formulario_filtro-materia_descr").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: info.url_buscar_materias,
                        dataType: "json",
                        data: {
                            term : request.term
                        },
                        success: function(data) {
                            response(data);
                        }
                    });
                },
                appendTo: id,
                minLength: 3,
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

            $( id ).on( "click", '#limpiar_materia', function() {
                limpiar_materia();
                $('#formulario_filtro-materia_descr').focus();
            });

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

            //Si hay una materia seleccionada la pongo como "solo lectura"
            if($('#formulario_filtro-materia').val()) set_solo_lectura("formulario_filtro-materia_descr", true);

            /* Autocomplete de Docente */

            $("#formulario_filtro-docente_descr").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: info.url_buscar_docentes,
                        dataType: "json",
                        data: {
                            term : request.term
                        },
                        success: function(data) {
                            response(data);
                        }
                    });
                },
                appendTo: id,
                minLength: 3,
                select: docente_seleccionado,
                focus: docente_foco,
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

            $( id ).on( "click", '#limpiar_docente', function() {
                limpiar_docente();
                $('#formulario_filtro-docente_descr').focus();
            });

            function limpiar_docente(){
                $('#formulario_filtro-docente').val('');
                $('#formulario_filtro-docente_descr').val('');
                set_solo_lectura("formulario_filtro-docente_descr", false);
            }

            function docente_seleccionado(event, ui)
            {
                var id = ui.item.id;
                var label = ui.item.label;

                $("#formulario_filtro-docente").val(id);
                $("#formulario_filtro-docente_descr").val(label);
                set_solo_lectura("formulario_filtro-docente_descr", true);
                event.preventDefault();
            }

            function docente_foco(event)
            {
                event.preventDefault();
            }

            //Si hay un docente seleccionado lo pongo como "solo lectura"
            if($("#formulario_filtro-docente").val()) set_solo_lectura("formulario_filtro-docente_descr", true);

            /* Datepickers */

            $('input.date').datepicker( "destroy" );

            $( id+" #formulario_filtro-fecha_desde" ).datepicker({
                maxDate: 0, //today
                onSelect: function( dateText, inst ) {
                    $( id+" #formulario_filtro-fecha_hasta" ).datepicker( "option", "minDate", dateText );
                }
            });

            $( id ).on( "click", '#limpiar_fecha_desde', function() {
                $( id+' #formulario_filtro-fecha_desde').val('');
                $( id+" #formulario_filtro-fecha_hasta" ).datepicker( "option", "minDate", null );
            });

            $( id+" #formulario_filtro-fecha_hasta" ).datepicker({
                maxDate: 0, //today
                onSelect: function( dateText, inst ) {
                    $( id+" #formulario_filtro-fecha_desde" ).datepicker( "option", "maxDate", dateText );
                }
            });

            $( id ).on( "click", '#limpiar_fecha_hasta', function() {
                $( id+' #formulario_filtro-fecha_hasta').val('');
                $( id+" #formulario_filtro-fecha_desde" ).datepicker( "option", "maxDate", 0 );
            });

            var fecha_desde = $( id+" #formulario_filtro-fecha_desde").val();
            var fecha_hasta = $( id+" #formulario_filtro-fecha_hasta").val();
            //Si hay fechas seleccionadas seteo los rangos...
            if(fecha_desde) $( id+" #formulario_filtro-fecha_hasta" ).datepicker( "option", "minDate", fecha_desde );
            if(fecha_hasta) $( id+" #formulario_filtro-fecha_desde" ).datepicker( "option", "maxDate", fecha_hasta );

            /* Submit del formulario */

            $( id ).on( "submit", '#formulario_filtro', function(event) {
                event.preventDefault();

                //Saco la descripción de la materia y el docente por si contienen caracteres especiales que rompan la URL.
                kernel.ajax.load(info.url_filtrar + '?' + $formulario_filtro.find("input[id!=formulario_filtro-materia_descr][id!=formulario_filtro-docente_descr]").serialize(), id, {
                    historia: true,
                    type: 'get',
                    show_loading: true,
                    forzar_cambio_op: true
                });

                return false;

            });

        }
    };
});

