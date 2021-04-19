import os, csv, smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Email variables
password = os.environ.get('SMTP_PASSWORD')
sender_email = "allen@shotover.com"
message = MIMEMultipart("alternative")
message["Subject"] = "DNS Blacklist Updated"
message["From"] = sender_email

text = """\
    Hello,
    
    The DNS blacklist has been updated. See attached for details (but not just yet).
    
    Sincerely,
    
    Mr. Roboto
    """

# Construct MIMEMultipart message
part1 = MIMEText(text, "plain")
message.attach(part1)

# Create a secure SSL context and connect
context = ssl.create_default_context()
with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
    server.login("allen@shotover.com", password)
    with open("dns_alertees.csv") as file:
        reader = csv.reader(file)
        next(reader)  # Skip header row
        for name, email in reader:
            server.sendmail(
                sender_email,
                email,
                message.as_string(),
            )
    file.close()