

      var tag = document.createElement('script');

      tag.src = "https://www.youtube.com/iframe_api";
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

      var player;
      function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
			playerVars: {
			    modestbranding: true,
				controls: 1,
			  },
          height: '720',
          width: '1280',
		

          events: {
            'onReady': onPlayerReady,
            'onStateChange': onPlayerStateChange
          }
        });
      }

      // 4. The API will call this function when the video player is ready.
      function onPlayerReady(event) {
       event.target.playVideo();
      }

      var done = false;
      function onPlayerStateChange(event) {
        if (event.data == YT.PlayerState.PLAYING && !done) {
   
          done = true;
        }

		if(event.data == 0){
			//controller needs to pass in these parameters everytime the video ends
			loadVideoById({'videoId': 		, 'startSeconds': , 'endSeconds': , 'suggestedQuality': 'large'});
			event.target.playVideo();
		}

      }
      function stopVideo() {
        player.stopVideo();
      }
