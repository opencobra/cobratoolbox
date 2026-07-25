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

var svg,
    graph = {},
    ograph,
    link,
    olink,
    node,
    rectnode,
    circlenode,
    shiftKey,
    gMain,
    rect,
    gDraw,
    zoom,
    color,
    gBrushHolder,
    gBrush,
    brushMode,
    brushing,
    brush,
    width,
    height,
    parentWidth,
    parentHeight,
    text,
    focus_node = null,
    highlight_color = "#0000ff",
    highlight_trans = 0.1,
    highlighting = false,
    linkedByIndex,
    ctrlKey,
    ctrlKeyIng,
    selected = [],
    count = 0,
    dragging = false,
    ciclecenter,
    rotatecenter,
    circling = false,
    vertlining = false,
    horzlining = false,
    diaglining = false,
    rotating = false,
    rotatinginit = false,
    rectangleinit = false,
    rectangle = false,
    recseltmp = [],
    beziering = false,
    suspended = [],
    centerref,
    typing = false,
    file,
    fluxmax = 1,
    fluxmin = -1,
    parsedmodels = {},
    currentparsed = "",
    backups = {},
    concentrationmax = 1,
    concentrationmin = -1,
    texting = false,
    shaping = false,
    addedText = [],
    addedShapes = [],
    onloadfilter = false,
    noshowedit = ["x","y","fx","fy","index","weight","selected","previouslySelected","vx","vy","r",
    "group","trap","labelshift","bezi","grouping","secondary","isfixed","labelarr"],
    noshowttp = ["fx","fy","weight","selected","previouslySelected","vx","vy",
    "group","trap","labelshift","bezi","grouping","isfixed","labelarr","width"],
    rxncolorbreaks = [],
    rxncolor = [],
    metcolorbreaks = [],
    metcolor = [],
    backupgraph = [],
    tpp,
    backupgraphcount = -1,
    backupparsing = false,
    fluxobj = {},
    concobj = {},
    scaling = false,
    tracking = false,
    minwidth = 0,
    maxwidth = 1,
    minrxnsize = 1,
    maxrxnsize = 2,
    minmetsize = 1,
    maxmetsize = 2,
    sizerxnobj = {},
    sizemetobj = {},
    linkwidthobj = {},
    sscale,
    curtr = [0,0,1];

    var numsts = ["labelsize", "addedtextsize", "strokewidth", "nodescale",
        "linkstrength", "nodestrength", "maparea", "velocityDecay", "centerstrength",
        "secondarystrength", "shortpathtime", "centersize", "pretify","arrowsize", "eschescale",
        "maxrxnsize","minrxnsize","rxnsizescale","maxmetsize","minmetsize","metsizescale",
        "maxwidth","minwidth","widthscale"],
        textsts = ["lbfield", "namefield", "pathfield", "compfield", "metcolor", "rxncolor",
        "fixmetcolor", "fixrxncolor", "edgecolor", "addednodecolor", "linkstraincolor",
        "metNameOpts", "secMetNameOpts", "rxnNameOpts","rxncolorsize","widthcolorsize",
        "metcolorsize"],
        checksts = ['arrows','tooltipbool','hiderxns','movelabels','linkstrain',"sizeref"];

function loadInitialGraph() {
    linkedByIndex = {};
    graph.links.forEach(function(d) {
	linkedByIndex[d.source + "," + d.target] = true;
    });

    graph.nodes.forEach(function(d) {
        if(d.isfixed == null){d.isfixed = false}; 
        return d;}
    )

    //if (typeof d3 == 'undefined') {d3 = d3};

    svg = d3.select("#d3_selectable_force_directed_graph")
        .append("svg")
        .attr("id","graphsvg")
        .classed("svg-content", true);

    svg.attr("height",d3.select('svg').node().parentNode.clientHeight-70);
    svg.attr("width",d3.select('svg').node().parentNode.clientWidth-5);

    parentWidth = d3.select('svg').node().parentNode.clientWidth;
    parentHeight = d3.select('svg').node().parentNode.clientHeight;

    // remove any previous graphs
    svg.selectAll('.g-main').remove();

    gMain = svg.append('g').attr("class","everything")

    rect = gMain.append('rect')
    .attr('width', 400*$(window).width())
    .attr('height', 400*$(window).height())
    .attr("x", -200*$(window).width())
    .attr("y", -200*$(window).height())
    .style('fill', 'white')

    gDraw = gMain.append('g');
    
    if (! ("links" in graph)) {
        console.log("Graph is missing links");
    }

    gMain.on("dblclick.zoom", null);
    gDraw.on("dblclick.zoom", null);
    svg.on("dblclick.zoom", null);

    gBrushHolder = gDraw.append('g')
    
    gBrush = null;

    brushMode = false;
    brushing = false;

    brush = d3.brush()
        .on("start", brushstarted)
        .on("brush", brushed)
        .on("end", brushended);

    defineSimulation()

    rect.on('click', () => {
        selectOpenMenu()
        
        if (texting) {
            texting = false;
            drawNewText(d3.event);
            return;
        }

        if (shaping) {
            shaping = false;
            drawNewShape(d3.event);
            return;
        }

        if (ctrlKeyIng) {
            exit_highlight()
            simulation.restart()
        }

        node.each(function(d) {
            d.selected = false;
            d.previouslySelected = false;
        });
        node.classed("selected", false);
        selected = [];                   
    })
    .on('dblclick', () => {
        if(tracking){trackMet()}
    });

    d3.select('body').on('keydown', keydown);
    d3.select('body').on('keyup', keyup);

    //Set Zoom
    zoom = d3.zoom()
    .on('zoom', zoomed);

    gMain.call(zoom);
}


function zoomed() {
    gDraw.attr('transform', d3.event.transform);
    curtr = [d3.event.transform.x,d3.event.transform.y,d3.event.transform.k];
    if (document.getElementById("sizeref").checked) {
        drawSizeReference();
    }
}

function brushed() {
    if (!d3.event.sourceEvent) return;
    if (!d3.event.selection) return;

    var extent = d3.event.selection;

    node.classed("selected", function(d) {
        d.selected = d.previouslySelected ^
        (extent[0][0] <= d.x && d.x < extent[1][0]
         && extent[0][1] <= d.y && d.y < extent[1][1])
         if (d.selected && selected.indexOf(d.index) == -1) {selected.push(d.index)};
         return(d.selected);
    });
}

