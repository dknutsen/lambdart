'use strict';
console.log('Loading function');

var aws = require('aws-sdk');

// read the .env file into an object called ENV
var fs = require('fs');
var ENV = {LAMBDART_ENV: undefined};
try {
  var envFile = fs.readFileSync('.env', "utf8");
  envFile.split('\n').forEach(function(line){
    var split = line.split('=');
    if(split.length > 1) {
      ENV[split[0]] = split.slice(1).join('=');
    }
  });
}
catch (e) { }

exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    event.Records.forEach((record) => {
        console.log(record.eventID);
        console.log(record.eventName);
        console.log('DynamoDB Record: %j', record.dynamodb);
    });
    callback(null, `Successfully processed ${event.Records.length} records.`);
};
