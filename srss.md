---
layout: default
---

{% assign srss = site.data.srss %}
<div class="container my-5 p-4 bg-light rounded shadow">
  <h2 class="display-5 text-warning mb-4 text-center">Sunrise &amp; Sunset</h2>
  <div class="row mb-3 justify-content-center align-items-center">
    <div class="col-auto fw-bold text-primary">Date:</div>
    <div class="col-auto h5 mb-0" id="srss-date">{{ srss.date }}</div>
  </div>
  <div class="row justify-content-center mb-2">
    <div class="col-auto">
      <img src="/assets/img/srss/sunrise.svg" alt="Sunrise" style="width:100px;height:100px;"/>
    </div>
  </div>
  <div class="row mb-3 justify-content-center align-items-center">
    <div class="col-auto fw-bold text-success">Sunrise:</div>
    <div class="col-auto h5 mb-0" id="srss-sunrise">{{ srss.sunrise }}</div>
  </div>
  <div class="row justify-content-center mb-2">
    <div class="col-auto">
      <img src="/assets/img/srss/sunset.svg" alt="Sunset" style="width:100px;height:100px;"/>
    </div>
  </div>
  <div class="row mb-3 justify-content-center align-items-center">
    <div class="col-auto fw-bold text-danger">Sunset:</div>
    <div class="col-auto h5 mb-0" id="srss-sunset">{{ srss.sunset }}</div>
  </div>
</div>
<script src="/assets/js/srss.js"></script>