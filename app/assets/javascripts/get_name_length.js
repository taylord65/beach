<script type="text/javascript">
    function youtubeFeedCallback(json){
    document.write("Title: " + json["data"]["title"] + "<br>");
    document.write("Duration: " + json["data"]["duration"] + "<br>");
    }
</script>
<script type="text/javascript" src=("http://gdata.youtube.com/feeds/api/videos/" + W8YAK8oMEKI + "?v=2&alt=jsonc&callback=youtubeFeedCallback&prettyprint=true")></script>