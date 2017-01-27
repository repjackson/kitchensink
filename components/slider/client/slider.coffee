
Template.slider.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'slides'



Template.slider.onRendered ->
    Meteor.setTimeout (->
        $('#layerslider').layerSlider
            autoStart: true
            # firstLayer: 1
            # skin: 'borderlesslight'
            # skinsPath: '/static/layerslider/skins/'
        ), 1000
    
        # console.log 'ready'


Template.slider.helpers
    slides: -> 
        Docs.find {
            tags: $in: ['slide']
            },
            sort: order: 1