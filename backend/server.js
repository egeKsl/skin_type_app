const express = require('express');
const multer = require('multer');
const { PredictionServiceClient } = require('@google-cloud/aiplatform').v1;
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();

const PROJECT_ID = process.env.VERTEX_AI_PROJECT_ID;
const LOCATION = process.env.SERVER_LOCATION;
const MODEL_NAME = process.env.AI_MODEL_NAME;

//image administration
const storage = multer.memoryStorage();
const upload = multer({storage: storage});

app.use(bodyParser.json());

//vertex ai connection
const clientOptions = {
    apiEndpoint: `${LOCATION}-aiplatform.googleapis.com`,
};
const predictionServiceClient = new PredictionServiceClient(clientOptions);

//api endpoint
app.post('/analyze-skin',upload.single('image'),async(req,res) =>
    {
        try
        {
            if(!req.file){
                return res.status(400).json({error: 'Image could not be found!'});
            }

            const imageBase64 = req.file.buffer.toString('base64');

            // Endpoint oluştur
            const endpoint = `projects/${PROJECT_ID}/locations/${LOCATION}/publishers/google/models/${MODEL_NAME}`;

            //request
            const instance = {
                structValue: {
                    fields: {
                        prompt: {
                            stringValue: `Sen profesyonel bir dermatologsun.
                            Bu resimdeki cildi analiz et.
                            Lütfen şu formatta Türkçe yanıt ver:
                            - Cilt Tipi: [Kuru/Yağlı/Karma]
                            - Tespitler: [Gözlemlerin]
                            - Öneri: [Kısa tavsiye]
                            Not: Sadece metin çıktısı ver, markdown kullanma.`
                        },
                        image: {
                            structValue: {
                                fields: {
                                    bytesBase64Encoded: {
                                        stringValue: imageBase64
                                    }
                                }
                            }
                        }
                    }
                }
            };

            const instances = [instance];

            console.log(`Request is being sending to the model ${MODEL_NAME} ......`)
            
            //result
            const [response] = await predictionServiceClient.predict({
                endpoint: endpoint,
                instances: instances,
            });

            const prediction = response.predictions[0];
            const text = prediction.structValue.fields.content.stringValue;

            res.json({ success: true, result: text });
        } catch (error)
        {
            console.error("Error!",error);
            res.status(500).json({ success: false, error: error.message });
        }
    }
);

app.get('/status', (req, res) => {
    res.json({
        status: 'running',
        project_id: PROJECT_ID,
        location: LOCATION,
        model: MODEL_NAME,
        port: PORT
    });
});

const PORT = process.env.PORT;
app.listen(PORT,() =>{
    console.log(`The server is ready on the ${PORT} port`);
});