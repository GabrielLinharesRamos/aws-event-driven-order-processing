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


# logica para salvar no dynamoDB

dynamo = boto3.resource('dynamodb')

table = dynamo.Table('event-driven-orders')

def lambda_handler(event, context):
    try:
        table.put_item(
            Item={
                'id': str(uuid.uuid4()),
                'items': json.loads(event["body"]),
                'status': 'PENDING',
                'createdAt': datetime.utcnow().isoformat()
            }
        )

        return {
            'statusCode': 201,
            'body': json.dumps('order created')
        }

    except Exception as e:
        print(f"erro: {str(e)}")

        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Internal server error"
            })
        }



