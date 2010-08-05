var Playlist = Class.extend({

  currentItem: -1,
  positionSlider: null,

  init: function (player) {
    this.player = player;
  },

  start: function () {
    // listeners
    this.player.addModelListener('STATE', 'stateListener');
    this.player.addModelListener('TIME', 'timeListener'); 
    this.player.addModelListener('LOADED', 'loadedListener'); 

    // sliders
    this.positionSlider = $("#position_slider");
    this.positionSlider.slider();

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

  load: function (id) {
    this.currentItem = id;
    var item = $(this.cssForItem(id));
    var songId = item.data()['song']['id'];
    $('#items div').removeClass('playing');
    item.addClass('playing');
    var url = '/songs/' + songId + '.mp3'
    this.sendEvent('load', { type: 'sound', file: url });
    this.play();
  },

  seek: function (pos) {
    this.sendEvent('seek', pos);
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

  next: function () {

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
  },

  timeListener: function (dur, pos) {
    var loc = pos / dur * 100;
    this.positionSlider.slider("value", loc);
  },

  loadedListener: function (loaded, total, offset) {
    console.log('loaded: loaded='+loaded+' total='+total+' offset='+offset);
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
