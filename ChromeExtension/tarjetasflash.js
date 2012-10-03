
console.log("Hello! This is tarjetaflash - wordreference.js");

// Remove 'WordReference.com' top banner (not ad)
//$('td.namecell').parent('tr').remove();

// Remove top advertisement
// $('div#adleaderboard').parent("td.bannertop").parent('tr').remove();

// Remove right advertisement
//$('div#adright').parent('td.rightcolumn').remove();

// Remove 'Links'
//$('div.actionsH').remove();
//$('div.actions').remove();

// Remove 'Subscribe to the Oxford..' because it's too wide
//$('p.OxAd').remove();

// Avoid the left column from being too wide
//$('td.leftcolumn').attr('width', '120px');

// The names of dictionaries
//$('.small1').remove();

Array.prototype.unique = function() {
  var a = [];
  var l = this.length;
  for(var i=0; i<l; i++) {
    for(var j=i+1; j<l; j++) {
      // If this[i] is found later in the array
      if (this[i] === this[j])
        j = ++i;
    }
    a.push(this[i]);
  }
  return a;
};


// It doesn't work, returning an empty string
/*
String.prototype.unescapeHtml = function () {
    var temp = document.createElement("div");
    temp.innerHTML = this;
    var result = temp.childNodes[0].nodeValue;
    temp.removeChild(temp.firstChild);
    return result;
}
*/

// Search the text in the current tab containing a word and return it to the background page
chrome.extension.onConnect.addListener(function(port) {
  if (port.name != 'get_text') return;
  port.onMessage.addListener(function(request) {
    //var sentences = {};
    if (document.URL.indexOf('wordreference.com') == -1 &&
        document.URL.indexOf('.google.') == -1 && // Google Reader returns very strange results
        0 == document.URL.indexOf('http')) {
      var start = new Date().getTime();
      var text = $("body > *:not(css,script)").text();
      /*
      var text = ''
      $("body *:visible:not(:has(*))").each(function(){
        if ($(this).nodeName != 'SCRIPT' && $(this).nodeName != 'STYLE') {
          console.log("******** text=", $(this).text());
          text += $(this).text() + " . ";
        }
      });
      */
     // var text = $('body').text();
     // console.log(text);
      //console.log("==UNESCAPE===");
      //console.log(text.unescapeHtml());
      console.log("Time to get body text=", new Date().getTime() - start);
      console.log("body text length=", text.length);
      //console.log("text="+text);

      /*
      if (text.length > 70000) { 
        console.log("Don't search for the sentences because this page is too large");
      } else {
        start = new Date().getTime();
        var all_sentences_in_lowercases = {}
        for (var w=0; w < request.words.length; ++ w) {
          var word = request.words[w];
          console.assert(word.length > 0);
          // \u00E0-\u00FC matches the letter with the accent symbol
          var LETTER = 'a-z\u00E0-\u00FC'; 
          var L  = '[' + LETTER + ']';
          var NL  = '[^' + LETTER + ']';
          // These quotation marks are used a lot in Italian 
          var LEFT_QUOTE = '\u00AB'; // left_pointing_double_angle_quotation_mark
          var RIGHT_QUOTE = '\u00BB'; // right_pointing_double_angle_quotation_mark
          var RIGHT_SINGLE_QUOTE = '\u2019'; // right single quotation mark (italian)
          var LPS = '[' + LETTER + LEFT_QUOTE + RIGHT_QUOTE + RIGHT_SINGLE_QUOTE + ' :;\(\)"\',0-9\-]'; // letter, punctions, space, and ' 
          var E  = '[\.\?!]'; // end of sentence, !
          var regexp = new RegExp(E + '*(' + LPS + '*' + NL + '+' + word + NL + '+' + LPS + '*' + E + '?)', 'ig');
          var match;
          while (match = regexp.exec(text)) {
            var sent = match[1].replace( /^\s+|\s+$/g, ''); // trim spaces
            sent = sent.replace(/\s+/g, ' '); // replace multiple space with only one
            // This check is necessary since in the same document there may 
            // be many similar texts.
            var sentence_in_lowercase = sent.toLowerCase();
            if (!(sentence_in_lowercase in all_sentences_in_lowercases)) {
              all_sentences_in_lowercases[sentence_in_lowercase] = true;
              sentences[sent] = word;
              console.log('match by word "' + word + '" in sentence length (' + sent.length + ') "'+ sent + '"');
            }
          }
        }
        console.log("Time to run regexp=", new Date().getTime() - start);
        port.postMessage({'sentences': sentences, 'url': document.URL, 'title': document.title});
      }
      */
      port.postMessage({'text': text, 'url': document.URL, 'title': document.title});
    }
  });
});