function brushended() {
    if (!d3.event.sourceEvent) return;
    if (!d3.event.selection) return;
    if (!gBrush) return;

    gBrush.call(brush.move, null);

    if (!brushMode) {
        gBrush.remove();
        gBrush = null;
    }

    brushing = false;
}

function brushstarted() {
    brushing = true;
    typing = false;

    node.each(function(d) { 
        d.previouslySelected = shiftKey && d.selected; 
    });
}

function keydown() {
    if (d3.event.altKey) {d3.event.preventDefault();};

    shiftKey = d3.event.shiftKey;
    ctrlKey = d3.event.ctrlKey;

    if (shiftKey) {
        // if we already have a brush, don't do anything
        if (gBrush)
            return;

        brushMode = true;

        if (!gBrush) {
            gBrush = gBrushHolder.append('g');
            gBrush.call(brush);
        }
    }
    
    //shortcuts
    if(d3.event.key == "a" && !typing) {
        selected = Array.from({length: graph.nodes.length}, (v, i) => i);
        graph.nodes.forEach(function(d){d.selected = true})
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
    }
    if(d3.event.key == "b" && !typing) {defineBackupGraph(); splitMet()}
    if(d3.event.key == "c" && !typing) {defineBackupGraph();editBezier()}
    if(d3.event.key == "d" && !typing) {defineBackupGraph();autoBezi()}
    //if(d3.event.key == "e" && !typing) {}
    if(d3.event.key == "f" && !typing) {defineBackupGraph(); fixSelected()}
    //if(d3.event.key == "g" && !typing) {}
    if(d3.event.key == "h" && !typing) {trackMet()}
    if(d3.event.key == "i" && !typing) {
        defineBackupGraph();
        if (selected.length == 1 && graph.nodes[selected[0]].group == 1) {
            isolateRxn()
        } else {
            isolateMetabolite()
        }
    }
    if(d3.event.key == "j" && !typing) {defineBackupGraph(); joinMetabolite()}
    //if(d3.event.key == "k" && !typing) {}
    //if(d3.event.key == "l" && !typing) {}
    if(d3.event.key == "m" && !typing) {document.getElementById('movelabels').checked = !document.getElementById('movelabels').checked; dragLabels();}
    if(d3.event.key == "n" && !typing) {defineBackupGraph(); selectConnected()}
    //if(d3.event.key == "o" && !typing) {}
    if(d3.event.key == "p" && !typing) {defineBackupGraph(); shortestPath("short")}
    if(d3.event.key == "q" && !typing) {
        defineBackupGraph();
        for (var i = 0; i < selected.length; i++) {
            if (graph.nodes[selected[i]].group == 2 &&
                graph.nodes[selected[i]].degree == 1 && 
                !graph.nodes[selected[i]].secondary) {makeSecondary(); return;}
        }
        makePrimary()
    }
    //if(d3.event.key == "r" && !typing) {}
    if(d3.event.key == "s" && !typing) {defineBackupGraph(); suspendMetabolite()}
    if(d3.event.key == "t" && !typing) {defineBackupGraph(); toggleSelected()}
    if(d3.event.key == "u" && !typing) {defineBackupGraph(); untrap()}
    //if(d3.event.key == "v" && !typing) {}
    //if(d3.event.key == "w" && !typing) {}
    //if(d3.event.key == "x" && !typing) {}
    //if(d3.event.key == "y" && !typing) {}
    //if(d3.event.key == "z" && !typing) {}
    
    //left 37
    //up 38
    //right 39
    //down 40
    if(d3.event.keyCode == 46 && !typing) {defineBackupGraph(); deleteNodes()}
    if(d3.event.key == "p" && !typing) {simulation.stop();}
    if(d3.event.key == "r" && !typing) {behave()}
    if(d3.event.ctrlKey && d3.event.key == "z" && !typing) {getBackupGraphBack()}
    if(d3.event.ctrlKey && d3.event.key == "y" && !typing) {getBackupGraphForward()}
    if(d3.event.keyCode == 37 && !typing) {
        d3.event.preventDefault();
        simulation.stop()
        selected.forEach(function(d){
            graph.nodes[d].x--;
            if (graph.nodes[d].isfixed) {graph.nodes[d].fx--;}
        })
        simulation.restart()
    }
    if(d3.event.keyCode == 38 && !typing) {
        d3.event.preventDefault();
        simulation.stop()
        selected.forEach(function(d){
            graph.nodes[d].y--;
            if (graph.nodes[d].isfixed) {graph.nodes[d].fy--;}
        })
        simulation.restart()
    }
    if(d3.event.keyCode == 39 && !typing) {
        d3.event.preventDefault();
        simulation.stop()
        selected.forEach(function(d){
            graph.nodes[d].x++;
            if (graph.nodes[d].isfixed) {graph.nodes[d].fx++;}
        })
        simulation.restart()
    }
    if(d3.event.keyCode == 40 && !typing) {
        d3.event.preventDefault();
        simulation.stop()
        selected.forEach(function(d){
            graph.nodes[d].y++;
            if (graph.nodes[d].isfixed) {graph.nodes[d].fy++;}
        })
        simulation.restart()
    }
}

function keyup() {
    shiftKey = false;
    brushMode = false;
    ctrlKey = false;

    if (!gBrush)
        return;

    if (!brushing) {
        // only remove the brush if we're not actively brushing
        // otherwise it'll be removed when the brushing ends
        gBrush.remove();
        gBrush = null;
    }
}

