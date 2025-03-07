function buildList(filename, elementClass) {


//load JSON file
$.getJSON(filename, function(data) {
//build menu
var builddata = function () {
    var source = [];
    var items = [];
    for (i = 0; i < data.length; i++) {
        var item = data[i];
        var label = item["name"];
        var parentid = item["parent_id"];
        var id = item["id"];
        var url = item["url"];

        if (items[parentid]) {
            var item = { parentid: parentid, label: label, url: url, item: item };
            if (!items[parentid].items) {
                items[parentid].items = [];
            }
            items[parentid].items[items[parentid].items.length] = item;
            items[id] = item;
        }
        else {
            items[id] = { parentid: parentid, label: label, url: url, item: item };
            source[id] = items[id];
        }
    }
    return source;
}

var buildUL = function (parent, items) {
    $.each(items, function () {
        if (this.label) {
            var li = $("<li class='js-menu' style='list-style:none;margin:0;'>" + "<a href='"+ this.url +"'>" + this.label + "</a></li>");
            li.appendTo(parent);
            if (this.items && this.items.length > 0) {
                var ul = $("<ul class='dropdown-menu js-menu'></ul>");
                ul.appendTo(li);
                buildUL(ul, this.items);
            }
        }
    });
}
var source = builddata();
var ul = $("." + elementClass + "-menu");
ul.appendTo("." + elementClass + "-menu");
buildUL(ul, source);
//add bootstrap classes
if ($("." + elementClass + "-menu>li:has(ul.js-menu)"))
{
    $("." + elementClass + "-menu>li.js-menu").addClass('dropdown-submenu');
}
if ($("." + elementClass + "-menu>li>ul.js-menu>li:has(> ul.js-menu)"))
{
    $("." + elementClass + "-menu>li>ul.js-menu li ").addClass('dropdown-submenu');
}
$("ul.js-menu").find("li:not(:has(> ul.js-menu))").removeClass("dropdown-submenu");
});
}