/*
  <span class="clickable" onclick="redirectWR(event,&quot;OXiten&quot;)">
    <span class="forma"> strada</span> /<span class="fonetica"> 'strada</span>
*/
var elements = [];

// WordReference
// .hw ?
// <span class="forma">1. colle</span> (Italian)
//
// span.b is usually for reflexive verbs, listed under the non-reflexive ones
//   <ol><li><span class="b">alzarsi</span>
// Some words do not have English translations but only the definition in its language.
//   <tr><td id="centercolumn"><div id="article"><b>abbarbicarsi</b>
var words = $('.hw, .forma, ol[type="I"] > li > span.b, div#article > b').map(function(index, element) {
    // Trim leading and tailing non-alphabet characters
    // For example: "1. colle" and "2. colle"         
    var w = $(element).text().replace(/^[\s0-9.]+|[\s0-9.]+$/g, '');
    elements.push({'domObject': $(element), 'word': w});
    $(element).css('border', '2px solid yellowgreen');
    return w;
  }).get().unique(); 

// This usually doesn't happen, but we check it just in case when the 
// implementation of words is wrong by accident.
words = $.grep(words, function(w) { return -1 == w.indexOf(' '); }); 

//console.log(words.join(","));

if (words.length != 0) {
  var port = chrome.extension.connect({name:'get_login_user'});
  port.postMessage({});
  port.onMessage.addListener(function(response) {
    if (response.user == '') { 
      console.log("not login");
      //window.showModalDialog(chrome.extension.getURL("login.html"), chrome.extension);
      // window.open(chrome.extension.getURL('login.html'));
    } else {
      console.log("login, continue to remember_word");
      var word = words.join(",")
      var lang = '';
      var splits = document.location.pathname.split('/');
      
      // Spanish
      if ('es' == splits[1]) {
          if ('en' == splits[2]) lang = 'es'; else return;
      }
      
      // Italian
      if ('iten' == splits[1] || 1 == document.location.pathname.indexOf('definizione')) lang = 'it';
      else if ('enit' == splits[1]) return;

      // This check is necessary since sometimes jQuery selectors will match on dictionary.com
      if (lang == '') return;
      
      console.log("TarjetaFlash word: '" + word + "' language: '" + lang + "'");    

      var port2 = chrome.extension.connect({name:'remember_word'});
      port2.onMessage.addListener(function(response) {
       var existed = $.grep(elements, function(v) { return words.indexOf(v.word) > -1; });
       var color;
       if (response.existed > 0)
         color = 'yellow';
       else             
         color = 'greenyellow';

       $.each(existed, function(i, v) { 
         v.domObject.css('background-color', color);

         // Icons are from: http://www.iconarchive.com/show/red-orb-alphabet-icons-by-iconarchive.html 
         var img_filename = "";
         if (response.existed <= 9) {
           img_filename = "Number-" + response.existed + '-icon.png';
         } else {
           img_filename = "Math-plus-icon.png";
         }
         v.domObject.after('<img width=16 src="' + chrome.extension.getURL(img_filename) + '" />');
       }); // $.each(existed
      }); 

      port2.postMessage({'lang': lang, 'word': word, 'timestamp': Date.now()});

    }
  }); 
}
 

