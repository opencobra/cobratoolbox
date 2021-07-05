// SAMMI is a tool for visualization of metabolic networks

// Copyright (C) 2019 The University of Texas MD Anderson Cancer Center.

// This program is free software: you can redistribute it and/or modify 
// it under the terms of the GNU General Public License as published by 
// the Free Software Foundation, either version 3 of the License, or 
// any later version.

// This program is distributed in the hope that it will be useful, 
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License 
// with this program. If not, see <https://www.gnu.org/licenses/>.

function newnodetemp(id,group) {
    return {
        concentration: null,
        flux: null,
        fx: null,
        fy: null,
        group: group,
        id: id,
        class: id,
        index: graph.nodes.length,
        isfixed: false,
        name: id,
        secondary: false,
        trap: -1,
        weight: 1.01,
        labelshift: [0,0],
        bezi: [null, null, null, null],
        selected: false,
        previouslySelected: false,
        grouping: [],
        vx: 0,
        vy: 0,
        reversed: 1,
        width: null
    }
}

function extent() {
    var svg = this.ownerSVGElement || this;
    return [[-200*$(window).width(), -200*$(window).height()], [200*$(window).width(), 200*$(window).height()]];
}

function set_highlight(d) {
    ctrlKeyIng = true;
	if (focus_node!==null) d = focus_node;

    node.style("opacity", function(o) {
        return isConnectedName(d, o) ? 1 : 0;
    });
    text.style("font-size", function(o) {
        return isConnectedName(d, o) ? document.getElementById("labelsize").value + "px" : "0px";
    });
    link.style("opacity", function(o) {
        return o.source.index == d.index || o.target.index == d.index ? 1 : 0;
    });
    arrows.style("opacity", function(o) {
        return o.source.index == d.index || o.target.index == d.index ? 1 : 0;
    });
}
function set_highlight_search() {
    ctrlKeyIng = true;
    node.style("opacity", 0);
    text.style("font-size", 0);
    link.style("opacity", 0);
    arrows.style("opacity",0)

    for (var i = 0; i < selected.length; i++) {
        d = graph.nodes[selected[i]];
        node.filter(function(o){return isConnectedName(d, o)}).style("opacity",1)
        text.filter(function(o){return isConnectedName(d, o)}).style("font-size",document.getElementById("labelsize").value + "px")
        link.filter(function(o){return o.source.index == d.index || o.target.index == d.index}).style("opacity",1)
        arrows.filter(function(o){return o.source.index == d.index || o.target.index == d.index}).style("opacity",1)
    }
}
function exit_highlight() {
    ctrlKeyIng = false;
		highlight_node = null;
	if (focus_node===null) {
        node.style("opacity",1)
        link.style("opacity",1)
        arrows.style("opacity",1)
        text.style("font-size", document.getElementById("labelsize").value + "px");
    }
    if (document.getElementById("hiderxns").checked) {
        node.style("opacity", function(d) {return d.group==1 ? 0 : 1;});
    } else {
        node.style("opacity", 1);
    }
}
function isConnectedName(a, b) {
    return linkedByName[a.class + "," + b.class] || linkedByName[b.class + "," + a.class] || a.index == b.index;
}
function isConnectedID(a, b) {
    return linkedByID[a.id + "," + b.id] || linkedByID[b.id + "," + a.id] || a.index == b.index;
}
function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}	


function splitMet() {

    simulation.stop()

    for (var j = 0; j < selected.length; j++) {
        curnode = graph.nodes[selected[j]];
        if (curnode.group == 1) {continue;}
        curnode.degree = 1;

        var firstone = true;
        for (var i = 0; i < graph.links.length; i++) {
            e = graph.links[i];
            if (e.source.id == curnode.id) {
                if (firstone) {firstone = false; continue}
                var tmp = JSON.parse(JSON.stringify(curnode))
                var newnode = Object.assign(tmp,{
                    id: tmp.id + "." + count,
                    fx: null,
                    fy: null,
                    isfixed: false,
                    selected: true,
                    previouslySelected: true,
                    degree: 1,
                    labelshift: [0,0],
                    grouping: [],
                    })
                count++;
                selected.push(graph.nodes.length)
                graph.nodes.push(newnode)
                e.source = graph.nodes[graph.nodes.length-1];
            } else if (e.target.id == curnode.id) {
                if (firstone) {firstone = false; continue}
                var tmp = JSON.parse(JSON.stringify(curnode));
                var newnode = Object.assign(tmp,
                    {id: tmp.id + "." + count,
                    fx: null,
                    fy: null,
                    isfixed: false,
                    selected: true,
                    previouslySelected: true,
                    degree: 1,
                    labelshift: [0,0],
                    grouping: [],
                })
                count++;
                selected.push(graph.nodes.length)
                graph.nodes.push(newnode)
                e.target = graph.nodes[graph.nodes.length-1];
            }
        }
    }
    
    reDefineSimulation()
}

function isolateRxn() {

    if (selected.length > 1) {return}
    if (graph.nodes[selected[0]].group != 1) {return}

    simulation.stop()

    curnode = graph.nodes[selected[0]];

    for (var i = 0; i < graph.links.length; i++) {
        e = graph.links[i];
        if (e.source.id == curnode.id & e.target.degree > 1) {
            var tmp = JSON.parse(JSON.stringify(e.target));
            var newnode = Object.assign(tmp,{
                id: tmp.id + "." + count,
                fx: null,
                fy: null,
                isfixed: false,
                selected: false,
                previouslySelected: false,
                degree: 1,
                labelshift: [0,0],
                grouping: [],
            })
            count++;
            e.target.degree--;
            graph.nodes.push(newnode)
            e.target = graph.nodes[graph.nodes.length-1];
        } else if (e.target.id == curnode.id & e.source.degree > 1) {
            var tmp = JSON.parse(JSON.stringify(e.source));
            var newnode = Object.assign(tmp,{
                id: tmp.id + "." + count,
                fx: null,
                fy: null,
                isfixed: false,
                selected: false,
                previouslySelected: false,
                degree: 1,
                labelshift: [0,0],
                grouping: [],
            })
            count++;
            e.source.degree--;
            graph.nodes.push(newnode)
            e.source = graph.nodes[graph.nodes.length-1];
        }
    }
    reDefineSimulation()
}

function toggleSelected() {
    if (dragging){
        graph.nodes.forEach(function(d) {
            if (d.selected) {
                d.isfixed = !d.isfixed;
                if(d.weight == 0) {d.weight = 1.01} else {d.weight = 0}
                node.attr("fill", defineNodeColor).attr("stroke", defineNodeColor)
            }
        });
    } else {
        simulation.stop()
        graph.nodes.forEach(function(d) {
            if (d.selected) {
                if (d.isfixed) {
                    d.fx = null;
                    d.fy = null;
                    d.isfixed = false;
                    d.weight = 1.01;
                } else {
                    d.fx = d.x;
                    d.fy = d.y;
                    d.vx = 0;
                    d.vy = 0;
                    d.isfixed = true;
                    d.weight = 0;
                }
            }
        });
        node.attr("fill", defineNodeColor).attr("stroke", defineNodeColor)
        simulation.restart()   
    }
}

function fixSelected() {
    
    if (dragging){
        graph.nodes.forEach(function(d) {
            if (d.selected) {
                d.isfixed = true;
                d.weight = 0;
                node.attr("fill", defineNodeColor).attr("stroke", defineNodeColor)
            }
        });
    } else {
        simulation.stop()
        graph.nodes.forEach(function(d) {
            if (d.selected) {
                d.fx = d.x;
                d.fy = d.y;
                d.vx = 0;
                d.vy = 0;
                d.isfixed = true;
                d.weight = 0;
            }
        });
        node.attr("fill", defineNodeColor).attr("stroke", defineNodeColor)
        simulation.restart()   
    }
}

function isolateMetabolite() {
    var metindex = [],
    rxnindex = [];
    selected.forEach(function(d){
        if (graph.nodes[d].group == 2) {
            metindex.push(graph.nodes[d].index);
        } else if (graph.nodes[d].group == 1) {
            rxnindex.push(graph.nodes[d].index);
        }
    })
    
    simulation.stop()
    for (var i = 0; i < metindex.length; i++) {
        goahead = false;
        graph.links.forEach(function(d){
            if ((d.source.index == metindex[i] && rxnindex.indexOf(d.target.index) == -1) || 
                (d.target.index == metindex[i] && rxnindex.indexOf(d.source.index) == -1)) {
                    goahead = true;
                }
        })
        if (!goahead) {continue;}
        
        //duplicate node
        var newnode = JSON.parse(JSON.stringify(graph.nodes[metindex[i]]));
        newnode.id = newnode.id + "." + count;
        newnode.grouping = [];
        count++
        if (newnode.fx) {newnode.fx += 10};
        if (newnode.fy) {newnode.fy += 10};
        newnode.selected = true;
        newnode.previouslySelected = true;
        selected.push(graph.nodes.length)
        graph.nodes.push(newnode)

        //connect reactions to that node
        graph.links.forEach(function(d){
            if (rxnindex.includes(d.target.index) && d.source.index == metindex[i]){
                d.source = graph.nodes[graph.nodes.length-1];
            } else if (rxnindex.includes(d.source.index) && d.target.index == metindex[i]) {
                d.target = graph.nodes[graph.nodes.length-1];
            }
        })  
    }
    reDefineSimulation()
}

function joinMetabolite() {
    simulation.stop()
    //get unique IDs
    metids = [];
    mets1 = [];
    mets2 = [];
    for (var i = 0; i < graph.nodes.length; i++) {
        //get all ids
        if (graph.nodes[i].group == 2 && graph.nodes[i].selected){
            metids.push(graph.nodes[i].id);
        }
        //if this is the first time we see the node
        if (graph.nodes[i].group == 2 && mets1.indexOf(graph.nodes[i].class) == -1 && graph.nodes[i].selected){
            mets1.push(graph.nodes[i].class);
            continue;
        }
        //if this is the second time we see the node
        if (graph.nodes[i].group == 2 && mets1.indexOf(graph.nodes[i].class) != -1 && mets2.indexOf(graph.nodes[i].class) == -1 && graph.nodes[i].selected){
            mets2.push(graph.nodes[i].class);
            continue;
        }
    }
    for (var i = 0; i < mets2.length; i++) {
        //re-define selected
        selected = [];
        for (var j = 0; j < graph.nodes.length; j++) {
            d = graph.nodes[j];
            if (d.class == mets2[i] && metids.indexOf(d.id) != -1) {
                d.selected = true;
                selected.push(d.index);
            } else {
                d.selected = false
            }
        }
        //Redefine links
        for (var j = 0; j < graph.links.length; j++) {
            d = graph.links[j];
            if(selected.includes(d.target.index)){
                d.target = graph.nodes[selected[0]];
            } else if (selected.includes(d.source.index)){
                d.source = graph.nodes[selected[0]];
            }
        }
        //remove nodes
        for (var j = selected.length-1; j > 0; j--) {
            graph.nodes.splice(selected[j],1);
        }
        for (var j = 0; j < graph.nodes.length; j++) {
            graph.nodes[j].index = j;
        }
    }

    //re-select
    selected = [];
    for (var j = 0; j < graph.nodes.length; j++){
        if (metids.indexOf(graph.nodes[j].id) != -1) {
            selected.push(graph.nodes[j].index)
            graph.nodes[j].selected = true;
        } else {
            graph.nodes[j].selected = false;
        }
    }
    //redefine
    reDefineSimulation()
}

function nodedegree(){
    graph.nodes.forEach(function(d){d.degree = 0})
    graph.links.forEach(function(d){
        graph.nodes[d.source.index].degree++
        graph.nodes[d.target.index].degree++
    })
    if (Object.keys(sizerxnobj).length == 0 && Object.keys(sizemetobj).length == 0) {
        graph.nodes.forEach(function(d){
            if (d.group == 5) {
                d.r = (Math.sqrt(d.degree) + 5)*Number(document.getElementById("refnodescale").value);
            } else {
                d.r = (Math.sqrt(d.degree) + 5)*Number(document.getElementById("nodescale").value);
            }
            if (d.secondary) {d.r = Math.sqrt(d.r)}
        })
    } else {
        var secs = Math.sqrt(6*Number(document.getElementById("nodescale").value));
        graph.nodes.forEach(function(d){
            if (d.secondary) {
                d.r = secs;
            } else if (d.group == 5) {
                d.r = 6*Number(document.getElementById("refnodescale").value);
            } else if (d.size == null) {
                d.r = 6*Number(document.getElementById("nodescale").value);
            } else if (d.group == 2) {
                if (d.size < minmetsize) {
                    d.r = minmetsize*Number(document.getElementById("metsizescale").value);
                } else if (d.size > maxmetsize) {
                    d.r = maxmetsize*Number(document.getElementById("metsizescale").value);
                } else {
                    d.r = d.size*Number(document.getElementById("metsizescale").value);
                }
            } else {
                if (d.size < minrxnsize) {
                    d.r = minrxnsize*Number(document.getElementById("rxnsizescale").value);
                } else if (d.size > maxrxnsize) {
                    d.r = maxrxnsize*Number(document.getElementById("rxnsizescale").value);
                } else {
                    d.r = d.size*Number(document.getElementById("rxnsizescale").value);
                }
            }
        })
    }
    
}

function suspendMetabolite() {
    simulation.stop()
    allids = [];
    graph.nodes.forEach(function(d){
        if (d.selected){
            if (d.group != 2) {return;}
            allids.push(d.id)
        }
    })
    for (var node = 0; node < allids.length; node++){
        for (var i = graph.nodes.length-1; i >= 0; i--) {
            var d = graph.nodes[i];
            if (d.id == allids[node]) {
                linktodel = [];
                cursel = [d.id];
                graph.links.forEach(function(e){
                    if (e.target.id == d.id) {
                        linktodel.push(e.index);
                        cursel.push(e.source.id + "t")
                    } else if (e.source.id == d.id) {
                        linktodel.push(e.index);
                        cursel.push(e.target.id + "s")
                    }
                })
                cursel.push(JSON.stringify(d))
                graph.suspended.push(cursel);
                for (var i = linktodel.length - 1; i >= 0; i--){graph.links.splice(linktodel[i],1)}
                graph.nodes.splice(d.index,1)
                for (var i = 0; i < graph.links.length; i++){graph.links[i].index = i;}
                for (var i = 0; i < graph.nodes.length; i++){graph.nodes[i].index = i;}
                list = document.getElementById("suspended");
                var p = document.createElement("option");
                p.id = "removed" + d.id;
                p.innerHTML = d.id;
                list.appendChild(p)
            }
        }
    }
    reDefineSimulation()
    defineSuspended()
}