function dragstarted(d) {
    typing = false;
    
    if (ctrlKeyIng) {
        exit_highlight()
        simulation.restart()
    }

    if (ctrlKey) {
        // set_highlight(d)
        // simulation.stop()
        // return;
        //document.getElementById("searchbox").value = "^" + d.class + "$";
        var e = {keyCode: 13};
        var rebol = document.getElementById("searchregexp").checked;
        document.getElementById("searchregexp").checked = false;
        if (d.group == 1) {
            getSearchNodes(e,"^" + d[document.getElementById("rxnNameOpts").value] + "$")
        } else {
            getSearchNodes(e,"^" + d[document.getElementById("metNameOpts").value] + "$")
        }
        document.getElementById("searchregexp").checked = rebol;
        simulation.stop()
        return;
    }

    if (texting) {
        texting = false;
        drawNewText(d3.event);
        return;
    }

    if (shaping) {
        shaping = false;
        drawNewShape(d3.event);
        return;
    }

    if (rectangle) {
        graph.nodes[graph.nodes.length-1].moving = d.index;
    }

    dragging = true;

    if (!d3.event.active) simulation.alphaTarget(0.9).restart();

    if (!d.selected && !shiftKey) {
        // if this node isn't selected, then we have to unselect every other node
        node.classed("selected", function(p) {
            selected = [];
            return p.selected =  p.previouslySelected = false;
        });
    }
    
    if (d.selected && shiftKey) {
        d3.select(this).classed("selected", function(p) { 
            d.previouslySelected = d.selected;
            selected.splice(selected.indexOf(d.index),1);
            return d.selected = false; });
    } else {
        if (d.grouping.length == 0) {
        d3.select(this).classed("selected", function(p) {
                d.previouslySelected = d.selected;
                if (selected.indexOf(d.index) == -1) {selected.push(d.index)};
                return d.selected = true; 
            }) 
        } else {
            for (var j = 0; j < d.grouping.length; j++) {
                graph.nodes.forEach(function(e){
                    if (e.id == d.grouping[j]) {
                        e.selected = e.previouslySelected = true;
                        if (selected.indexOf(e.index) == -1) {selected.push(e.index)};
                    }
                })
            }
            node.classed("selected",function(d){return d.selected})
        };
    }
    
    node.filter(function(d) { return d.selected; })
    .each(function(d) { //d.fixed |= 2; 
        d.fx = d.x;
        d.fy = d.y;
    })
    
    if (document.getElementById("dialog2").style.display == "block") {editNodeProperties(d)}
}

