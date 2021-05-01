from __future__ import print_function
import datetime
import pickle
import os.path
import sys
from dateutil import parser
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# Go to gmail bot and type this in:
# source env/bin/activate
# deactivate
# You might have to delete pickle file

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/calendar']


def main():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('CalendarBot/token.pickle'):
        with open('CalendarBot/token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'CalendarBot/credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('CalendarBot/token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('calendar', 'v3', credentials=creds)
    
    # argv[1] is is the date, everything after goes into summary
    summary = sys.argv[2]
    pastSummary = sys.argv[3]
    formerSummary = sys.argv[4]
    print(summary)

    date = parser.parse(sys.argv[1]).strftime('%Y-%m-%d')
    print(date)

    page_token = None
    updated = 0
    while True:
      events = service.events().list(calendarId='dlnti5k13hivhcralm49eojndk@group.calendar.google.com', pageToken=page_token).execute()
      for event in events['items']:
        if ((event['summary'] == summary) or (event['summary'] == pastSummary) or (event['summary'] == formerSummary)):
            try:
                newEvent = {
                  'summary': summary,
                  'location': '',
                  'description': event['description'],
                  'start': {
                    'date': date,
                    'timeZone': 'America/Phoenix',
                  },
                  'end': {
                    'date': date,
                    'timeZone': 'America/Phoenix',
                  },
                }
                print(event['description'])         
            except:
                newEvent = {
                  'summary': summary,
                  'location': '',
                  'description': '',
                  'start': {
                    'date': date,
                    'timeZone': 'America/Phoenix',
                  },
                  'end': {
                    'date': date,
                    'timeZone': 'America/Phoenix',
                  },
                }
            updated = 1
            # return
            try:
                print("Calendar event: '"+ summary +" "+ event['start']['date'] + " ' rescheduled to: " + date)
            except:
                text_file = open("emailLog.txt", "w")
                text = summary + " DATE: " + date
                text_file.write(text)
                text_file.close()   
            # return
            updated_event = service.events().update(calendarId='dlnti5k13hivhcralm49eojndk@group.calendar.google.com', eventId=event['id'], body=newEvent).execute()

      page_token = events.get('nextPageToken')
      if not page_token:
        break
        
    if (updated == 0):
        newEvent = {
          'summary': summary,
          'location': '',
          'description': '',
          'start': {
            'date': date,
            'timeZone': 'America/Phoenix',
          },
          'end': {
            'date': date,
            'timeZone': 'America/Phoenix',
          },
        }
        text_file = open("emailLog.txt", "w")
        text_file.write("Calendar event: '"+ summary +" " + " ' scheduled for: " + date)
        text_file.close()   
        event = service.events().insert(calendarId='dlnti5k13hivhcralm49eojndk@group.calendar.google.com', body=newEvent).execute()
        print ('Event created: %s' % (event.get('htmlLink')))

if __name__ == '__main__':
    main()