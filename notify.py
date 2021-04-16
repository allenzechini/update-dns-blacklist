import smtplib, ssl

port = 465  # For SSL
password = ""

sender_email = "alerts@shotover.com"
receiver_email = "allen@shotover.com, logan@shotover.com"
message = """\
    Subject: Hi there

    This message is sent from Python.
    """

# Create a secure SSL context
context = ssl.create_default_context()

with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
    server.login("alerts@shotover.com", password)
    server.sendmail(sender_email, receiver_email, message)