# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20181213T223133", dur = 80, amp = 0.081, sector = "Null", bkzOn = 323, bkzEnd = 291, bkzAv = 315, freq1 = 3, freq2 = 2, rel = "M", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)