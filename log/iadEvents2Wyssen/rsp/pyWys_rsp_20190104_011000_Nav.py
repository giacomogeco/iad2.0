# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190104T011000", dur = 71, amp = 1.078, sector = "Null", bkzOn = 198, bkzEnd = 200, bkzAv = 205, freq1 = 3, freq2 = 2, rel = "M", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)