class Player
  constructor: ->
    @isPlaying = false

  play: (@currentlyPlayingSong) ->
    @isPlaying = true

  pause: ->
    @isPlaying = false

  resume: ->
    throw new Error "song is already playing" if @isPlaying
    @isPlaying = true

  makeFavorite: ->
    @currentlyPlayingSong.persistFavoriteStatus true

namespace = exports ? this
(namespace.Media ?= {}).Player = Player