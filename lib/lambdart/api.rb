


#create_rest_api(options = {}) ⇒ Types::RestApi - Creates a new RestApi resource.
resp = client.create_rest_api({
  name: "String", # required
  description: "String",
  clone_from: "String",
})
#create_resource(options = {}) ⇒ Types::Resource - Creates a Resource resource.
resp = client.create_resource({
  rest_api_id: "String", # required
  parent_id: "String", # required (eg '/' or '/parent')
  path_part: "String", # required last part of path (eg 'child' or 'post')
})
#put_method(options = {}) ⇒ Types::Method - Add a method to an existing Resource resource.
resp = client.put_method({
  rest_api_id: "String", # required
  resource_id: "String", # required
  http_method: "String", # required (eg 'GET')
  authorization_type: "String", # required (eg 'None' for default?)
  authorizer_id: "String", # Specifies the identifier of an Authorizer to use on this Method, if the type is CUSTOM
  api_key_required: false, # Specifies whether the method required a valid ApiKey
  request_parameters: {
    "String" => true,
  },
  request_models: {
    "String" => "String",
  },
})


#Integration - API Gateway uses mapping templates to transform incoming requests before they are sent to the integration back end. With API Gateway, you can define one mapping template for each possible content type. The content type selection is based on the Content-Type header of the incoming request. If no content type is specified in the request, API Gateway uses an application/json mapping template. By default, mapping templates are configured to simply pass through the request input. Mapping templates use Apache Velocity to generate a request for your back end. <a href=&quot;http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html&quot; target=&quot;_blank&quot;>The reference documentation</a> lists all of the properties and functions that API Gateway makes available in the templates."


#delete_deployment(options = {}) ⇒ Struct - Deletes a Deployment resource.
#delete_domain_name(options = {}) ⇒ Struct - Deletes the DomainName resource.







# See also:
# https://github.com/serverless/serverless/blob/f6add73f4b4f44c5c0ec94395c0867ec27e71f95/lib/actions/EndpointBuildApiGateway.js




require 'yaml'
require 'aws-sdk'
require 'json'
creds = YAML.load(File.read('secrets.yml'))
client = Aws::APIGateway::Client.new(
  access_key_id: creds['AWS_ACCESS_KEY_ID'],
  secret_access_key: creds['AWS_SECRET_ACCESS_KEY'],
  region: creds['AWS_DEFAULT_REGION']
)
client.get_rest_apis
client.get_resources({rest_api_id:"wz6zgytkce"})
ient.get_integration({rest_api_id:"wz6zgytkce", resource_id:"clpvw5", http_method:"GET"}) => {
  "type": "AWS",
  "http_method": "POST",
  "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:292654076870:function:apigatewaytest/invocations",
  "request_templates": {
    "application/json": "{\n  \"method\": \"$context.httpMethod\",\n  \"body\" : $input.json('$'),\n  \"headers\": {\n    #foreach($param in $input.params().header.keySet())\n    \"$param\": \"$util.escapeJavaScript($input.params().header.get($param))\" #if($foreach.hasNext),#end\n\n    #end\n  },\n  \"queryParams\": {\n    #foreach($param in $input.params().querystring.keySet())\n    \"$param\": \"$util.escapeJavaScript($input.params().querystring.get($param))\" #if($foreach.hasNext),#end\n\n    #end\n  },\n  \"pathParams\": {\n    #foreach($param in $input.params().path.keySet())\n    \"$param\": \"$util.escapeJavaScript($input.params().path.get($param))\" #if($foreach.hasNext),#end\n\n    #end\n  }  \n}"
  },
  "cache_namespace": "clpvw5",
  "cache_key_parameters": [

  ],
  "integration_responses": {
    "200": {
      "status_code": "200",
      "selection_pattern": ".*"
    }
  }
}







request_template = %{{
  "method": "$context.httpMethod",
  "body" : $input.json('$'),
  "headers": {
    #foreach($param in $input.params().header.keySet())
    "$param": "$util.escapeJavaScript($input.params().header.get($param))" #if($foreach.hasNext),#end

    #end
  },
  "queryParams": {
    #foreach($param in $input.params().querystring.keySet())
    "$param": "$util.escapeJavaScript($input.params().querystring.get($param))" #if($foreach.hasNext),#end

    #end
  },
  "pathParams": {
    #foreach($param in $input.params().path.keySet())
    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end

    #end
  }  
}}












