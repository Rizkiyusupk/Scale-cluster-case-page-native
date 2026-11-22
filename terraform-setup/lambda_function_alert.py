import json
import os
import urllib.parse
import urllib.request

def lambda_handler(event, context):
    print(f"RAW EVENT: {json.dumps(event)}")
    for record in event['Records']:
        raw = record['Sns']['Message']
        try:
            alarm = json.loads(raw)
            text = (f"🚨 ALARM: {alarm['AlarmName']}\n"
                    f"State: {alarm['NewStateValue']}\n"
                    f"Reason: {alarm['NewStateReason']}")
        except (ValueError, KeyError):
            text = f"🚨 ALARM: {raw}"

        url = f"https://api.telegram.org/bot{os.environ['TELEGRAM_BOT_TOKEN']}/sendMessage"
        data = urllib.parse.urlencode({
            'chat_id': os.environ['TELEGRAM_CHAT_ID'],
            'text': text,
        }).encode()
        urllib.request.urlopen(url, data=data, timeout=8)