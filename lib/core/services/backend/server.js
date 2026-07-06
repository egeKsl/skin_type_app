const express = require('express');
const multer = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const bodyParser = require('body-parser');
require('dotenv').config(); // Load environment variables

const app = express();


const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const MODEL_NAME = process.env.AI_MODEL_NAME || "gemini-2.5-flash-image"; 

// Verify environment variables are loaded
console.log('Environment Variables Loaded:');
console.log('API_KEY_STATUS:', GEMINI_API_KEY ? 'Loaded' : 'NOT SET');
console.log('MODEL_NAME:', MODEL_NAME ? 'Loaded' : 'NOT SET');

// Image handling
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

app.use(bodyParser.json());

// Initialize Google Generative AI
let generativeModel;
if (GEMINI_API_KEY && MODEL_NAME) {
    try {
        const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
        generativeModel = genAI.getGenerativeModel({ 
            model: MODEL_NAME,
            config: {
                temperature: 0.4,
                maxOutputTokens: 512,
            }
        });
        console.log('Google Generative AI initialized successfully');
    } catch (error) {
        console.error('Generative AI initialization failed:', error.message);
    }
} else {
    console.warn('Generative AI not initialized - missing API Key or Model Name');
}

// API endpoint for skin analysis
app.post('/analyze-skin', upload.single('image'), async (req, res) => {
    try {
        // Check if the model is initialized
        if (!generativeModel) {
            return res.status(500).json({ 
                success: false, 
                error: 'Server configuration error - AI Model not initialized',
                details: 'Check environment variables: GEMINI_API_KEY, AI_MODEL_NAME'
            });
        }

        if (!req.file) {
            return res.status(400).json({ error: 'Image not found!' });
        }

        const imageBase64 = req.file.buffer.toString('base64');

        // Helper function for converting local file information to a GenerativePart object.
        function fileToGenerativePart(base64Data, mimeType) {
            return {
                inlineData: {
                    data: base64Data,
                    mimeType
                },
            };
        }

        // Request structure (Multimodal)
        const mimeType = req.file.mimetype && req.file.mimetype.startsWith("image/") 
            ? req.file.mimetype 
            : "image/jpeg";  // fallback

        const imagePart = fileToGenerativePart(imageBase64, mimeType);
        
        const promptText = `You are a professional dermatologist.
            Your task is to analyze the skin type from the uploaded face image and generate a highly detailed, precise JSON output in ENGLISH according to the following format.

            ### RULES
            1. Produce ONLY valid JSON. Do not include any explanations, comments, markdown formatting, code blocks, or additional text outside the JSON object.
            2. Skin type classification must be exactly ONE of the following English strings:
            - "OILY / ACNE-PRONE SKIN"
            - "DRY SKIN"
            - "COMBINATION SKIN"
            - "SENSITIVE / ROSACEA-PRONE SKIN"
            - "BLEMISHED / HYPERPIGMENTATION-PRONE SKIN"

            3. The following keys are MANDATORY in the JSON and must remain in Turkish as specified:
            - "cilt_tipi"
            - "belirtiler"
            - "ihtiyaclar"
            - "dogal_icerikler"
            - "kimyasal_aktif_icerikler"
            - "makyaj_kullanilmasi_gerekenler"
            - "makyaj_uzak_durulmasi_gerekenler"
            - "cilt_tipi_benzerlik_yuzdesi"
            - "rutin"

            4. For "dogal_icerikler" and "kimyasal_aktif_icerikler", create an array of objects. Each object MUST contain:
            - "isim": The name of the ingredient (in English).
            - "temel_faydalar": A list of maximum 3 key benefits (in English).
            - "nasil_kullanilir": Instructions on how to apply/use it (in English).
            - "ai_analizi": A personalized analysis of why this ingredient is specifically recommended for the user's detected skin condition (in English).

            5. For "dogal_icerikler", choose from: "Tea tree oil", "Aloe vera", "Green tea", "Clay (kaolin, bentonite)", "Witch hazel (alcohol-free)", "Shea butter", "Avocado oil", "Honey", "Natural hyaluronic derivatives", "Oat extract", "Centella Asiatica", "Chamomile, calendula".

            6. For "kimyasal_aktif_icerikler", choose from: "Salicylic Acid (BHA)", "Niacinamide", "Zinc PCA", "Azelaic Acid", "Retinol", "AHA + BHA", "Benzoyl Peroxide", "Hyaluronic Acid", "Ceramides", "Glycerin", "Squalane", "Peptides", "Lactic Acid", "Panthenol", "Madecassoside".

            7. For "sabah_rutini" and "aksam_rutini" inside "rutin", provide short, ingredient-based English recommendations.

            8. THE ENTIRE CONTENT OF THE JSON VALUES MUST BE IN ENGLISH. KEYS MUST BE TURKISH.

            ### OUTPUT FORMAT SCHEMA
            {
            "cilt_tipi": "string",
            "belirtiler": ["string"],
            "ihtiyaclar": ["string"],
            "dogal_icerikler": [
                {
                "isim": "string",
                "temel_faydalar": ["string (max 3)"],
                "nasil_kullanilir": "string",
                "ai_analizi": "string"
                }
            ],
            "kimyasal_aktif_icerikler": [
                {
                "isim": "string",
                "temel_faydalar": ["string (max 3)"],
                "nasil_kullanilir": "string",
                "ai_analizi": "string"
                }
            ],
            "makyaj_kullanilmasi_gerekenler": ["string"],
            "makyaj_uzak_durulmasi_gerekenler": ["string"],
            "cilt_tipi_benzerlik_yuzdesi": "string",
            "rutin": {
                "sabah_rutini": {
                "nazik_jel_temizleyici": "string",
                "tonik_gozenek_sikilastirici": "string",
                "serum": "string",
                "hafif_nemlendirici": "string",
                "gunes_kremi": "string"
                },
                "aksam_rutini": {
                "cift_temizleme": "string",
                "eksfoliasyon": "string",
                "tedavi_serumu": "string",
                "hafif_nemlendirici": "string",
                "nokta_tedavisi": "string"
                }
            }
            }

            ### TASK
            Analyze the provided face image and generate a response that fits this complex JSON schema 100%. Ensure the "ai_analizi" for each ingredient explains the specific visual evidence found in the photo (e.g., "Since I see redness around your T-zone...").`;
        
        
            const contents = [
                {
                    role: "user",
                    parts: [
                        { text: promptText },
                        imagePart
                    ]
                }
            ];

        console.log(`Sending request to model ${MODEL_NAME}...`);
        
        // Get response
        const result = await generativeModel.generateContent({
            contents,
            generationConfig: {
                responseModalities: ["TEXT"]
            }
        });

        let text = "";
        try {
            if (result?.response?.candidates?.length > 0) {
                const parts = result.response.candidates[0].content.parts;
                const partWithText = parts.find(p => p.text);
                text = partWithText?.text || "";
            }
        } catch (e) {
            console.error("Parse Error:", e);
        }
        res.json({ success: true, result: text || "EMPTY_RESPONSE" });

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
            api_key: GEMINI_API_KEY ? 'Set' : 'Missing',
            model: MODEL_NAME ? 'Set' : 'Missing',
            ai_initialized: !!generativeModel
        },
        server_info: {
            model: MODEL_NAME,
            timestamp: new Date().toISOString()
        }
    });
});

// Home page
app.get('/', (req, res) => {
    const envStatus = GEMINI_API_KEY && MODEL_NAME ? 
        '<span style="color: green;">✓ All set</span>' : 
        '<span style="color: red;">⚠ Missing API Key or Model Name</span>';
    
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
            <h1>🧴 Skin Analysis API (API Key Mode)</h1>
            <p>API is running successfully!</p>
            
            <div class="endpoint">
                <h3>Environment Status: ${envStatus}</h3>
                <ul>
                    <li>API_KEY: ${GEMINI_API_KEY ? '<span class="env-ok">✓ Set</span>' : '<span class="env-missing">✗ Missing</span>'}</li>
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
    if (!GEMINI_API_KEY || !MODEL_NAME) {
        console.warn('\n⚠️ WARNING: Some environment variables are missing:');
        if (!GEMINI_API_KEY) console.warn('  - GEMINI_API_KEY is not set');
        if (!MODEL_NAME) console.warn('  - AI_MODEL_NAME is not set');
        console.warn('\nCreate a .env file with these variables or set them in your environment.');
    } else {
        console.log('\n✅ All environment variables are loaded correctly');
    }
});