function dragged(d) {
    
    if (ctrlKey) {
        return;
    }

    if (rotatinginit) {
        node.filter(function(d) { return d.group == 5; })
        .each(function(d) { 
            d.fx += d3.event.dx;
            d.fy += d3.event.dy;
        })
        return;
    }

    if (beziering) {
        node.filter(function(d) { return d.group == 5; })
        .each(function(d) {
            d.fx += d3.event.dx;
            d.fy += d3.event.dy;
            graph.nodes[d.refindex].bezi[0] = d.fx - graph.nodes[d.refindex].x;
            graph.nodes[d.refindex].bezi[1] = d.fy - graph.nodes[d.refindex].y;
            graph.nodes[d.refindex].bezi[2] = -graph.nodes[d.refindex].bezi[0];
            graph.nodes[d.refindex].bezi[3] = -graph.nodes[d.refindex].bezi[1];
        })
        return
    }

    if (circling) {
        var curradius = graph.nodes[graph.nodes.length-1].radius(),
        curangle = graph.nodes[graph.nodes.length-1].angle();
        rev = document.getElementById("reverseline").checked ? -1 : 1;

        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "circlemap") {
                d.fx = ciclecenter[0] - curradius*Math.cos(d.angle+curangle);
                d.fy = ciclecenter[1] - curradius*Math.sin(d.angle+curangle);
                d.rotradius = curradius;
                if (d.group == 1) {
                    if (d.circleindex == 0) {
                        var index2 = selected.length - 2,
                        index1 = 1;
                    } else if (d.circleindex == (selected.length-2)){
                        var index2 = selected.length-3,
                        index1 = 0;
                    } else {
                        var index2 = d.circleindex - 1,
                        index1 = d.circleindex + 1;
                    }
                    if (document.getElementById("reverseline").checked) {var tmp = index1; index1 = index2; index2 = tmp;}
                    if ((linkedByID[d.id + "," + graph.nodes[selected[index1]].id] && linkedByID[d.id + "," + graph.nodes[selected[index2]].id]) || 
                    (linkedByID[graph.nodes[selected[index1]].id + "," + d.id] && linkedByID[graph.nodes[selected[index2]].id + "," + d.id])) {
                        // if (d.group == 1) {
                            d.bezi[0] = -0.3*curradius*Math.cos(d.angle+curangle);
                            d.bezi[1] = -0.3*curradius*Math.sin(d.angle+curangle);
                            d.bezi[2] = - d.bezi[0];
                            d.bezi[3] = - d.bezi[1];
                        // } else {
                        //     d.bezi = [null, null, null, null];
                        // }
                    } else if (linkedByID[d.id + "," + graph.nodes[selected[index1]].id]) {
                        var refpts = [ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3))];
                        d.bezi[0] = d.fx - refpts[0];
                        d.bezi[1] = d.fy - refpts[1];
                        d.bezi[2] = d.fx - refpts[2];
                        d.bezi[3] = d.fy - refpts[3];
                    } else if (linkedByID[graph.nodes[selected[index1]].id + "," + d.id]) {
                        var refpts = [ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3))];
                        d.bezi[0] = -d.fx + refpts[0];
                        d.bezi[1] = -d.fy + refpts[1];
                        d.bezi[2] = -d.fx + refpts[2];
                        d.bezi[3] = -d.fy + refpts[3];
                    } else {
                        //var refpts = [ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        //ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle-(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        //ciclecenter[0] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.cos(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3)),
                        //ciclecenter[1] - (3*curradius - 2*curradius*Math.cos(graph.nodes[graph.nodes.length-1].anglestep/3))*Math.sin(d.angle+curangle+(rev*graph.nodes[graph.nodes.length-1].anglestep/3))];
                        //d.bezi[0] = d.fx - refpts[0];
                        //d.bezi[1] = d.fy - refpts[1];
                        //d.bezi[2] = d.fx - refpts[2];
                        //d.bezi[3] = d.fy - refpts[3];
                    }
                }
            }
        });
    }

    if (rotating) {
        node.filter(function(d) { return d.id == "rotatemap" && d.selected; })
        .each(function(d) { 
            d.fx += d3.event.dx;
            d.fy += d3.event.dy;
        })
        var curangle = graph.nodes[graph.nodes.length-1].angle();
        graph.nodes[graph.nodes.length-1].px = graph.nodes[graph.nodes.length-1].fx;
        graph.nodes[graph.nodes.length-1].py = graph.nodes[graph.nodes.length-1].fy;
        var cursin = Math.sin(curangle),
        curcos = Math.cos(curangle);

        curradius = graph.nodes[graph.nodes.length-1].radius();
        curscale = curradius/graph.nodes[graph.nodes.length-1].pradius;
        graph.nodes[graph.nodes.length-1].pradius = curradius;
        
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "rotatemap") {
                var x = rotatecenter[0] - d.fx,
                y = rotatecenter[1] - d.fy;
                d.fx = rotatecenter[0] - curscale*(x*curcos - y*cursin);
                d.fy = rotatecenter[1] - curscale*(x*cursin + y*curcos);
                if (d.bezi[0] != null) {
                    tmp = curscale*(d.bezi[0]*curcos - d.bezi[1]*cursin);
                    d.bezi[1] = curscale*(d.bezi[0]*cursin + d.bezi[1]*curcos);
                    d.bezi[0] = tmp;
                    d.bezi[2] = -d.bezi[0];
                    d.bezi[3] = -d.bezi[1];
                }
            }
        });
        return;
    }

    if (rectangle) {
        var curpos = [graph.nodes[graph.nodes.length-1].x-10, graph.nodes[graph.nodes.length-1].y-10],
        af = graph.nodes[graph.nodes.length-1].af;
        graph.nodes.forEach(function(d) {
            if (d.index == graph.nodes[graph.nodes.length-1].moving) {
                d.fx += d3.event.dx;
                d.fy += d3.event.dy;
                if (d3.event.x > curpos[0]){d.fx = curpos[0];}
                if (d3.event.x < af[0]){d.fx = af[0];}
                if (d3.event.y > curpos[1]){d.fy = curpos[1];}
                if (d3.event.y < af[2]) {d.fy = af[2]}

                //d3.event.
                d.x = d.fx;
                d.y = d.fy;
            }
            return d;
        });
        return;
    }

    if (scaling) {
        var minx,
        miny,
        maxx,
        maxy,
        oldfx,
        oldfy;
        node.filter(function(d) { return d.group == 5; })
        .each(function(d) {
            oldfx = d.fx;
            oldfy = d.fy;
            d.fx += d3.event.dx;
            d.fy += d3.event.dy;
            minx = d.minx;
            miny = d.miny;
            maxx = d.maxx;
            maxy = d.maxy;
        })

        node.filter(function(d) {return d.selected && d.group != 5})
        .each(function(d) {
            d.fx = d.fx + (d3.event.dx * (d.fx - minx) / (graph.nodes[graph.nodes.length-1].fx - d3.event.dx - minx))
            d.fy = d.fy + (d3.event.dy * (d.fy - miny) / (graph.nodes[graph.nodes.length-1].fy - d3.event.dy - miny))
            if (d.bezi[0] != null) {
                d.bezi[0] = d.bezi[0]*(graph.nodes[graph.nodes.length-1].fx-minx)/(oldfx-minx);
                d.bezi[2] = d.bezi[2]*(graph.nodes[graph.nodes.length-1].fx-minx)/(oldfx-minx);
                d.bezi[1] = d.bezi[1]*(graph.nodes[graph.nodes.length-1].fy-miny)/(oldfy-miny);
                d.bezi[3] = d.bezi[3]*(graph.nodes[graph.nodes.length-1].fy-miny)/(oldfy-miny);
            }
        })

        return;
    }
    
    node.filter(function(d) { return d.selected; })
    .each(function(d) { 
        d.fx += d3.event.dx;
        d.fy += d3.event.dy;
    })

    if (rectangleinit) {
        var curpos = [graph.nodes[graph.nodes.length-1].x, graph.nodes[graph.nodes.length-1].y],
        af = graph.nodes[graph.nodes.length-1].af;
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "rectanglemap") {
                if (d.rectpos == "l") {
                    d.fx = af[0];
                    d.fy = af[2] + d.scale*(curpos[1]-af[2]);
                } else if (d.rectpos == "r") {
                    d.fx = curpos[0];
                    d.fy = af[2] + d.scale*(curpos[1]-af[2]);
                } else if (d.rectpos == "t") {
                    d.fy = af[2];
                    d.fx = af[0] + d.scale*(curpos[0]-af[0]);
                } else if (d.rectpos == "b") {
                    d.fy = curpos[1];
                    d.fx = af[0] + d.scale*(curpos[0]-af[0]);
                }
                d.x = d.fx;
                d.y = d.fy;
            }
            return d;
        });
        return;
    }

    if (vertlining) {
        graph.nodes[graph.nodes.length-1].fx = graph.nodes[graph.nodes.length-1].fixedx;
        var curstep = graph.nodes[graph.nodes.length-1].step();
        currev = document.getElementById("reverseline").checked ? -1 : 1;
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "vertlinemap") {
                d.fx = graph.nodes[graph.nodes.length-1].fixedx + (1^(d.stepnum % 2))*0.1*curstep - curstep/10;
                d.fy = graph.nodes[graph.nodes.length-1].miny + d.stepnum*curstep;
                if (d.group == 1) {
                    lineFunctionBezi(d,currev,0,curstep)
                }
            }
        });
    }

    if (horzlining) {
        graph.nodes[graph.nodes.length-1].fy = graph.nodes[graph.nodes.length-1].fixedy;
        var curstep = graph.nodes[graph.nodes.length-1].step();
        currev = document.getElementById("reverseline").checked ? -1 : 1;
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "horzlinemap") {
                d.fy = graph.nodes[graph.nodes.length-1].fixedy + (1^(d.stepnum % 2))*0.1*curstep - curstep/10;
                d.fx = graph.nodes[graph.nodes.length-1].minx + d.stepnum*curstep;
                if (d.group == 1) {
                    lineFunctionBezi(d,currev,curstep,0)
                }
            }
        });
    }

    if (diaglining) {
        var curstepy = graph.nodes[graph.nodes.length-1].stepy(),
        curstepx = graph.nodes[graph.nodes.length-1].stepx();
        currev = document.getElementById("reverseline").checked ? -1 : 1;
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "diaglinemap") {
                d.fy = graph.nodes[graph.nodes.length-1].fixedy + d.stepnum*curstepy;
                d.fx = graph.nodes[graph.nodes.length-1].fixedx + d.stepnum*curstepx;
                if (d.group == 1) {
                    lineFunctionBezi(d,currev,curstepx,curstepy)
                }
            }
        });
    }

}

