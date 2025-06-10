from flask import Flask, jsonify, request, send_from_directory
from authlib.integrations.flask_client import OAuth
import re
import os
from flask_cors import CORS  # Import CORS
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Starting the application...")

app = Flask(__name__, static_folder="build", static_url_path="/")
app.secret_key = os.getenv('FLASK_SECRET_KEY')  # Remove default, force env var

# Enable CORS for all origins (adjust as needed for production)
CORS(app)

oauth = OAuth(app)
oauth.register(
    name='linkedin',
    client_id=os.getenv('LINKEDIN_CLIENT_ID'),
    client_secret=os.getenv('LINKEDIN_CLIENT_SECRET'),
    access_token_url='https://www.linkedin.com/oauth/v2/accessToken',
    authorize_url='https://www.linkedin.com/oauth/v2/authorization',
    api_base_url='https://api.linkedin.com/v2/',
    client_kwargs={'scope': 'r_liteprofile r_emailaddress'},
)

def is_valid_email(email):
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

def evaluate_lead(data):
    issues = []
    required_fields = ["firstName", "lastName", "email", "jobTitle", "company", "phone", "country", "industry", "capabilityNeeded"]
    for field in required_fields:
        if not data.get(field):
            issues.append(f"Missing: {field}")
    if not is_valid_email(data.get("email", "")):
        issues.append("Invalid email format.")
    return {"isValid": not issues, "issues": issues}

@app.route("/")
def home():
    logger.info("Handling request to /")
    return send_from_directory(app.static_folder, "index.html")

@app.route("/submit-lead", methods=["POST"])
def submit_lead():
    try:
        data = request.json
        result = evaluate_lead(data)
        if not result["isValid"]:
            return jsonify({"status": "error", "issues": result["issues"]}), 400

        # TODO: Save lead logic here (replace with actual database interaction)
        # Example:
        # db.save_lead(data)

        return jsonify({"status": "success", "message": "Lead submitted successfully"})
    except Exception as e:
        logger.error(f"Error submitting lead: {e}")  # Log the error
        return jsonify({"status": "error", "message": "Internal server error"}), 500


@app.route("/<path:path>")
def static_files(path):
    return send_from_directory(app.static_folder, path)

if __name__ == "__main__":
    logger.info("Running in standalone mode")
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
