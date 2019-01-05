# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Cav", rtime = "20190104T020150", dur = 54, amp = 0.26, sector = "Null", bkzOn = 322, bkzEnd = 286, bkzAv = 311, freq1 = 3, freq2 = 2, rel = "H", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)