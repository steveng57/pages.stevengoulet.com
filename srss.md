---
layout: default
---

{% assign srss = site.data.srss %}
<link rel="stylesheet" href="/assets/css/srss.css">
<div class="srss-container">
  <div class="srss-title">Sunrise &amp; Sunset</div>
  <div class="srss-row">
    <span class="srss-label">Date:</span>
  <span class="srss-value" id="srss-date">{{ srss.date }}</span>
  </div>
  <div class="srss-row">
    <img src="/assets/img/srss/sunrise.svg" alt="Sunrise" class="srss-graphic"/>
  </div>
  <div class="srss-row">
    <span class="srss-label">Sunrise:</span>
    <span class="srss-value" id="srss-sunrise">{{ srss.sunrise }}</span>
  </div>
  <div class="srss-row">
    <img src="/assets/img/srss/sunset.svg" alt="Sunset" class="srss-graphic"/>
  </div>
  <div class="srss-row">
    <span class="srss-label">Sunset:</span>
    <span class="srss-value" id="srss-sunset">{{ srss.sunset }}</span>
  </div>
</div>
<script>

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
// Format date as local-only (not UTC) to avoid timezone shift
const dateElem = document.getElementById('srss-date');
const dateStr = dateElem.textContent;
// Parse as local date (YYYY-MM-DD)
const parts = dateStr.split('-');
const localDate = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
dateElem.textContent = localDate.toLocaleDateString('en-US', {
  weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
});
// Format times
document.getElementById('srss-sunrise').textContent = toLocal(document.getElementById('srss-sunrise').textContent);
document.getElementById('srss-sunset').textContent = toLocal(document.getElementById('srss-sunset').textContent);
</script>