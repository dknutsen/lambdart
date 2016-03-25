console.log('Loading function');

var aws = require('aws-sdk');
var s3 = new aws.S3({ apiVersion: '2006-03-01' });

// read the .env file into an object called ENV
var fs = require('fs');
var envFile = fs.readFileSync('.env', "utf8");
var ENV = {};
envFile.split('\n').forEach(function(line){
  var split = line.split('=');
  if(split.length > 1) {
    ENV[split[0]] = split.slice(1).join('=');
  }
});


exports.handler = function(event, context) {
    console.log('Received event:', JSON.stringify(event, null, 2));
    print("Lambdart env: " +  ENV['LAMBDART_ENV'])

};
