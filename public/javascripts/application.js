var Playlist = Class.extend({

  duration: -1,

  positionSlider: null,
  sliderInMotion: false,

  init: function (player) {
    this.player = player;
  },

  start: function () {
    // listeners
    this.player.addModelListener('STATE', 'stateListener');
    this.player.addModelListener('TIME', 'timeListener'); 
    this.player.addModelListener('LOADED', 'loadedListener'); 

    // sliders
    var self = this;
    this.positionSlider = $("#position_slider");
    this.positionSlider.slider({
      start: function (event, ui) {
        self.sliderInMotion = true;
      },
      stop: function (event, ui) {
        self.seek(ui.value);
        self.sliderInMotion = false;
      }
    });

    this.volume(80);
    console.log('playlist has started');
  },

  sendEvent: function (name, arg) {
    name = name.toUpperCase();
    if (arg == undefined) {
      console.log('sending event="'+name+'"');
      this.player.sendEvent(name);
    }
    else {
      console.log('sending event="'+name+'" arg="'+arg+'"');
      this.player.sendEvent(name, arg);
    }
  },

  currentItem: function () {
    return $('div.playing');
  },

  load: function (itemId) {
    $('div.playlist_item').removeClass('playing');
    var item = $(this.cssForItem(itemId));
    item.addClass('playing');
    this.sendEvent('load', { type: 'sound', file: '/songs/' + item.data()['song']['id'] + '.mp3' });
    setTimeout('playlist.play()', 500);
  },

  seek: function (pos) {
    this.sendEvent('seek', pos * this.duration / 100);
  },

  volume: function (percent) {
    this.sendEvent('volume', percent);
  },

  playToggle: function () {
    this.sendEvent('play');
  },

  play: function () {
    this.sendEvent('play', true);
  },

  pause: function () {
    this.sendEvent('play', false);
  },

  playItem: function (item) {
    if (item.length) {
      item.effect('highlight');
      this.load(item.attr('id').split('_')[2]);
    }
  },

  next: function () {
    this.playItem(this.currentItem().next('.playlist_item'));
  },

  previous: function () {
    this.playItem(this.currentItem().prev('.playlist_item'));
  },

  cssForSong: function (id) {
    return '#song_' + id;
  },

  cssForItem: function (id) {
    return '#playlist_item_' + id;
  },

  // listeners
  stateListener: function (oldState, newState) {
    console.log('state: '+oldState+' => '+newState);
    if (oldState == 'IDLE' && newState == 'COMPLETED') {
      this.next();
    }
  },

  timeListener: function (dur, pos) {
    this.duration = dur;
    $('#time').text(this.formatTime(pos) + '/' + this.formatTime(dur));
    if (!this.sliderInMotion) {
      this.positionSlider.slider("value", pos / dur * 100);
    }
  },

  loadedListener: function (loaded, total, offset) {
    console.log("loaded="+loaded+" total="+total);
    var percent = 100 * Math.round(loaded / total * 10) / 10
    if (loaded == 0 && total == 0) percent = 100.0
    $('#load').text(percent + '%');
  },

  formatTime: function(time) {
    var mins = parseInt(time / 60);
    var secs = parseInt(time % 60);
    if (secs < 10) secs = "0" + secs;
    return mins + ":" + secs;
  }

});

var playlist = null;

function playerReady(obj) {
  if (playlist == null) {
    playlist = new Playlist(document.getElementById('ply'));
    playlist.start();
  }
}

function stateListener(obj) {
  playlist.stateListener(obj.oldstate, obj.newstate);
}
function timeListener(obj) {
  playlist.timeListener(obj.duration, obj.position);
}
function loadedListener(obj) {
  playlist.loadedListener(obj.loaded, obj.total, obj.offset);
}

$(function () {
  setTimeout('playerReady()', 500);
});
