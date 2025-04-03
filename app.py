from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def home():
    return "Flask server is running!"

@app.route("/y")
def test():
    return f"Received request at {request.path}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
