import AWS from 'aws-sdk'
import { ActionMapping, ResponseCode } from '../lib/schemas'

const REGION = 'us-east-1'
const API_VERSION = '2012-08-10'
const TABLE_NAME = 'blog-url-actions'

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

export async function list(): Promise<void> {
  try {
    const params = {
      TableName: TABLE_NAME,
    }
    const client = createClient()
    const result = await client.scan(params).promise()
    console.log(result)
  } catch (error) {
    console.log('Error', error)
  }
}

export type SetUrlActionOptions = {
  force: boolean
}
export async function set(
  urlAction: ActionMapping,
  options: SetUrlActionOptions,
): Promise<void> {
  try {
    const getParams = {
      TableName: TABLE_NAME,
      Key: {
        url: urlAction.url,
      },
    }
    const client = createClient()
    const getResult = await client.get(getParams).promise()
    const keyExists = typeof getResult.Item !== 'undefined'

    if (keyExists && options.force === false) {
      console.log(`Stop: existing action for URL: ${urlAction.url}`)
      console.log(`use -f or --force to overwrite`)
    } else {
      const setResult = await client
        .put({
          TableName: TABLE_NAME,
          Item: urlAction,
        })
        .promise()
      if (keyExists) {
        console.log(`updated action for URL: ${urlAction.url}`)
      } else {
        console.log(`added new action for URL: ${urlAction.url}`)
      }
    }
  } catch (error) {
    console.log('Error', error)
  }
}
