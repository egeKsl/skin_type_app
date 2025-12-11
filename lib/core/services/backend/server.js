const express = require('express');
const multer = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const bodyParser = require('body-parser');
require('dotenv').config(); // Load environment variables

const app = express();


const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "AIzaSyBhWrSGko7nxNd2ZXSyDNLuo20dI00Dy28";

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
        
        const promptText = `Sen profesyonel bir dermatologsun. 
            Görevin, gönderilen yüz görüntüsünden cilt tipini analiz etmek ve aşağıdaki formatta TÜRKÇE olarak kesin bir JSON çıktısı oluşturmaktır.

            ### KURALLAR
            1. Yalnızca geçerli JSON üret. JSON dışında hiçbir açıklama, yorum, markdown, kod bloğu veya metin ekleme.
            2. Cilt tipi sınıflandırması aşağıdaki seçeneklerden BİRİ olmalıdır:
            - "YAĞLI / AKNEYE EĞİLİMLİ CİLT"
            - "KURU CİLT"
            - "KARMA CİLT"
            - "HASSAS / ROSACEA EĞİLİMLİ CİLT"
            - "LEKELİ / PİGMENTASYON SORUNLU CİLT"

            3. Aşağıdaki başlıkları JSON içinde zorunlu olarak üret:
            - "belirtiler"
            - "ihtiyaclar"
            - "dogal_icerikler"
            - "kimyasal_aktif_icerikler"
            - "makyaj_kullanilmasi_gerekenler"
            - "makyaj_uzak_durulmasi_gerekenler"
            - "cilt_tipi_benzerlik_yuzdesi"

            4. Bu başlıklar mutlaka liste (array) formatında olmalıdır.

            5. Ek olarak, “rutin” isimli bir alan oluştur ve bunun içine:
            - "sabah_rutini"
            - "aksam_rutini"
            başlıklarını ekle.

            6. Sabah rutini için model aşağıdaki adımlardan uygun olanları seçmeli ve her adım için kısa, içerik bazlı öneri yapmalıdır:
            - "nazik_jel_temizleyici" (ör: “Salicylic Acid (0.5–1%)”)
            - "tonik_gozenek_sikilastirici" (ör: “Niacinamide”)
            - "serum" (ör: “Niacinamide 4–10% → yağ dengesi”)
            - "hafif_nemlendirici" (ör: “Oil-free, jel form”)
            - "gunes_kremi" (ör: “Mineral, zinc oxide/titanium dioxide”)

            7. Akşam rutini için model aşağıdaki adımlardan uygun olanları seçmeli ve kısa, içerik bazlı öneri yapmalıdır:
            - "cift_temizleme" (ör: “Yağ bazlı temizleyici ile başla”)
            - "eksfoliasyon" (ör: “Salicylic Acid 2% (gün aşırı)”)  
            - "tedavi_serumu" (ör: “Retinol 0.2–0.5%”)  
            - "hafif_nemlendirici" (ör: “Non-comedogenic, yatıştırıcı”)
            - "nokta_tedavisi" (ör: “Akne için benzoyl peroxide 2.5%”)  

            8. Kullanılmaması gereken bir adım varsa, o adımı boş dizi olarak değil, hiç ekleme.

            9. Cevap tamamen Türkçe olmalıdır.

            ### ÇIKTI FORMAT ŞEMASI
            {
            "cilt_tipi": "string",
            "belirtiler": ["..."],
            "ihtiyaclar": ["..."],
            "dogal_icerikler": ["..."],
            "kimyasal_aktif_icerikler": ["..."],
            "makyaj_kullanilmasi_gerekenler": ["..."],
            "makyaj_uzak_durulmasi_gerekenler": ["..."],
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

            ### GÖREV
            Gönderilen yüz görüntüsünü analiz et ve yukarıdaki JSON formatına %100 uygun bir çıktı üret.`;
        
        
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