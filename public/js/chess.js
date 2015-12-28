var c = document.getElementById("mycanvas");
var ctx = c.getContext("2d");

var width = c.width;
var height = c.height;

var square_width = width / 8;
var square_height = height / 8;

var texture_size = 64;

var img = document.getElementById('chess-pieces');
var tile = document.getElementById('tiles');
var board, selected;

// shim layer with setTimeout fallback
window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          function( callback ){
            window.setTimeout(callback, 1000 / 60);
          };
})();


// usage:
// instead of setInterval(render, 16) ....

(function animloop(){
  requestAnimFrame(animloop);
  update();
  if (!!board) {
    render();
  }
})();
// place the rAF *before* the render() to assure as close to
// 60fps with the setTimeout fallback.

function update() {
  var jqxhr = $.getJSON( "games/board.json", function() {
  })
    .done(function(data) {
      board = data.board;
      selected = data.selected;
    })
    .fail(function() {
    })
    .always(function() {
    });
}

function render() {
  ctx.clearRect(0, 0, width, height);

  for ( var i = 0; i < 8; i++ ) {
    for ( var j = 0; j < 8; j++ ) {
      col = i;
      row = j;
      if ( col % 2 == 0 && row % 2 != 0 || col % 2 != 0 && row % 2 == 0 ) {
        var sourceX = 0;
      } else {
        var sourceX = texture_size;
      }

      ctx.drawImage(tile, sourceX, 0, texture_size, texture_size, col*square_width, row*square_height, square_width, square_height);

      piece_string = board[7-row][col];

      if ( piece_string != "00" ) {
        if ( piece_string[0] == "W" ) {
          sourceY = 0;
        } else {
          sourceY = texture_size;
        }

        if ( piece_string[1] == "P" ) {
          sourceX = 0;
        } else if ( piece_string[1] == "R" ) {
          sourceX = texture_size;
        } else if ( piece_string[1] == "N" ) {
          sourceX = texture_size*2;
        } else if ( piece_string[1] == "B" ) {
          sourceX = texture_size*3;
        } else if ( piece_string[1] == "Q" ) {
          sourceX = texture_size*4;
        } else {
          sourceX = texture_size*5;
        }

        ctx.drawImage(img, sourceX, sourceY, texture_size, texture_size, col*square_width, row*square_height, square_width, square_height);
      }
      if (!!selected) {
        if (7 - row === selected[0] && col === selected[1] ) {
          ctx.drawImage(tile, 0, texture_size, texture_size, texture_size, col*square_width, row*square_height, square_width, square_height);
        }
      }
    }
  }
}

function getMousePos(canvas, evt) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: evt.clientX - rect.left,
    y: evt.clientY - rect.top
  };
}

c.addEventListener('mousemove', function(evt) {
  var mousePos = getMousePos(canvas, evt);
}, false);
