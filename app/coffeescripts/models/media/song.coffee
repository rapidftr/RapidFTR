class Song
  persistFavoriteStatus: (value) ->
    "throw new Error not yet implemented"
    
namespace = exports ? window
(namespace.Media ?= {}).Song = Song