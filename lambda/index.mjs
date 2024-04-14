// Lambda handler
export const handler = async event => {
  console.log('SQS EVENT:', event);

  const batchItemFailures = [];
  if (event.Records.length == 0) {
    console.log('Empty SQS Event received');
    return { batchItemFailures };
  }

  // Extract Records array from event object. This array contains one or more SQS messages.
  // Each message contains the S3 object details.
  const { Records } = event;

  // Process each SQS message.
  for (const record of Records) {
    const itemIdentifier = record.messageId;
    console.log(`Processing message Id: ${itemIdentifier}`);

    // Get SQS message body
    const body = JSON.parse(record.body);

    // Skip S3 TestEvent messages, https://mikulskibartosz.name/what-is-s3-test-event
    if (body.hasOwnProperty('Event') && body.Event === 's3:TestEvent') continue;

    // Extract S3 object details.
    for (const s3Record of body.Records) {
      const { s3, eventName } = s3Record;

      console.log('Bucket name:', s3.bucket.name);
      console.log('Object key:', s3.object.key);
      console.log('Event name:', eventName);
    }

    // Returning error to test DLQ - add message Id to batchItemFailures array.
    batchItemFailures.push({ itemIdentifier });
    return { batchItemFailures };
  }
};
