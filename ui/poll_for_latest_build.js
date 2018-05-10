function fetchTimeOfLastGreenBuild() {
  return fetch('http://last-green-build-api.cfapps.io').then(function(response) {
    return response.text();
  });
}

function displayTimeSinceLastGreenBuild(lastBuildTimestamp){
  const currentTimestamp = Math.round(Date.now() / 1000);
  const duration = currentTimestamp - lastBuildTimestamp;
  const days = Math.floor(duration / 86400);
  const hours = Math.floor(duration % 86400 / 3600);

  const daysDisplay = document.querySelector('#days');
  const hoursDisplay = document.querySelector('#hours');

  daysDisplay.innerHTML = `${days}`.padStart(2, '0');
  hoursDisplay.innerHTML = `${hours}`.padStart(2, '0');
}

function fetchAndDisplayTimeOfLastGreenBuild(){
  fetchTimeOfLastGreenBuild().then(displayTimeSinceLastGreenBuild);
}

function autorun() {
  fetchAndDisplayTimeOfLastGreenBuild();
  setInterval(fetchAndDisplayTimeOfLastGreenBuild, 60000);
}

if (document.addEventListener) document.addEventListener("DOMContentLoaded", autorun, false);
else if (document.attachEvent) document.attachEvent("onreadystatechange", autorun);
else window.onload = autorun;
