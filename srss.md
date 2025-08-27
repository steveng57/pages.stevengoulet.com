---
layout: default
---

{% assign srss = site.data.srss %}
<div>
  <strong>Date:</strong> {{ srss.date | date: "%B %d, %Y" }}<br>
  <strong>Sunrise:</strong> {{ srss.sunrise | date: "%I:%M %p" }}<br>
  <strong>Sunset:</strong> {{ srss.sunset | date: "%I:%M %p" }}
</div>