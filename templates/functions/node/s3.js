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

    // Get the object from the event and show its content type
    var bucket = event.Records[0].s3.bucket.name;
    var key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
    var params = {
        Bucket: bucket,
        Key: key
    };
    s3.getObject(params, function(err, data) {
        if (err) {
            console.log(err);
            var message = "Error getting object " + key + " from bucket " + bucket +
                ". Make sure they exist and your bucket is in the same region as this function.";
            console.log(message);
            context.fail(message);
        } else {
            console.log('CONTENT TYPE:', data.ContentType);
            context.succeed(data.ContentType);
        }
    });
};
