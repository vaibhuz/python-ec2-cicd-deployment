from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "Python Application Deployed Successfully!",
        "status": "Running",
        "platform": "AWS EC2",
        "deployment": "GitHub Actions CI/CD",
        "technology": "Python Flask"
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })

@app.route("/about")
def about():
    return jsonify({
        "application": "Python Flask Application",
        "version": "1.0.0",
        "cloud": "AWS"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)