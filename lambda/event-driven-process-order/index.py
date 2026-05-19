import json
import uuid
import boto3
from datetime import datetime


# logica para salvar no dynamoDB

dynamo = boto3.resource('dynamodb')

table = dynamo.Table('event-driven-orders')

def lambda_handler(event, context):
    try:
        for record in event["Records"]:

            order_event = json.loads(record["body"])

            table.put_item(
                Item={
                    'id': order_event["id"],
                    'items': order_event["payload"],
                    'status': 'PENDING',
                    'createdAt': datetime.utcnow().isoformat()
                }
            )

        return {
            'statusCode': 202,
            'body': json.dumps('order Accepted')
        }

    except Exception as e:
        print(f"erro: {str(e)}")
        raise e



