# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Ex", rtime = "20190103T193951", dur = 4, amp = 0.023, sector = "GP4-GP3-GP2", bkzOn = 86, bkzEnd = 86, bkzAv = 86, freq1 = 4, freq2 = 3, rel = "H", sname = "HRM", sid = 7831)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)