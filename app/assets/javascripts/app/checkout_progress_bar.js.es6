App.CheckoutProgressBar = class CheckoutProgressBar {

  constructor(container_selector, steps, links) {
    this.container = d3.select(container_selector)
    this.steps = steps
    this.links = links
    console.log(steps)
    this.margin = {top: 0, right: 0, bottom: 20, left: 0}
    this.dimensions = this._loadDimensions()
    this.range = this._loadRange()
    this.domain = this._loadDomain()
    this.scale = this._loadScale()
    this.chart = this._loadChart()
  }

  _loadDimensions() {
    var cBox = this.container.node().getBoundingClientRect()
    var width = cBox.width
    var height = cBox.height
    return {
      width: width - this.margin.left - this.margin.right,
      height: height - this.margin.top - this.margin.bottom,
      chartWidth: width,
      chartHeight: height,
      chartTransform: 'translate('+this.margin.left+','+this.margin.top+')'
    }
  } 

  _loadRange() {
    var bar = {height: 8}
    var circle = {r: bar.height}
    var rect = {width: circle.r*2 + 4, height: bar.height - 2}
    return {
      x: [0, this.dimensions.width],
      y: [this.dimensions.height, 0],
      background: {
        bar: bar,
        circle: circle,
        rect: rect
      },
      text: {
        color: ['#A6A9AF', '#5C5C5C']
      },
      links: {
        href: this.links
      }
    }
  }

  _loadDomain() {
    return {
      x: this.steps.map((step) => {return step.title}),
      y: [1],
      text: {
        color: [true, false]
      },
      links: {
        href: this.steps.map((step) => {return step.title})
      }
    }
  }

  _loadScale() {
    var scale = {
      x: d3.scaleBand().domain(this.domain.x).range(this.range.x),
      y: d3.scaleBand().domain(this.domain.y).range(this.range.y)
    }
    scale.background = this._loadBackgroundScale(scale)
    scale.paths = this._loadProgressPathScale(scale)
    scale.text = this._loadTextScale(scale)
    scale.links = {
      href: d3.scaleOrdinal().domain(this.domain.links.href).range(this.range.links.href)
    }
    return scale
  }

  _loadTextScale(scale) {
    return {
      color: d3.scaleOrdinal().domain(this.domain.text.color).range(this.range.text.color)
    }
  }

  _loadProgressPathScale(scale) {
    var generateLine = d3.line()
    var bw = scale.x.bandwidth()
    var bw4 = scale.x.bandwidth()/4
    var bw2 = scale.x.bandwidth()/2
    var paths = {
      x1: (x) => {
        if(x.css_class === 'left') {
          return x.index === 0 ? (scale.x(x.step.title) + bw4) : scale.x(x.step.title)
        } else {
          return (scale.x(x.step.title) + (bw2))
        }
      },
      y1: () => {return scale.y(1) + (scale.y.bandwidth()/2)},
      x2: (x) => {
        var base = scale.x(x.step.title)
        if(x.css_class === 'left') {
          return base + bw2
        } else {
          return x.index+1 === this.steps.length ? (base + bw - bw4) : (base + bw)
        }
      },
      y2: () => {return scale.y(1) + (scale.y.bandwidth()/2)},
      stroke: (x) => {return '#C5AA80'}
    }
    paths.line = (x) => {
      return generateLine([[paths.x1(x), paths.y1()], [paths.x2(x), paths.y2()]])
    }
    return paths
  }

  _loadBackgroundScale(scale) {
    var bar = {y: () => {return scale.y(1) + (scale.y.bandwidth()/2) - (this.range.background.bar.height/2)}}
    var circle = {
      cy: () => {return scale.y(1) + scale.y.bandwidth()/2},
      cx: (x) => {return scale.x(x) + scale.x.bandwidth()/2}, 
    }
    var rect = {
      x: (x) => {return circle.cx(x) - (this.range.background.circle.r/2) - 6},
      y: () => {return circle.cy() - (this.range.background.bar.height/2)+1},
      width: () => {return this.range.background.rect.width},
      height: () => {return this.range.background.rect.height}
    }
    return {
      bar: bar,
      circle: circle,
      rect: rect
    }
  }

  _loadChart() {
    var svg = this.container.append('svg')
      .attr('width', this.dimensions.chartWidth)
      .attr('height', this.dimensions.chartHeight)
    var chart = svg.append('g')
      .attr('transform', this.dimensions.chartTransform)
    return chart
  }

  _drawAxes() {
    this.chart.selectAll('text')
      .data(this.steps)
      .enter()
      .append('text')
        .text((d) => {return d.title})
        .attr('x', (d) => {return this.scale.x(d.title)+(this.scale.x.bandwidth()/2)})
        .attr('y', (d) => {return this.scale.y(1)+this.scale.y.bandwidth()+10})
        .attr('text-anchor', 'middle')
        .style('font-size', '12px')
        .style('font-family', '"Akkurat-Regular", sans-serif')
        .attr('fill', (d) => {return this.scale.text.color(d.disabled)})
  }

  _drawBackgroundBar() {
    this.chart.append('rect')
      .attr('x', 0+(this.scale.x.bandwidth()/4))
      .attr('y', this.scale.background.bar.y())
      .attr('width', this.dimensions.width-(this.scale.x.bandwidth()/2))
      .attr('height', this.range.background.bar.height+'px')
      .attr('fill', '#FFFFFF')
      .attr('stroke-width', '1px')
      .attr('stroke', '#C4C4C4')
      .attr('rx', '6px')
  }

  _drawBackgroundCircles() {
    this.chart.selectAll('.pb-bg__circle')
      .data(this.steps.filter((step) => {return step.disabled == false}))
      .enter()
      .append('circle')
        .attr('class', 'pb-bg__circle')
        .attr('fill', '#FFFFFF')
        .attr('stroke-width', '1px')
        .attr('stroke', '#C4C4C4')
        .attr('cx', (step) => {return this.scale.background.circle.cx(step.title)})
        .attr('cy', (step) => {return this.scale.background.circle.cy()})
        .attr('r', this.range.background.circle.r)
    // rect to hide border on circle
    this.chart.selectAll('.pb-bg__rect')
      .data(this.steps.filter((step) => {return step.disabled == false}))
      .enter()
      .append('rect')
        .attr('class', 'pb-bg__rect')
        .attr('fill', '#FFFFFF')
        .attr('x', (step) => {return this.scale.background.rect.x(step.title)})
        .attr('y', (step) => {return this.scale.background.rect.y()})
        .attr('width', (step) => {return this.scale.background.rect.width()+'px'})
        .attr('height', (step) => {return this.scale.background.rect.height()+'px'})
  }

  _drawProgressPaths() {
    var generateLine = d3.line()
    this.chart.selectAll('.pb-path__group')
      .data(this.steps)
      .enter()
      .append('g')
        .attr('class', 'pb-path__group')
        .selectAll('.pb-path')
          .data((d, i) => {
            var data = []
            if(!d.disabled) {
              data.push({css_class: 'left', step: d, index: i})
            }
            if(d.complete) {
              data.push({css_class: 'right', step: d, index: i})
            }
            return data
          })
          .enter()
          .append('path')
            .attr('class', 'pb-path')
            .attr('d', (d) => {return this.scale.paths.line(d)})
            .attr('stroke', (d) => {return this.scale.paths.stroke(d)})
            .attr('stroke-width', '2px')
  }

  _drawProgressDots() {
    this.chart.selectAll('.bp-path__dot')
      .data(this.steps.filter((step) => {return step.disabled == false}))
      .enter()
      .append('circle')
        .attr('class', 'bp-path__dot')
        .attr('cx', (d) => {return this.scale.paths.x2({css_class: 'left', step: d})})
        .attr('cy', (d) => {return this.scale.paths.y1()})
        .attr('r', '3px')
        .attr('stroke-width', '2px')
        .attr('stroke', (d) => {return this.scale.paths.stroke(d)})
        .attr('fill', (d) => { return d.complete ? '#C5AA80' : '#FFFFFF'})
  }

  _drawLinks() {
    this.container.selectAll('a')
      .data(this.steps)
      .enter()
      .append('a')
        .attr('href', (d) => {
          if(d.disabled) {
            return "javascript:void(0)"
          } else {
            return this.scale.links.href(d.title)
          }
        })
        .style('left', (d) => {return this.scale.x(d.title)+'px'})
        .attr('class', (d) => {
          if(d.disabled) {
            return 'co-progress-bar__disabled'
          } 
        })
  }

  draw() {
    var yBandwidth = this.scale.y.bandwidth()
    this._drawAxes()
    this._drawBackgroundBar()
    this._drawBackgroundCircles()
    this._drawProgressPaths()
    this._drawProgressDots()
    this._drawLinks()
  }

}