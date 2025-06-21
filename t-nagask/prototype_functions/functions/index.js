/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const vision = require('@google-cloud/vision');
const path = require('path');

admin.initializeApp();
const client = new vision.ImageAnnotatorClient();

exports.analyzeImage = functions.storage.object().onFinalize(async (object) => {
    const filePath = object.name;
    const bucketName = object.bucket;
    const contentType = object.contentType;

    if (!contentType.startsWith('image/')) {
        console.log('画像以外のファイルなのでスキップします:', contentType);
        return null;
    }

    const gcsUri = `gs://${bucketName}/${filePath}`;
    console.log(`画像をVision APIに送信: ${gcsUri}`);

    const [result] = await client.labelDetection(gcsUri); // 例: ラベル検出
    const labels = result.labelAnnotations;

    console.log('ラベル検出結果:', labels.map(label => label.description));

    // 必要に応じてFirestoreなどに保存
    return null;
});
