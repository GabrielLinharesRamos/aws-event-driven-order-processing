import json
import uuid
import boto3
from datetime import datetime
import os

# logica para mandar para o sqs

client = boto3.client('sqs')

def lambda_handler(event,context):
    try:

        event_payload={
            'id': str(uuid.uuid4()),
            'payload': json.loads(event["body"]),
            'eventType': 'OrderCreated',
            'timestamp': datetime.utcnow().isoformat()
        }

        event_payload_serialized = json.dumps(event_payload)

        response = client.send_message(
            QueueUrl=os.environ["QUEUE_URL"],
            MessageBody=event_payload_serialized,
        )
        
        return {
            'statusCode': 202,
            'body': json.dumps('order Created')
        }
    
    except Exception as e:
        print(f"erro: {str(e)}")

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error"
            })
        }



