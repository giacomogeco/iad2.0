# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190103T203500", dur = 38, amp = 0.17, sector = "Null", bkzOn = 308, bkzEnd = 255, bkzAv = 289, freq1 = 3, freq2 = 2, rel = "M", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)