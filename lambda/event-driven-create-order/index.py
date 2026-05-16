import json
import uuid
import boto3
from datetime import datetime

# logica para mandar para o sqs

client = boto3.client('sqs')

def lambda_handler(event,context):
    event_payload={
        'id': str(uuid.uuid4()),
        'payload': json.loads(event["body"]),
        'eventType': 'OrderCreated',
        'timestamp': datetime.utcnow().isoformat()
    }

    event_payload_serialized = json.dumps(event_payload)

    response = client.send_message(
        QueueUrl='string',
        MessageBody=event_payload_serialized,
    )



