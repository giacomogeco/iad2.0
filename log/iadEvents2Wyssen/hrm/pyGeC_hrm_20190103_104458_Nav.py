from smtplib import SMTP
import datetime
smtp = SMTP('smtp.gmail.com:587')
smtp.starttls()
smtp.login('sandrovezzosi@gmail.com', 'paciugO80')
from_addr = "sandrovezzosi@gmail.com"
to_addr = ['IAD@smshosting.it']
subj = "IDA-ALERT"
date = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )
message_text = "HRM Nav ALERT 2019-01-03 10:44:58 UT - Rel: M"
msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" %( from_addr, to_addr, subj, date, message_text )
smtp.sendmail(from_addr, to_addr, msg)
smtp.quit()
