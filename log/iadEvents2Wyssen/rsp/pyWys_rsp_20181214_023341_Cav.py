# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Cav", rtime = "20181214T023341", dur = 53, amp = 0.144, sector = "Null", bkzOn = 323, bkzEnd = 288, bkzAv = 314, freq1 = 4, freq2 = 3, rel = "H", sname = "RSP", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)