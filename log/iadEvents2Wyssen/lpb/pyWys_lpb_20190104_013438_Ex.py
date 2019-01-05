# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Ex", rtime = "20190104T013438", dur = 4, amp = 0.155, sector = "GP10", bkzOn = 239, bkzEnd = 239, bkzAv = 239, freq1 = 8, freq2 = 8, rel = "H", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)