---
layout: default
---

{% assign srss = site.data.srss %}
<link rel="stylesheet" href="/assets/css/srss.css">
<div class="srss-container">
  <div class="srss-title" style="font-family: 'Comic Sans MS', 'Comic Sans', 'Marker Felt', 'Arial Rounded MT Bold', 'Arial', 'sans-serif';">Sunrise &amp; Sunset</div>
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
<script src="/assets/js/srss.js"></script>