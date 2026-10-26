kernel.renderer.registrar_pagelet('listado_encuesta', function (info) {
    var id = '#' + info.id;

    return {
        onload: function () {

            //Llamada a todas las rtas de la encuesta
            $(id).on('vclick', '#expandir', function (event) {

                event.preventDefault();

                var formulario = $(this).data('formulario');
                var habilitacion = $(this).data('habilitacion');
                var elemento = $(this).data('elemento');
                var encuesta = $(this).data('encuesta');
                var unidad_gestion = $(this).data('unidad_gestion');
                var cargado = $(this).data('cargado');

                if (cargado){
                    $(".collapse").collapse('show');
                }else{
                    kernel.ajax.call( info.url_ver_encuesta_completa, {
                        type: 'GET',
                        data: {
                            formulario_encuesta: formulario,
                            elemento_encuestado: elemento,
                            habilitacion: habilitacion,
                            encuesta: encuesta,
                            unidad_gestion: unidad_gestion
                        },
                        success: function (res) {
                            $("#encuesta_completa").html(res.cont);
                            $("#expandir").data('cargado', true);
                            $("#encuesta_completa .accordion-toggle").data("cargado", true);
                            $(".collapse").collapse('show');
                        }
                    });
                }
            });

            $(id).on('vclick', '#contraer', function (event) {
                // verifico si existe algun div expandido para dispara el evento que los contrae
                var divs_expandidos = $("div.collapse.in").length;
                if (divs_expandidos > 0)
                {
                    event.preventDefault();
                    $(".collapse").collapse('hide');
                }
            });

            //Llamada a las preguntas del bloque seleccionado.
            $(document).on("click", "a.bloque",function (event) {
                var bloque = $(this);
                var url = $(this).attr("url");
                var collapse = $(this).data('target');
                var cargado = $(this).data('cargado');

                if (cargado) {
                    $(collapse).collapse('toggle');
                }
                else {
                    kernel.ajax.call(url, {
                        type: 'GET',
                        success: function (res) {
                            $(collapse + " div.accordion-inner").html(res.cont);
                            $(collapse).collapse('show');
                            bloque.data('cargado', true);
                        }
                    });
                }
            });
            
            //Llamada de las respuestas a la pregunta seleccionada.
            $(document).on("click", "a.pregunta", function (event) {
                event.preventDefault();
                event.stopImmediatePropagation();
                var pregunta = $(this);
                var url = $(this).attr("url");
                var collapse = $(this).data('target');
                var cargado = $(this).data('cargado');
                var orden = $(this).data('pregunta_orden');
                var formulario = pregunta.parents("div.bloque-param").data('formulario');
                var habilitacion = pregunta.parents("div.bloque-param").data('habilitacion');
                var elemento = pregunta.parents("div.bloque-param").data('elemento');

                if (cargado) {
                    $(collapse).collapse('toggle');
                }
                else {
                    kernel.ajax.call(url, {
                        type: 'GET',
                        data: {formulario_encuesta : formulario, elemento_encuestado: elemento, id_habilitacion_alcance_kolla: habilitacion, pregunta_orden: orden},
                        success: function (res) {
                            $(collapse + " div.accordion-inner").html(res.cont);
                            $(collapse).collapse('show');
                            pregunta.data('cargado', true);
                        }
                    });
                }

            });

            //Dibuja el grafico segun la opcion seleccionada
            $(id).on("shown", 'a[data-toggle="tab"]', function (e) {

                var id = $(this).data('id');
                var data = eval($(this).data('data'));
                var tipo = $(this).data('tipo');

                if ((tipo == 'torta') && (!$(this).data('cargado'))) {
                    dibujar_grafico_torta(id, data);
                    $(this).data('cargado', true);
                }
                else if ((tipo == 'barra') && (!$(this).data('cargado'))) {
                    dibujar_grafico_barra(id, data);
                    $(this).data('cargado', true);
                }

            });

            function dibujar_grafico_torta(id, data) {

                var total = 0;
                $(data).map(function () {
                    total += this[1];
                });

                var plot1 = jQuery.jqplot(id,
                    [data],
                    {
                        title: ' ',
                        seriesDefaults: {
                            shadow: false,
                            renderer: jQuery.jqplot.PieRenderer,
                            rendererOptions: {padding: 2, sliceMargin: 2, showDataLabels: true}
                        },
                        highlighter: {
                            show: true,
                            tooltipLocation: 'n',
                            tooltipAxes: '',
                            useAxesFormatters: false,
                            showTooltip: true,
                            tooltipFormatString: '%s'
                        },
                        legend: {
                            show: true,
                            location: 'e',
                            renderer: $.jqplot.EnhancedPieLegendRenderer,
                            fontSize: '10pt'
                        }
                    });
                // Ref: http://stackoverflow.com/questions/24145901/show-percentage-in-jqplot-piechart-tooltip
                $("#" + id).bind('jqplotDataHighlight', function (ev, seriesIndex, pointIndex, data) {
                    var highlightToolTip = $(".jqplot-highlighter-tooltip");
                    var pct = Math.round(data[1] / total * 100);
                    highlightToolTip.html(pct + "%");
                });
            }

            function dibujar_grafico_barra(id, data) {

                $('#' + id).jqplot([data], {
                    title: '',
                    seriesDefaults: {
                        renderer: $.jqplot.BarRenderer,
                        rendererOptions: {
                            // Set the varyBarColor option to true to use different colors for each bar.
                            // The default series colors are used.
                            varyBarColor: true
                        }
                    },
                    axes: {
                        xaxis: {
                            renderer: $.jqplot.CategoryAxisRenderer,
                            tickRenderer: $.jqplot.CanvasAxisTickRenderer,
                            tickOptions: {
                                angle: -25,
                                fontSize: '8pt'
                            }
                        },
                        yaxis: {
                            min: 0,
                            tickInterval: 1,
                            tickOptions: {
                                formatString: '%d'
                            }
                        }
                    }
                });
            }
        }
    };
});