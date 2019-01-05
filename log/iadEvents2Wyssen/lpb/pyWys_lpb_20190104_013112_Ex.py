# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Ex", rtime = "20190104T013112", dur = 4, amp = 0.152, sector = "GP10", bkzOn = 240, bkzEnd = 240, bkzAv = 240, freq1 = 9, freq2 = 8, rel = "H", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)