function dragended(d) {
    if (ctrlKey) {
        return;
    }
    if (!d3.event.active) simulation.alphaTarget(0);

    selected.forEach(function(e){defineTrap(graph.nodes[e])})

    graph.nodes.forEach(function(d){
        if (!d.isfixed){
            d.fx = null;
            d.fy = null;
        } else {
            d.fx = d.x;
            d.fy = d.y;
        }
    })

    dragging = false;

    if (beziering) {
        beziering = false;
        delfive();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }

    if (circling) {
        circling = false;
        delfive();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if (rotating) {
        rotating = false;
        delfive();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if (rotatinginit) {
        rotatecenter = [graph.nodes[graph.nodes.length-1].x, graph.nodes[graph.nodes.length-1].y]
        rotatinginit = false;
        graph.nodes[graph.nodes.length-1].selected = false;
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
        rotateNodes()
    }
    if (rectangleinit) {
        rectangleinit = false;
        rectangle = true;
        recseltmp = selected;
        selected = [];
        graph.nodes.forEach(function(d){d.selected = false; return d;})
        graph.nodes[graph.nodes.length-1].selected = false;
        graph.nodes[graph.nodes.length-1].fx += 10;
        graph.nodes[graph.nodes.length-1].fy += 10;
        graph.nodes[graph.nodes.length-1].x += 10;
        graph.nodes[graph.nodes.length-1].y += 10;
        graph.nodes[graph.nodes.length-1].af[1] -= 10;
        graph.nodes[graph.nodes.length-1].af[3] -= 10;
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if (rectangle && graph.nodes[graph.nodes.length-1].selected) {
        rectangle = false;
        delfive();
        
        //selected.pop();
        selected = recseltmp;
        selected.pop();
        graph.nodes.forEach(function(d){
            if (selected.indexOf(d.index) != -1) {
                d.selected = true;
                d.previouslySelected = true;
            } else {
                d.selected = false;
                d.previouslySelected = false;
            }
        })

        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if(vertlining) {
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "vertlinemap") {
                d.fx = graph.nodes[graph.nodes.length-1].fixedx;
                d.fy = graph.nodes[graph.nodes.length-1].miny + d.stepnum*graph.nodes[graph.nodes.length-1].step();
            }
        });
        vertlining = false;
        graph.nodes.pop();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if(horzlining) {
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "horzlinemap") {
                d.fy = graph.nodes[graph.nodes.length-1].fixedy;
                d.fx = graph.nodes[graph.nodes.length-1].minx + d.stepnum*graph.nodes[graph.nodes.length-1].step();
            }
        });
        horzlining = false;
        graph.nodes.pop();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if (diaglining){
        graph.nodes.forEach(function(d) {
            if (d.selected && d.id != "diaglinemap") {
                d.fy = graph.nodes[graph.nodes.length-1].fixedy + d.stepnum*graph.nodes[graph.nodes.length-1].stepy();
                d.fx = graph.nodes[graph.nodes.length-1].fixedx + d.stepnum*graph.nodes[graph.nodes.length-1].stepx();
            }
        });
        diaglining = false;
        graph.nodes.pop();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
    if (scaling) {
        scaling = false;
        graph.nodes.pop();
        selected.pop();
        reDefineSimulation()
        node.classed("selected",function(d){return d.selected})
        simulation.restart()
    }
}

function ticked() {
    defineSecondaryPosition()
    
    node.filter(function(d) { return d.trap != -1 && d.group != 5})
    .each(function(d) { 
        trapNodes(d);
    })

    text.selectAll("tspan").attr("x", function(d) {return d.x + d.labelshift[0];});
    text.selectAll("tspan").attr("y", function(d) {return d.y + d.labelshift[1];});
    
    var maxatcf = 0;
    var as = Number(document.getElementById("arrowsize").value);
    var asfr = 0.5*as;
    var lb = document.getElementById("lbfield").value;
    var rxnshape = document.getElementById("rxnshape").value == "circle";
    var metshape = document.getElementById("metshape").value == "circle";

    if (document.getElementById("arrows").checked) {
            if (document.getElementById("reversibility").value == "None" || document.getElementById("reversibility").value == "Both Ways") {
            graph.links.forEach(function(d){
                //Get distance and max distance
                d.atcf = Math.sqrt(Math.pow(d.target.x - d.source.x,2) + Math.pow(d.target.y - d.source.y,2));
                if (d.atcf > maxatcf) {maxatcf = d.atcf};
                rev = d.target[lb] < 0 || d.source[lb] < 0;
                //Get variables to calculate arrowhead and path
                if (d.target.bezi[0] != null) {
                    var sp = [d.target.x+d.target.bezi[0],d.target.y+d.target.bezi[1]],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else if (d.source.bezi[0] != null) {
                    var sp = [d.source.x+d.source.bezi[2],d.source.y+d.source.bezi[3]],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else {
                    var sp = [d.source.x,d.source.y],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1]
                    r = d.atcf;
                }
                if (r < 0.1) {
                    var sp = [d.source.x,d.source.y],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1]
                    r = d.atcf;
                }
                
                //Define target reference node
                if (document.getElementById("hiderxns").checked && d.source.group == 2) {
                    var p4 = [d.target.x,d.target.y];
                    d.ppath = "";
                } else {
                    if ((d.target.group == 1 && rxnshape) || (d.target.group == 2 && metshape)) { //If target its a circle calculate ofset
                        var cst = r - d.target.r - as;
                        var p3 = [(sp[0]+((r-d.target.r-0.8)*x/r)),(sp[1]+((r-d.target.r-0.8)*y/r))];
                    } else {
                        if (x < y) {
                            if (x > -y) {
                                var cst = r - (d.target.r*r/y) - as;
                                var p3 = [(sp[0]+(x*(1 - (d.target.r+0.8)/y))),(sp[1]+(y-d.target.r-0.8))];
                            } else {
                                var cst = r + (d.target.r*r/x) - as;
                                var p3 = [(sp[0]+(x+d.target.r+0.8)),(sp[1]+(y*(1 + (d.target.r+0.8)/x)))];
                            }
                        } else {
                            if (x > -y) {
                                var cst = r - (d.target.r*r/x) - as;
                                var p3 = [(sp[0]+(x-d.target.r-0.8)),(sp[1]+(y*(1 - (d.target.r+0.8)/x)))];
                            } else {
                                var cst = r + (d.target.r*r/y) - as;
                                var p3 = [(sp[0]+(x*(1 + (d.target.r+0.8)/y))),(sp[1]+(y+d.target.r+0.8))];
                            }
                        }
                    }
                    var p1 = [(sp[0]+(cst*x-y*asfr-0.8)/r) , (sp[1]+(cst*y+x*asfr-0.8)/r)],
                        p2 = [(sp[0]+(cst*x+y*asfr-0.8)/r) , (sp[1]+(cst*y-x*asfr-0.8)/r)];
                        var p4 = [((p1[0]+p2[0]+0.1*p3[0])/2.1),((p1[1]+p2[1]+0.1*p3[1])/2.1)];
                        d.ppath = "M" + p1[0] + "," + p1[1] + "L" + p2[0] + "," + p2[1] + "L" + p3[0] + "," + p3[1]
                }
                if (document.getElementById("reversibility").value == "None" || !rev || (document.getElementById("hiderxns").checked && d.source.group == 1)) {
                    //Define path
                    if (d.source.bezi[0] != null && d.target.bezi[0] != null) {
                        d.bpath = "M" + d.source.x + "," + d.source.y + 
                        "C" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                        (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                        p4[0] + "," + p4[1];
                    } else if (d.target.bezi[0] != null) {
                        d.bpath = "M" + d.source.x + "," + d.source.y + 
                        "Q" + (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                        p4[0] + "," + p4[1];
                    } else if (d.source.bezi[0] != null) {
                        d.bpath = "M" + d.source.x + "," + d.source.y + 
                        "Q" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                        p4[0] + "," + p4[1];
                    } else {
                        d.bpath = "M" + d.source.x + "," + d.source.y + "L" + p4[0] + "," + p4[1];
                    }
                    return d;
                } else {
                    d.p4 = p4;
                }
            })
        } else if (document.getElementById("reversibility").value == "Diamond Arrowheads") {
            graph.links.forEach(function(d){
                //Get distance and max distance
                d.atcf = Math.sqrt(Math.pow(d.target.x - d.source.x,2) + Math.pow(d.target.y - d.source.y,2));
                if (d.atcf > maxatcf) {maxatcf = d.atcf};
                rev = d.target[lb] < 0 || d.source[lb] < 0;
                //Get variables to calculate arrowhead and path
                if (d.target.bezi[0] != null) {
                    var sp = [d.target.x+d.target.bezi[0],d.target.y+d.target.bezi[1]],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else if (d.source.bezi[0] != null) {
                    var sp = [d.source.x+d.source.bezi[2],d.source.y+d.source.bezi[3]],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else {
                    var sp = [d.source.x,d.source.y],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1]
                    r = d.atcf;
                }
                if (r < 0.1) {
                    var sp = [d.source.x,d.source.y],
                    x = d.target.x - sp[0],
                    y = d.target.y - sp[1]
                    r = d.atcf;
                }
                //Define arrowhead
                if (rev) {
                    //Define target reference node
                    if (document.getElementById("hiderxns").checked && d.target.group == 1) {
                        var p4 = [d.target.x,d.target.y];
                        d.ppath = "";
                    } else {
                        if ((d.target.group == 1 && rxnshape) || (d.target.group == 2 && metshape)) {
                            var cst = r - d.target.r - as,
                                cst2 = r - d.target.r - 2*as;
                            var p3 = [(sp[0]+((r-d.target.r-0.8)*x/r)),(sp[1]+((r-d.target.r-0.8)*y/r))];
                        } else {
                            if (x < y) {
                                if (x > -y) {
                                    var cst = r - (d.target.r*r/y) - as;
                                    var cst2 = cst - as;
                                    var p3 = [(sp[0]+(x*(1 - (d.target.r+0.8)/y))),(sp[1]+(y-d.target.r-0.8))];
                                } else {
                                    var cst = r + (d.target.r*r/x) - as;
                                    var cst2 = cst - as;
                                    var p3 = [(sp[0]+(x+d.target.r+0.8)),(sp[1]+(y*(1 + (d.target.r+0.8)/x)))];
                                }
                            } else {
                                if (x > -y) {
                                    var cst = r - (d.target.r*r/x) - as;
                                    var cst2 = cst - as;
                                    var p3 = [(sp[0]+(x-d.target.r-0.8)),(sp[1]+(y*(1 - (d.target.r+0.8)/x)))];
                                } else {
                                    var cst = r + (d.target.r*r/y) - as;
                                    var cst2 = cst - as;
                                    var p3 = [(sp[0]+(x*(1 + (d.target.r+0.8)/y))),(sp[1]+(y+d.target.r+0.8))];
                                }
                            }
                        }
                        p1 = [(sp[0]+(cst*x-y*asfr-0.8)/r) , (sp[1]+(cst*y+x*asfr-0.8)/r)],
                            p2 = [(sp[0]+(cst*x+y*asfr-0.8)/r) , (sp[1]+(cst*y-x*asfr-0.8)/r)],
                            p5 = [(sp[0]+((cst2+0.8)*x/r)),(sp[1]+((cst2+0.8)*y/r))];
                        var p4 = [((p1[0]+p2[0]+0.1*p3[0])/2.1),((p1[1]+p2[1]+0.1*p3[1])/2.1)];
                            d.ppath = "M" + p1[0] + "," + p1[1] + "L" + p3[0] + "," + p3[1] + "L" + p2[0] + "," + p2[1] + "L" + p5[0] + "," + p5[1];
                    }
                } else {
                    if ((d.target.group == 1 && rxnshape) || (d.target.group == 2 && metshape)) { //If target its a circle calculate ofset
                        var cst = r - d.target.r - as;
                        var p3 = [(sp[0]+((r-d.target.r-0.8)*x/r)),(sp[1]+((r-d.target.r-0.8)*y/r))];
                    } else {
                        if (x < y) {
                            if (x > -y) {
                                var cst = r - (d.target.r*r/y) - as;
                                var p3 = [(sp[0]+(x*(1 - (d.target.r+0.8)/y))),(sp[1]+(y-d.target.r-0.8))];
                            } else {
                                var cst = r + (d.target.r*r/x) - as;
                                var p3 = [(sp[0]+(x+d.target.r+0.8)),(sp[1]+(y*(1 + (d.target.r+0.8)/x)))];
                            }
                        } else {
                            if (x > -y) {
                                var cst = r - (d.target.r*r/x) - as;
                                var p3 = [(sp[0]+(x-d.target.r-0.8)),(sp[1]+(y*(1 - (d.target.r+0.8)/x)))];
                            } else {
                                var cst = r + (d.target.r*r/y) - as;
                                var p3 = [(sp[0]+(x*(1 + (d.target.r+0.8)/y))),(sp[1]+(y+d.target.r+0.8))];
                            }
                        }
                    }
                    var p1 = [(sp[0]+(cst*x-y*asfr-0.8)/r) , (sp[1]+(cst*y+x*asfr-0.8)/r)],
                        p2 = [(sp[0]+(cst*x+y*asfr-0.8)/r) , (sp[1]+(cst*y-x*asfr-0.8)/r)];
                        var p4 = [((p1[0]+p2[0]+0.1*p3[0])/2.1),((p1[1]+p2[1]+0.1*p3[1])/2.1)];
                        d.ppath = "M" + p1[0] + "," + p1[1] + "L" + p2[0] + "," + p2[1] + "L" + p3[0] + "," + p3[1]
                }
                //Define path
                if (d.source.bezi[0] != null && d.target.bezi[0] != null) {
                    d.bpath = "M" + d.source.x + "," + d.source.y + 
                    "C" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                    (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                    p4[0] + "," + p4[1];
                } else if (d.target.bezi[0] != null) {
                    d.bpath = "M" + d.source.x + "," + d.source.y + 
                    "Q" + (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                    p4[0] + "," + p4[1];
                } else if (d.source.bezi[0] != null) {
                    d.bpath = "M" + d.source.x + "," + d.source.y + 
                    "Q" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                    p4[0] + "," + p4[1];
                } else {
                    d.bpath = "M" + d.source.x + "," + d.source.y + "L" + p4[0] + "," + p4[1];
                }
                return d; 
            })
        }
        if (document.getElementById("reversibility").value == "Both Ways") {
            if (document.getElementById("hiderxns").checked) { //If we are hiding reactions, add to the source only if it is a metabolite
                tmp = graph.links.filter(function(d){return d.source.group == 2 && d.target[lb] < 0})
            } else { //If we are not hiding reactions, add to the source whether its a reaction or not. Just make sure it is reversible
                tmp = graph.links.filter(function(d){return d.target[lb] < 0 || d.source[lb] < 0})
            }
            //Add arrow to source
            tmp.forEach(function(d) {
                //Get variables to calculate arrowhead and path
                if (d.source.bezi[0] != null) {
                    var sp = [d.source.x+d.source.bezi[2],d.source.y+d.source.bezi[3]],
                    x = d.source.x - sp[0],
                    y = d.source.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else if (d.target.bezi[0] != null) {
                    var sp = [d.target.x+d.target.bezi[0],d.target.y+d.target.bezi[1]],
                    x = d.source.x - sp[0],
                    y = d.source.y - sp[1],
                    r = Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
                } else {
                    var sp = [d.target.x,d.target.y],
                    x = d.source.x - sp[0],
                    y = d.source.y - sp[1]
                    r = d.atcf;
                }
                if (r < 0.1) {
                    var sp = [d.target.x,d.target.y],
                    x = d.source.x - sp[0],
                    y = d.source.y - sp[1]
                    r = d.atcf;
                }
                //Define arrowhead
                if ((d.source.group == 1 && rxnshape) || (d.source.group == 2 && metshape)) {
                    var cst = r - d.source.r - as;
                    var p3 = [(sp[0]+((r-d.source.r-0.8)*x/r)),(sp[1]+((r-d.source.r-0.8)*y/r))];
                } else {
                    if (x < y) {
                        if (x > -y) {
                            var cst = r - (d.source.r*r/y) - as;
                            var p3 = [(sp[0]+(x*(1 - (d.source.r+0.8)/y))),(sp[1]+(y-d.source.r-0.8))];
                        } else {
                            var cst = r + (d.source.r*r/x) - as;
                            var p3 = [(sp[0]+(x+d.source.r+0.8)),(sp[1]+(y*(1 + (d.source.r+0.8)/x)))];
                        }
                    } else {
                        if (x > -y) {
                            var cst = r - (d.source.r*r/x) - as;
                            var p3 = [(sp[0]+(x-d.source.r-0.8)),(sp[1]+(y*(1 - (d.source.r+0.8)/x)))];
                        } else {
                            var cst = r + (d.source.r*r/y) - as;
                            var p3 = [(sp[0]+(x*(1 + (d.source.r+0.8)/y))),(sp[1]+(y+d.source.r+0.8))];
                        }
                    }
                }
                var p1 = [(sp[0]+(cst*x-y*asfr-0.8)/r) , (sp[1]+(cst*y+x*asfr-0.8)/r)],
                    p2 = [(sp[0]+(cst*x+y*asfr-0.8)/r) , (sp[1]+(cst*y-x*asfr-0.8)/r)];
                var p4 = [((p1[0]+p2[0]+0.1*p3[0])/2.1),((p1[1]+p2[1]+0.1*p3[1])/2.1)];
                    d.ppath = d.ppath + "M" + p1[0] + "," + p1[1] + "L" + p2[0] + "," + p2[1] + "L" + p3[0] + "," + p3[1];
    
                //Define path
                if (d.source.bezi[0] != null && d.target.bezi[0] != null) {
                    d.bpath = "M" + p4[0] + "," + p4[1] + 
                    "C" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                    (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                    d.p4[0] + "," + d.p4[1];
                } else if (d.target.bezi[0] != null) {
                    d.bpath = "M" + p4[0] + "," + p4[1] + 
                    "Q" + (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                    d.p4[0] + "," + d.p4[1];
                } else if (d.source.bezi[0] != null) {
                    d.bpath = "M" + p4[0] + "," + p4[1] + 
                    "Q" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                    d.p4[0] + "," + d.p4[1];
                } else {
                    d.bpath = "M" + p4[0] + "," + p4[1] + "L" + d.p4[0] + "," + d.p4[1];
                }
                return d;
            })
        }
    } else {
        graph.links.forEach((d) => {
            //Define path
            if (d.source.bezi[0] != null && d.target.bezi[0] != null) {
                d.bpath = "M" + d.source.x + "," + d.source.y + 
                "C" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                d.target.x + "," + d.target.y;
            } else if (d.target.bezi[0] != null) {
                d.bpath = "M" + d.source.x + "," + d.source.y + 
                "Q" + (d.target.x + d.target.bezi[0]) + "," + (d.target.y + d.target.bezi[1]) + "," + 
                d.target.x + "," + d.target.y;
            } else if (d.source.bezi[0] != null) {
                d.bpath = "M" + d.source.x + "," + d.source.y + 
                "Q" + (d.source.x + d.source.bezi[2]) + "," + (d.source.y + d.source.bezi[3]) + "," + 
                d.target.x + "," + d.target.y;
            } else {
                d.bpath = "M" + d.source.x + "," + d.source.y + "L" + d.target.x + "," + d.target.y;
            }
            d.ppath = "";
            return d;
        })
    }

    link.attr("d",function(d){return d.bpath;})
    arrows.attr("d",function(d){return d.ppath;})

    if (document.getElementById("linkstrain").checked) {
        var tmpmincol = hexToRgb(document.getElementById("edgecolor").value),
            tmpminval = maxatcf/2,
            tmpmaxcol = hexToRgb(document.getElementById("linkstraincolor").value),
            tmpmaxval = maxatcf;
        
        if (tmpminval >= tmpmaxval) {
            link.style("stroke",document.getElementById("edgecolor").value)
        } else {
            link.style("stroke",function(l){
                if (l.atcf > tmpmaxval) {
                    return document.getElementById("linkstraincolor").value
                } else if (l.atcf < tmpminval) {
                    return document.getElementById("edgecolor").value;
                } else {
                    var col = [],
                    tmpscale = (l.atcf-tmpminval)/(tmpmaxval-tmpminval);
                    for (var j = 0; j < 3; j++) {
                        col.push(Math.round(tmpmincol[j] + ((tmpmaxcol[j]-tmpmincol[j])*tmpscale)))
                    }
                    return rgbToHex(col)
                }
            })
        }
    }

    circlenode.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
    rectnode.attr("x", function(d) { return d.x-d.r; })
        .attr("y", function(d) { return d.y-d.r; });

}

function defineSimulation() {
    drawShapes() 
    drawTexts()

    link = gDraw.append("g")
    .attr("class","link")
    .selectAll(".link")
    .data(graph.links)
    .enter().append("svg:path")
        .attr("class", "link")
        .style("stroke",defineLinkColor)
        .attr("fill","none")
        .attr("stroke-width",function(l) {
            if (l.width == null) {
                return Number(document.getElementById("strokewidth").value);
            } else {
                return (l.width < minwidth ? minwidth:(l.width > maxwidth ? maxwidth:l.width))*Number(document.getElementById("widthscale").value);
            }
            
        });

    manageArrows()

    node = gDraw.append("g")
    .attr("class", "node")
    
    node = node.selectAll(".node")
    .data(graph.nodes)
    .enter()

    if (document.getElementById("rxnshape").value == "rect") {
        node.filter(function(d){return d.group == 1})
        .append("rect").attr("class","rectnode")
    } else {
        node.filter(function(d){return d.group == 1})
        .append("circle").attr("class","circlenode")
    }
    

    if (document.getElementById("metshape").value == "rect") {
        node.filter(function(d){return d.group == 2})
        .append("rect").attr("class","rectnode")
    } else {
        node.filter(function(d){return d.group == 2})
        .append("circle").attr("class","circlenode")
    }

    node.filter(function(d){return d.group != 1 && d.group != 2})
        .append("circle").attr("class","circlenode")

    node = d3.selectAll(".rectnode,.circlenode")
    rectnode = d3.selectAll(".rectnode")
    circlenode = d3.selectAll(".circlenode")

    node.attr("fill", defineNodeColor)
    .attr("stroke", defineNodeColor)
    .call(d3.drag()
    .on("start", dragstarted)
    .on("drag", dragged)
    .on("end", dragended))
    .on("mouseover",function(d){
        if (d3.event.altKey){
            d.selected = true;
            d.previouslySelected = true;
            node.classed("selected",function(d){return d.selected});
            if (selected.indexOf(d.index) == -1) {selected.push(d.index)};
        } 
    })

    node.filter(function(d){return "jparse" in d})
    .on("dblclick",function(d){
        var nodename;
        if (d.group == 1) {
            nodename = "^" + d[document.getElementById("rxnNameOpts").value] + "$";
        } else {
            nodename = "^" + d[document.getElementById("metNameOpts").value] + "$";
        }
        nodename = nodename.replace(", " + d.jparse,"")
        graph = parsedmodels[currentparsed];
        var nd = document.getElementById("onloadf1")
        if (nd) {
            nd.value = d.jparse;
            if (Object.keys(parsedmodels).length > 1) {onLoadSwitch(nd)};
        }
        var e = {keyCode: 13};
        getSearchNodes(e,nodename)
    })

    if (document.getElementById("hiderxns").checked) {
        node.style("opacity", function(d) {return d.group==1 ? 0 : 1;});
    } else {
        node.style("opacity", 1);
    }

    manageTooltips()

    centerref = gDraw.append("circle")
    .attr("cx", parentWidth/2)
    .attr("cy", parentHeight/2)
    .attr("r", Number(document.getElementById("centersize").value));

    text = gDraw.append("g")
        .attr("class","labels")
        .selectAll("text")
        .data(graph.nodes)
        .enter().append("text")
        .style("font-size", document.getElementById("labelsize").value + "px")
        //.attr("x", function(d) {return d.x + d.labelshift[0];})
        //.attr("y", function(d) {return d.y + d.labelshift[1];})
        .style("text-anchor", "middle")
        .style("pointer-events","none")
    if (document.getElementById('movelabels').checked) {dragLabels()}
    renameNodes()

    reDefineSimulationParameters()
}

function reDefineSimulation() {
    simulation.stop()
    var prevzoom = false;
    if (gDraw._groups[0][0].attributes.transform != null) {
        tmp = gDraw.attr("transform");
        prevzoom = true;
    }
    gDraw.remove()

    gDraw = gMain.append('g');
    gMain.on("dblclick.zoom", null);
    gDraw.on("dblclick.zoom", null);
    svg.on("dblclick.zoom", null);

    gMain.call(zoom);
    gMain.on("dblclick.zoom", null);

    gBrushHolder = gDraw.append('g')

    gBrush = null;

    brushMode = false;
    brushing = false;

    brush = d3.brush()
        .on("start", brushstarted)
        .on("brush", brushed)
        .on("end", brushended)
        .extent(extent);

    if (prevzoom) {gDraw.attr("transform",tmp)}

    graph.nodes.forEach(function(d) {
        if (!d.selected & !d.isfixed){
            d.fx = null;
            d.fy = null;
        }
    })

    defineSimulation()
    if (document.getElementById("sizeref").checked) {drawSizeReference();}
    node.classed("selected",function(d){return d.selected})
    defineSuspended()
    simulation.restart()
}