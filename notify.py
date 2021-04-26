import os
import csv
import smtplib
import ssl
import subprocess
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# bind variables
working = '/etc/bind/named.conf.block'
new_bl = '/etc/bind/named.conf.block.new'
#num = os.system('diff -y --suppress-common-lines /etc/bind/named.conf.block.working_backup /etc/bind/named.conf.block | wc -l')
stream = os.popen('diff -y --suppress-common-lines /etc/bind/named.conf.block.working_backup /etc/bind/named.conf.block | wc -l')
num = stream.read().strip()

# Email variables
username = os.environ.get('SMTP_USERNAME')
password = os.environ.get('SMTP_PASSWORD')
receivers = os.environ.get('SMTP_RECEIVERS')
message = MIMEMultipart("alternative")
message["Subject"] = "DNS Blacklist Updated"
message["From"] = username
text = f"""\
    Hello,
    
    The DNS blacklist has been updated. The update contains {num} changes.
    
    Sincerely,
    
    Mr. Roboto
    """

# Construct MIMEMultipart message
part1 = MIMEText(text, "plain")
message.attach(part1)

# Create a secure SSL context and connect
context = ssl.create_default_context()
with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
    server.login(username, password)
    with open(receivers) as file:
        reader = csv.reader(file)
        next(reader)  # Skip header row
        for name, email in reader:
            server.sendmail(
                username,
                email,
                message.as_string(),
            )
    file.close()
