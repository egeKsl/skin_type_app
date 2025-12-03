from IPython.display import Image, Markdown, display
from google import genai
from google.genai.types import GenerateContentConfig, Part
import base64
from pathlib import Path

PROJECT_ID = "vertex-api-c4832"
LOCATION = "global"

client = genai.Client(vertexai=True, project=PROJECT_ID, location=LOCATION)
MODEL_ID = "gemini-2.5-flash-image"

# Function to convert image to base64
def encode_image(image_path):
    return base64.b64encode(Path(image_path).read_bytes()).decode("utf-8")

# Safe and ethical prompt
def analyze_image_safely(image_path):
    # Load image
    image_data = encode_image(image_path)
    
    # Ethical prompt
    prompt = """Analyze this image in the following ways:
    1. What are the main objects in the image?
    2. What is the color palette like?
    3. Technical observations about composition
    4. Read any text present in the image
    Do not make assumptions about people or perform ethnic analysis."""
    
    response = client.models.generate_content(
        model=MODEL_ID,
        contents=[
            Part.from_text(text=prompt),
            Part.from_inline_data(
                mime_type="image/jpeg",
                data=image_data
            )
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
        print(f"An error occurred: {str(e)}")

# Run test
test_model_with_image("C:\\Users\\corle\\Downloads\\uktnL3moyStQBY2J-636047206885563346.jpg")