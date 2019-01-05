# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190104T011000", dur = 69, amp = 0.16, sector = "Null", bkzOn = 248, bkzEnd = 254, bkzAv = 254, freq1 = 2, freq2 = 2, rel = "H", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)