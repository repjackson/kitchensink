ScrapeParser.registerHelper 'toInt', (str, url) ->
    parseInt '0' + str.replace(',', '')
ScrapeParser.registerHelper 'titleLinks', (arr, url) ->
    arr and arr.map((str) ->
        $ = cheerio.load(str)
        link = $('a.title')
        {
            link: link.attr('href')
            title: link.text()
        }
    )
# ScrapeParser.reset()
# Remove any/all stored parsers
# ScrapeParser.parser '.*azlyrics.com.*',
#     # topic:
#     #     path: 'meta[property="og:title"]'
#     #     attribute: 'content'
#     # subscribers:
#     #     path: '.subscribers .number'
#     #     content: true
#     #     helper: 'toInt'
#     links:
#         path: 'a'
#         attribute: 'href'
#         multi: true
#     # titles:
#     #     path: 'a.title'
#     #     content: true
#     #     multi: true
#     # titleLinks:
#     #     path: 'p.title'
#     #     content: true
#     #     helper: 'titleLinks'
#     #     multi: true
# ScrapeParser.resetExcept [ '.*reddit.com.*' ]
# Remove stored parsers except those in array

Meteor.methods
    scrape: ->
        result = ScrapeParser.get 'http://www.reddit.com/r/javascript/'
        console.log result
