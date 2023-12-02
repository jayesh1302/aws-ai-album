import json
import boto3
import requests
import time
from requests_aws4auth import AWS4Auth
import os
import base64
# Initialize S3 client
s3_client = boto3.client('s3')

def detect_labels(photo, bucket):
    labels_res = []

    client = boto3.client('rekognition')
    s3_clientobj = s3_client.get_object(Bucket=bucket, Key=photo)
    body=s3_clientobj['Body'].read().decode('utf-8')
    image = base64.b64decode(body)    

    response = client.detect_labels(Image={'Bytes':image}, MaxLabels=10)
    print('Detected labels for ' + photo)
    for label in response['Labels']:
        print("Label: " + label['Name'])
        labels_res.append(label['Name'])

    try:
        im_metadata = s3_client.head_object(Bucket=bucket, Key=photo)
        if 'Metadata' in im_metadata and 'customlabels' in im_metadata['Metadata']:
            user_labels = im_metadata['Metadata']['customlabels'].split(",")
            labels_res.extend(user_labels)
    except Exception as e:
        print(f"Error getting metadata for {photo}: {str(e)}")

    return labels_res

def lambda_handler(event, context):
    print('********** event **********    ',event)
    bucket = os.getenv('BUCKET_NAME')
    elastic_url = os.getenv('ES_ENDPOINT')

    region = 'us-east-1' 
    service = 'es'
    credentials = boto3.Session().get_credentials()
    awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

    for record in event['Records']:
        image_name = record["s3"]["object"]["key"]
        labels_res = detect_labels(image_name, bucket)
        print("labels result =====>>", labels_res)
        timestamp = time.time()
        query = {'objectKey': image_name, 'bucket': bucket, 'createdTimestamp': timestamp,'labels': labels_res}
        # response = requests.post(elastic_url, auth= awsauth, data = json.dumps(query), headers= headers)
        index_into_es(elastic_url,'photos',json.dumps(query), awsauth)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

def index_into_es(elastic_url, index, new_doc, awsauth):
    endpoint = f'{elastic_url}/{index}/_doc'  
    print(endpoint)
    headers = {'Content-Type': 'application/json'}
    try:
        res = requests.post(endpoint, auth=awsauth, data=new_doc, headers=headers)
        print(res)
    except Exception as e:
        print(f"Error indexing document: {str(e)}")

