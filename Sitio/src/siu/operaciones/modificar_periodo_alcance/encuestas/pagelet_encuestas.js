kernel.renderer.registrar_pagelet('encuestas', function(info) {

    var id = '#' + info.id;

    function setMinDateFechaHasta(alcance){

        if($("#fecha_hasta_alcance_"+alcance).is(":disabled")){
            return false;
        }

        if($("#fecha_desde_alcance_"+alcance).is(":enabled")){
            var fecha_desde_date = Date.parse($( "#fecha_desde_alcance_"+alcance ).val());
            var minDate = fecha_desde_date.add({ days: 1 }).toString('dd/MM/yyyy');
        }
        else{

            var fecha_desde_date = Date.parse($( "#fecha_desde_alcance_"+alcance ).val());

            if(fecha_desde_date.equals(Date.parse(info.fecha_actual))){
                var minDate = fecha_desde_date.add({ days: 1 }).toString('dd/MM/yyyy');
            }
            else{
                var minDate = info.fecha_actual;
            }

        }

        $("#fecha_hasta_alcance_"+alcance).datepicker( "option", "minDate", minDate);

    }

    function setMinDateFechaDesde(alcance){

        $("#fecha_desde_alcance_"+alcance).datepicker( "option", "minDate", info.fecha_actual);

    }

    function setMaxDateFechaDesde(alcance){

        if($("#fecha_desde_alcance_"+alcance).is(":disabled")){
            return false;
        }

        if($("#fecha_hasta_alcance_"+alcance).is(":enabled")){
            var fecha_hasta_date = Date.parse($( "#fecha_hasta_alcance_"+alcance ).val());
            var maxDate = fecha_hasta_date.add({ days: -1 }).toString('dd/MM/yyyy');
        }
        else{
            var maxDate = info.fecha_actual;
        }

        $("#fecha_desde_alcance_"+alcance).datepicker( "option", "maxDate", maxDate);

    }

    function verificarCambioEnFechasDeAlcance(alcance){

        var fecha_desde_original = $("#fecha_desde_alcance_"+alcance).data("fechaOriginal");
        var fecha_desde_nueva = $("#fecha_desde_alcance_"+alcance).val();
        var fecha_hasta_original = $("#fecha_hasta_alcance_"+alcance).data("fechaOriginal");
        var fecha_hasta_nueva = $("#fecha_hasta_alcance_"+alcance).val();

        if((fecha_desde_original != fecha_desde_nueva) || (fecha_hasta_original != fecha_hasta_nueva)){//Si hubo cambio en las fechas...
            $("#boton_guardar_alcance_"+alcance).prop( "disabled", false );
        }
        else{
            $("#boton_guardar_alcance_"+alcance).prop( "disabled", true );
        }
    }

    return {
        onload: function() {

            $( id+" .fecha_desde:enabled" ).datepicker({
                onSelect: function( dateText, inst ) {

                    setMinDateFechaHasta($(this).data('alcance'));
                    verificarCambioEnFechasDeAlcance($(this).data('alcance'));

                }
            });

            $( id+" .fecha_hasta:enabled" ).datepicker({
                onSelect: function( dateText, inst ) {

                    setMaxDateFechaDesde($(this).data('alcance'));
                    verificarCambioEnFechasDeAlcance($(this).data('alcance'));

                }
            });

            //Esto se ejecuta una sola vez al principio...
            $( id+" .fecha_desde:enabled" ).each(function() {
                setMinDateFechaDesde($(this).data('alcance'));
                setMaxDateFechaDesde($(this).data('alcance'));
            });

            $(id).on('click', '.guardar', function(){

                var btn_guardar = $(this);
                $(btn_guardar).prop( "disabled", true );
                $("#mensaje-guardar").hide();
                $('.control-group').removeClass('error');

                var alcance = $(this).data('alcance');
                var fecha_desde = $("#fecha_desde_alcance_" + alcance).val();
                var fecha_hasta = $("#fecha_hasta_alcance_" + alcance).val();

                kernel.ajax.call(info.url_guardar, {
                    type: 'POST',
                    data: {
                        alcance: alcance,
                        fecha_desde: fecha_desde,
                        fecha_hasta: fecha_hasta
                    },
                    success: function(paquete) {

                        if(paquete.hubo_error){
                            $("#mensaje-guardar").text(paquete.mensaje).removeClass("alert-success").addClass("alert-error").fadeIn("slow");

                            switch (paquete.parametro_con_error) {
                                case 'fecha desde':
                                    $("#fecha_desde_alcance_" + alcance).parents('.control-group').addClass('error');
                                    break;
                                case 'fecha hasta':
                                    $("#fecha_hasta_alcance_" + alcance).parents('.control-group').addClass('error');
                                    break;
                            }

                            $(btn_guardar).prop( "disabled", false );

                        }
                        else{
                            $("#fecha_desde_alcance_"+alcance).data("fechaOriginal", $("#fecha_desde_alcance_"+alcance).val());
                            $("#fecha_hasta_alcance_"+alcance).data("fechaOriginal", $("#fecha_hasta_alcance_"+alcance).val());
                            $(btn_guardar).prop( "disabled", true );
                            $("#mensaje-guardar").text(paquete.mensaje).removeClass("alert-error").addClass("alert-success").fadeIn("slow");
                        }
                    }
                });

            });

        }
    }
});