kernel.renderer.registrar_pagelet('filtro', function (info) {
	var id = '#' + info.id;
	var $filtro;

	return {
		onload: function () {

			$filtro = $('form').formulario();

            if(($("#formulario_filtro-materia_descr").val() != "") && ($("#formulario_filtro-materia").val() != "")){
                set_solo_lectura("formulario_filtro-materia_descr", true);
            }
            else{
                $("#formulario_filtro-materia_descr").val("");
                $("#formulario_filtro-materia").val("");
            }

            $("#formulario_filtro-carrera").on("change", function(){

                var $elem_planes = $('#formulario_filtro-plan');
                $elem_planes.children().remove();

                $elem_planes.append(
                    $('<option></option>').val("").html(info.mensajes.filtro_todos)
                );

                if($(this).val() != ""){

                    kernel.ajax.call(info.url_buscar_planes, {
                        type: 'GET',
                        dataType: 'json',
                        data: {
                            carrera: $(this).val()
                        },
                        success: function(data) {

                            $.each(data.planes, function(key, value) {
                                $elem_planes.append(
                                    $('<option></option>').val(value['_ID_']).html(value['PLAN'])
                                );
                            });

                            $elem_planes.focus();

                        }
                    });

                    limpiar_materia();

                }

            });

            $("#formulario_filtro-plan").on("change", function(){

                if($(this).val() != ""){
                    limpiar_materia();
                    $('#formulario_filtro-materia_descr').focus();
                }
                else if(($("#formulario_filtro-materia").val() == "") && ($("#formulario_filtro-materia_descr").val() == "")){
                    $('#formulario_filtro-materia_descr').focus();
                }

            });

            $("#formulario_filtro-materia_descr").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: info.url_buscar_materias,
                        dataType: "json",
                        data: {
                            term : request.term,
                            carrera : $('#formulario_filtro-carrera').val(),
                            plan : $('#formulario_filtro-plan').val()
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

            $('#limpiar_materia').on('click', function () {
                limpiar_materia();
                $('#formulario_filtro-materia_descr').focus();
            });

            $filtro.find('input.date').datepicker( "destroy" );
            $filtro.find('input.date').datepicker({
                changeMonth: true,
                changeYear: true,
                firstDay: 0
            });

            $("#formulario_filtro").on("submit", function(event){
                event.preventDefault();

                var fecha_desde = $filtro.find('#formulario_filtro-fecha_desde').val();
                var fecha_hasta = $filtro.find('#formulario_filtro-fecha_hasta').val();
                var fecha_desde_error = false;
                var fecha_hasta_error = false;
                var error_filtros = false;
                var msg_error;

                if(fecha_desde != ""){
                    if(isDateValid(fecha_desde))
                    {
                        fecha_desde = Date.parse(fecha_desde);
                    }
                    else
                    {
                        fecha_desde_error = true;
                        error_filtros = true;
                    }
                }

                if(fecha_hasta != ""){
                    if(isDateValid(fecha_hasta))
                    {
                        fecha_hasta = Date.parse(fecha_hasta);
                    }
                    else
                    {
                        fecha_hasta_error = true;
                        error_filtros = true;
                    }
                }

                if(fecha_desde_error && fecha_hasta_error)
                {
                    msg_error = info.mensajes.msg_error_fechas;
                }
                else if(fecha_desde_error)
                {
                    msg_error = info.mensajes.fecha_desde_invalida;
                }
                else if(fecha_hasta_error)
                {
                    msg_error = info.mensajes.fecha_hasta_invalida;
                }
                else if((fecha_desde != "") && (fecha_hasta != ""))
                {
                    if(fecha_desde.compareTo(fecha_hasta) > 0)
                    {
                        msg_error = info.mensajes.fecha_hasta_menor_fecha_desde;
                        error_filtros = true;
                    }

                }

                //si hay error muestro mensaje
                if(error_filtros)
                {
                    kernel.ui.show_mensaje(msg_error, {tipo: 'alert-error', until_interaction: true});
                }
                else{
                    filtar();
                }


            });

            $(id).on('click', 'a.ver_mas_info', function(e){
                delegate_ver_mas_info($(this));
                e.preventDefault();
                return false;
            });

            $(id).on('keypress', 'a.ver_mas_info', function(e){
                if(e.keyCode == 13) {
                    $(this).trigger('click');
                }
            });

		}
	};

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

    function delegate_ver_mas_info($link) {

        if ($link.data('estado') == 'v') {

            $('#'+$link.data('id')).slideDown('slow', function(){
                $link.text(info.ocultar);
                $link.data('estado', 'o');
            });

        } else {

            $('#'+$link.data('id')).slideUp('slow', function(){
                $link.text(info.ver);
                $link.data('estado', 'v');
            });

        }


    }

    function isDateValid(date){
        var isValid = false;

        //Si la fecha cumple con el formato dd/mm/yyyy
        if(/^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/\d{4}$/.test(date))
        {
            //si la fecha es valida, ej: 31/02/2013 no es valida
            //ver doc en https://code.google.com/p/datejs/
            if(Date.parse(date))
            {
                isValid = true;
            }

        }

        return isValid;
    }

    function filtar(){

        kernel.ajax.load(info.url_buscar + '?' + $filtro.find("select, input[id!=formulario_filtro-materia_descr]").serialize(), id, {
            historia: true,
            type: 'get',
            show_loading: true,
            forzar_cambio_op: true
        });

        return false;
    }
});