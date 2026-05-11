import json
import uuid
import boto3
from datetime import datetime

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



