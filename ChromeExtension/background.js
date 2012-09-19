Parse.initialize("xvt7zz08Ye9MFDn7OIVJ91IPOlU9LaOr4fJgqgS6", "poPYUlOnq2T4HAZaCLR6VPr3MilvkdAt1sRG5SBU"); 

String.prototype.format = function() {
    var formatted = this;
    for (var i = 0; i < arguments.length; i++) {
        var regexp = new RegExp('\\{'+i+'\\}', 'gi');
        formatted = formatted.replace(regexp, arguments[i]);
    } 
    return formatted;
};

var user = localStorage.user;
var password = localStorage.password;
if (user != undefined) {
  logIn(user, password, null);
}

chrome.extension.onConnect.addListener(function(port) {
  if (port.name != 'get_login_user') return;
  port.onMessage.addListener(function (request) { 
    console.log("get_login_user_listener");
    var u = Parse.User.current();
    if (u) {
      port.postMessage({'user': u.getUsername(), 'password': localStorage.password});
    } else {
      port.postMessage({'user': '', 'password': ''});
    }
  });
});

chrome.extension.onConnect.addListener(function(port) {
  if (port.name != 'login') return;
  port.onMessage.addListener(function(request) {
    logIn(request.user, request.password, port);
  });
});


chrome.extension.onConnect.addListener(function(port) {
  if (port.name != 'signup') return;
  port.onMessage.addListener(function(request) {
    signUp(request.user, request.password, port);
  });
});

chrome.extension.onConnect.addListener(function(port) {
  if (port.name != 'logout') return;
  port.onMessage.addListener(function(request) { 
    var u = Parse.User.current();
    if (u) { 
      Parse.User.logOut();
    } 
    localStorage.user = '';
    localStorage.password = '';
    port.postMessage({'user': '', 'password': ''});
  });
});

chrome.extension.onConnect.addListener(function(port) {
  if (port.name != "remember_word") return;
  port.onMessage.addListener(function(request) {
    console.log("onMessage_Parse, word=" + request.word);
    var Entry = Parse.Object.extend("Entry");
    var query = new Parse.Query(Entry);
    query.equalTo("user", Parse.User.current()); // This may not be necessary

    /* Note that request.word may be a comma seperated string.
       This is to avoid:
        1. Find 'gratifica', WR gives you two words, so a new Entry will be create with 'words'='gratifica,gratificare'
        2. Then find 'gratificare'. Using simply query.equalTo('word', 'gratificare') won't tell
           you that this word should be considered as existing.
        The same for swap step 1 and 2.
    */
    var W = '(' + request.word.replace(',', '|') + ')';
    var regexp = ['^' + W + '$', '^' + W + ',', ',' + W + ',', ',' + W + '$'].join('|');
    query.matches('word', new RegExp(regexp));

    query.equalTo("lang", request.lang);
    query.first({
      // It's necessary to create a closure here to capture 'port'
      success: function(port, request) {
        return function(entry_found) {
          var words = request.word.split(',');

          // REFACTORING: this should be done in the content script
          var substrings = words.slice();
          var url_components = port.sender.tab.url.split('/');
          if (url_components.length > 0) {
            var last_url_component = decodeURIComponent(url_components[url_components.length - 1]).toLowerCase();
            // The string which user has typed in the search box of WordReference
            // It can be a conjugated verb but WordReference will find the infinite form for you.
            var original_lookup = ''
            if ('it' == request.lang) 
              original_lookup = last_url_component;
            else if ('es' == request.lang) {
              // http://www.wordreference.com/es/en/translation.asp?spen=pite
              original_lookup = last_url_component.split('=')[1];
            }
            if (substrings.indexOf(original_lookup) == -1) 
              substrings.push(original_lookup);
          }

          if (entry_found != undefined) {

            // See the comment above of the regular expression to match 'word'
            if (request.word.length > entry_found.get("word").length) {
              entry_found.set("word", request.word);
            }

            // do the calculation in local time
            var now = new Date();
            // entry_found.updateAt is a string of ISO 8601 format
            // Date() will always return an object in local time,
            // the conversion is done automatically.
            var updatedAt = new Date(entry_found.updatedAt);
            var diff = now.getTime() - updatedAt.getTime(); // in milliseconds
            var lookups = parseInt(entry_found.get("lookups"));
            var skip_check = false;  // only for debugging
            if (diff > 30 * 60000 || skip_check) { // 30 minutes
              lookups = lookups + 1;
              entry_found.increment("lookups");
            } 
            entry_found.save();
            port.postMessage({'word': words, 'existed': lookups});
            find_matched_sentences(entry_found.id, substrings, false);
          } else { // reach here also when there is no current user 
            port.postMessage({'word': words, 'existed': 1});

            var Entry = Parse.Object.extend("Entry");
            var entry = new Entry();
            entry.set("user", Parse.User.current());
            entry.set("word", request.word);
            entry.set("lang", request.lang);
            entry.set("lookups", 1);
            entry.save(null, {
              success: function(savedEntry) {
                return function() {
                  find_matched_sentences(savedEntry.id, substrings, true);
                }();
              }
            });
          }

        }; // return function(entry_found)
      }(port, request) // success
    }); // first
  }); // addListener
});  


function find_matched_sentences(entryObjectId, substrings, new_word) {
  for (var t in tabs) {
    var tab_id = tabs[t].id;
    console.log("t=" + t + " tab_id=" + tab_id + " url=" + tabs[t].url);
    var port = chrome.tabs.connect(tab_id, {name:'search_sentences'});
    port.onMessage.addListener(function() {
      return function(response) { 
        for (var s in response.sentences) {
          if (response.sentences.hasOwnProperty(s)) {
            var Note = Parse.Object.extend("Note");

            // Always query for the existing note because even if
            // it's a new word, the same note may have been already 
            // added from the other tab
            var query = new Parse.Query(Note);
            query.equalTo("entryObjectId", entryObjectId);
            query.equalTo("note", s);
            query.count({
              success: function(s) {
                return function(count) {
                  if (0 == count) {
                    var note = new Note();
                    note.set("entryObjectId", entryObjectId);
                    note.set('note', s);
                    note.set('word', response.sentences[s]);
                    note.set('url', response.url);
                    note.set('title', response.title);
                    note.save();
                  }
                };
              }(s) // success
            }); // query.count
          }
        } // for
      } // function(response)
    }()); // addListener
    port.postMessage({'words': substrings});
  }                       
}

function signUp(user, password, port) {
  var u = new Parse.User();
  u.set('username', user);
  u.set('password', password);
  u.signUp(null, {
    success: function(u) {
      localStorage.user = user;
      localStorage.password = password;
      port.postMessage({'user': user, 'password': password});
    },
    error: function(u, error) {
      port.postMessage({'error_message': error.message});
    }
  });
}

function logIn(user, password, port) {
  Parse.User.logIn(user, password, {
    success: function(u) {
      localStorage.user = user;
      localStorage.password = password;
      if (port) port.postMessage({'user': user, 'password': password});
    },
    error: function(u, error) {
      if (port) port.postMessage({'error_message': error.message});
    }
  });
}

var tabs = [];
chrome.tabs.onCreated.addListener(function(tab) {
  tabs.push(tab);
});

chrome.tabs.onRemoved.addListener(function(tab_id) {
  for (var t in tabs) {
    if (tabs[t].id == tab_id) {
      tabs.splice(t, 1);
    }
  }
});
  
