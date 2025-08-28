// Robust JS for srss page, works on iOS and all browsers
document.addEventListener('DOMContentLoaded', function() {
  function toLocal(dt) {
    // Use hour: 'numeric' for no leading zero, minute: '2-digit', and custom am/pm
    let str = new Date(dt).toLocaleTimeString([], {
      hour: 'numeric', minute: '2-digit', hour12: true
    });
    // Replace any non-digit suffix (am/pm, a.m./p.m., with/without space, etc.) with ' am' or ' pm'
    str = str.replace(/[^\d]+$/i, function(s) {
      return /a/i.test(s) ? ' am' : ' pm';
    });
    return str;
  }
  // Format date as local-only (not UTC) to avoid timezone shift, robust for iOS
  var dateElem = document.getElementById('srss-date');
  if (dateElem) {
    var dateStr = dateElem.textContent;
    // Parse as local date (YYYY-MM-DD) for cross-browser
    var parts = dateStr.split('-');
    if (parts.length === 3) {
      var localDate = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
      dateElem.textContent = localDate.toLocaleDateString('en-US', {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
      });
    }
  }
  // Format times
  var sunriseElem = document.getElementById('srss-sunrise');
  var sunsetElem = document.getElementById('srss-sunset');
  if (sunriseElem) sunriseElem.textContent = toLocal(sunriseElem.textContent);
  if (sunsetElem) sunsetElem.textContent = toLocal(sunsetElem.textContent);
});
