kernel.renderer.registrar_pagelet('lista_materias', function (info) {
    var id = '#' + info.id;

    function info_materia_inscripto() {
        $(id + ' .active').addClass('insc');
    }

    function info_materia_baja(params) {
        if (params.cant_inscripciones && params.cant_inscripciones > 0) {
            // no hay que desmarcar la materia porque quedan inscripciones
            return;
        }
        if (params.materia) {
            var selector = id + " a[href$='" + params.materia + "']";
            $(selector).parent().removeClass('insc');
        } else {
            $(id + ' .active').removeClass('insc');
        }
    }

    var cargando_materia = false;

    function info_materia_cargada(params) {
        var anchors = id + ' a';
        $(anchors).parent().removeClass('active');
        $(anchors).attr('aria-pressed', 'false');
        cargando_materia = false;
        var anchor_seleccionado = anchors + '[href$="' + params.href + '"]';
        $(anchor_seleccionado).parent().addClass('active');
        $(anchor_seleccionado).attr('aria-pressed', 'true');
//		$('body,html').animate({
//			scrollTop: $('#kernel_contenido').position().top + 10
//		}, 500);
    }

    function registrar_disparadores() {
        $(id).delegate('li', 'click', function () {
            $(this).find('a').trigger('click');
        });

        $(id).delegate('select', 'change', function () {
            if (cargando_materia) {
                return false;
            }

            cargando_materia = true;

            var option = $(this).find("option:selected");

            kernel.evts.disparar('seleccion_materia', {
                href: option.val(),
                materia: option.text()
            });

            return false;
        });

        $(id).delegate('a', 'click', function (e) {
            if (cargando_materia) {
                return false;
            }
            cargando_materia = true;

            setTimeout(function () {
                cargando_materia = false;
            }, 5000);

            if (e.ctrlKey) { // para que ctrl + click abra una nueva pesta�a
                return true;
            }

            kernel.evts.disparar('seleccion_materia', {
                href: $(this).attr('href'),
                materia: $(this).text()
            });

            return false;
        });
    }

    function registrar_listeners() {
        kernel.evts.escuchar('info_materia_cargada', info_materia_cargada);
        kernel.evts.escuchar('info_materia_inscripto', info_materia_inscripto);
        kernel.evts.escuchar('info_materia_baja', info_materia_baja);
        kernel.evts.escuchar('info_examen_inscripto', info_materia_inscripto);
        kernel.evts.escuchar('info_examen_baja', info_materia_baja);
    }

    function menu_mobile() {
        $("<select id='select_materias' class='span12 hidden-desktop'/>").insertAfter($('#js-listado-materias'));

        $("<option />", {
            "selected": "selected",
            "value": "",
            "text": "Seleccionar materia..."
        }).appendTo("#select_materias");

        $(".nav-list li a").each(function () {
            var el = $(this);
            $("<option />", {
                "value": el.attr("href"),
                "text": el.text()
            }).appendTo("#select_materias");
        });
    }

    return {
        onload: function () {
            registrar_listeners();
            registrar_disparadores();
            new util.filtro_lista({
                selector_pagelet: id,
                valor_defecto: info.busca_actividad,
                selector_input: '#filtro_materias input',
                selector_li: '#js-listado-materias li',
                filtra_planes: info.filtra_planes
            });
        }
    };
}, '_comun/pagelets')
