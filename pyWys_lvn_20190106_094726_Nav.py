# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20190106T094726", dur = 57, amp = 0.141, sector = "Sarasteinen", bkzOn = 285, bkzEnd = 309, bkzAv = 298, freq1 = 3, freq2 = 2, rel = "H", sname = "LVN", sid = 7963)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)