beforeEach ->
  this.addMatchers {
      toBePlaying: (expectedSong) ->
        player = @actual
        (player.currentlyPlayingSong == expectedSong) && player.isPlaying
    }
