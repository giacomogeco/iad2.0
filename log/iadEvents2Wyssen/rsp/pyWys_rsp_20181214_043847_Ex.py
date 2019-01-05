# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Ex", rtime = "20181214T043847", dur = 4, amp = 0.6, sector = "GP11", bkzOn = 43, bkzEnd = 43, bkzAv = 43, freq1 = 9, freq2 = 7, rel = "H", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)