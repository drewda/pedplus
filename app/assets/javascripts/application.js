// libraries that are used throughout the application 
// (including for users who have yet to sign in)

//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require json2
//= require underscore
//= require backbone
//= require backbone-relational

// http://stackoverflow.com/questions/646628/javascript-startswith
String.prototype.startsWith = function (str){
    return this.indexOf(str) == 0;
};