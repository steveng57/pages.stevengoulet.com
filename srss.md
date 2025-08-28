---
layout: default
---

{% assign srss = site.data.srss %}
<div>
  <strong>Date:</strong> <span id="srss-date">{{ srss.date }}</span><br>
  <strong>Sunrise:</strong> <span id="srss-sunrise">{{ srss.sunrise }}</span><br>
  <strong>Sunset:</strong> <span id="srss-sunset">{{ srss.sunset }}</span>
</div>
<script>
function toLocal(dt) {
  return new Date(dt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}
document.getElementById('srss-sunrise').textContent = toLocal(document.getElementById('srss-sunrise').textContent);
document.getElementById('srss-sunset').textContent = toLocal(document.getElementById('srss-sunset').textContent);
</script>