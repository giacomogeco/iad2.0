# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190104T010836", dur = 155, amp = 1.078, sector = "Null", bkzOn = 187, bkzEnd = 200, bkzAv = 193, freq1 = 2, freq2 = 1, rel = "H", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)