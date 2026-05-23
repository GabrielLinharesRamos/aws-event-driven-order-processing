import json
import uuid
import boto3
from datetime import datetime
import os
import logging


# logica para salvar no dynamoDB

dynamo = boto3.resource('dynamodb')

table = dynamo.Table(os.environ["ORDERS_TABLE"])
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        for record in event["Records"]:

            order_event = json.loads(record["body"])

            #teste de resiliência (comentar)

            # if order_event["payload"]["product"] == "fail":
            #     raise Exception("Falha simulada")

            #fim do teste

            table.put_item(
                Item={
                    'id': order_event["id"],
                    'items': order_event["payload"],
                    'status': 'PENDING',
                    'createdAt': datetime.utcnow().isoformat()
                },
                ConditionExpression="attribute_not_exists(id)",
            )

        return {
            'statusCode': 202,
            'body': json.dumps('order Accepted')
        }
    
    except dynamo.meta.client.exceptions.ConditionalCheckFailedException:
        logger.info({
            "message": "Duplicate event detected",
            "event_id": order_event["id"],
            "event_type": order_event["eventType"],
            "status": "ignored"
        })

    except Exception as e:
        logger.error({
            "message": "Failed processing order",
            "event_id": order_event["id"],
            "event_type": order_event["eventType"],
            "status": "failed",
            "erro": str(e)
        })
        raise e



