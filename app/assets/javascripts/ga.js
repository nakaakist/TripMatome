var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-68849715-1']);
(function () {
    var ga = document.createElement('script');
    ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(ga, s);
})();
$(document).on("pageshow", '[data-role="page"]', function () {
    var url = location.pathname + location.hash;
    url ? _gaq.push(['_trackPageview', url]) : _gaq.push(['_trackPageview']);
});
