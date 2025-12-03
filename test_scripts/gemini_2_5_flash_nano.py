from IPython.display import Image, Markdown, display
from google import genai
from google.genai.types import GenerateContentConfig, Part
from pathlib import Path
import traceback

PROJECT_ID = "vertex-api-c4832"
LOCATION = "global"

client = genai.Client(vertexai=True, project=PROJECT_ID, location=LOCATION)
MODEL_ID = "publishers/google/models/gemini-2.5-flash-image"

# Function to load image bytes for inline upload
def load_image_bytes(image_path):
    return Path(image_path).read_bytes()

# Safe and ethical prompt
def analyze_image_safely(image_path):
    # Load image
    image_data = load_image_bytes(image_path)
    
    # Ethical prompt
    prompt = """What are you figuring out about where the person in this image is from?"""
    
    response = client.models.generate_content(
        model=MODEL_ID,
        contents=[
            Part.from_text(text=prompt),
            Part.from_bytes(data=image_data, mime_type="image/jpeg")
        ],
        config=GenerateContentConfig(
            temperature=0.2,
            max_output_tokens=1000,
        ),
    )
    
    return response

# Test function
def test_model_with_image(image_path):
    try:
        print("Starting image analysis...")
        display(Image(filename=image_path, width=300))
        
        response = analyze_image_safely(image_path)
        
        print("\n" + "="*50)
        print("MODEL OUTPUT:")
        print("="*50)
        
        for candidate in response.candidates:
            for part in candidate.content.parts:
                if part.text:
                    print(part.text)
        
        print("\n" + "="*50)
        print("TEST COMPLETED")
        print("="*50)
        
    except Exception as e:
        print(f"An error occurred: {e}")
        print(f"Exception type: {e.__class__.__name__}")
        print("Full traceback:")
        traceback.print_exc()

# Run test
test_model_with_image("input/input-6.jpg")
#test_model_with_image("C:\\Users\\corle\\Downloads\\uktnL3moyStQBY2J-636047206885563346.jpg")