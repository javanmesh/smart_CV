# Smart CV – Automated Resume & Cover Letter Customizer

**What it does:** Smart CV takes your PDF résumé (or cover letter) and a job description, then:
1. Extracts your contact info and full text
2. Uses Mistral AI to parse and structure key résumé details
3. Converts your original PDF to HTML
4. Customizes and reorders content to match a job posting
5. Generates a polished PDF and HTML version
6. Packages both in a downloadable ZIP

**Why it matters:**
- **Save hours** manually tweaking bullets and formatting
- **Maximize impact** by surfacing the achievements recruiters care about
- **Consistent branding** with clean, professional PDFs every time

## Features

- **PDF parsing** via `pdfplumber`
- **AI-powered detail extraction & customization** using Mistral
- **HTML conversion** (via `pdf2htmlEX` or Playwright fallback)
- **Headless PDF generation** with Playwright (no Chromium CLI hacks)
- **One-click ZIP output** containing both PDF & HTML

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/your-org/smart-cv.git
cd smart-cv
```

### 2. Create & activate a virtualenv

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Set environment variables

```bash
export MISTRAL_API_KEY="your_mistral_api_key"
export PORT=10000  # optional; default is 10000
```

### 5. Install `pdf2htmlEX`

- On Ubuntu/Debian: `sudo apt-get install pdf2htmlex`
- Or follow instructions at https://github.com/pdf2htmlEX/pdf2htmlEX

### 6. Run the server

```bash
flask run --host=0.0.0.0 --port=$PORT
```

### 7. Open your browser

Visit: `https://smart-cv-56kq.onrender.com/`

## Usage

1. Upload your résumé PDF
2. Paste the target job description
3. Select "Resume" or "Cover Letter"
4. Hit **Submit**
5. Download the `.zip` containing your customized HTML & PDF

## Deployment

- **Render.com**: The project is live at `https://smart-cv-56kq.onrender.com/`
- For Docker/Kubernetes:
  - Build your image with your env vars
  - Ensure Playwright dependencies are installed (`libnss3`, etc.)
  - Expose port 10000

## Project Structure

```
.
├── app.py               # Main Flask app
├── requirements.txt     # Python deps
├── templates/
│   └── form.html        # Upload form
├── static/              # CSS/JS assets
└── README.md            # This file
```

## Environment Variables

- `MISTRAL_API_KEY` – **(required)** your Mistral AI API key
- `PORT` – port to listen on (default: `10000`)

## Troubleshooting & Tips

- **Blank PDF output?** Ensure Playwright's Chromium dependencies are installed on your host
- **HTML conversion errors?** Double-check `pdf2htmlEX` is on your `$PATH`
- **AI output malformed?** If JSON parsing fails, review the first 5000 chars of your CV; long headers can break prompts

## License

MIT © 2025 Javan Meshack