function putBack(node) {
    defineBackupGraph();
    var toremove;
    var allids = [];
    graph.suspended.forEach(function(d){
        allids.push(d[0])
        if (d[0] == node.value) {
            toremove = d[0];
            var newnode = JSON.parse(d[d.length-1]);
            newnode.index = graph.nodes.length;
            newnode.selected = true;
            selected.push(graph.nodes.length);
            graph.nodes.push(newnode)
            re = /(.)$/;
            for (var i = 1; i < d.length-1; i++) {
                var newlink = {
                    index: graph.links.length,
                    value: 1
                }
                linkdata = d[i].split(re)
                graph.nodes.forEach(function(e){
                    if (e.id == linkdata[0]) {
                        link.reversed = e.reversed;
                        if (linkdata[1] == "t") {
                            newlink.target = newnode;
                            newlink.source = e;
                        } else {
                            newlink.source = newnode;
                            newlink.target = e;
                        }
                        newlink.flux = e.flux;
                        newlink.reversed = e.reversed;
                        newlink.width = e.width;
                        graph.links.push(newlink);
                    }
                })
            }
        }
    })
    document.getElementById("removed" + toremove).remove()
    document.getElementById("suspended").selectedIndex = 0;

    while(allids.indexOf(toremove) != -1) {
        graph.suspended.splice(allids.indexOf(toremove),1)
        var allids = [];
        graph.suspended.forEach(function(d){allids.push(d[0])})
    }

    reDefineSimulation()
}

