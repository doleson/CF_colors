function CustomTooltip(tooltipId, width){
	var tooltipId = tooltipId;
	var tool = d3.select("#tool").append("div")
		.classed(tooltipId, true)
		.style("z-index", "1010")
		.style("display", "none")
		.style("padding", "0px")
		.style("opacity", 0.95)
		.style("position", "absolute")
		.style("margin-left", "30px")
		.style("margin-top", "30px");

	var toolTitle = tool.append("div")
		.classed("tool-title", true)
		.style("height", "33px")
		.style("border-top-right-radius", "10px")
		.style("border-top-left-radius", "10px")
		.style("border-top", "3px solid #000000")
		.style("border-left", "3px solid #000000")
		.style("border-right", "3px solid #000000");

	var toolInput = tool.append("div")
		.classed("tool-input", true)
		.style("border-bottom-right-radius", "10px")
		.style("border-bottom-left-radius", "10px")
		.style("padding", "8px")
		.style("background-color", "#ffffff")
		.style("border", "3px solid #000000")
		.style("font-family", 'Georgia, "Times New Roman", serif');
		 
	if (width) {
		toolTitle.style("width", width+"px");
		toolInput.style("width", width-16+"px");
	}

	hideTooltip();
	
	function showTooltip(content, event, color, data, toCamel){
		$(".tool-input").html(content);
		$("."+tooltipId).show();
		toolTitle.style("background-color", color);

		var toolBody = d3.select('#color-tbody');
    var color_rows = toolBody.selectAll('tr')
      .data(data);
    color_rows.enter().append('tr')
      .html(function(d) {return '<td><img title="'+d[1]+'" src="images/'+d[0]+'.png"/></td><td>'+ toCamel(d[2])+'</td><td>'+toCamel(d[3])+'</td>';});

		updatePosition(event);
	}
	
	function hideTooltip(){
		$("."+tooltipId).hide();
	}
	
	function updatePosition(event){
		var ttid = "."+tooltipId;
		var xOffset = 20;
		var yOffset = -30;
		
		 var ttw = $(ttid).width();
		 var tth = $(ttid).height();
		 var wscrY = $(window).scrollTop();
		 var wscrX = $(window).scrollLeft();
		 var curX = (document.all) ? event.clientX + wscrX : event.pageX;
		 var curY = (document.all) ? event.clientY + wscrY : event.pageY;
		 var ttleft = ((curX - wscrX + xOffset*2 + ttw) > $(window).width()) ? curX - ttw - xOffset*2 : curX + xOffset;
		 if (ttleft < wscrX + xOffset){
		 	ttleft = wscrX + xOffset;
		 } 
		 var tttop = ((curY - wscrY + yOffset*2 + tth) > $(window).height()) ? curY - tth - yOffset*2 : curY + yOffset;
		 if (tttop < wscrY + yOffset){
		 	tttop = curY + yOffset;
		 } 
		 $(ttid).css('top', tttop + 'px').css('left', ttleft + 'px');
	}
	
	return {
		showTooltip: showTooltip,
		hideTooltip: hideTooltip,
		updatePosition: updatePosition
	}
}
