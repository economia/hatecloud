var ext = document.createElement('script');
ext.type = 'text/javascript';
ext.async = false;
ext.src = './external.js';
var s = document.getElementsByTagName('script')[0];
s.parentNode.insertBefore(ext, s);
