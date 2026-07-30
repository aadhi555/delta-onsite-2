from flask import Flask, request

app = Flask(__name__)
unique_users = set()

@app.route("/")
def info():
    user = request.headers.get("X-User-ID", "anonymous")
    unique_users.add(user)
    
    return f"Server: backend1 | Total Users: {len(unique_users)} | Current User: {user}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
