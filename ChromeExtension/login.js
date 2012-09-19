

function reflect_login_status_callback(response) {
  if (response.user != '' && response.user != undefined) {
    document.getElementById('status').innerHTML = 'Already loggin-ed';
    document.getElementById('user').value = response.user;
    document.getElementById('password').value = response.password;
    document.getElementById('signup').style.visibility = "hidden";
    document.getElementById('login').style.visibility = "hidden";
    document.getElementById('logout').style.visibility = "visible";
  } else {
    document.getElementById('status').innerHTML = 'Not loggin-ed';
    document.getElementById('user').value = '';
    document.getElementById('password').value = '';
    document.getElementById('signup').style.visibility = "visible";
    document.getElementById('login').style.visibility = "visible";
    document.getElementById('logout').style.visibility = "hidden";
  }
}

var port1 = chrome.extension.connect({name:'get_login_user'});
port1.onMessage.addListener(reflect_login_status_callback);
port1.postMessage(reflect_login_status_callback);

function callback(result, message) {
  var status = document.getElementById('status');
  if (result) {
    status.innerHTML = "Message";
    setTimeout(function() { window.close(); }, 1000);
  } else {
    status.innerHTML = "Login failed. Try again (" + message + ")";
  }
}

function signUp(event) {
  var status = document.getElementById('status');
  status.innerHTML = "Creating new user...";
  event.preventDefault();
  var user = document.getElementById('user').value;
  var password = document.getElementById('password').value;
  //var bkpage = window.dialogArguments.getBackgroundPage();
  var bkpage = chrome.extension.getBackgroundPage();
  var port = chrome.extension.connect({name:'signup'});
  port.onMessage.addListener(reflect_login_status_callback);
  port.postMessage({'user':user, 'password':password});
  /*
     var bkpage = window.dialogArguments.backgroundPage;
     bkpage.signUp(user, password, callback, window.dialogArguments.loginCallback);
   */
}

function logIn(event) {
  status.innerHTML = "Logging-in...";
  event.preventDefault();
  var user = document.getElementById('user').value;
  var password = document.getElementById('password').value;
  var port = chrome.extension.connect({name:'login'});
  port.onMessage.addListener(reflect_login_status_callback);
  port.postMessage({'user':user, 'password':password});
}

function logOut(event) {
  var status = document.getElementById('status');
  status.innerHTML = "Logging out...";
  event.preventDefault();
  var port = chrome.extension.connect({name:'logout'});
  port.onMessage.addListener(reflect_login_status_callback);
  port.postMessage();
}

document.addEventListener('DOMContentLoaded', function () {
  document.getElementById('signup').addEventListener('click', signUp);
  document.getElementById('login').addEventListener('click', logIn);
  document.getElementById('logout').addEventListener('click', logOut);
});
