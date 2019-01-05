# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Cav", rtime = "20190104T052244", dur = 57, amp = 0.033, sector = "Null", bkzOn = 42, bkzEnd = 69, bkzAv = 60, freq1 = 3, freq2 = 1, rel = "H", sname = "HRM", sid = 7831)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)