const express = require('express');
const multer = require('multer');
const { VertexAI } = require('@google-cloud/vertexai');
const bodyParser = require('body-parser');
require('dotenv').config(); // Load environment variables

const app = express();

// Configuration from environment variables
const PROJECT_ID = process.env.VERTEX_AI_PROJECT_ID || "vertex-api-c4832";
const LOCATION = process.env.SERVER_LOCATION || "us-central1";
const MODEL_NAME = process.env.AI_MODEL_NAME || "gemini-2.5-flash-image";

// Verify environment variables are loaded
console.log('Environment Variables Loaded:');
console.log('PROJECT_ID:', PROJECT_ID ? 'Loaded' : 'NOT SET');
console.log('LOCATION:', LOCATION ? 'Loaded' : 'NOT SET');
console.log('MODEL_NAME:', MODEL_NAME ? 'Loaded' : 'NOT SET');

// Image handling
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(bodyParser.json());

// Initialize Vertex AI (only if project ID is available)
let generativeModel;
if (PROJECT_ID && LOCATION && MODEL_NAME) {
    try {
        const vertexAI = new VertexAI({ project: PROJECT_ID, location: LOCATION });
        generativeModel = vertexAI.getGenerativeModel({
            model: MODEL_NAME,
            generationConfig: {
                temperature: 0.4,
                maxOutputTokens: 512,
            }
        });
        console.log('Vertex AI initialized successfully');
    } catch (error) {
        console.error('Vertex AI initialization failed:', error.message);
    }
} else {
    console.warn('Vertex AI not initialized - missing environment variables');
}

// API endpoint for skin analysis
app.post('/analyze-skin', upload.single('image'), async (req, res) => {
    try {
        // Check if Vertex AI is initialized
        if (!generativeModel) {
            return res.status(500).json({ 
                success: false, 
                error: 'Server configuration error - Vertex AI not initialized',
                details: 'Check environment variables: VERTEX_AI_PROJECT_ID, SERVER_LOCATION, AI_MODEL_NAME'
            });
        }

        if (!req.file) {
            return res.status(400).json({ error: 'Image not found!' });
        }

        const imageBase64 = req.file.buffer.toString('base64');

        // Request structure
        const request = {
            contents: [
                {
                    role: 'user',
                    parts: [
                        // Image data
                        {
                            inlineData: {
                                mimeType: req.file.mimetype,
                                data: imageBase64
                            }
                        },
                        // Text prompt
                        {
                            text: `You are a professional dermatologist.
                            Analyze the skin in this image.
                            Please respond in Turkish with this format:
                            - Skin Type: [Dry/Oily/Combination]
                            - Observations: [Your observations]
                            - Recommendation: [Brief advice]
                            Note: Only provide text output, no markdown.`
                        }
                    ]
                }
            ]
        };

        console.log(`Sending request to model ${MODEL_NAME}...`);
        
        // Get response
        const result = await generativeModel.generateContent(request);
        const response = await result.response;

        const text = response.candidates[0].content.parts[0].text;

        res.json({ success: true, result: text });
    } catch (error) {
        console.error("Error:", error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Status endpoint - shows environment variables status
app.get('/status', (req, res) => {
    res.json({
        status: 'running',
        environment_variables: {
            project_id: PROJECT_ID ? 'Set' : 'Missing',
            location: LOCATION ? 'Set' : 'Missing',
            model: MODEL_NAME ? 'Set' : 'Missing',
            vertex_ai_initialized: !!generativeModel
        },
        server_info: {
            project_id: PROJECT_ID,
            location: LOCATION,
            model: MODEL_NAME,
            timestamp: new Date().toISOString()
        }
    });
});

// Home page
app.get('/', (req, res) => {
    const envStatus = PROJECT_ID && LOCATION && MODEL_NAME ? 
        '<span style="color: green;">✓ All set</span>' : 
        '<span style="color: red;">⚠ Missing some variables</span>';
    
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Skin Analysis API</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
                code { background: #e0e0e0; padding: 2px 5px; border-radius: 3px; }
                .env-ok { color: green; }
                .env-missing { color: red; }
            </style>
        </head>
        <body>
            <h1>🧴 Skin Analysis API</h1>
            <p>API is running successfully!</p>
            
            <div class="endpoint">
                <h3>Environment Status: ${envStatus}</h3>
                <ul>
                    <li>PROJECT_ID: ${PROJECT_ID ? '<span class="env-ok">✓ Set</span>' : '<span class="env-missing">✗ Missing</span>'}</li>
                    <li>LOCATION: ${LOCATION ? '<span class="env-ok">✓ Set</span>' : '<span class="env-missing">✗ Missing</span>'}</li>
                    <li>MODEL_NAME: ${MODEL_NAME ? '<span class="env-ok">✓ Set</span>' : '<span class="env-missing">✗ Missing</span>'}</li>
                </ul>
            </div>
            
            <div class="endpoint">
                <h3>GET /status</h3>
                <p>Check API status: <a href="/status">/status</a></p>
            </div>
            
            <div class="endpoint">
                <h3>POST /analyze-skin</h3>
                <p>Analyze a skin image (POST method required)</p>
                <p><strong>Test with curl:</strong></p>
                <code>curl -X POST -F "image=@photo.jpg" ${req.protocol}://${req.get('host')}/analyze-skin</code>
            </div>
        </body>
        </html>
    `);
});

// GET handler for /analyze-skin (for browser requests)
app.get('/analyze-skin', (req, res) => {
    res.status(405).json({
        error: 'Method Not Allowed',
        message: 'This endpoint only accepts POST requests',
        correct_usage: {
            method: 'POST',
            url: `${req.protocol}://${req.get('host')}/analyze-skin`,
            body_format: 'multipart/form-data with "image" field'
        }
    });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`Homepage: http://localhost:${PORT}`);
    console.log(`Status: http://localhost:${PORT}/status`);
    
    // Display environment status on startup
    if (!PROJECT_ID || !LOCATION || !MODEL_NAME) {
        console.warn('\n⚠️ WARNING: Some environment variables are missing:');
        if (!PROJECT_ID) console.warn('  - VERTEX_AI_PROJECT_ID is not set');
        if (!LOCATION) console.warn('  - SERVER_LOCATION is not set');
        if (!MODEL_NAME) console.warn('  - AI_MODEL_NAME is not set');
        console.warn('\nCreate a .env file with these variables or set them in your environment.');
    } else {
        console.log('\n✅ All environment variables are loaded correctly');
    }
});