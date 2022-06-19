"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
// Import required AWS SDK clients and commands for Node.js
const client_dynamodb_1 = require("@aws-sdk/client-dynamodb");
// Set the AWS Region.
const REGION = "us-east-1"; //e.g. "us-east-1"
// Set the parameters
const params = { TableName: "blog-url-actions" }; //TABLE_NAME
const run = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const ddbClient = new client_dynamodb_1.DynamoDBClient({ region: REGION });
        const data = yield ddbClient.send(new client_dynamodb_1.DescribeTableCommand(params));
        console.log("Success", data);
        // console.log("Success", data.Table.KeySchema);
        return data;
    }
    catch (err) {
        console.log("Error", err);
    }
});
run();
//# sourceMappingURL=index.js.map