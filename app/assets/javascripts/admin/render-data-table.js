/* Table initialisation */
$(document).ready(function() {
  $('.data-table').dataTable( {
    "sDom": "T<'row'<'span6'l><'span6'>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "sPaginationType": "bootstrap",
    "oLanguage": {
      "sLengthMenu": "_MENU_ records per page"
    },
    "aLengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
    "oTableTools": {
        "sSwfPath": "/assets/copy_csv_xls_pdf.swf",
        "aButtons": [
                "copy",
                "csv"
                ]
    }
  } );
} );
