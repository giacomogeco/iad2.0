# -*- coding: utf-8 -*-
import requests
import base64
from requests.auth import HTTPBasicAuth
url = "https://control.wyssenavalanche.com/app/api/ida/new-event.php"
data = dict(key = "zC8AqKrpAw-8tHawJGiDT-R80ab1PRic", type = "Nav", rtime = "20181214T224243", dur = 124, amp = 0.092, sector = "Null", bkzOn = 323, bkzEnd = 290, bkzAv = 306, freq1 = 3, freq2 = 2, rel = "M", sname = "LPB", sid = 7843)
r = requests.post(url, data=data, allow_redirects=True)
print(r.content)