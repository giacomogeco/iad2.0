# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Cav", rtime = "20190104T015700", dur = 64, amp = 0.221, sector = "Null", bkzOn = 28, bkzEnd = 25, bkzAv = 28, freq1 = 2, freq2 = 1, rel = "H", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)