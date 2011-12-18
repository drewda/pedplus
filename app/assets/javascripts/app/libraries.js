//= require jquery
//= require jquery_ujs
//= require json2
//= require underscore
//= require backbone
//= require backbone-relational
//= require jquery-svg
//= require jquery-svgdom
//= require bootstrap-dropdown
//= require bootstrap-modal
//= require xdate
//= require jquery-datatables
//= require jquery-datatables-bootstrap

// http://stackoverflow.com/questions/646628/javascript-startswith
String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
};

// include local cid in Backbone-produced JSON
Backbone.Model.prototype.toJSON = function() {
 return _(_.clone(this.attributes)).extend({
  cid : this.cid
 });
}