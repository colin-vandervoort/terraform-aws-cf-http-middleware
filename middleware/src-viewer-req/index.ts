import {
  CloudFrontRequestEvent,
  Context,
  CloudFrontRequestCallback,
  CloudFrontResultResponse,
} from 'aws-lambda'

import AWS from 'aws-sdk'

import { Action } from '../lib/schemas'

const REGION = 'us-east-1'
const API_VERSION = '2012-08-10'
const lambdaName = process.env.AWS_LAMBDA_FUNCTION_NAME ?? ''

AWS.config.update({ region: REGION })

type CachedUrlAction = {
  expires: number
  action: Action
}

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

const cache = new Map<string, CachedUrlAction>()
const client = createClient()

export const handler = (
  event: CloudFrontRequestEvent,
  context: Context,
  callback: CloudFrontRequestCallback,
): void => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`)
  console.log(`Context: ${JSON.stringify(context, null, 2)}`)

  const request = event.Records[0].cf.request
  const reqUri = request.uri

  new Promise<Action | null>((resolve) => {

    // try the action cache first
    const cacheResult = cache.get(reqUri)
    if (cacheResult) {
      if (Date.now() < cacheResult.expires ) {
        // cache hit
        console.log(`Action from cache: ${ cacheResult.action.code }:${ reqUri } -> ${ cacheResult.action.target }`)
        resolve(cacheResult.action)
      } else {
        // this mapping should be overwritten anyways, but delete just in case
        cache.delete(reqUri)
      }
      resolve(null)
    } else {
      // see if DynamoDB has an action for this URI
      const getParams: AWS.DynamoDB.DocumentClient.GetItemInput = {
        TableName: lambdaName,
        Key: {
          url: reqUri,
        },
      }
      client.get(getParams, function (err, data) {
        if (err) {
          console.log(err.message)
        }
        if (typeof data.Item !== 'undefined') {
          const actionFromDb = data.Item.action
          console.log(`Action from new database query: ${ actionFromDb.code }:${ reqUri } -> ${ actionFromDb.target }`)
          cache.set(reqUri, {
            expires: Date.now() + (30 * 60 * 1000), // 30 minutes
            action: actionFromDb
          })
          resolve(actionFromDb)
        }
        resolve(null)
      })
    }
  }).then((action: Action | null) => {
    if (action) {
      // action found, respond to the viewer
      const response: CloudFrontResultResponse = {
        status: String(action.code),
        headers: {
          location: [
            {
              key: 'Location',
              value: action.target,
            },
          ],
        },
      }
      callback(null, response)
    } else {
      // no action found, translate to .html file request and pass it along to the origin
      console.log(`No action found for URI: ${ reqUri }`)
      request.uri = reqUri.replace(/\/$/, '/index.html')
      callback(null, request)
    }
  })
}
