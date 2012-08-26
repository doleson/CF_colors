# Adapted from Jim Vallandingham's Bubble Chart Animation
# http://vallandingham.me/bubble_charts_in_d3.html


class BubbleChart
  constructor: (data) ->
    @data = data
    @height = 600

    @languages = [['EN', 'English'], ['ES', 'Spanish'], ['ZH', 'Chinese'], ['JA', 'Japanese'], ['KO', 'Korean'], ['FR', 'French'], ['DE', 'German'], ['IT', 'Italian'], ['RU', 'Russian'], ['WO', 'All Languages']]
    @lang = 'EN'

    tool_width = 280
    if $(document).width() < 350 then tool_width = 180

    @tooltip = CustomTooltip("color_tooltip", tool_width)

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @circles = null
    
    this.create_nodes()
    this.create_vis()
    this.create_box()

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.RGB
        radius:3
        red: d.r
        green: d.g
        blue: d.b
        SE_EN: d.name+' '+d.short_name
        SE_ES:d.EN_ES+' '+d.Spanish
        SE_RU:d.EN_RU+' '+d.Russian
        SE_DE:d.EN_DE+' '+d.German
        SE_FR:d.EN_FR+' '+d.French
        SE_ZH:d.EN_ZH+' '+d.Chinese
        SE_IT:d.EN_IT+' '+d.Italian
        SE_JA:d.EN_JA+' '+d.Japanese
        SE_KO: d.EN_KO+' '+d.Korean
        SE_WO: d.name+' '+d.short_name+' '+d.Spanish+' '+d.EN_ES+' '+d.Russian+' '+d.EN_RU+' '+d.German+' '+d.EN_DE+' '+d.French+' '+d.EN_FR+' '+d.Chinese+' '+d.EN_ZH+' '+d.Italian+' '+d.EN_IT+' '+d.Japanese+' '+d.EN_JP+' '+d.Korean+' '+d.EN_KO
        toolContent: [['EN', 'English', d.name, d.short_name], ['ES', 'Spanish', d.Spanish, d.EN_ES], ['ZH', 'Chinese', d.Chinese, d.EN_ZH], ['JA', 'Japanese', d.Japanese, d.EN_JA], ['KO', 'Korean', d.Korean, d.EN_KO], ['FR', 'French', d.French, d.EN_FR], ['DE', 'German', d.German, d.EN_DE], ['IT', 'Italian', d.Italian, d.EN_IT], ['RU', 'Russian', d.Russian, d.EN_RU]]
        x: d.cx
        y: d.cy
      }
      @nodes.push node


  # create svg at #vis and then 
  # create circle representation for each node
  create_vis: () =>
    if $(document).width() < 350 then @height = 300

    @vis = d3.select("#vis").append("svg")
      .attr("id", "svg_vis")
      .attr("viewBox", "0 0 600 600")
      .attr("height", @height)

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the 
    # mouse callbacks
    that = this

    @circles.enter().append("circle")
      .attr("r", (d) -> d.radius)
      .attr("fill", (d) => d3.rgb(parseInt(d.red), parseInt(d.green), parseInt(d.blue)))
      .attr("id", (d) -> d.id)
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))


  # create the input box for searching
  create_box: () =>
    that = this
    @searchtext = d3.select('#color_search').append("td")
    @searchtext.append("span")
      .html("Search Colors Here:")
      .style("font-size", "22px")
      .style("font-weight", "bold")
      .style("padding-right", "30px")
    @searchtext.append("input")
      .attr("type", "text")
      .attr("id", "color-input")
      .style("width", "309px")
      .on("keyup", (d,i) -> that.search(this.value))

    @langtext = d3.select('#lang_legend').append("td")
      .style("text-align", "right")
    @langtext.append("span")
      .html("in:")
      .style("font-size", "22px")
      .style("text-align", "right")
      .style("vertical-align", "middle")
      .style("padding-right", "30px")
    
    @langflags = @langtext.append("div")
      .attr("class", "flags")

    @flags = @langflags.selectAll("div")
      .data(@languages)

    @flags.enter().append("div")
    @flags.append('a')
        .style("cursor", "pointer")
        .on("click", (d,i) ->that.pickLang(d,i))
      .append('img')
        .attr("class", "lang-radio")
        .attr("id", (d)->"lang_"+d[0])
        .attr("title", (d)->d[1])
        .attr("src", (d)-> "images/"+d[0]+".png")

    d3.select("#lang_EN").attr("class", "lang-radio-checked")
    return

  show_details: (data, i, element) =>
    that = this

    d3.select(element).attr("r", "8").moveToFront()

    content = "
      <table class='color-tool table-condensed'>
        <thead>
          <tr>
            <th>Lang.</th>
            <th>Color name</th>
            <th>EN Transl.</th>
          </tr>
        </thead>
        <tbody id='color-tbody'>
        </tbody>
      </table>
    "
    @tooltip.showTooltip(content,d3.event, "rgb(#{data.red},#{data.green},#{data.blue})", data.toolContent, that.toCamel)
    
    #toolBody = d3.select('#color-tbody')
    #color_rows = toolBody.selectAll('tr')
    #  .data(data.toolContent)
    #color_rows.enter().append('tr')
    #  .html((d) -> '<td><img title="'+d[1]+'" src="images/'+d[0]+'.png"/></td><td>'+that.toCamel(d[2])+'</td><td>'+that.toCamel(d[3])+'</td>')

    tool = d3.select('#tool')
    tool.selectAll('th')
      .style('padding-top', '0px')
      .style('padding-bottom', '0px')
      .style('padding-left', '2px')
      .style('padding-right', '2px')
    tool.selectAll('td')
      .style('padding-top', '0px')
      .style('padding-bottom', '0px')
      .style('padding-left', '2px')
      .style('padding-right', '2px')
    return

  hide_details: (data, i, element) =>
    d3.select(element).attr("r", "3")
    @tooltip.hideTooltip()

  search: (input) =>
    that = this
    input = that.toCamel(input)
    input = input.replace /^ */, ''
    #input = input.replace / *$/, ''
    search = new RegExp(input)
    empty = /^ *$/.test(input)
    #searchname = d['EN_'+that.lang]
    @circles
      .attr('visibility', (d)=> if empty || that.toCamel(d['SE_'+that.lang]).test(search) then 'visible' else 'hidden')
  
  toCamel: (str) =>
    return str.replace /(?:^|\s)\w/g, (m) -> m.toUpperCase()

  pickLang: (d, i) =>
    that = this
    @lang = d[0]
    d3.select(".lang-radio-checked").attr("class", "lang-radio")
    d3.select("#lang_"+d[0]).attr("class", "lang-radio-checked")
    that.search(document.getElementById('color-input').value)


d3.selection.prototype.moveToFront = `function() { 
  return this.each(function() { 
    this.parentNode.appendChild(this); 
  }); 
}`

$ ->
  chart = null

  render_vis = (csv) ->
    chart = new BubbleChart csv
    return

  d3.csv "data/allLang.csv", render_vis