# create api
resp = client.create_rest_api({
  name: api['name'],
  description: api['description'],
  clone_from: nil,
})
api['id'] = resp[:id]
# create resource
root_resource_id = client.get_resources({rest_api_id:api['id']})[:items][0][:id]
resp = client.create_resource({
  rest_api_id: api['id'],
  parent_id: root_resource_id,
  path_part: api['path'],
})
resource = resp
# create method (request?)
resp = client.put_method({
  rest_api_id: api['id'],
  resource_id: resource[:id],
  http_method: "GET",
  authorization_type: "NONE", 
  #authorizer_id: "String",
  api_key_required: false,
#  request_parameters: {
#  },
#  request_models: {
#  },
})
method = resp
# create integration
farn = "arn:aws:lambda:us-east-1:362572083286:function:apitester"
farn = "arn:aws:lambda:us-east-1:292654076870:function:apigatewaytest"
uri_data = {
  aws_region: "us-east-1",
  api_version: "2015-03-31",
  aws_acct_id: "362572083286",
  lambda_function_name: "apitester",
  aws_api_id: api['id'],
  http_method: "GET",
}
uri = "arn:aws:apigateway:%{aws_region}:lambda:path/%{api_version}/functions/arn:aws:lambda:%{aws_region}:%{aws_acct_id}:function:%{lambda_function_name}/invocations" % uri_data
client.put_integration({
  rest_api_id: api['id'],
  resource_id: resource[:id],
  http_method: "POST",
  type: "AWS",
  integration_http_method: "POST", 
  uri: uri,
#  credentials: nil,
#  request_parameters: nil,
#  request_templates: {
#    "application/json" => request_template
#  },
#  cache_namespace: nil,
#  cache_key_parameters: []
})

# does this have to be first?!?
resp = client.put_method_response({
  rest_api_id: api['id'],
  resource_id: resource[:id],
  http_method: "GET",
  status_code: "204", # status code
  response_parameters: nil,
  response_models: {}
})
# does this have to be after put method response?
client.put_integration_response({
  rest_api_id: api['id'],
  resource_id: resource['id'],
  http_method: "GET",
  status_code: "204", # status code
  selection_pattern: "resp204.*",
  response_parameters: nil,
  response_templates: nil
})


# create a deployment
# stages should probably be specified in a file, maybe an API config of some sort
stage = {"v1"=>"It's like a stage or whatever man"} # should probably be passed into the deploy function
# TODO: check if deployment exists, if so update it, if not, create it?
resp = client.create_deployment({
  rest_api_id: api["id"],
  stage_name: stage.keys[0],
  stage_description: stage[stage.keys[0]],
  description: "No clue what goes here to be tolly honest",
  #cache_cluster_enabled: true,
  #cache_cluster_size: "0.5", # accepts 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237
  #variables: {
  #  "String" => "String",
  #},
})




# also need to add a permission to the function so we get something along these lines (example with and without conditions)
    {
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:execute-api:us-east-1:292654076870:wz6zgytkce/*/GET/apigatewaytest"
        }
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:292654076870:function:apigatewaytest",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Sid": "259585cf-250f-4806-99c7-ca5431a3a577"
    },
    {
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-1:292654076870:function:apigatewaytest",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Sid": "customidmakesnodiff"
    }








# Integration response maps Lambda (or other) return values to the method response
client.get_integration_response({rest_api_id:"wz6zgytkce", resource_id:"clpvw5", http_method:"GET", status_code:"200"})
# => #<struct Aws::APIGateway::Types::IntegrationResponse status_code="200", selection_pattern=".*", response_parameters=nil, response_templates=nil>
client.put_integration_response
client.update_integration_response


# Method Response is where you define status codes and reponse parameters
client.get_method_response({rest_api_id:"wz6zgytkce", resource_id:"clpvw5", http_method:"GET", status_code:"200"})
# => #<struct Aws::APIGateway::Types::MethodResponse status_code="200", response_parameters=nil, response_models={}>
client.put_method_response
client.update_method_response

Add "204" to method response for API>resource>method
Add handler to integration response with error regex "updateNotFound.*" or similar, and 204 status code with no payload.






client.put_integration_response({
  rest_api_id: api['id'],
  resource_id: resource['id'],
  http_method: "GET",
  status_code: "200", # status code
  selection_pattern: ".*",
#  response_parameters: nil,
#  response_templates: nil
})
resp = client.put_method_response({
  rest_api_id: api['id'],
  resource_id: resource[:id],
  http_method: "GET",
  status_code: "200", # status code
#  response_parameters: nil,
#  response_models: {}
})



source_arn = "arn:aws:execute-api:%{aws_region}:%{aws_acct_id}:%{aws_api_id}/*/%{http_method}/%{lambda_function_name}" % uri_data
$lambda_client.add_permission({function_name: 
aws_lambda.add_permission(
    FunctionName=lambda_func_name,
    StatementId=uuid.uuid4().hex,
    SourceArn=source_arn
)
    #sid = SecureRandom.uuid
    lambda_client.add_permission({
      function_name: function_name,
      statement_id:  sid,
      action:        "lambda:InvokeFunction",
      principal:     "apigateway.amazonaws.com",
      source_arn:    source_arn
    })

    $lambda_client.add_permission({
      function_name: uri_data[:lambda_function_name],
      statement_id:  "blahblahblahalskdjflkajsdlkfj",
      action:        "lambda:InvokeFunction",
      principal:     "apigateway.amazonaws.com",
      source_arn:    source_arn
    })
















root_resource_id = client.get_resources({rest_api_id:api['id']})[:items][0][:id]
resp = client.create_resource({
  rest_api_id: api['id'],
  parent_id: "xhslzxzhtj",
  path_part: "blasted",
})
resource = resp



puts JSON.pretty_generate(Hash(client.get_integration({rest_api_id: "uenz92o27f", resource_id:"wys128", http_method: "GET"})))

puts JSON.pretty_generate(Hash(client.get_resources({rest_api_id: "uenz92o27f"})))


