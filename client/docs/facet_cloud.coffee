@selectedTags = new ReactiveArray []


Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedTags.array()

Template.cloud.onRendered ->
    bubbleChart = new (d3.svg.BubbleChart)(
        supportResponsive: true
        size: 600
        innerRadius: 600 / 3.5
        radiusMin: 50
        data:
            items: [
                {
                    text: 'Java'
                    count: '236'
                }
                {
                    text: '.Net'
                    count: '382'
                }
                {
                    text: 'Php'
                    count: '170'
                }
                {
                    text: 'Ruby'
                    count: '123'
                }
                {
                    text: 'D'
                    count: '12'
                }
                {
                    text: 'Python'
                    count: '170'
                }
                {
                    text: 'C/C++'
                    count: '382'
                }
                {
                    text: 'Pascal'
                    count: '10'
                }
                {
                    text: 'Something'
                    count: '170'
                }
            ]
            eval: (item) ->
                item.count
            classed: (item) ->
                item.text.split(' ').join ''
        plugins: [
            {
                name: 'central-click'
                options:
                    text: '(See more detail)'
                    style:
                        'font-size': '12px'
                        'font-style': 'italic'
                        'font-family': 'Source Sans Pro, sans-serif'
                        'text-anchor': 'middle'
                        'fill': 'white'
                    attr: dy: '65px'
                    centralClick: ->
                        alert 'Here is more details!!'
                        return

            }
            {
                name: 'lines'
                options:
                    format: [
                        {
                            textField: 'count'
                            classed: count: true
                            style:
                                'font-size': '28px'
                                'font-family': 'Source Sans Pro, sans-serif'
                                'text-anchor': 'middle'
                                fill: 'white'
                            attr:
                                dy: '0px'
                                x: (d) ->
                                    d.cx
                                y: (d) ->
                                    d.cy

                        }
                        {
                            textField: 'text'
                            classed: text: true
                            style:
                                'font-size': '14px'
                                'font-family': 'Source Sans Pro, sans-serif'
                                'text-anchor': 'middle'
                                fill: 'white'
                            attr:
                                dy: '20px'
                                x: (d) ->
                                    d.cx
                                y: (d) ->
                                    d.cy

                        }
                    ]
                    centralFormat: [
                        {
                            style: 'font-size': '50px'
                            attr: {}
                        }
                        {
                            style: 'font-size': '30px'
                            attr: dy: '40px'
                        }
                    ]
            }
        ])
    return

Template.cloud.helpers
    globalTags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        # Tags.find()


    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass


    selectedTags: -> selectedTags.list()


Template.cloud.events
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selectedTags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selectedTags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selectedTags.pop()

    'click .selectTag': -> selectedTags.push @name

    'click .unselectTag': -> selectedTags.remove @valueOf()

    'click #clearTags': -> selectedTags.clear()
