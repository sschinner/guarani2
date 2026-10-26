kernel.renderer.registrar_pagelet('certificado_evaluacion', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            function exp_pdf(url) {
                window.open(encodeURI(url));
            }

            $(id).on('click', '#pdf_btn', function (evt){
                exp_pdf($(this).attr('href'));
                evt.preventDefault();
                evt.stopPropagation();
            });

        }
    }
})
