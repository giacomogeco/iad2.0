# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190103T100000", dur = 69, amp = 0.304, sector = "Null", bkzOn = 7, bkzEnd = 84, bkzAv = 11, freq1 = 4, freq2 = 2, rel = "M", sname = "HRM", sid = 7831)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)