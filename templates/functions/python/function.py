from __future__ import print_function
import boto3
import json

# Read the .env file
ENV = {}
with open(".env") as f:
    for line in f:
       (key, val) = line.strip().split("=")
       ENV[key] = val

#------------------------ Event receiver function -----------------------
def test_function(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    print("Lambdart env: %s" % (ENV['LAMBDART_ENV']))

