var util = util || {};

util.filtro_lista = function (options) {
    var $pagelet = $(options.selector_pagelet);
    var string_inicial = options.valor_defecto;
    var $input = $(options.selector_input);
    var filtra_planes = options.filtra_planes;
    /*
     * La lista filtrada
     */
    var $li = $(options.selector_li);
    var tipo_filtrado = 'T';
    var tipo_plan = 'V'; // V = Vigente / A = anterior

    style_input();
    volver_estado_inicial();

    filtrado_inscripciones();
    
    $input.blur(function () {
        if ($(this).val() == '') {
            volver_estado_inicial();
        }
    }).focus(function () {
        if ($(this).val() == string_inicial) {
            limpiar_estado_inicial();
        }
    }).keyup(function (e) {
        if (e.keyCode == 27) {
            volver_estado_inicial();
        } else {
            var nuevo_valor = strip_acentos($(this).val().toLowerCase());
            nuevo_input(nuevo_valor);
        }
    });

    $pagelet.find('.js-mostrar-todas-materias').click(function () {
        if (tipo_filtrado !== 'T')
        {
            tipo_filtrado = 'T';
            filtrado_inscripciones();
        }
        $('.js-mostrar-todas-materias').attr("aria-pressed", "true");
        $pagelet.find('.js-mostrar-materias-solo-inscriptas').attr("aria-pressed", "false");
    });

    $pagelet.find('.js-mostrar-materias-solo-inscriptas').click(function () {
        if (tipo_filtrado !== 'I')
        {
            tipo_filtrado = 'I';
            filtrado_inscripciones();
        }
        $('.js-mostrar-materias-solo-inscriptas').attr("aria-pressed", "true");
        $pagelet.find('.js-mostrar-todas-materias').attr("aria-pressed", "false");
    });
    
    $pagelet.find('.js-filtro-plan-actual').click(function () {
        tipo_plan = "V";
        filtrado_inscripciones();
        $(this).attr("aria-pressed", "true");
        $pagelet.find('.js-filtro-plan-anterior').attr("aria-pressed", "false");
    });
    
    $pagelet.find('.js-filtro-plan-anterior').click(function () {
        tipo_plan = "A";
        filtrado_inscripciones();
        $(this).attr("aria-pressed", "true");
        $pagelet.find('.js-filtro-plan-actual').attr("aria-pressed", "false");
    });
    
    function filtrado_inscripciones(){
        $pagelet.find('#js-listado-materias li').show();
        
        if (tipo_filtrado === 'I'){
            $li.not('.insc').hide();
        } else {
            nuevo_input($input.val());
        }
        
        if (filtra_planes){
            if (tipo_plan === "V"){
                $li.not('.plan_actual').hide();
            } else {
                $li.not('.plan_anterior').hide();
            }
        }
    }
    

    /*  (C)Scripterlative.com
     *  Strips grave, acute, circumflex umlaut and tilde from vowels and �.
     *  Include this script block, then within the tag of each text element to be controlled, insert:
     *  onblur='this.value=stripVowelAccent(this.value)'
     *  GratuityWare
     *  ~~~~~~~~~~~~
     *  You obtained this script probably out of desperation, so if you wish to express your gratitude for our efforts,
     *  please visit: www.scripterlative.com
     */
    function strip_acentos(str) {
        var rExps = [
            {re: /[\xC0-\xC6]/g, ch: 'A'},
            {re: /[\xE0-\xE6]/g, ch: 'a'},
            {re: /[\xC8-\xCB]/g, ch: 'E'},
            {re: /[\xE8-\xEB]/g, ch: 'e'},
            {re: /[\xCC-\xCF]/g, ch: 'I'},
            {re: /[\xEC-\xEF]/g, ch: 'i'},
            {re: /[\xD2-\xD6]/g, ch: 'O'},
            {re: /[\xF2-\xF6]/g, ch: 'o'},
            {re: /[\xD9-\xDC]/g, ch: 'U'},
            {re: /[\xF9-\xFC]/g, ch: 'u'},
            {re: /[\xD1]/g, ch: 'N'},
            {re: /[\xF1]/g, ch: 'n'}];

        for (var i = 0, len = rExps.length; i < len; i++)
            str = str.replace(rExps[i].re, rExps[i].ch);

        return str;
    }

    function highlight(str, from, to) {
        var primer_parte = str.substring(0, from);
        var resaltada = "<span class='highlight'>" + str.substring(from, to) + "</span>";
        var ultima_parte = str.substring(to);
        return primer_parte + resaltada + ultima_parte;
    }

    function highlight_li($li, from, to) {
        //var aux, a;
        $li.find('.js-filter-content').html(highlight($li.find('.js-filter-content').text(), from, to));
    }

    function unhighlight_li($li) {
        $li.find('.js-filter-content').html($li.find('.js-filter-content').text());
    }

    function style_input() {
        //var $limpiar_lista = $("<div class='limpiar_lista' />");
        var $limpiar_lista = $("<span class='btn'><span class='icon-remove'><span class='acchide'>Borrar filtro</span></span></span>");
        $limpiar_lista.click(function () {
            $input.focus(); // le damos foco para que escriba un nuevo filtro
            volver_estado_inicial();
        });

        $input.after($limpiar_lista);
    }

    function volver_estado_inicial() {
        if ($input.is(':focus')) {
            // si el input sigue con foco (por ej: si se apreta esc) no hay que 
            // poner de vuelta el string inicial
            $input.val('');
        } else {
            $input.val(string_inicial);
            $input.addClass('cursiva');
        }

        nuevo_input('');
    }

    function limpiar_estado_inicial() {
        $input.val('');
        $input.removeClass('cursiva');
    }

    function nuevo_input(nuevo_valor) {
        $li.each(function () {
            var $this = $(this);
            var materia = strip_acentos($this.text().toLowerCase());
            var index = materia.indexOf(nuevo_valor);
            if (index < 0 || nuevo_valor.length == 0)
            {
                unhighlight_li($this);
            }
            else
            {
                highlight_li($this, index, index + nuevo_valor.length);
//            if (index < 0 || (tipo_filtrado == 'I' && !$this.hasClass('insc')))
//                $this.hide();
//            else
//                $this.show();
            }
        })
    }

    return {
        evento_input: function (nuevo_valor) {
            nuevo_input(nuevo_valor);
        }
    }
};
