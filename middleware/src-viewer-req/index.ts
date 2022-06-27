import {
  CloudFrontRequestEvent,
  Context,
  CloudFrontRequestCallback,
  CloudFrontRequest,
} from 'aws-lambda'

import AWS from 'aws-sdk'

const REGION = 'us-east-1'
const API_VERSION = '2012-08-10'
const TABLE_NAME = process.env.URL_ACTION_TABLE_NAME || 'url-actions'

AWS.config.update({ region: REGION })

function createClient(): AWS.DynamoDB.DocumentClient {
  try {
    const ddbDocClient = new AWS.DynamoDB.DocumentClient({
      apiVersion: API_VERSION,
    })
    return ddbDocClient
  } catch (error) {
    console.log(error)
    process.exit(1)
  }
}

function passRequest(
  request: CloudFrontRequest,
  callback: CloudFrontRequestCallback,
): void {
  request.uri = request.uri.replace(/\/$/, '/index.html')
  callback(null, request)
}

export const handler = (
  event: CloudFrontRequestEvent,
  context: Context,
  callback: CloudFrontRequestCallback,
): void => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`)
  console.log(`Context: ${JSON.stringify(context, null, 2)}`)

  const request = event.Records[0].cf.request

  const getParams = {
    TableName: TABLE_NAME,
    Key: {
      url: request.uri,
    },
  }
  const client = createClient()

  client.get(getParams, function (err, data) {
    if (err) {
      console.log(err)
      passRequest(request, callback)
    } else if (typeof data.Item !== 'undefined') {
      console.log(data)
      const response = {
        status: data.Item.action.code,
        headers: {
          location: [
            {
              key: 'Location',
              value: data.Item.action.target,
            },
          ],
        },
      }
      callback(null, response)
    } else {
      passRequest(request, callback)
    }
  })
}
