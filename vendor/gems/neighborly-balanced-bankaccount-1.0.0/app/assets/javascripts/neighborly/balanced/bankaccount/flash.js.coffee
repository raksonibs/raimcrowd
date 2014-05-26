Neighborly.Neighborly                               ?= {}
Neighborly.Neighborly.Balanced                      ?= {}
Neighborly.Neighborly.Balanced.Bankaccount          ?= {}

Neighborly.Neighborly.Balanced.Bankaccount.Flash =
  message: (text)->
    this.remove()
    alertBox         = $('<div>', { 'class': 'alert-box error text-center', 'html':
                         $('<h5>', { 'html': text })
                       } )
    errorBoxWrapper  = $('<div>', { 'class': 'error-box large-12 columns hide', 'html': alertBox}).insertBefore('.neighborly-balanced-bankaccount-form .submit')
    errorBoxWrapper.fadeIn(300)

  remove: ->
    $('.error-box').remove()

