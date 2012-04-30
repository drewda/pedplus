//= require jquery
//= require jquery_ujs
//= require json2
//= require underscore
//= require underscore-addons
//= require backbone
//= require polymaps
//= require d3
//= require d3.geo
//= require jquery-svg
//= require jquery-svgdom
//= require bootstrap-dropdown
//= require bootstrap-modal
//= require bootstrap-button
//= require bootstrap-transition
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootbox
//= require xdate
//= require jquery-datatables
//= require jquery-datatables-bootstrap
//= require jquery-datatables-tabletools
//= require jquery-scrollto
//= require jquery-stay-in-web-app

// http://stackoverflow.com/questions/646628/javascript-startswith
String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
};

// include local cid in Backbone-produced JSON
Backbone.Model.prototype.toJSON = function() {
  var object = new Object;
  object = _(_.clone(this.attributes)).extend({
    cid : this.cid
  });
  return object;
}

// enable boolean sorting in jquery-datatables
// http://www.datatables.net/forums/discussion/1067/bug-javascript-error-on-sort-with-booleans-in-column/p1
var fnConvertToString = function(value){
  return (value + '').toLowerCase();
};
     
var fnEquals = function(lhs, rhs){
  if (lhs < rhs){
    return -1;
  }
    else if (lhs > rhs){
      return 1;
    }
    return 0;
   };
     
var fnCompareString = function(lhs, rhs){
  var lhs = fnConvertToString(lhs);
  var rhs = fnConvertToString(rhs);
  return fnEquals(lhs, rhs);
};
     
$.fn.dataTableExt.oSort[ 'string-asc' ] = function(lhs, rhs){
  return fnCompareString(lhs, rhs);
};
     
$.fn.dataTableExt.oSort[ 'string-desc' ] = function(lhs, rhs){
  return fnCompareString(lhs, rhs) * -1;
};

// code from http://forums.devarticles.com/showpost.php?p=71368&postcount=2
function roundNumber(num, dec) {
  var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
  return result;
}