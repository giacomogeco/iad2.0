# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Cav", rtime = "20190104T004401", dur = 65, amp = 0.08, sector = "Null", bkzOn = 152, bkzEnd = 119, bkzAv = 138, freq1 = 3, freq2 = 2, rel = "H", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)