from __future__ import print_function
import pickle
import os.path
import sys
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import base64
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from apiclient import errors, discovery
import mimetypes
from email.mime.image import MIMEImage
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase


# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://mail.google.com/']

def main():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('emailbot/token.pickle'):
        with open('emailbot/token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'emailbot/credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('emailbot/token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('gmail', 'v1', credentials=creds)


    subject = "subject"
    msgPlain = ""

    with open("C:/Fulton-Bot/log.txt", "r", encoding="utf-16") as infile:
        for line in infile.readlines():
            msgPlain += line.rstrip()
            msgPlain += '\n'

    # Call the Gmail API
    msg = MIMEMultipart('alternative')
    msg['Subject'] = sys.argv[1]
    msg['From'] = 'notify.oddbot@gmail.com'
    msg['To'] = "fultonnewstart@empiresmart.com"
    # msg['To'] = "testfultonbot123@gmail.com"        # TODO: change email
    msg['BCC'] = "Tim@Odd-Bot.com, tleduc88@gmail.com"
    msg.attach(MIMEText(msgPlain, 'plain'))
    b64_bytes = base64.urlsafe_b64encode(msg.as_bytes())
    b64_string = b64_bytes.decode()
    message = {'raw': b64_string}
    text_file = open("emailLog.txt", "w")
    text_file.write(msgPlain)
    text_file.close()
    print(msgPlain)
    # return


    try:
        message = (service.users().messages().send(userId="me", body=message).execute())
        print('Message Id: %s' % message['id'])
    except errors.HttpError as error:
        print('An error occurred: %s' % error)

if __name__ == '__main__':
    main()