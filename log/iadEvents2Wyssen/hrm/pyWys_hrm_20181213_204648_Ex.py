# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Ex", rtime = "20181213T204648", dur = 4, amp = 0.025, sector = "GP4-GP3-GP2", bkzOn = 83, bkzEnd = 83, bkzAv = 83, freq1 = 6, freq2 = 5, rel = "H", sname = "HRM", sid = 7831)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)