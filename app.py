from flask import Flask, render_template, request, send_file
import pdfplumber
import re
import json
import os
import subprocess
import asyncio
from datetime import datetime
from bs4 import BeautifulSoup
from mistralai import Mistral
from mistralai.models import UserMessage
import zipfile
import io

# Import Playwright
from playwright.sync_api import sync_playwright

app = Flask(__name__)

# Set up Mistral AI client
MISTRAL_API_KEY = os.environ.get("MISTRAL_API_KEY")
client = Mistral(api_key=MISTRAL_API_KEY)

def extract_text_from_pdf(pdf_file):
    pdf_file.seek(0)
    text = ""
    with pdfplumber.open(pdf_file) as pdf:
        for page in pdf.pages:
            text += page.extract_text() + "\n\n"
    return text

def generate_pdf_with_playwright(html_content, output_path):
    """Generates a PDF using Playwright instead of calling Chromium via subprocess."""
    with sync_playwright() as p:
        # Launch Chromium with --no-sandbox (useful for container environments)
        browser = p.chromium.launch(headless=True, args=["--no-sandbox"])
        page = browser.new_page()
        # Set the HTML content directly
        page.set_content(html_content)
        # Optionally wait for all network activity to finish
        page.wait_for_load_state("networkidle")
        # Generate PDF (you can tweak options like format, margins, etc.)
        page.pdf(path=output_path, format="A4")
        browser.close()

def extract_cv_details(cv_text):
    contact_info = {
        "email": re.search(r"[\w\.-]+@[\w\.-]+", cv_text),
        "phone": re.search(r"\+?\d[\d\- ]{7,}\d", cv_text),
        "linkedin": re.search(r"(linkedin\.com/|linkedin\.com/in/)\S+", cv_text, re.I),
        "github": re.search(r"github\.com/\S+", cv_text, re.I),
        "portfolio": re.search(r"(https?://)?(www\.)?\S+\.(com|io|net|tech|dev)\b", cv_text, re.I)
    }
    contact_info = {k: v.group(0) if v else "" for k, v in contact_info.items()}

    prompt = f"""Extract structured details from this resume. Include dates where available.
Resume Text:
{cv_text[:5000]}
"""
    response = client.chat.complete(
        model="mistral-small",
        messages=[{"role": "user", "content": prompt}]
    )
    try:
        extracted_data = json.loads(response.choices[0].message.content)
    except json.JSONDecodeError:
        extracted_data = {}
    return {**contact_info, **extracted_data}

def convert_pdf_to_html(pdf_file):
    temp_pdf_path = "temp_upload.pdf"
    pdf_file.seek(0)
    with open(temp_pdf_path, "wb") as f:
        f.write(pdf_file.read())
    output_html_path = "converted.html"
    command = ["pdf2htmlEX", temp_pdf_path, output_html_path]
    # Using subprocess to call pdf2htmlEX; no changes here.
    subprocess.run(command, check=True)
    with open(output_html_path, "r", encoding="utf-8") as f:
        html_content = f.read()
    os.remove(temp_pdf_path)
    return html_content

def customize_html(html_content, cv_data, job_description):
    soup = BeautifulSoup(html_content, "html.parser")
    prompt = f"""Customize the resume content for this job.
Candidate Details:
{json.dumps(cv_data, indent=2)}
Job Description:
{job_description}
"""
    response = client.chat.complete(
         model="mistral-small",
         messages=[{"role": "user", "content": prompt}]
    )
    custom_html = response.choices[0].message.content
    custom_fragment = BeautifulSoup(custom_html, "html.parser")
    if soup.body:
        soup.body.insert(0, custom_fragment)
    else:
        soup.insert(0, custom_fragment)
    return str(soup)

def generate_pdf(html_content, output_path):
    """Uses Playwright to convert HTML to PDF."""
    generate_pdf_with_playwright(html_content, output_path)

@app.route("/", methods=["GET", "POST"])
def form():
    if request.method == "POST":
        cv_file = request.files["cv"]
        job_description = request.form["job_description"]
        document_type = request.form["document_type"]

        cv_file.seek(0)
        cv_text = extract_text_from_pdf(cv_file)
        cv_data = extract_cv_details(cv_text)

        candidate_name = cv_data.get("name", "Candidate").replace(" ", "_")
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        pdf_filename = f"{candidate_name}_{timestamp}.pdf"
        html_filename = f"{candidate_name}_{timestamp}.html"

        if document_type == "resume":
            cv_file.seek(0)
            original_html = convert_pdf_to_html(cv_file)
            customized_html = customize_html(original_html, cv_data, job_description)
        else:
            customized_html = f"<html><body><h1>Cover Letter</h1><p>Generated Content</p></body></html>"

        generate_pdf(customized_html, pdf_filename)
        with open(html_filename, "w", encoding="utf-8") as f:
            f.write(customized_html)

        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
            zip_file.write(pdf_filename)
            zip_file.write(html_filename)
        zip_buffer.seek(0)

        os.remove(pdf_filename)
        os.remove(html_filename)

        return send_file(zip_buffer, as_attachment=True,
                         download_name=f"{candidate_name}_{timestamp}.zip",
                         mimetype="application/zip")

    return render_template("form.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 10000)))
