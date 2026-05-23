import json
import uuid
import boto3
from datetime import datetime
import os
import logging

# logica para mandar para o sqs

client = boto3.client('sqs')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event,context):

    event_payload   = {}

    try:

        event_payload={
            'id': str(uuid.uuid4()),
            'payload': json.loads(event["body"]),
            'eventType': 'OrderCreated',
            'timestamp': datetime.utcnow().isoformat()
        }

        event_payload_serialized = json.dumps(event_payload)

        response = client.send_message(
            QueueUrl    =os.environ["QUEUE_URL"],
            MessageBody =event_payload_serialized,
        )

        logger.info({
            "message": "message created",
            "event_id": event_payload.get("id"),
            "event_type": event_payload.get("eventType"),
            "status": "accepted"
        })
        
        return {
            'statusCode': 202,
            'body': json.dumps('order Created')
        }
    
    except Exception as e:
        logger.error({
            "message": "Failed creating order",
            "event_id": event_payload.get("id"),
            "event_type": event_payload.get("eventType"),
            "status": "failed",
            "error": str(e)
        })

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error"
            })
        }



