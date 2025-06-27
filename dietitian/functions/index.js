// functions/index.js
const functions = require('firebase-functions');
const { Storage } = require('@google-cloud/storage');
const vision = require('@google-cloud/vision');

const storage = new Storage();
const client = new vision.ImageAnnotatorClient();

exports.analyzeImage = functions.https.onRequest(async (req, res) => {
  try {
    const imageUrl = req.body.imageUrl;

    const [result] = await client.annotateImage({
      image: { source: { imageUri: imageUrl } },
      features: [{ type: 'LABEL_DETECTION' }],
    });

    const labels = result.labelAnnotations.map(label => ({
      description: label.description,
      score: label.score,
    }));

    res.json({ labels });
    console.log("index.js: Image analyzed successfully", labels);
  } catch (error) {
    console.error(error);
    res.status(500).send("Error analyzing image");
  }
});
