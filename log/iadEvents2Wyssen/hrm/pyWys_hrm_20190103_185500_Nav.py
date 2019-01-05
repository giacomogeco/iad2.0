# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190103T185500", dur = 35, amp = 0.2, sector = "Null", bkzOn = 9, bkzEnd = 55, bkzAv = 28, freq1 = 4, freq2 = 3, rel = "M", sname = "HRM", sid = 7831)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)