function getSearchNodes(e,nodeid) {
    if (e.keyCode == 13){
        if(tracking){trackMet()}
        //define search keys
        if (document.getElementById('metNameOpts').value == "") {
            metkey = "class";
        } else {
            metkey = document.getElementById('metNameOpts').value;
        }

        if (document.getElementById('rxnNameOpts').value == "") {
            rxnkey = "class";
        } else {
            rxnkey = document.getElementById('rxnNameOpts').value;
        }

        //var re = new RegExp(document.getElementById("searchbox").value, "i");
        if (document.getElementById("searchregexp").checked) {
            nodeidesc = nodeid;
        } else {
            nodeidesc = nodeid.replace(/[-[\]{}()*+?.,\\|#\s]/g, '\\$&');
        }
        var re = new RegExp(nodeidesc, "i");
        selected = [];
        for (var i = 0; i < graph.nodes.length; i++) {
            if (graph.nodes[i].group == 2) {
                if (re.test(graph.nodes[i][metkey])) {
                    graph.nodes[i].selected = true;
                    selected.push(i);
                } else {
                    graph.nodes[i].selected = false;
                }
            } else {
                if (re.test(graph.nodes[i][rxnkey])) {
                    graph.nodes[i].selected = true;
                    selected.push(i);
                } else {
                    graph.nodes[i].selected = false;
                }
            } 
        }
        node.classed("selected",function(d){return d.selected})
        if (document.getElementById("searchhighlight").checked) {set_highlight_search()}

        //If it is present on other subgraphs
        if (Object.keys(parsedmodels).length == 1) {return;}
        wd = openEdit()

        var sgs = [],
        ct = [];
        for (j in parsedmodels) {
            if (j == currentparsed) {continue;}
            found = false;
            cct = 0;
            for (var i = 0; i < parsedmodels[j].nodes.length; i++){
                if (parsedmodels[j].nodes[i].group == 2) {
                    if (re.test(parsedmodels[j].nodes[i][metkey])) {
                        cct++;
                        if (!found) {sgs.push(j)};
                        found = true;
                    }
                } else {
                    if (re.test(parsedmodels[j].nodes[i][rxnkey])) {
                        cct++;
                        if (!found) {sgs.push(j)};
                        found = true;
                    }
                }
            }
            if (cct > 0) {ct.push(cct)}
        }
        
        if (sgs.length == 0) {return;}

        list = sortTwo(ct,sgs);
        ct = list[0].reverse();
        sgs = list[1].reverse();

        //Dialog 2
        for (var i = 0; i < sgs.length; i++) {
            var a = document.createElement("a");
            a.innerHTML = ct[i] + " - " + sgs[i];
            a.setAttribute("sval", sgs[i]);
            a.className = "debug";
            a.onclick = function(){
                document.getElementById("onloadf1").value = this.attributes.sval.value;
                onLoadSwitch(document.getElementById("onloadf1"));
                e.keyCode = 13;
                getSearchNodes(e,nodeid)
            }
            a.onmouseover = function(){document.body.style.cursor = "pointer"};
            a.onmouseout = function(){document.body.style.cursor = "auto"};
            wd.appendChild(a)
            var br = document.createElement("br");
            wd.appendChild(br);
        }

        wd.style = "display:block;";
        document.getElementsByClassName("ui-dialog-titlebar")[1].style = "display:block;";

        if (document.getElementsByClassName("ui-dialog-titlebar")[1].childElementCount == 2) {
            span = document.createElement("span")
            span.id = "ui-id-2"
            span.className = "ui-dialog-title"
            span.innerHTML = "X"
            span.onclick = function(){closeEdit()}
            span.style = "cursor: context-menu;position: absolute;right: 10px;"
            document.getElementsByClassName("ui-dialog-titlebar")[1].appendChild(span)
        }
    }
}

function deleteNodes() {
    for (var i = 0; i < graph.links.length; i++){
        if (graph.links[i].target.selected || graph.links[i].source.selected) {
            graph.links.splice(i,1);
            i--;
        } else {
            graph.links[i].index = i;
        }
    }

    for (var i = 0; i < graph.nodes.length; i++) {
        if (graph.nodes[i].selected){
            graph.nodes.splice(i,1);
            i--
        } else {
            graph.nodes[i].index = i;
        }
    }

    selected = [];

    reDefineSimulation()
}



function color(n){
    if (n==1) {return document.getElementById("rxncolor").value}
    else if (n==2) {return document.getElementById("metcolor").value}
    else if (n==3) {return document.getElementById("fixrxncolor").value}
    else if (n==4) {return document.getElementById("fixmetcolor").value}
    else if (n==5) {return document.getElementById("addednodecolor").value}
    else if (n==6) {return document.getElementById("edgecolor").value}
    else if (n==7) {return document.getElementById("rxncolorsize").value}
    else if (n==8) {return document.getElementById("metcolorsize").value}
    else if (n==9) {return document.getElementById("widthcolorsize").value}
    else if (n==10) {return "#ff9896"}
}

function makeSecondary() {
    graph.nodes.forEach(function(d){
        if (d.selected && d.group == 2 && d.degree == 1) {
            d.secondary = true;
        }
    })
    defineSecondaryPosition()
    graph.nodes.forEach(function(d){
        if (d.selected && d.group == 2 && d.degree == 1) {
            if (d.relposfunx != null) {
                d.x = d.relposfunx;
                d.y = d.relposfuny;
            }
        }
    })
    reDefineSimulation()
}
function makePrimary() {
    graph.nodes.forEach(function(d){
        if (d.selected && d.group == 2 && d.degree == 1) {
            d.secondary = false;
        }
    })
    defineSecondaryPosition()
    reDefineSimulation()
}
function defineSecondaryPosition() {
    graph.nodes.forEach(function(d){
        if (d.secondary) {
            var rindex = -1;
            for (var i = 0; i < graph.links.length; i++) {
                if (graph.links[i].source.id == d.id) {
                    var contype = "s";
                    rindex = graph.links[i].target.index;
                    break;
                } else if (graph.links[i].target.id == d.id) {
                    var contype = "t";
                    rindex = graph.links[i].source.index;
                    break;
                }
            }
            if (rindex == -1) {
                return d;
            }
            if (graph.nodes[rindex].bezi[0] != null) {
                if (contype == "s") {
                    d.relposfunx = graph.nodes[rindex].x + 1.3*graph.nodes[rindex].bezi[0] + 5;
                    d.relposfuny = graph.nodes[rindex].y + 1.3*graph.nodes[rindex].bezi[1] + 5;
                } else {
                    d.relposfunx = graph.nodes[rindex].x + 1.3*graph.nodes[rindex].bezi[2] + 5;
                    d.relposfuny = graph.nodes[rindex].y + 1.3*graph.nodes[rindex].bezi[3] + 5;
                }
            } else {
                var mindexes = [];
                if (contype == "s") {
                    for (var i = 0; i < graph.links.length; i++) {
                        if (graph.links[i].target.index == rindex && !graph.links[i].source.secondary) {mindexes.push(graph.links[i].source.index)}
                    }
                } else {
                    for (var i = 0; i < graph.links.length; i++) {
                        if (graph.links[i].source.index == rindex && !graph.links[i].target.secondary) {mindexes.push(graph.links[i].target.index)}
                    }
                }
                d.relpos = mindexes;
                if (d.relpos.length == 0) {
                    d.relposfuny = null;
                } else {
                    var mean = 0,
                    meancount = 0;
                    d.relpos.forEach(function(e) {mean += graph.nodes[e].y; meancount++;})
                    d.relposfuny = mean/meancount;
                }
                
                if (d.relpos.length == 0) {
                    d.relposfunx = null;
                } else {
                    var mean = 0,
                    meancount = 0;
                    d.relpos.forEach(function(e) {mean += graph.nodes[e].x; meancount++;})
                    d.relposfunx = mean/meancount;
                }
            }
        }
        return d;
    })
}

function rgbToHex(vec) {
    return "#" + ((1 << 24) + (vec[0] << 16) + (vec[1] << 8) + vec[2]).toString(16).slice(1);
}
function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return [parseInt(result[1], 16),parseInt(result[2], 16),parseInt(result[3], 16)]
}

function putBackCommit(com) {
    select = document.getElementById("commits")

    parsedmodels = JSON.parse(JSON.stringify(backups[select.value]));
    for (j in parsedmodels) {
        parsedmodels[j].links.forEach(function(d){
            d.target = parsedmodels[j].nodes[d.target.index];
            d.source = parsedmodels[j].nodes[d.source.index];
        })
    }
    graph = parsedmodels[currentparsed]

    defineSuspended()
    reDefineSimulation()
    select.selectedIndex = 0;
}
function commitGraph() {
    var tmp = document.getElementById("commitname").value;
    if (tmp.length == 0) {
        var d = new Date();
        commitname = d.toUTCString();
    } else {
        commitname = tmp;
    }
    
    option = document.createElement("option");
    option.innerHTML = commitname;
    
    select = document.getElementById("commits");
    if (select.options.length == 1) {
        select.appendChild(option)
    } else {
        select.insertBefore(option,select.children[1])
    }

    backups[commitname] = JSON.parse(JSON.stringify(parsedmodels));

    for (j in backups[commitname]) {
        backups[commitname][j].links.forEach(function(d){
            d.target = backups[commitname][j].nodes[d.target.index];
            d.source = backups[commitname][j].nodes[d.source.index];
        })
    }

    //remove too many
    if (Object.keys(backups).length > 20) {
        delete backups[select.children[select.childElementCount-1].value];
        select.children[select.childElementCount-1].remove();
    }
    document.getElementById("commitname").value = "";
}

function keepNodes() {
    var nodestokeep = [];

    graph.nodes.filter(function(d){return d.selected})
    .forEach(function(d){
        nodestokeep.push(d.index);
        if (d.group == 1) {
            graph.links.filter(function(l){return l.target.index == d.index})
            .forEach(function(l){
                nodestokeep.push(l.source.index);
            })
            graph.links.filter(function(l){return l.source.index == d.index})
            .forEach(function(l){
                nodestokeep.push(l.target.index);
            })
        }
    })

    uniquenodes = nodestokeep.filter(onlyUnique)

    graph.nodes.forEach(function(e) {e.selected = true;})
    uniquenodes.forEach(function(e){graph.nodes[e].selected = false})

    deleteNodes()
}

function putAllBack() {
    defineBackupGraph()
    select = document.getElementById("suspended");
    while (select.options.length > 1) {
        select.selectedIndex = 1;
        putBack(select)
    }
}

function reDefineSimulationParameters() {
    simulation = d3.forceSimulation()
        .force("link", d3.forceLink()
            .id(function(d) { return d.id; })
            //.distance(Number(document.getElementById("linkstrength").value)))
            .distance(function(d){
                    return Number(document.getElementById("linkstrength").value);
            }))
        .force("charge", d3.forceManyBody()
            .distanceMax(500)
            .strength((d) => {
                if (d.secondary) {
                    return -Math.sqrt(Number(document.getElementById("maparea").value))
                } else {
                    return -Number(document.getElementById("maparea").value)
                }
            }))
        .force("x", d3.forceX(function(d){
            if (d.secondary){
                return d.relposfunx;
            } else {
                return parentWidth/2
            }
        }).strength(function(d) {
            if (d.secondary){
                if (d.relposfunx == null) {
                    return 0;
                } else {
                    return Number(document.getElementById("secondarystrength").value)
                }
            } else {
                return Number(document.getElementById("centerstrength").value)
            }
        }))
        .force("y", d3.forceY(function(d){
            if (d.secondary){
                return d.relposfuny;
            } else {
                return parentHeight/2
            }
        }).strength(function(d) {
            if (d.secondary){
                if (d.relposfuny == null) {
                    return 0;
                } else {
                    return Number(document.getElementById("secondarystrength").value)
                }
            } else {
                return Number(document.getElementById("centerstrength").value)
            }
        }))
        
    simulation.velocityDecay(Number(document.getElementById("velocityDecay").value))

    simulation
        .nodes(graph.nodes)
        .on("tick", ticked);

    simulation.force("link")
        .links(graph.links);
    linkedByName = {};
    graph.links.forEach(function(d) {
    linkedByName[d.source.class + "," + d.target.class] = true;
    });

    linkedByID = {};
    graph.links.forEach(function(d) {
    linkedByID[d.source.id + "," + d.target.id] = true;
    });

    simulation.force('collision', d3.forceCollide().radius(function(d){
        if (d.secondary) {
            return 0//d.r*d.r + Number(document.getElementById("nodestrength").value)
        } else {
            return d.r + Number(document.getElementById("nodestrength").value)
        }
    }));

    nodedegree()

    circlenode.attr("r", function(d){return d.r;})
    rectnode.attr("width", function(d){return 2*d.r;})
    rectnode.attr("height", function(d){return 2*d.r;})
}

function setdisplay() {
    document.getElementsByClassName("ui-dialog-content")[0].style = "display:block;";
    document.getElementsByClassName("ui-dialog-content")[1].style = "display:none;";
    document.getElementsByClassName("ui-dialog-titlebar")[0].style = "display:block;";
    document.getElementById("topbar").style = "display:block;"
    document.getElementById("d3_selectable_force_directed_graph").style="width: 100%; height: 100%; display: block";
    document.getElementById("dialog").parentNode.style.left = "10px";
    document.getElementById("dialog").parentNode.style.top = -window.innerHeight + 5 + "px";
    document.getElementById("dialog2").parentNode.style.left = "50px";
    document.getElementById("dialog2").parentNode.style.top = -window.innerHeight + 5 - document.getElementById("dialog").clientHeight + "px";
}
function loadExistingReactionToAdd(gp) {
    var allrxns = [];
    var allmets = [];
    for (j in gp) {
        for (var i = 0; i < gp[j].nodes.length; i++) {
            if (gp[j].nodes[i].group == 1 && allrxns.indexOf(gp[j].nodes[i].class) == -1) {
                allrxns.push(gp[j].nodes[i].class)
            } else if (gp[j].nodes[i].group == 2 && allmets.indexOf(gp[j].nodes[i].class) == -1) {
                allmets.push(gp[j].nodes[i].class)
            }
        }
    }
    autocomplete(document.getElementById("existingReactions"), allrxns);
    autocomplete(document.getElementById("existingMetabolites"), allmets);
}

function autocomplete(inp, arr) {
    var currentFocus;
    inp.addEventListener("input", function(e) {
        var a, b, i, val = this.value;
        closeAllLists();
        if (!val) { return false;}
        currentFocus = -1;
        a = document.createElement("DIV");
        a.setAttribute("id", this.id + "autocomplete-list");
        a.setAttribute("class", "autocomplete-items");
        this.parentNode.appendChild(a);
        for (i = 0; i < arr.length; i++) {
          if (arr[i].substr(0, val.length).toUpperCase() == val.toUpperCase()) {
            b = document.createElement("DIV");
            b.innerHTML = "<strong>" + arr[i].substr(0, val.length) + "</strong>";
            b.innerHTML += arr[i].substr(val.length);
            b.innerHTML += "<input type='hidden' value='" + arr[i] + "'>";
            b.addEventListener("click", function(e) {
                inp.value = this.getElementsByTagName("input")[0].value;
                closeAllLists();
            });
            a.appendChild(b);
          }
        }
    });
    inp.addEventListener("keydown", function(e) {
        var x = document.getElementById(this.id + "autocomplete-list");
        if (x) x = x.getElementsByTagName("div");
        if (e.keyCode == 40) {
          currentFocus++;
          addActive(x);
        } else if (e.keyCode == 38) { //up
          currentFocus--;
          addActive(x);
        } else if (e.keyCode == 13) {
          e.preventDefault();
          if (currentFocus > -1) {
            if (x) x[currentFocus].click();
          }
        }
    });
    function addActive(x) {
      if (!x) return false;
      removeActive(x);
      if (currentFocus >= x.length) currentFocus = 0;
      if (currentFocus < 0) currentFocus = (x.length - 1);
      x[currentFocus].classList.add("autocomplete-active");
    }
    function removeActive(x) {
      for (var i = 0; i < x.length; i++) {
        x[i].classList.remove("autocomplete-active");
      }
    }
    function closeAllLists(elmnt) {
      var x = document.getElementsByClassName("autocomplete-items");
      for (var i = 0; i < x.length; i++) {
        if (elmnt != x[i] && elmnt != inp) {
          x[i].parentNode.removeChild(x[i]);
        }
      }
    }
    document.addEventListener("click", function (e) {
        closeAllLists(e.target);
    });
}

function autocomplete2(inp, arr) {
    var currentFocus;
    inp.addEventListener("input", function(e) {
        var a, b, i, val = this.value;
        closeAllLists();
        if (!val) { return false;}
        currentFocus = -1;
        a = document.createElement("DIV");
        a.setAttribute("id", this.id + "autocomplete-list");
        a.setAttribute("class", "autocomplete-items");
        this.parentNode.appendChild(a);
        for (i = 0; i < arr.length; i++) {
          //if (arr[i].substr(0, val.length).toUpperCase() == val.toUpperCase()) {
            var ind = arr[i].toUpperCase().indexOf(val.toUpperCase())
            if (ind != -1) {
            b = document.createElement("DIV");
            b.onclick = () => {loadKEGGmodel()}
            b.innerHTML = arr[i]
            b.innerHTML = b.innerHTML.replace(arr[i].substr(ind, val.length),
            "<strong>" + arr[i].substr(ind, val.length) + "</strong>")
            b.innerHTML += "<input type='hidden' value='" + arr[i] + "'>";
            b.addEventListener("click", function(e) {
                inp.value = this.getElementsByTagName("input")[0].value;
                closeAllLists();
            });
            a.appendChild(b);
          }
        }
    });
    inp.addEventListener("keydown", function(e) {
        var x = document.getElementById(this.id + "autocomplete-list");
        if (x) x = x.getElementsByTagName("div");
        if (e.keyCode == 40) {
          currentFocus++;
          addActive(x);
        } else if (e.keyCode == 38) { //up
          currentFocus--;
          addActive(x);
        } else if (e.keyCode == 13) {
          e.preventDefault();
          if (currentFocus > -1) {
            if (x) x[currentFocus].click();
          }
        }
    });
    function addActive(x) {
      if (!x) return false;
      removeActive(x);
      if (currentFocus >= x.length) currentFocus = 0;
      if (currentFocus < 0) currentFocus = (x.length - 1);
      x[currentFocus].classList.add("autocomplete-active");
    }
    function removeActive(x) {
      for (var i = 0; i < x.length; i++) {
        x[i].classList.remove("autocomplete-active");
      }
    }
    function closeAllLists(elmnt) {
      var x = document.getElementsByClassName("autocomplete-items");
      for (var i = 0; i < x.length; i++) {
        if (elmnt != x[i] && elmnt != inp) {
          x[i].parentNode.removeChild(x[i]);
        }
      }
    }
    document.addEventListener("click", function (e) {
        closeAllLists(e.target);
    });
}

function addExistingReaction(e) {
    if (e.keyCode == 13) {
        defineBackupGraph(); 
        setTimeout(function() {
            var rx = document.getElementById("existingReactions").value;
            var nodeadded = false;
            for (j in parsedmodels) {
                for (var i = 0; i < parsedmodels[j].nodes.length; i++) {
                    if (parsedmodels[j].nodes[i].class == rx) {
                        graph.nodes.push(JSON.parse(JSON.stringify(parsedmodels[j].nodes[i])))
                        graph.nodes[graph.nodes.length-1].id = graph.nodes[graph.nodes.length-1].id + "." + count;
                        count++;
                        if (graph.nodes[graph.nodes.length-1].fx !=null) {
                            graph.nodes[graph.nodes.length-1].fx += 10;
                            graph.nodes[graph.nodes.length-1].fy += 10;
                        }
                        nodeadded = true;
                        break;
                    }
                }
                if (nodeadded) {break}
            }
            if (nodeadded) {
                var limit = parsedmodels[j].links.length;
                var newnodeindex = graph.nodes.length-1;
                graph.nodes[graph.nodes.length-1].index = newnodeindex;
                for (var i = 0; i < limit; i++) {
                    if (parsedmodels[j].links[i].source.class == rx) {
                        var newlink = Object.assign(JSON.parse(JSON.stringify(parsedmodels[j].links[i])),{
                            source: graph.nodes[newnodeindex],
                            index: graph.links.length,
                        })
                        newlink.index = graph.links.length;
                        var newnode = JSON.parse(JSON.stringify(parsedmodels[j].links[i].target));
                        newnode.index = graph.nodes.length;
                        newnode.id = newnode.id + "." + count;
                        count++;
                        if (newnode.fx != null) {
                            newnode.fx += 10;
                            newnode.fy += 10;
                        }
                        graph.nodes.push(newnode);
                        newlink.target = newnode;
                        graph.links.push(newlink);

                    } else if (parsedmodels[j].links[i].target.class == rx) {
                        var newlink = Object.assign(JSON.parse(JSON.stringify(parsedmodels[j].links[i])),{
                            target: graph.nodes[newnodeindex],
                            index: graph.links.length,
                        })
                        newlink.index = graph.links.length;
                        var newnode = JSON.parse(JSON.stringify(parsedmodels[j].links[i].source));
                        newnode.index = graph.nodes.length;
                        newnode.id = newnode.id + "." + count;
                        count++;
                        if (newnode.fx != null) {
                            newnode.fx += 10;
                            newnode.fy += 10;
                        }
                        graph.nodes.push(newnode);
                        newlink.source = newnode;
                        graph.links.push(newlink);
                    }
                }
                for (var i = 0; i < parsedmodels[j].suspended.length; i++) {
                    for (var k = 1; k < (parsedmodels[j].suspended[i].length-1); k++) {
                        tmp = parsedmodels[j].suspended[i][k].split(/([t,s])$/i);
                        if (tmp[0] == graph.nodes[newnodeindex].class) {
                            var newnode = JSON.parse(parsedmodels[j].suspended[i][parsedmodels[j].suspended[i].length-1]);
                            newnode.id = newnode.id + "." + count;
                            count++;
                            graph.nodes.push(newnode)
                            var newlink = {};
                            newlink.reversed = graph.nodes[newnodeindex].reversed;
                            newlink.flux = graph.nodes[newnodeindex].flux;
                            newlink.width = graph.nodes[newnodeindex].width;
                            if (tmp[1] == "t") {
                                newlink.source = graph.nodes[newnodeindex];
                                newlink.target = newnode;
                            } else {
                                newlink.target = graph.nodes[newnodeindex];
                                newlink.source = newnode;
                            }
                            graph.links.push(newlink)
                        }
                    }
                }
            } else {
                var newnode = newnodetemp(rx,1)
                graph.nodes.push(newnode)
            }
            reDefineSimulation()
        },100)
    }
}

function addExistingMetabolite(e) {
    if (e.keyCode == 13) {
        defineBackupGraph(); 
        setTimeout(function() {
            var rx = document.getElementById("existingMetabolites").value;
            for (j in parsedmodels) {
                for (var i = 0; i < parsedmodels[j].nodes.length; i++) {
                    if (parsedmodels[j].nodes[i].class == rx) {
                        graph.nodes.push(JSON.parse(JSON.stringify(parsedmodels[j].nodes[i])))
                        graph.nodes[graph.nodes.length-1].id = graph.nodes[graph.nodes.length-1].id + "." + count;
                        count++;
                        reDefineSimulation()
                        return
                    }
                }
            }

            var newnode = newnodetemp(rx,2)
            graph.nodes.push(newnode)
            reDefineSimulation()
        },100)
    }
}

function defineSuspended() {
    //clear
    sspd = document.getElementById("suspended");
    while (sspd.childElementCount > 1) {
        sspd.removeChild(sspd.lastChild);
    }
    //get unique
    var added = [];
    for (var i = 0; i < graph.suspended.length; i++){
        if (added.indexOf(graph.suspended[i][0]) == -1){
            added.push(graph.suspended[i][0])
        }
    }
    //add options
    added.sort()
    added.forEach(function(d){
        var p = document.createElement("option");
        p.id = "removed" + d;
        p.innerHTML = d;
        sspd.appendChild(p)
    })
    
}
function defineNodeColor(d) {
    if (d.group == 1) {
        if (d.flux != null && d.flux*d.reversed >= fluxmax) {
            return document.getElementById("edgemax").value
        } else if (d.flux != null && d.flux*d.reversed <= fluxmin) {
            return document.getElementById("edgemin").value
        } else if (d.flux != null) {
            return defineFluxColor(d.flux*d.reversed)
        } else if (d.flux == null && d.size == null) {
            return color(d.group + d.isfixed*2);
        } else {
            return color(7);
        }
    } 
    if (d.group == 2) {
        if (d.concentration != null && d.concentration >= concentrationmax) {
            return document.getElementById("metmax").value
        } else if (d.concentration != null && d.concentration <= concentrationmin) {
            return document.getElementById("metmin").value
        } else if (d.concentration != null) {
            return defineFluxColorMet(d.concentration)
        } else if (d.concentration == null && d.size == null) {
            return color(d.group + d.isfixed*2);
        } else {
            return color(8);
        }
    } 
    return color(d.group);
}
function reDefineColors() {
    node.attr("fill", defineNodeColor).attr("stroke", defineNodeColor)
    if (document.getElementById("linkstrain").checked) {
        ticked()
    } else {
        link.style("stroke",defineLinkColor)
    }
    reDefineSimulation()
    manageTooltips()
    node.classed("selected",function(d){return d.selected})
}
function defineLinkColor(d){
    if (d.flux != null && d.flux*d.reversed >= fluxmax) {
        return document.getElementById("edgemax").value
    } else if (d.flux != null && d.flux*d.reversed <= fluxmin) {
        return document.getElementById("edgemin").value
    } else if (d.flux != null) {
        return defineFluxColor(d.flux*d.reversed)
    } else if (d.flux == null && d.width == null) {
        return color(6)
    } else {
        return color(9)
    }
}
function defineFluxColor(val) {
    for (var i = 0; i < rxncolorbreaks.length; i++) {if (val < rxncolorbreaks[i]) {break}}
    if (i == rxncolorbreaks.length) {i = rxncolorbreaks.length-1;}
    var col = [];
    for (var j = 0; j < 3; j++) {
        col.push(Math.round(rxncolor[i-1][j] + (rxncolor[i][j] - rxncolor[i-1][j]) * ((val - rxncolorbreaks[i-1]) /(rxncolorbreaks[i] - rxncolorbreaks[i-1]))))
    }
    return rgbToHex(col)
}
function defineFluxColorMet(val) {
    for (var i = 0; i < metcolorbreaks.length; i++) {if (val < metcolorbreaks[i]) {break}}
    if (i == metcolorbreaks.length) {i = metcolorbreaks.length-1;}
    var col = [];
    for (var j = 0; j < 3; j++) {
        col.push(Math.round(metcolor[i-1][j] + (metcolor[i][j] - metcolor[i-1][j]) * ((val - metcolorbreaks[i-1]) /(metcolorbreaks[i] - metcolorbreaks[i-1]))))
    }
    return rgbToHex(col)
}

function addAs(condition) {
    var rxns = [],
    mets = [];
    for (var i = 0; i < selected.length; i++) {
        if (graph.nodes[selected[i]].group == 1) {
            rxns.push(selected[i]);
        } else if (graph.nodes[selected[i]].group == 2) {
            mets.push(selected[i]);
        }
    }

    if (mets.length == 0 || rxns.length == 0) {return;}

    if (condition == "substrate") {
        for (var i = 0; i < rxns.length; i++) {
            for (var j = 0; j < mets.length; j++) {
                var newlink = {
                    flux: null,
                    width: null,
                    source: graph.nodes[mets[j]],
                    target: graph.nodes[rxns[i]]
                }
                newlink.reversed = newlink.target.reversed;
                graph.links.push(newlink)
            }
        }
    } else {
        for (var i = 0; i < rxns.length; i++) {
            for (var j = 0; j < mets.length; j++) {
                var newlink = {
                    flux: null,
                    width: null,
                    target: graph.nodes[mets[j]],
                    source: graph.nodes[rxns[i]],
                }
                newlink.reversed = newlink.source.reversed;
                graph.links.push(newlink)
            }
        }
    }
    reDefineSimulation()
}

function defineNameOptions() {
    var metkeys = [],
    rxnkeys = [];
    graph.nodes.forEach(function(e){
        if (e.group == 2) {
            Object.keys(e).forEach(function(z){if (metkeys.indexOf(z) == -1){metkeys.push(z)}})
        } else {
            Object.keys(e).forEach(function(z){if (rxnkeys.indexOf(z) == -1){rxnkeys.push(z)}})
        }
    })

    var select = document.getElementById("metNameOpts");
    while (select.childElementCount > 0) {select.removeChild(select.children[0])}
    for (var i = 0; i < metkeys.length; i++) {
        if (noshowttp.indexOf(metkeys[i]) != -1) {continue;}
        var option = document.createElement("option")
        option.innerHTML = metkeys[i];
        select.appendChild(option)
    }
    if (metkeys.indexOf("class") != -1) {select.value = "class"}

    var select = document.getElementById("secMetNameOpts");
    while (select.childElementCount > 0) {select.removeChild(select.children[0])}
    for (var i = 0; i < metkeys.length; i++) {
        if (noshowttp.indexOf(metkeys[i]) != -1) {continue;}
        var option = document.createElement("option")
        option.innerHTML = metkeys[i];
        select.appendChild(option)
    }
    if (metkeys.indexOf("class") != -1) {select.value = "class"}

    var select = document.getElementById("rxnNameOpts");
    while (select.childElementCount > 0) {select.removeChild(select.children[0])}
    for (var i = 0; i < rxnkeys.length; i++) {
        if (noshowttp.indexOf(rxnkeys[i]) != -1) {continue;}
        var option = document.createElement("option")
        option.innerHTML = rxnkeys[i];
        select.appendChild(option)
    }
    if (rxnkeys.indexOf("class") != -1) {select.value = "class"}
}

function renameNodes() {
    //Clear
    text.selectAll("tspan").remove()

    //Define label array
    var maxlen = 0;
    graph.nodes.forEach((d) => {
        var str;
        if (d.group == 2 && !d.secondary) {
            if (document.getElementById("metNameOpts").value == "") {
                str = d.class;
            } else {
                str = d[document.getElementById("metNameOpts").value];
            }
        } else if (d.group == 2) {
            if (document.getElementById("secMetNameOpts").value == "") {
                str = d.class;
            } else {
                str = d[document.getElementById("secMetNameOpts").value];
            }
        } else {
            if (document.getElementById("rxnNameOpts").value == "") {
                str = d.class;
            } else {
                str = d[document.getElementById("rxnNameOpts").value];
            }
        };
        if (!str) {str = ""};
        str = str.trim();
        str = str.replace(/\s+/,' ')
        tmp = str.split(" ");
        if (tmp.length > 3) {
            curid = str.indexOf(' ',0);
            ids = [];
            while (curid > 0) {
                ids.push(curid);
                curid = str.indexOf(' ',curid+1);
            }
            minid = ids.map((d) => {return Math.abs(d-str.length/3)});
            minid = ids[minid.indexOf(Math.min(...minid))];
            maxid = ids.map((d) => {return Math.abs(d-2*str.length/3)});
            maxid = ids[maxid.indexOf(Math.min(...maxid))];
            str = [str.slice(0,minid), str.slice(minid,maxid), str.slice(maxid)]
        } else {
            str = tmp;
        }
        if (str.length > maxlen) {maxlen = str.length;}
        d.labelarr = str;
        return d
    })
    //Add label
    var tmp = [0.3, -0.3, -.9]
    for (var i = 0; i < maxlen; i++) {
        text.filter((d) => {return d.labelarr.length > i}).append("tspan")
        //.data(graph.nodes)
        .text(function(d) {return d.labelarr[i]})
        .attr("dy",(d) => (tmp[d.labelarr.length-1] + "em"))
        .attr("x",function(d){return d.x});

        tmp = tmp.map((d) => {return d+1.2});
    }
}
function editNodeProperties(d) {

    wd = openEdit()

    for (j in d) {
        if (noshowedit.indexOf(j) != -1) {continue;}
        input = document.createElement("input")
        if (j == "flux" && Object.keys(fluxobj).length == 0) {
            input.type = "text";
            input.value = "Upload data";
            input.readOnly = true;
        } else if (j == "concentration" && Object.keys(concobj).length == 0) {
            input.type = "text";
            input.value = "Upload data";
            input.readOnly = true;
        } else if (d.group == 1 && j == "size" && Object.keys(sizerxnobj).length == 0) {
            input.type = "text";
            input.value = "Upload data";
            input.readOnly = true;
        } else if (d.group == 2 && j == "size" && Object.keys(sizemetobj).length == 0) {
            input.type = "text";
            input.value = "Upload data";
            input.readOnly = true;
        } else if (d.group == 1 && j == "width" && Object.keys(linkwidthobj).length == 0) {
            input.type = "text";
            input.value = "Upload data";
            input.readOnly = true;
        } else if (j == "size" || j == "flux" || j == "concentration" || j == "width") {
            input.type = "number";
            input.value = d[j]
        } else if (j == "degree") {
            input.type = "number";
            input.value = d[j];
            input.readOnly = true;
        } else if (typeof(d[j]) == "number") {
            input.type = "number";
            input.value = d[j]
        } else if (typeof(d[j]) == "string") {
            input.type = "text";
            input.value = d[j]
        } else {
            input.type = "text";
            input.value = d[j];
            input.readOnly = true;
        }
        input.style = "width: 100px; float: right"
        input.onchange = function(){editAttribute(this)}
        input.onclick = function(){typing = true;}
        input.onkeydown = function(){typing = true;}
        input.onfocus = function(){typing = true;}
        input.nodeindex = d.index;

        a = document.createElement('a');
        a.innerHTML = j + ":";
        wd.appendChild(a)
        wd.appendChild(input)

        br = document.createElement("br")
        br.style = "line-height:22px;";
        wd.appendChild(br)
    }
}

function editAttribute(node) {
    j = node.previousSibling.innerHTML.slice(0,-1)
    if ((j == "size" || j == "flux" || j == "concentration" || j == "width") && node.value == "") {
        graph.nodes[Number(node.nodeindex)][j] = null;
        if (j == "flux") {
            graph.links.filter(l => l.target.id == graph.nodes[Number(node.nodeindex)].id || l.source.id == graph.nodes[Number(node.nodeindex)].id)
                .forEach(l => l.flux = null)
        }
    } else if (node.type == "number") {
        if (node.value == "") {
            node.value = graph.nodes[Number(node.nodeindex)][j];
            return;
        } else {
            graph.nodes[Number(node.nodeindex)][j] = Number(node.value);
            if (j == "flux") {
                graph.links.filter(l => l.target.id == graph.nodes[Number(node.nodeindex)].id || l.source.id == graph.nodes[Number(node.nodeindex)].id)
                .forEach(l => l.flux = Number(node.value))
            } else if (j == "width") {
                graph.links.filter(l => l.target.id == graph.nodes[Number(node.nodeindex)].id || l.source.id == graph.nodes[Number(node.nodeindex)].id)
                .forEach(l => l.width = Number(node.value))
            }
        }

    } else {
        graph.nodes[Number(node.nodeindex)][j] = node.value;
    }

    setTimeout(function(){reDefineSimulation()},10)
}
function closeEdit() {
    document.getElementById("dialog2").style = "display:none;";
    document.getElementsByClassName("ui-dialog-titlebar")[1].style = "display:none;";
}
function openEdit() {
    wd = document.getElementById("dialog2");

    while (wd.hasChildNodes()) {wd.children[0].remove()}

    wd.style = "display:block;";
    document.getElementsByClassName("ui-dialog-titlebar")[1].style = "display:block;";

    if (document.getElementsByClassName("ui-dialog-titlebar")[1].childElementCount == 2) {
        var span = document.createElement("span")
        span.id = "ui-id-2"
        span.className = "ui-dialog-title"
        span.innerHTML = "X"
        span.onclick = function(){closeEdit()}
        span.style = "cursor: context-menu;position: absolute;right: 10px;"
        document.getElementsByClassName("ui-dialog-titlebar")[1].appendChild(span)
    }

    return wd
}

function addReactionColorBreak(btn) {
    var input = document.createElement("input");
    input.type = "number";
    input.onclick="typing=true;";
    input.onfocus="typing=true;"
    input.className = "rxnbreakval";
    input.value = (fluxmax + fluxmin)/2
    input.onchange = function() {defineFluxColorVectors()}

    var input2 = document.createElement("input");
    input2.type = "color";
    input2.className = "rxnbreakcol jscolor";
    input2.style = "margin: 0px 0px 0px 3px;"
    input2.onchange = function() {defineFluxColorVectors()}

    var x = document.createElement("a")
    x.innerHTML = "X";
    x.style = "display: inline; margin: 0px 10px 0px 10px; padding: 4px;"
    x.onclick = function(){deleteReactionColorBreak(this)}

    var br = document.createElement("br")

    btn.parentNode.insertBefore(input,btn)
    btn.parentNode.insertBefore(input2,btn)
    btn.parentNode.insertBefore(x,btn)
    btn.parentNode.insertBefore(br,btn)

    //defineFluxColorVectors()
    //defineFluxColorBar()
}
function deleteReactionColorBreak(tmp) {
    tmp.previousSibling.previousSibling.remove()
    tmp.previousSibling.remove()
    tmp.nextSibling.remove()
    tmp.remove()
    defineFluxColorVectors()
    defineFluxColorBar()
}
function defineFluxColorVectors() {

    rxncolorbreaks = [fluxmin, fluxmax],
    rxncolor = [hexToRgb(document.getElementById("edgemin").value),hexToRgb(document.getElementById("edgemax").value)]

    brks = document.getElementsByClassName("rxnbreakval");

    for (var i = 0; i < brks.length; i++) {
        if (Number(brks[i].value) > fluxmax) {brks[i].value = fluxmax}
        if (Number(brks[i].value) < fluxmin) {brks[i].value = fluxmin}
        rxncolorbreaks.push(Number(brks[i].value))
        rxncolor.push(hexToRgb(brks[i].nextSibling.value))
    }

    list = sortTwo(rxncolorbreaks,rxncolor)
    rxncolorbreaks = list[0];
    rxncolor = list[1];

    if (document.getElementById("fluxscroll") != null) {
        id = document.getElementById("fluxscroll").selectedIndex;
        fluxobj.rcbs[id] = rxncolorbreaks;
        fluxobj.rcs[id] = rxncolor;
    }

    if (Object.keys(graph).length > 0) {reDefineColors()}
    defineFluxColorBar()
}
function defineFluxColorBar() {
    var cv  = document.getElementById('fluxcolorbar'),
    ctx = cv.getContext('2d');
    ctx.clearRect(0, 0, cv.width, cv.height);
    step = (fluxmax - fluxmin) / 255;

    ctx.beginPath();
    colorvec = hexToRgb(document.getElementById("edgemin").value)
    var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
    ctx.fillStyle = color;
    ctx.fillRect(25, 0, 1, 20);
    for(var i = 1; i <= 254; i++) {
        ctx.beginPath();
        colorvec = hexToRgb(defineFluxColor(fluxmin + i*step))
        var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
        ctx.fillStyle = color;
        ctx.fillRect(i+25, 0, 1, 20);
    }
    ctx.beginPath();
    colorvec = hexToRgb(document.getElementById("edgemax").value)
    var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
    ctx.fillStyle = color;
    ctx.fillRect(i+25, 0, 1, 20);

    ctx.fillStyle = "black";
    for (var j = 0; j < rxncolorbreaks.length; j++) {
        ctx.fillText(rxncolorbreaks[j],(255*(rxncolorbreaks[j]-fluxmin)/(fluxmax-fluxmin))+25,30)
        ctx.textAlign="center";
    }
}

function addMetaboliteColorBreak(btn) {
    var input = document.createElement("input");
    input.type = "number";
    input.onclick="typing=true;";
    input.onfocus="typing=true;"
    input.className = "metbreakval";
    input.value = (concentrationmax + concentrationmin)/2
    input.onchange = function() {defineMetColorVectors()}

    var input2 = document.createElement("input");
    input2.type = "color";
    input2.className = "metbreakcol jscolor"
    input2.style = "margin: 0px 0px 0px 3px;"
    input2.onchange = function() {defineMetColorVectors()}

    var x = document.createElement("a")
    x.innerHTML = "X";
    x.style = "display: inline; margin: 0px 10px 0px 10px; padding: 4px;"
    x.onclick = function(){deleteMetColorBreak(this)}

    var br = document.createElement("br")

    btn.parentNode.insertBefore(input,btn)
    btn.parentNode.insertBefore(input2,btn)
    btn.parentNode.insertBefore(x,btn)
    btn.parentNode.insertBefore(br,btn)

    //defineMetColorVectors()
    //defineMetColorBar()
}
function deleteMetColorBreak(node) {
    node.previousSibling.previousSibling.remove()
    node.previousSibling.remove()
    node.nextSibling.remove()
    node.remove()
    defineMetColorVectors()
    defineMetColorBar()
}
function defineMetColorVectors() {

    metcolorbreaks = [concentrationmin, concentrationmax],
    metcolor = [hexToRgb(document.getElementById("metmin").value),hexToRgb(document.getElementById("metmax").value)]

    brks = document.getElementsByClassName("metbreakval");

    for (var i = 0; i < brks.length; i++) {
        if (Number(brks[i].value) > concentrationmax) {brks[i].value = concentrationmax}
        if (Number(brks[i].value) < concentrationmin) {brks[i].value = concentrationmin}
        metcolorbreaks.push(Number(brks[i].value))
        metcolor.push(hexToRgb(brks[i].nextSibling.value))
    }

    list = sortTwo(metcolorbreaks,metcolor)
    metcolorbreaks = list[0];
    metcolor = list[1];

    if (document.getElementById("concscroll") != null) {
        id = document.getElementById("concscroll").selectedIndex;
        concobj.mcbs[id] = metcolorbreaks;
        concobj.mcs[id] = metcolor;
    }

    if (Object.keys(graph).length > 0) {reDefineColors()}
    defineMetColorBar()
}
function defineMetColorBar() {
    var cv  = document.getElementById('metcolorbar'),
    ctx = cv.getContext('2d');
    ctx.clearRect(0, 0, cv.width, cv.height);
    step = (concentrationmax - concentrationmin) / 255;

    ctx.beginPath();
    colorvec = hexToRgb(document.getElementById("metmin").value)
    var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
    ctx.fillStyle = color;
    ctx.fillRect(25, 0, 1, 20);
    for(var i = 1; i <= 254; i++) {
        ctx.beginPath();
        colorvec = hexToRgb(defineFluxColorMet(concentrationmin + i*step))
        var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
        ctx.fillStyle = color;
        ctx.fillRect(i+25, 0, 1, 20);
    }
    ctx.beginPath();
    colorvec = hexToRgb(document.getElementById("metmax").value)
    var color = 'rgb(' + colorvec[0] + ', ' + colorvec[1] + ', ' + colorvec[2] + ')';
    ctx.fillStyle = color;
    ctx.fillRect(i+25, 0, 1, 20);

    ctx.fillStyle = "black";
    for (var j = 0; j < metcolorbreaks.length; j++) {
        ctx.fillText(metcolorbreaks[j],(255*(metcolorbreaks[j]-concentrationmin)/(concentrationmax-concentrationmin))+25,30)
        ctx.textAlign="center";
    }
}

function defineBackupGraph() {
    if (backupgraphcount > -1) {
        backupgraph.splice(0,backupgraphcount+1)
        backupgraphcount = -1;
    }
    var tmp = JSON.parse(JSON.stringify(graph))
    tmp.links.forEach(function(d){
        d.source = tmp.nodes[d.source.index]
        d.target = tmp.nodes[d.target.index]
    })
    backupgraph.unshift(tmp)
    if (backupgraph.length > 10) {backupgraph.pop()}
    backupparsing = false;
}
function getBackupGraphBack() {
    if (backupgraphcount == -1 && !backupparsing) {
        var tmp = JSON.parse(JSON.stringify(graph))
        tmp.links.forEach(function(d){
            d.source = tmp.nodes[d.source.index]
            d.target = tmp.nodes[d.target.index]
        })
        backupgraph.unshift(tmp)
        backupgraphcount++;
    }
    backupgraphcount++;
    if (backupgraphcount > backupgraph.length-1) {backupgraphcount--;return}
    graph = JSON.parse(JSON.stringify(backupgraph[backupgraphcount]))
    graph.links.forEach(function(d){
        d.source = graph.nodes[d.source.index]
        d.target = graph.nodes[d.target.index]
    })
    graph.nodes.forEach(function(d){d.selected = false; return d;})
    selected = [];
    reDefineSimulation()
    defineSuspended()
    backupparsing = true;
    parsedmodels[currentparsed] = graph;
}
function getBackupGraphForward() {
    backupgraphcount--;
    if (backupgraphcount < 0) {backupgraphcount = 0;return}
    graph = JSON.parse(JSON.stringify(backupgraph[backupgraphcount]))
    graph.links.forEach(function(d){
        d.source = graph.nodes[d.source.index]
        d.target = graph.nodes[d.target.index]
    })
    reDefineSimulation()
    defineSuspended()
    backupparsing = true;
    parsedmodels[currentparsed] = graph;
}

function addNoise() {
    node.filter(function(d) { return d.selected; })
    .each(function(d) { //d.fixed |= 2; 
        d.x = d.x + Math.random()/100;
        d.y = d.y + Math.random()/100;
        d.fx = d.x;
        d.fy = d.y;
    })
}

function sortTwo(vec1,vec2) {
    var list = [];
    for (var j = 0; j < vec1.length; j++) 
        list.push({'vec1': vec1[j], 'vec2': vec2[j]});

    list.sort(function(a, b) {return ((a.vec1 < b.vec1) ? -1 : ((a.vec1 == b.vec1) ? 0 : 1));});
    for (var k = 0; k < list.length; k++) {
        vec1[k] = list[k].vec1;
        vec2[k] = list[k].vec2;
    }
    return [vec1, vec2]
}

function lineFunctionBezi(d,currev,curstepx,curstepy) {
    if (d.stepnum == 0) {
        if (document.getElementById("reverseline").checked ? 
            linkedByID[d.id + "," + graph.nodes[selected[1]].id] : 
            linkedByID[graph.nodes[selected[1]].id + "," + d.id]) {
            d.bezi[0] = currev*curstepx/2;
            d.bezi[1] = currev*curstepy/2;
        } else {
            d.bezi[0] = -currev*curstepx/2;
            d.bezi[1] = -currev*curstepy/2;
        }
    } else if (d.stepnum == selected.length-2) {
        if (document.getElementById("reverseline").checked ? 
            linkedByID[graph.nodes[selected[selected.length-3]].id + "," + d.id] : 
            linkedByID[d.id + "," + graph.nodes[selected[selected.length-3]].id]) {
            d.bezi[0] = currev*curstepx/2;
            d.bezi[1] = currev*curstepy/2;
        } else {
            d.bezi[0] = -currev*curstepx/2;
            d.bezi[1] = -currev*curstepy/2;
        }
    } else {
        if (linkedByID[d.id + "," + graph.nodes[selected[d.stepnum-1]].id] && linkedByID[d.id + "," + graph.nodes[selected[d.stepnum+1]].id]) {
            d.bezi[0] = currev*curstepx;
            d.bezi[1] = -currev*curstepy;
        } else if (linkedByID[graph.nodes[selected[d.stepnum-1]].id + "," + d.id] && linkedByID[graph.nodes[selected[d.stepnum+1]].id + "," + d.id]) {
            d.bezi[0] = -currev*curstepx;
            d.bezi[1] = currev*curstepy;
        } else if (linkedByID[d.id + "," + graph.nodes[selected[d.stepnum + (document.getElementById("reverseline").checked ? 1 : -1)]].id]) {
            d.bezi[0] = currev*curstepx/2;
            d.bezi[1] = currev*curstepy/2;
        } else {
            d.bezi[0] = -currev*curstepx/2;
            d.bezi[1] = -currev*curstepy/2;
        }
    }
    d.bezi[2] = - d.bezi[0];
    d.bezi[3] = - d.bezi[1];
}

function manageTooltips(){
    node.attr("title",function(d) { 
        //return d.id;
        var str = [];
        for (j in d) {
            if (noshowttp.indexOf(j) == -1) {str.push(j + ": " + d[j])};
        }
        return str.join('<br>');

    })
    .attr("class","btn childnode");
    
    if (document.getElementById("tooltipbool").checked) {
        tpp = tippy('.btn', {
            delay: 0,
            arrow: true,
            arrowType: 'round',
            size: 'large',
            animation: 'scale',
            sticky: false,
        });
    } else if (tpp) {
        tpp.tooltips.forEach(function(d){d.destroy()})
    }
}
function manageArrows() {
    //Remove previous
    var x = document.getElementsByClassName("arrows");
    for (var i = x.length-1; i >=0; i--) {x[i].remove()}
    delete x

    if (document.getElementById("arrows").checked) {
        arrows = gDraw.append("g")
        .attr("class","arrows")
        .selectAll(".arrows")
        .data(graph.links)
        .enter().append("svg:path")
        .style("fill",defineLinkColor)
    } else {
        arrows = gDraw.append("g")
        .attr("class","arrows")
        .selectAll(".arrows")
        .data({})
        .enter().append("svg:path")
        .style("fill",defineLinkColor)
    }
    //Update
    if (node && link && text) {ticked()}
}

function groupNodes() {
    for (var i = 0; i < selected.length; i++) {
        for (var j = 0; j < graph.nodes[i].grouping.length; j++) {
            graph.nodes[graph.nodes[i].grouping[j]].grouping = [];
        }
    }
    var vec = [];
    for (var i = 0; i < selected.length; i++) {
        vec.push(graph.nodes[selected[i]].id)
    }
    selected.forEach(function(d){
        graph.nodes[d].grouping = vec;
    })
}
function unGroupNodes() {
    selected.forEach(function(d){
        graph.nodes[d].grouping = [];
        graph.nodes[d].selected = graph.nodes[d].previouslySelected = false;
    })
    node.classed("selected",function(d){return d.selected})
    selected = [];
}

function joinSubGraphs() {
    if(tracking){trackMet()}
    wd = openEdit()

    var a = document.createElement("a")
    a.innerHTML = "Name: ";
    var br = document.createElement("br");
    var input = document.createElement("input");
    input.onclick = function(){typing=true;};
    input.onfocus = function(){typing=true;};
    input.id = "jsgname";
    input.value = currentparsed;
    wd.appendChild(a);
    wd.appendChild(input);
    wd.appendChild(br);

    x = document.getElementById("onloadf1")
    for (var i = 0; i < x.childElementCount; i++) {
        if (x.children[i].value != currentparsed) {
            var check = document.createElement("input")
            check.type="checkbox";
            check.className = "jsgcheck";
            check.id = x.children[i].value;
            var br = document.createElement("br");
            var a = document.createElement("a")
            a.innerHTML = x.children[i].value;
            a.id = "AA" + x.children[i].value + "AA";
            wd.appendChild(check)
            wd.appendChild(a)
            wd.appendChild(br)
        }
    }

    var br = document.createElement("br");
    var btn = document.createElement("button")
    btn.onclick = function(){joinSubGraphs2();};
    btn.innerHTML = "Join"
    wd.appendChild(btn)
    wd.appendChild(br)

    a = document.createElement("a")
    a.innerHTML = "Join similar metabolites: ";

    checkbox = document.createElement("input")
    checkbox.type = "checkbox";
    checkbox.id = "joinjoinnodes";
    checkbox.checked = true;

    wd.appendChild(document.createElement("br"))
    wd.appendChild(a)
    wd.appendChild(checkbox)
}
function joinSubGraphs2() {
    cs = document.getElementsByClassName("jsgcheck")
    for (var ij = 0; ij < cs.length; ij++) {
        if (cs[ij].checked) {
            //name of subgraph to join
            var gr = cs[ij].id;

            //re-define selected
            graph.nodes.forEach(function(d){
                d.select = false;
                d.previouslySelected = false;
            })
            selected = [];
            
            //join
            nodefix = graph.nodes.length;
            linkfix = graph.links.length;
            parsedmodels[gr].nodes.forEach(function(d){
                d.index += nodefix;
                d.selected = true;
                d.previouslySelected = true;
                selected.push(d.index);
                graph.nodes.push(d);
            })
            parsedmodels[gr].links.forEach(function(l){
                l.index += linkfix;
                graph.links.push(l)
            })
            //merge suspended metabolites
            var broke = false;
            for (var j = 0; j < parsedmodels[gr].suspended.length; j++) {
                for (var i = 0; i < graph.suspended.length; i++) {
                    if (parsedmodels[gr].suspended[j][0] == graph.suspended[i][0]) {
                        graph.suspended[i].splice(1,0,...parsedmodels[gr].suspended[j].splice(1,parsedmodels[gr].suspended[j].length-2));
                        break
                    } else if (i == graph.suspended.length - 1) {
                        graph.suspended.push(parsedmodels[gr].suspended[j])
                    }
                }
            }

            //join nodes if possible
            if (document.getElementById("joinjoinnodes").checked){
                selected = [];
                for (var i = 0; i < graph.nodes.length; i++){
                    if (graph.nodes[i].group == 2) {
                        graph.nodes[i].selected = true;
                        selected.push(graph.nodes[i].index)
                    } else {
                        graph.nodes[i].selected = false;
                    }
                }
                joinMetabolite()
                graph.nodes.forEach(function(d){d.selected = false;})
                selected = [];

                //Re-select
                var tmp = [];
                parsedmodels[gr].nodes.forEach(function(d){tmp.push(d.class)})
                graph.nodes.forEach(function(d){
                    if (tmp.indexOf(d.class) != -1) {
                        d.selected = true;
                        d.previouslySelected = true;
                        selected.push(d.index);
                    }
                })
            }

            //delete graph
            delete parsedmodels[gr]
        }
    }
    
    //Update current graph
    gname = document.getElementById("jsgname").value;
    parsedmodels[gname] = JSON.parse(JSON.stringify(graph))
    graph = parsedmodels[gname]
    //make links
    parsedmodels[gname].links.forEach(function(l){
        l.source = parsedmodels[gname].nodes[l.source.index];
        l.target = parsedmodels[gname].nodes[l.target.index];
    })
    //delete previous name
    if (currentparsed != gname) {
        delete parsedmodels[currentparsed]
        currentparsed = gname;
    }
    reDefineSimulation()

    //update menu
    select = document.getElementById("onloadf1")
    while (select.childElementCount > 0) {select.children[0].remove()}
    var unique = Object.keys(parsedmodels)
    unique.sort()

    for (var i = 0; i < unique.length; i++) {
        var option = document.createElement("option")
        option.id = unique[i];
        option.innerHTML = unique[i];
        select.appendChild(option)
    }
    select.value = gname;

    //re-design menu
    joinSubGraphs()
}

function renameSubgraph() {
    if(tracking){trackMet()}
    wd = openEdit()

    input = document.createElement("input")
    input.type = "text";
    input.value = currentparsed;
    input.onkeydown = function(){renameSubgraphSupport(event,this)}
    input.onclick = function(){typing=true;};
    input.onfocus = function(){typing=true;};
    wd.appendChild(input)
}
function renameSubgraphSupport(e,d) {
    if (e.keyCode == 13){
        parsedmodels[d.value] = graph;
        delete parsedmodels[currentparsed];
        currentparsed = d.value;

        select = document.getElementById("onloadf1")
        var unique = Object.keys(parsedmodels);
        unique.sort()
        for (var i = 0; i < select.childElementCount; i++) {
            select.children[i].id = unique[i];
            select.children[i].innerHTML = unique[i]
        }
        select.value = d.value;
    }
}

function shortestPath(condition) {
    //if (selected.length != 2) {return;}
    var tempsel = selected.slice(),
    trupath = [];
    for (var i = 0; i < tempsel.length-1; i++) {
        selected = tempsel.slice(i,i+2);
        if (condition == "short") {
            var tmp = DFS(graph);
        } else if (condition == "long") {
            var tmp = DFSlong(graph);
        }
        for (var j = 0; j < tmp.length; j++) {
            if (trupath.indexOf(tmp[j]) == -1) {trupath.push(tmp[j])}
        }
    }

    if (trupath.length == 0) {
        return;
    } else {
        selected = trupath.slice();
        graph.nodes.forEach(function(d){
            d.selected = false;
            d.previouslySelected = false;
            return d;
        })
        selected.forEach(function(d){graph.nodes[d].selected = true; graph.nodes[d].previouslySelected = true;})
        node.classed("selected",function(d){return d.selected})
    }
}

function shortestCircle() {
    if (selected.length != 2) {return;}
    if (!isConnectedID(graph.nodes[selected[0]],graph.nodes[selected[1]])) {return;}

    if (linkedByID[graph.nodes[selected[0]].id + "," + graph.nodes[selected[1]].id]) {
        linkedByID[graph.nodes[selected[0]].id + "," + graph.nodes[selected[1]].id] = false;
        retstring = graph.nodes[selected[0]].id + "," + graph.nodes[selected[1]].id;
    } else {
        linkedByID[graph.nodes[selected[1]].id + "," + graph.nodes[selected[0]].id] = false;
        retstring = graph.nodes[selected[1]].id + "," + graph.nodes[selected[0]].id;
    }

    trupath = DFS(graph);
    
    if (trupath.length == 0) {
        return;
    } else {
        selected = trupath.slice();
        graph.nodes.forEach(function(d){
            d.selected = false;
            d.previouslySelected = false;
            return d;
        })
        selected.forEach(function(d){graph.nodes[d].selected = true; graph.nodes[d].previouslySelected = true;})
        node.classed("selected",function(d){return d.selected})
    }
    linkedByID[retstring] = true;
}

function DFS(fgraph) {
    var paths = [[selected[0]]];
    var terminate = false,
    stillgoing = false,
    tout = performance.now(),
    reached = [],
    trupath = [];

    while (true) {
        stillgoing = false;
        var newpaths = [];
        paths.forEach(function(p){
            fgraph.nodes.forEach(function(n){
                if (isConnectedID(fgraph.nodes[p[p.length-1]],n) && p.indexOf(n.index) == -1 && reached.indexOf(n.index) == -1 && !terminate){
                    stillgoing = true;
                    var np = p.slice();
                    reached.push(n.index)
                    np.push(n.index)
                    newpaths.push(np)
                    if (n.index == selected[1]) {
                        trupath = np.slice();
                        terminate = true;
                        return;
                    }
                }
            })
        })
        if (terminate) {
            return trupath;
        }
        if (!stillgoing || performance.now()-tout > 1000*Number(document.getElementById("shortpathtime").value)) {return trupath;}
        paths = newpaths;
    }
}
//var alllongpaths = [];
function DFSlong(fgraph) {
    var dfspaths = [[selected[0]]];
    var stillgoing = false,
    tout = performance.now(),
    trupath = [];

    while (true) {
        stillgoing = false;
        var dfsnewpaths = [];
        for (var i = 0; i < dfspaths.length; i++) {
            p = dfspaths[i];
            if (p.length == 0) {continue;}
            fgraph.nodes.forEach(function(n){
                if (isConnectedID(fgraph.nodes[p[p.length-1]],n) && p.indexOf(n.index) == -1){
                    stillgoing = true; 
                    np = p.slice();
                    np.push(n.index);
                    dfsnewpaths.push(np);
                    if (n.index == selected[1]) {
                        trupath = np.slice();
                    }
                }
            })
        }
        if (!stillgoing || performance.now()-tout > 1000*Number(document.getElementById("shortpathtime").value)) {return trupath;}
        var dfspaths = dfsnewpaths;
    }
}

function dragLabels() {
    if (document.getElementById("movelabels").checked) {
        text.style("pointer-events","auto")
        .style("cursor","pointer")
        .call(d3.drag()
            .on("drag", (d) => {
                d.labelshift[0] += d3.event.dx;
                d.labelshift[1] += d3.event.dy;
                text.selectAll("tspan").attr("x", function(d) {return d.x + d.labelshift[0];});
                text.selectAll("tspan").attr("y", function(d) {return d.y + d.labelshift[1];});
                return d;
            })
            .on("end", () => {
                text.selectAll("tspan").attr("x", function(d) {return d.x + d.labelshift[0];});
                text.selectAll("tspan").attr("y", function(d) {return d.y + d.labelshift[1];});
            }))
    } else {
        text.style("pointer-events","none")
    }
}

function reverseReactions() {
    graph.nodes.forEach(function(d) {
        if (d.selected && d.group == 1) {
            if (document.getElementById("reverseflux").checked) {
                d.reversed = -1*d.reversed;
            }

            if (d.bezi[0] != null) {d.bezi = d.bezi.map(x => -1 * x);}
            graph.links.forEach(function(l){
                if (l.source.id == d.id || l.target.id == d.id) {
                    if (l.source.id == d.id) {
                        l.source = l.target;
                        l.target = d;
                    } else if (l.target.id == d.id) {
                        l.target = l.source;
                        l.source = d;
                    }
                    if (document.getElementById("reverseflux").checked) {l.reversed = -1*l.reversed;}
                    return l;
                }
            })
            graph.suspended.forEach(function(l){
                id = l.indexOf(d.id + "t");
                if (id != -1) {
                    l[id] = d.id + "s";
                    return l;
                }
                id = l.indexOf(d.id + "s");
                if (id != -1) {
                    l[id] = d.id + "t";
                    return l;
                }
            })
            return d;
        }
    })
    reDefineColors();
    manageArrows()
}

function pretify() {
    var xp = Number(document.getElementById("pretify").value),
    first = true;
    var refpos;
    graph.nodes.forEach(function(d){
        if (d.selected && d.group == 1) {
            d.isfixed = true;
            d.selected = true;
            tcount = 0;
            scount = 0;
            d.bezi = [-xp/2,0,xp/2,0];
            if (first) {refpos = [d.x,d.y]; first = false;}
            d.x = refpos[0];
            d.y = refpos[1];
            d.fx = refpos[0];
            d.fy = refpos[1];
            graph.links.forEach(function(l){
                if (l.source.id == d.id) {
                    l.target.isfixed = true;
                    l.target.selected = true;
                    if (selected.indexOf(l.target.index) == -1) {selected.push(l.target.index)}
                    // if (!l.target.secondary) {
                        l.target.x = refpos[0] + xp;
                        l.target.fx = refpos[0] + xp;
                        l.target.y = refpos[1] - tcount*xp/2;
                        l.target.fy = refpos[1] - tcount*xp/2;
                        tcount++;
                    // } else {
                    //     l.target.isfixed = false;
                    //     l.target.fx = null;
                    //     l.target.fy = null;
                    // }
                    
                } else if (l.target.id == d.id) {
                    l.source.isfixed = true;
                    l.source.selected = true;
                    if (selected.indexOf(l.source.index) == -1) {selected.push(l.source.index)}
                    // if (!l.source.secondary) {
                        l.source.x = refpos[0] - xp;
                        l.source.fx = refpos[0] - xp;
                        l.source.y = refpos[1] - scount*xp/2;
                        l.source.fy = refpos[1] - scount*xp/2;
                        scount++;
                    // } else {
                    //     l.source.isfixed = false;
                    //     l.source.fx = null;
                    //     l.source.fy = null;
                    // }
                    
                }
            })
            refpos[1] -= xp/2 + Math.max(scount,tcount)*xp/2
        }
    })
    reDefineSimulation()
}

function deleteBezi() {
    graph.nodes.forEach(function(d){
        if (d.selected) {
            d.bezi = [null,null,null,null];
        }
    })
    ticked()
}

function scaleAll() {
    //Fix selected
    selected.forEach(function(index){
        graph.nodes[index].isfixed = true;
        graph.nodes[index].previouslySelected = true;
        graph.nodes[index].fx = graph.nodes[index].x;
        graph.nodes[index].fy = graph.nodes[index].y;
    })
    //Get minimum and maximum X
    if (selected.length < 2) {return;}
    var minx = graph.nodes[selected[0]].x;
    var maxx = minx;
    var miny = graph.nodes[selected[0]].y;
    var maxy = miny;
    for (i = 1; i < selected.length; i++) {
        d = selected[i];
        if (minx > graph.nodes[d].x) {minx = graph.nodes[d].x}
        if (maxx < graph.nodes[d].x) {maxx = graph.nodes[d].x}
        if (miny > graph.nodes[d].y) {miny = graph.nodes[d].y}
        if (maxy < graph.nodes[d].y) {maxy = graph.nodes[d].y}
    }

    //Define new node
    var newnode = Object.assign(newnodetemp("scalex",5),{
        class: "s",
        x: maxx,
        y: maxy,
        fx: maxx,
        fy: maxy,
        minx: minx,
        miny: miny,
        maxx: maxx,
        maxy: maxy,
        isfixed: true,
        selected: true,
        previouslySelected: true,
    })
    
    graph.nodes.push(newnode)

    scaling = true;

    reDefineSimulation()
    node.classed("selected",function(d){return d.selected})
}

function trackMet() {
    //If returning
    //if(tracking){trackMet()}
    if (tracking) {
        graph = parsedmodels[currentparsed];
        reDefineSimulation()
        tracking = !tracking;
        document.getElementById("trackmet").style.opacity = '1';
        return
    }
    //If more than one node selected, or if node is a reaction
    if (selected.length != 1 || graph.nodes[selected[0]].group == 1) {return;}

    //If tracking
    if (!tracking) {
        document.getElementById("trackmet").style.opacity = '0.2';
        //Re-define node and copy metabolite
        nstr = JSON.stringify(graph.nodes[selected[0]]);
        graph = {nodes: [],
            links: [],
            shapes: [],
            suspended: [],
            text: []
        };
        graph.nodes = [];
        graph.nodes.push(JSON.parse(nstr));
        graph.nodes[0].index = 0;
        graph.links = [];

        for (j in parsedmodels) {
            parsedmodels[j].links.forEach(function(l){
                if (l.source.class == graph.nodes[0].class) {
                    graph.links.push(JSON.parse(JSON.stringify(l)));
                    graph.links[graph.links.length-1].source = graph.nodes[0];
                    //graph.links[graph.links.length-1].target.index = graph.nodes.length;
                    var newnode = JSON.parse(JSON.stringify(graph.links[graph.links.length-1].target));
                    newnode.index = graph.nodes.length;
                    graph.links[graph.links.length-1].target = newnode;
                    graph.nodes.push(newnode);
                    graph.nodes[graph.nodes.length-1].class = graph.nodes[graph.nodes.length-1].class + ', ' + j;
                    graph.nodes[graph.nodes.length-1].jparse = j;
                } else if (l.target.class == graph.nodes[0].class) {
                    graph.links.push(JSON.parse(JSON.stringify(l)));
                    graph.links[graph.links.length-1].target = graph.nodes[0];
                    //graph.links[graph.links.length-1].source.index = graph.nodes.length;
                    var newnode = JSON.parse(JSON.stringify(graph.links[graph.links.length-1].source));
                    newnode.index = graph.nodes.length;
                    graph.links[graph.links.length-1].source = newnode;
                    graph.nodes.push(newnode);
                    graph.nodes[graph.nodes.length-1].class = graph.nodes[graph.nodes.length-1].class + ', ' + j;
                    graph.nodes[graph.nodes.length-1].jparse = j;
                }
            })
        }
    }
    graph.nodes.forEach(function(d){
        d.bezi = [null, null, null, null]; 
        d.fx = null;
        d.fy = null;
        d.isfixed = false;
        return d;
    })
    reDefineSimulation()
    node.filter(function(d){return d.group==1}).on("dblclick",function(d){
        var nodename = graph.nodes[0][document.getElementById("metNameOpts").value];
        graph = parsedmodels[currentparsed];
        var nd = document.getElementById("onloadf1")
        if (nd) {
            nd.value = d.jparse;
            onLoadSwitch(nd);
        }
        var e = {keyCode: 13};
        getSearchNodes(e,"^" + nodename + "$")
    })
    setTimeout(() => {
        selected = [];
        graph.nodes.forEach((d) => {
            if (d.group == 1) {
                d.selected = true;
                selected.push(d.index);
            } else {
                d.selected = false;
            }
            return d;
        })
        node.classed("selected",function(d){return d.selected})
        circle()
    },1000)
    tracking = !tracking
}

function behave() {    
    dragging = false,
    circling = false,
    vertlining = false,
    horzlining = false,
    diaglining = false,
    rotating = false,
    rotatinginit = false,
    rectangleinit = false,
    rectangle = false,
    beziering = false,
    typing = false,
    texting = false,
    shaping = false,
    checkchange = true,
    scaling = false,
    tracking = false;

    delfive()

    for (var i = 0; i < graph.nodes.length; i++) {
        graph.nodes[i].index = i;
        graph.nodes[i].selected = false;
        graph.nodes[i].previouslySelected = false;
    }
    selected = [];

    reDefineSimulation()
    simulation.alpha(0)
}
delfive  = () => {
    supnodes = [];
    graph.nodes.forEach(function(d){if (d.group == 5) {supnodes.push(d.index)}})
    for (var i = supnodes.length; i-- ; i >= 0) {
        delete graph.nodes.splice(supnodes[i],1);
    }
}

function autoBezi() {
    graph.nodes.filter(function(d){
        return d.selected && d.group == 1 && d.bezi[0] == null;
    }).forEach(function(d){
        //Initialize
        var inx = [],
        iny = [],
        outx = [],
        outy = [];

        //Get reaction metabolite position
        graph.links.forEach(function(l){
            if (l.target.id == d.id && !l.source.secondary) {
                inx.push(l.source.x)
                iny.push(l.source.y)
            } else if (l.source.id == d.id && !l.target.secondary) {
                outx.push(l.target.x)
                outy.push(l.target.y)
            }
        })

        //If no metabolites connecter return
        if (inx.length == 0 && outx.length == 0) {return;}

        //Calculate mean position and adjust by node position
        if (inx.length > 0) {
            inpos = [inx.reduce(function(a, b){ return a + b; })/inx.length, iny.reduce(function(a, b){ return a + b; })/iny.length];
            inpos[0] += 0.5*(d.x-inpos[0])
            inpos[1] += 0.5*(d.y-inpos[1])
        }
        if (outx.length > 0) {
            outpos = [outx.reduce(function(a, b){ return a + b; })/outx.length, outy.reduce(function(a, b){ return a + b; })/outy.length];
            outpos[0] += 0.5*(d.x-outpos[0])
            outpos[1] += 0.5*(d.y-outpos[1])
        }
        
        //If only reactants or products
        if (inx.length == 0) {
            d.bezi = [-outpos[0] + d.x, -outpos[1] + d.y, outpos[0] - d.x, outpos[1] - d.y];
            return d
        } else if (outx.length == 0) {
            d.bezi = [inpos[0] - d.x, inpos[1] - d.y, -inpos[0] + d.x, -inpos[1] + d.y];
            return d
        }

        //If both adjust
        var m = [(inpos[0]+outpos[0])/2, (inpos[1]+outpos[1])/2];
        var diff = [m[0]-d.x, m[1]-d.y];
        inpos[0] -= diff[0];
        inpos[1] -= diff[1];
        outpos[0] -= diff[0];
        outpos[1] -= diff[1];
        d.bezi = [inpos[0] - d.x, inpos[1] - d.y, outpos[0] - d.x, outpos[1] - d.y];
        return d;
    })

    reDefineSimulation()
    simulation.alpha(0)
}
//Depth first search with ties
function DFSall(fgraph) {
    var paths = [[selected[0]]];
    var terminate = false,
    stillgoing = false,
    tout = performance.now(),
    reached = [],
    trupath = [];

    while (true) {
        stillgoing = false;
        var newpaths = [];
        paths.forEach(function(p){
            fgraph.nodes.forEach(function(n){
                if (isConnectedID(fgraph.nodes[p[p.length-1]],n) && p.indexOf(n.index) == -1 && reached.indexOf(n.index) == -1){
                    stillgoing = true;
                    var np = p.slice();
                    reached.push(n.index)
                    np.push(n.index)
                    newpaths.push(np)
                    if (n.index == selected[1]) {
                        trupath.push(np.slice());
                        terminate = true;
                        reached.pop();
                    }
                }
            })
        })
        if (terminate) {
            return trupath;
        }
        if (!stillgoing || performance.now()-tout > 1000*Number(document.getElementById("shortpathtime").value)) {return trupath;}
        paths = newpaths;
    }
}

function getComponent() {
    //deselect
    graph.nodes.forEach(function(d){
        d.selected = false;
        d.previouslySelected = false;
    })
    //Get pairwise shortest paths (with ties) and select
    var tempsel = selected.slice();
    selected = [];
    for (var i = 0; i < tempsel.length-1; i++) {
        for (var j = i+1; j < tempsel.length; j++) {
            selected = [tempsel[i],tempsel[j]];
            var tmp = DFSall(graph);
            tmp.forEach(function(p){
                p.forEach(function(n){
                    graph.nodes[n].selected = true;
                    graph.nodes[n].previouslySelected = true;
                })
            })
        }
    }
    //Get associated metabolites as well
    graph.nodes.filter(function(d){return d.group == 1 && d.selected})
    .forEach(function(d){
        graph.links.forEach(function(l){
            if (l.target.index == d.index) {
                l.source.selected = true;
                l.source.previouslySelected = true;
            } else if (l.source.index == d.index) {
                l.target.selected = true;
                l.target.previouslySelected = true;
            }
        })
    })
    //redefine selected
    selected = [];
    graph.nodes.filter(function(d){return d.selected})
    .forEach(function(d){selected.push(d.index)})
    //redefine
    reDefineSimulation()
    simulation.alpha(0)
}

function loadWrapper(id) {
    while (document.getElementById(id)) {document.getElementById(id).remove()}
    div = document.getElementsByClassName("center")[0];
    var input = document.createElement("input");
    input.style = "display:none;"
    input.type = 'file';
    input.id = 'loadwrap';
    if (id == "fileinput") {
        input.id='fileinput';
        input.onchange = function(){
            onloadfilter=false;
            setdisplay();
            loadFile();
        }
    } else if (id == "fileinput2") {
        input.id='fileinput2';
        input.onchange = function(){
            onloadfilter=true;
            loadFile2();
        }
    } else if (id == "fileinputsammi") {
        input.id='fileinputsammi';
        input.onchange = function(){
            setdisplay();
            loadFileSammi();
        }
    } else if (id == "filefilter") {
        input.id = "filefilter";
        input.multiple = true;
        input.onchange = function() {
            setdisplay();
            loadFilterFiles();
        }
    } else if (id == 'fileinputflux') {
        input.id = 'fileinputflux';
        input.onchange = function() {
            loadFileFlux();
        }
    } else if (id == 'fileinputconcentration') {
        input.id = 'fileinputconcentration';
        input.onchange = function() {
            loadFileConcentration();
        }
    } else if (id == 'fileinputsizerxn') {
        input.id = 'fileinputsizerxn';
        input.onchange = function() {
            loadFileSizeRxn();
        }
    } else if (id == 'fileinputsizemet') {
        input.id = 'fileinputsizemet';
        input.onchange = function() {
            loadFileSizeMet();
        }
    } else if (id == 'fileinputwidth') {
        input.id = 'fileinputwidth';
        input.onchange = function() {
            loadFileWidth();
        }
    } else if (id == 'fileinputsecondary') {
        input.id = 'fileinputsecondary';
        input.onchange = function() {
            loadFileSecondary();
        }
    }
    else if (id == 'fileinputgene') {
        input.id = 'fileinputgene';
        input.onchange = function() {
            return loadFileGene();
        }
    }
    div.appendChild(input);
    input.click();
}

function openDocs(pg) {
    a = document.createElement("a");
    if (pg == "documentation") {
        a.href = "https://sammim.readthedocs.io/en/latest/index.html"; 
    }
    a.target = "_blank";
    div = document.getElementById("blankdiv");
    div.appendChild(a);
    a.click();
    a.remove()
}

function checkSizeLimits(cond) {
    if (cond == "maxrxnsize" && maxrxnsize < minrxnsize) {
        maxrxnsize = minrxnsize;
        document.getElementById("maxrxnsize").value = maxrxnsize;
    }
    if (cond == "minrxnsize" && minrxnsize > maxrxnsize) {
        minrxnsize = maxrxnsize;
        document.getElementById("minrxnsize").value = minrxnsize;
    }
    if (cond == "maxmetsize" && maxmetsize < minmetsize) {
        maxmetsize = minmetsize;
        document.getElementById("maxmetsize").value = maxmetsize;
    }
    if (cond == "minmetsize" && minmetsize > maxmetsize) {
        minmetsize = maxmetsize;
        document.getElementById("minmetsize").value = minmetsize;
    }
    if (cond == "minwidth" && minwidth > maxwidth) {
        minwidth = maxwidth;
        document.getElementById("minwidth").value = minwidth;
    }
    if (cond == "maxwidth" && maxwidth < minwidth) {
        maxwidth = minwidth;
        document.getElementById("maxwidth").value = maxwidth;
    }
    reDefineSimulation()
    simulation.alpha(0)
    if (document.getElementById("sizeref").checked) {drawSizeReference();}
}

function drawSizeReference() {
    if (document.getElementById("sizeref").checked) {
        if (typeof sscale !== 'undefined') {sscale.remove()}
        // if (typeof reftext !== 'undefined') {reftext.remove();}
        // if (typeof reftext2 !== 'undefined') {reftext2.remove();}
        // if (typeof reftext3 !== 'undefined') {reftext3.remove();}
        // if (typeof reflink !== 'undefined') {reflink.remove();}

        r1 = minmetsize*Number(document.getElementById("metsizescale").value);
        r2 = maxmetsize*Number(document.getElementById("metsizescale").value);
        r3 = minrxnsize*Number(document.getElementById("rxnsizescale").value);
        r4 = maxrxnsize*Number(document.getElementById("rxnsizescale").value);
        mr = Math.max(r1,r2,r3,r4);
        ht = text.node().getBBox().height+2;
        pos = curtr;
        pos[0]+=2;
        tr = [(-pos[0]/pos[2])+mr+5, (-pos[1]/pos[2])+ht+5];
        sminw = minwidth*document.getElementById("widthscale").value;
        smaxw = maxwidth*document.getElementById("widthscale").value;
        mlp = (tr[1]+(2*r1)+(2*r2)+(2*r3)+(2*r4)+22+(2*ht)+(sminw/2))
        
        
        refdata = {
            "references": [
                {
                    cx: tr[0],
                    cy: tr[1]+r1,
                    x: tr[0]-r1,
                    y: tr[1],
                    r: r1,
                    width: 2*r1,
                    height: 2*r1,
                    label: minmetsize,
                    shape: document.getElementById("metshape").value
                },
                {
                    cx: tr[0],
                    cy: tr[1]+(2*r1)+r2+3,
                    x: tr[0] - r2,
                    y: tr[1]+(2*r1)+3,
                    r: r2,
                    width: 2*r2,
                    height: 2*r2,
                    label: maxmetsize,
                    shape: document.getElementById("metshape").value
                },
                {
                    cx: tr[0],
                    cy: tr[1]+(2*r1)+(2*r2)+r3+10+ht,
                    y: tr[1]+(2*r1)+(2*r2)+10+ht,
                    x: tr[0]-r3,
                    r: r3,
                    width: 2*r3,
                    height: 2*r3,
                    label: minrxnsize,
                    shape: document.getElementById("rxnshape").value
                },
                {
                    cx: tr[0],
                    cy: tr[1]+(2*r1)+(2*r2)+(2*r3)+r4+13+ht,
                    x: tr[0]-r4,
                    y: tr[1]+(2*r1)+(2*r2)+(2*r3)+13+ht,
                    r: r4,
                    width: 2*r4,
                    height: 2*r4,
                    label: maxrxnsize,
                    shape: document.getElementById("rxnshape").value
                }
            ],
        "links": [
                {
                    path: "M" + (tr[0]-mr+2) + "," + mlp + "L" + (tr[0]+mr) + "," + mlp,
                    width: sminw,
                    cx: tr[0]+mr+3,
                    cy: mlp,
                    label: minwidth
                },
                {
                    path: "M" + (tr[0]-mr+2) + "," + (mlp+(sminw/2)+(smaxw/2)+4) + "L" + (tr[0]+mr) + "," + (mlp+(sminw/2)+(smaxw/2)+4),
                    width: smaxw,
                    cx: tr[0]+mr+3,
                    cy: mlp+(sminw/2)+(smaxw/2)+4,
                    label: maxwidth
                }
            ],
        "titles": [
                {
                    cx: tr[0],
                    cy: tr[1]-ht,
                    label: "Metabolites"
                },
                {
                    cx: tr[0],
                    cy: tr[1]+(2*r1)+(2*r2)+10,
                    label: "Reactions"
                },
                {
                    cx: tr[0],
                    cy: tr[1]+(2*r1)+(2*r2)+(2*r3)+(2*r4)+20+(ht),
                    label: "Links"
                }
            ]
        }
        sscale = gDraw.append('g')
            .attr("id","sscale");

        ref = sscale.append("g")
            .selectAll("#sscale")
            .data(refdata.references)
            .enter()

        rectref = ref.filter(function(d){return d.shape == "rect"})
        .append("rect")
            .attr("x",function(d){return d.x})
            .attr("y",function(d){return d.y})
            .attr("width",function(d){return d.width})
            .attr("height",function(d){return d.height})
            .attr("fill","white")
            .attr("stroke","black")
            .attr("stroke-width",2);
        
        circleref = ref.filter(function(d){return d.shape == "circle"})
        .append("circle")
            .attr("cx", function(d){return d.cx;})
            .attr("cy", function(d){return d.cy;})
            .attr("r", function(d){return d.r;})
            .attr("fill","white")
            .attr("stroke","black")
            .attr("stroke-width",2);

        reftext = sscale.append("g")
            .selectAll("text")
            .data(refdata.references)
            .enter().append("text")
            .style("font-size", document.getElementById("labelsize").value + "px")
            .attr("x",function(d){return d.cx + mr + 3})
            .attr("y",function(d){return d.cy})
            .attr("alignment-baseline", "central")
            .style("pointer-events","none")
            .text(function(d) {return d.label});

        reftext2 = sscale.append("g")
            .selectAll("text")
            .data(refdata.titles)
            .enter().append("text")
            .style("font-size", document.getElementById("labelsize").value + "px")
            .attr("x",function(d){return d.cx})
            .attr("y",function(d){return d.cy})
            .attr("alignment-baseline", "hanging")
            .style("pointer-events","none")
            .text(function(d) {return d.label});

        reftext3 = sscale.append("g")
            .selectAll("text")
            .data(refdata.links)
            .enter().append("text")
            .style("font-size", document.getElementById("labelsize").value + "px")
            .attr("x",function(d){return d.cx})
            .attr("y",function(d){return d.cy})
            .attr("alignment-baseline", "central")
            .style("pointer-events","none")
            .text(function(d) {return d.label});

        reflink = sscale.append("g")
            .selectAll("line")
            .data(refdata.links)
            .enter().append("svg:path")
                .attr("stroke-width",function(d){return d.width})
                .attr("d",function(d){return d.path})
                .style("stroke","#000000");
    } else {
        if (typeof sscale !== 'undefined') {sscale.remove()}
    }
    
}

function makeColorScaleGlobal(cs) {
    if (cs == "rxn") {
        id = document.getElementById("fluxscroll").selectedIndex;
        for (var i = 0; i < fluxobj.ttls.length; i++) {
            fluxobj.rcbs[i] = fluxobj.rcbs[id];
            fluxobj.rcs[i] = fluxobj.rcs[id];
        }
    } else if (cs = "met"){
        id = document.getElementById("concscroll").selectedIndex;
        for (var i = 0; i < concobj.ttls.length; i++) {
            concobj.mcbs[i] = concobj.mcbs[id];
            concobj.mcs[i] = concobj.mcs[id];
        }
    }
}

function removeData(id) {
    x = document.getElementById(id);
    if (x == null) {return;}
    x.previousElementSibling.remove()
    x.previousElementSibling.remove()
    if (x.previousElementSibling != null) {x.previousElementSibling.remove()}
    x.nextElementSibling.remove()
    x.nextElementSibling.remove()
    x.remove()
    if (id == 'fluxscroll') {
        graph.nodes.forEach(function(d){d.flux = null; return d;})
        graph.links.forEach(function(d){d.flux = null; return d;})
        fluxobj = {};
    } else if (id == 'concscroll') {
        graph.nodes.forEach(function(d){d.concentration = null; return d;})
        concobj = {};
    } else if (id == 'rxnsizescroll') {
        graph.nodes.filter(function(d){return d.group == 1;}).forEach(function(d){d.size = null; return d;})
        sizerxnobj = {};
    } else if (id == 'metsizescroll') {
        graph.nodes.filter(function(d){return d.group == 2;}).forEach(function(d){d.size = null; return d;})
        sizemetobj = {};
    } else if (id == 'widthscroll') {
        graph.links.forEach(function(l){l.width = null; return l;})
        linkwidthobj = {};
    }
    reDefineSimulation()
    simulation.alpha(0)
}

function selectOpenMenu(btn) {
    tmp = document.getElementsByClassName("dropdown-content");
    if (btn) {var prev = btn.nextElementSibling.style.display;}
    for (var i = 0; i < tmp.length; i++ ) {
        tmp[i].style="display:none;"
        tmp[i].previousElementSibling.style.backgroundColor = "#fff";
        tmp[i].previousElementSibling.onmouseover = function() {this.style.backgroundColor = "#ddd";};
        tmp[i].previousElementSibling.onmouseout = function() {this.style.backgroundColor = "#fff";};

    }
    if (btn) {
        if (prev === "block") {
            btn.nextElementSibling.style.display = "none";
            btn.style.backgroundColor = "#fff";
            btn.onmouseout = function() {this.style.backgroundColor = "#fff";};
        } else {
            btn.nextElementSibling.style.display = "block";
            btn.style.backgroundColor = "#ddd";
            btn.onmouseout = function() {};
        }
        btn.onmouseover = function() {this.style.backgroundColor = "#ddd";};
    }
}

function loadKEGGmodel2(org) {
    document.body.style.cursor = "wait";
    $.getJSON("KEGG/KEGGrxns.json", function (data) {
        allrxns = data;
        $.getJSON("KEGG/KEGGmets.json", function (data1) {
            allmets = data1;
            $.getJSON("KEGG/mapFiles/"+org+".json", function (data2) {
                tmp = data2;
                setdisplay()
                var maps = Object.keys(tmp);
                //Add additional data
                for (var i = 0; i < maps.length; i++) {
                    var localmets = [];
                    for (var j = 0; j < tmp[maps[i]]["reactions"].length; j++) {
                        mets = Object.keys(tmp[maps[i]]["reactions"][j].metabolites);
                        for (var k = 0; k < mets.length; k++) {
                            if (localmets.indexOf(mets[k]) == -1) {localmets.push(mets[k])}
                        }

                        if (allrxns[tmp[maps[i]]["reactions"][j].class]) {
                            Object.assign(tmp[maps[i]]["reactions"][j],
                            allrxns[tmp[maps[i]]["reactions"][j].class],{"upper_bound":10})
                        }
                    }
                    tmp[maps[i]]["metabolites"] = [];
                    for (var j = 0; j < localmets.length; j++) {
                        var id = localmets[j].replace(/_[0-9]*$/,"")
                        id = id.replace(/cpd:/,"")
                        if(allmets[id]) {
                            tmp[maps[i]]["metabolites"].push(Object.assign({
                                "id":localmets[j],
                                "class":id}, allmets[id]))
                        } else {
                            tmp[maps[i]]["metabolites"].push({
                                "id":localmets[j],
                                "class":id})
                        }
                    }
                }
                //Make them into SAMMI format
                var place = document.getElementById("onloadoptions");
                var select = document.createElement("select");
                select.id = "onloadf1";
                place.appendChild(select);
                select.style.visibility = "hidden";
                for (var i = 0; i < maps.length; i++) {
                    graph = {
                        nodes: [],
                        links: [],
                        suspended: [],
                        text: [],
                        shapes: []
                    };

                    for(var j = 0; j < tmp[maps[i]].metabolites.length; j++) {
                        var newnode = Object.assign(tmp[maps[i]].metabolites[j],{
                            index: j,
                            group: 2,
                            secondary: false,
                            flux: null,
                            size: null,
                            trap: -1,
                            concentration: null,
                            bezi: [null, null, null, null],
                            labelshift: [0,0],
                            grouping: [],
                            reversed: 1,
                            width: null,
                            isfixed: false
                        });
                        graph.nodes.push(newnode)
                    }

                    linkcount = 0;
                    for (var j = 0; j < tmp[maps[i]].reactions.length; j++) {
                        var newnode = Object.assign(tmp[maps[i]].reactions[j],{
                            index: tmp[maps[i]].metabolites.length + j,
                            group: 1,
                            secondary: false,
                            flux: null,
                            size: null,
                            trap: -1,
                            concentration: null,
                            bezi: [null, null, null, null],
                            labelshift: [0,0],
                            grouping: [],
                            reversed: 1,
                            width: null,
                            isfixed: false
                        });                        
                        graph.nodes.push(newnode)
                
                        for (var k in newnode.metabolites) {
                            var newlink = {index: linkcount, flux: null, refx: 0, refy: 0, width: null, reversed: 1}
                            linkcount++;
                            for (var l = 0; l < graph.nodes.length; l++){
                                if (graph.nodes[l].id == k) {
                                    if (newnode.metabolites[k] < 0) {
                                        newlink.source = graph.nodes[l];
                                        newlink.target = graph.nodes[graph.nodes.length-1];
                                    } else {
                                        newlink.target = graph.nodes[l];
                                        newlink.source = graph.nodes[graph.nodes.length-1];
                                    }
                                    graph.links.push(newlink)
                                    break;
                                }
                            }
                        }
                    }
                    defineNameOptions()

                    maps[i] = maps[i].replace(/\..*$/i,"") + " (" + org + ")";
                    parsedmodels[maps[i]] = graph;

                    var option = document.createElement("option")
                    option.innerHTML = maps[i];
                    option.id = maps[i];
                    select.appendChild(option)
                }
                currentparsed = maps[0];
                graph = parsedmodels[currentparsed];

                a = document.createElement("a")
                a.innerHTML = "&#8249";
                a.className = "scrollopts";
                a.onclick = function(){previousScroll("onloadf1")}
                place.appendChild(a)
                a = document.createElement("a")
                a.innerHTML = "&#8250";
                a.className = "scrollopts";
                a.onclick = function(){nextScroll("onloadf1")}
                place.appendChild(a)
                select.style.visibility = "visible";
                select.onchange = function (){onLoadSwitch(this)}
            
                loadExistingReactionToAdd(parsedmodels)
                loadInitialGraph()
                reDefineSimulation()
            });
        });
    });
    document.body.style.cursor = "auto";
}

loadKEGG = () => {
    document.getElementById("onloadKEGG").style.display = "block";
    for (var k = 0; k < document.getElementsByClassName("topopt").length; k++) {
        document.getElementsByClassName("topopt")[k].style="display:none;";
    }
    for (var k = 0; k < document.getElementsByClassName("topbr").length; k++) {
        document.getElementsByClassName("topbr")[k].style="display:none;";
    }
    $.getJSON("KEGG/allOrgs.json", function (data) {
        autocomplete2(document.getElementById("KEGGorgs"), data);
    })
}

loadKEGGmodel = (e) => {
    //if (e.keyCode == 13) {
        document.getElementById("KEGGorgs").onkeydown = () => {console.log("Give it a minute")}
        setTimeout(function() {
            var org = document.getElementById("KEGGorgs").value;
            org = org.match(/\(([a-z]{3,4})\) \(T[0-9]*\)$/)
            org = org[1]
            loadKEGGmodel2(org)
        },200)
    //}
}

function toDataUrl(src, callback, outputFormat) {
    // Create an Image object
    var img = new Image();
    // Add CORS approval to prevent a tainted canvas
    img.crossOrigin = 'Anonymous';
    img.onload = function() {
      // Create an html canvas element
      var canvas = document.createElement('CANVAS');
      // Create a 2d context
      var ctx = canvas.getContext('2d');
      var dataURL;
      // Resize the canavas to the original image dimensions
      canvas.height = 250;
      canvas.width = 494;
      // Draw the image to a canvas
      ctx.drawImage(this, 10, 10, 474, 230);
      // Convert the canvas to a data url
      dataURL = canvas.toDataURL(outputFormat);
      // Return the data url via callback
      callback(dataURL);
      // Mark the canvas to be ready for garbage 
      // collection
      canvas = null;
    };
    // Load the image
    img.src = src;
    // make sure the load event fires for cached images too
    if (img.complete || img.complete === undefined) {
      // Flush cache
      img.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==';
      // Try again
      img.src = src;
    }
  }

shelveStandard = () => {
    //Open dialog
    wd = openEdit()

    var smet = ["h","h2o","nad","nadh","nadp","nadph","atp","adp","pi","na1","o2","co2",
    "nh4","coa","fad","fadh2","ppi","amp","q10","q10h2","cl","gtp","gdp","dadp","datp"];
    smet = smet.sort();

    select = document.createElement("select");
    select.id = "compann";
    var option = document.createElement("option");
    option.value = "_.";
    option.innerHTML = "_.";
    select.appendChild(option);
    var option = document.createElement("option");
    option.value = "\\[.\\]";
    option.innerHTML = "[.]";
    select.appendChild(option);
    
    p = document.createElement("p");
    p.innerHTML = "Select Compartment Annotation:";
    p.style = "font-weight: bold;"
    wd.appendChild(p);
    wd.appendChild(select)

    p = document.createElement("p");
    p.innerHTML = "Select Metabolites to Shelve:";
    p.style = "font-weight: bold;"
    wd.appendChild(p);

    btn = document.createElement("button");
    btn.className = "menubutton";
    btn.style = "width: 120px;"
    btn.innerHTML = "Check/Uncheck All";
    btn.onclick = () => {shelveStandard3()}
    wd.append(btn)

    br = document.createElement("br")
    wd.append(br)

    for (var i = 0; i < smet.length; i++) {
        var cbx = document.createElement("input");
        cbx.type="checkbox";
        cbx.className = "shelvelist";
        cbx.setAttribute("value",smet[i]);
        p = document.createElement("a");
        p.innerHTML = smet[i];
        br = document.createElement("br")
        wd.append(cbx);
        wd.append(p)
        wd.append(br)
    }

    btn = document.createElement("button");
    btn.className = "menubutton";
    btn.innerHTML = "Shelve";
    btn.onclick = () => {shelveStandard2()}
    wd.append(btn)
}

shelveStandard2 = () => {
    var bxs = document.getElementsByClassName("shelvelist");
    e = '(?:';
    comp = document.getElementById("compann").value;
    for (var i = 0; i < bxs.length; i++) {
        if (bxs[i].checked) {
            e = e + "^" + bxs[i].value + comp + '$)|(?:';
        }
    }
    e = e.replace(/\$\)\|\(\?\:$/,')');
    shelveList(e)
}

shelveStandard3 = () => {
    var bxs = document.getElementsByClassName("shelvelist");
    var bl = !bxs[0].checked;
    for (var i = 0; i < bxs.length; i++) {
        bxs[i].checked = bl;
    }
}

function shelveList(vec) {

    var re = new RegExp(vec, "i");
    selected = [];

    for (j in parsedmodels) {
        //select right ones
        for (var i = parsedmodels[j].nodes.length-1; i > -1; i--) {
            var d = parsedmodels[j].nodes[i];
            if (re.test(d.class) && d.group == 2 ){
                var linktodel = [];
                var cursel = [d.id];

                for (var k = 0; k < parsedmodels[j].links.length; k++){
                    if (parsedmodels[j].links[k].target.id == d.id) {
                        linktodel.push(parsedmodels[j].links[k].index);
                        cursel.push(parsedmodels[j].links[k].source.id + "t")
                    } else if (parsedmodels[j].links[k].source.id == d.id) {
                        linktodel.push(parsedmodels[j].links[k].index);
                        cursel.push(parsedmodels[j].links[k].target.id + "s")
                    }
                }
                cursel.push(JSON.stringify(d))
                parsedmodels[j].suspended.push(cursel);

                for (var k = linktodel.length - 1; k > -1; k--){
                    parsedmodels[j].links.splice(linktodel[k],1)
                }

                parsedmodels[j].nodes.splice(d.index,1)
    
                for (var k = 0; k < parsedmodels[j].links.length; k++){
                    parsedmodels[j].links[k].index = k;
                }
                for (var k = 0; k < parsedmodels[j].nodes.length; k++){
                    parsedmodels[j].nodes[k].index = k;
                }
            } 
        }
    }

    defineSuspended()
    reDefineSimulation()
    node.classed("selected",function(d){return d.selected})
    simulation.restart()
}

selectConnected = () => {
    graph.nodes.filter(function(d){return d.selected})
    .forEach(function(d){
        graph.nodes.forEach(function(l) {
            if (isConnectedID(d,l)) {
                l.selected = true;
                if (selected.indexOf(l.index) == -1) {selected.push(l.index)}
            }
        })
    })
    reDefineSimulation()
    simulation.alpha(0)
}


collapse = () => {
    //Get only selected reactions
    graph.nodes.filter(function(d){return d.group == 2}).forEach(function(d){d.selected = false})
    //Select their metabolites
    selectConnected()
    //Go through metabolite nodes and get ones to remove
    torm = [];
    graph.nodes.filter(function(d){return d.selected && d.group == 2}).forEach(function(n){
        var vec = graph.links.filter(function(l){return l.source.id == n.id}).map(function(x){return x.target.selected}).concat(
        graph.links.filter(function(l){return l.target.id == n.id}).map(function(x){return x.source.selected}));
        if (vec.every(function(n){return n})) {torm.push(n.id)}
    })
    //remove links
    vec = graph.links.filter(function(n){return torm.indexOf(n.source.id) != -1 || torm.indexOf(n.target.id) != -1}).map(function(n){return n.index}).reverse()
    vec.forEach(function(n){graph.links.splice(n,1)})
    for (i = 0; i < graph.links.length; i++) {graph.links[i].index = i}
    //remove nodes
    vec = graph.nodes.filter(function(d){return torm.indexOf(d.id) != -1}).map(function(d){return d.index}).reverse()
    vec.forEach(function(n){graph.nodes.splice(n,1)})
    for (i = 0; i < graph.nodes.length; i++) {graph.nodes[i].index = i}
    //make new node
    var newnode = Object.assign(newnodetemp("NewNode" + count,5),{class: "collapsed",group: 1});
    graph.nodes.push(newnode);
    newnode = graph.nodes[graph.nodes.length-1];
    count++;
    //connect links to new node
    torm = [];
    graph.links.forEach(function(n){
        if (n.source.selected && n.source.group == 1) {
            if (isConnectedID(newnode,n.target)) {
                torm.push(n.index)
            } else {
                n.source = newnode;
                redefineLBID()
            }
            return;
        }
        if (n.target.selected && n.target.group == 1) {
            if (isConnectedID(newnode,n.source)) {
                torm.push(n.index)
            } else {
                n.target = newnode;
                redefineLBID()
            }
            return;
        }
    })
    //remove repeated ones
    torm.reverse().forEach(function(n){graph.links.splice(n,1)})
    for (i = 0; i < graph.links.length; i++) {graph.links[i].index = i}
    //Remove reactions
    var tmpx = 0,
    tmpy = 0,
    tmp = 0;
    for (i = graph.nodes.length-1; i >= 0; i--) {
        if (graph.nodes[i].selected && graph.nodes[i].group == 1) {
            tmpx += graph.nodes[i].x;
            tmpy += graph.nodes[i].y;
            tmp++
            graph.nodes.splice(i,1);
        }
    }
    for (i = 0; i < graph.nodes.length; i++) {graph.nodes[i].index = 1}
    newnode.x = tmpx/tmp;
    newnode.y = tmpy/tmp;
    //Select
    graph.nodes.forEach(function(d){d.selected = false})
    graph.nodes[graph.nodes.length-1].selected = true;
    selected = [graph.nodes.length-1];
    //Re-define
    reDefineSimulation()
    simulation.alpha(0)
    editNodeProperties(graph.nodes[selected[0]])
}
redefineLBID = () => {
    linkedByID = {};
    graph.links.forEach(function(d) {
    linkedByID[d.source.id + "," + d.target.id] = true;
    });
}
loadGeneData = () => {
    wd = openEdit()
    //Field
    field = document.createElement('input');
    field.onfocus = function(){typing=true;};
    field.id = 'gexfield'
    field.value = 'gene_reaction_rule';
    a = document.createElement('a');
    a.text = 'Gene Expression Rule Field:'
    a.style = "font-weight: bold;"
    wd.append(a)
    wd.append(document.createElement('br'))
    wd.append(field)
    wd.append(document.createElement('br'))
    //Split
    field = document.createElement('input');
    field.onfocus = function(){typing=true;};
    field.id = 'gexsplit'
    field.value = 'and;or';
    a = document.createElement('a');
    a.text = 'Regular Expressions to split:'
    a.style = "font-weight: bold;"
    wd.append(a)
    wd.append(document.createElement('br'))
    wd.append(field)
    wd.append(document.createElement('br'))
    //Split
    field = document.createElement('input');
    field.onfocus = function(){typing=true;};
    field.id = 'gexrem'
    field.value = '_AT[0-9]*;\\(;\\)';
    a = document.createElement('a');
    a.text = 'Regular Expressions to remove:'
    a.style = "font-weight: bold;"
    wd.append(a)
    wd.append(document.createElement('br'))
    wd.append(field)
    wd.append(document.createElement('br'))
    //Calculate by
    a = document.createElement('a');
    a.text = 'Select mapping function:'
    a.style = "font-weight: bold;"
    wd.append(a)
    wd.append(document.createElement('br'))

    select = document.createElement('select');
    select.id = 'gexmap';

    option = document.createElement('option');
    option.value = 'Max';
    option.innerHTML = 'Max';
    select.append(option)

    option1 = document.createElement('option');
    option1.value = 'Min';
    option1.innerHTML = 'Min';
    select.append(option1)

    option2 = document.createElement('option');
    option2.value = 'Mean';
    option2.innerHTML = 'Mean';
    select.append(option2)

    option3 = document.createElement('option');
    option3.value = 'Median';
    option3.innerHTML = 'Median';
    select.append(option3)
    wd.append(select)
    wd.append(document.createElement('br'))
    //Run
    a = document.createElement('a');
    a.text = 'Map data:'
    a.style = "font-weight: bold;"
    wd.append(a)
    wd.append(document.createElement('br'))
    button = document.createElement('button');
    button.innerHTML = 'Map';
    button.onclick =  () => {loadWrapper("fileinputgene")}
    wd.append(button)
    

    //onclick = loadWrapper("fileinputgene")
}

clearBackup = () => {
    backupgraph = [];
    backupgraphcount = -1;
    backupparsing = false;
}