from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

# SQL Server Connection
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=DESKTOP-T8Q4KAO;'
    'DATABASE=SmartStocksX;'
    'Trusted_Connection=yes;'
)

# === Page Routes ===
@app.route('/')
def login_page():
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    return render_template('Dashboard.html')

@app.route('/products')
def products():
    return render_template('products.html')

@app.route('/suppliers')
def suppliers():
    return render_template('suppliers.html')

@app.route('/supplierdetails')
def supplierdetails():
    return render_template('supplierdetail.html')

@app.route('/users')
def users():
    return render_template('User.html')

@app.route('/settings')
def settings():
    return render_template('settings.html')

# === Login API ===
@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    cursor = conn.cursor()
    cursor.execute("SELECT UserID, Username, Role FROM Users WHERE Email=? AND Password=?", (email, password))
    user = cursor.fetchone()

    if user:
        return jsonify({
            "message": "Login successful",
            "user": {
                "id": user.UserID,
                "name": user.Username,
                "role": user.Role
            }
        })
    else:
        return jsonify({"message": "Invalid email or password"}), 401

if __name__ == '__main__':
    app.run(debug=True)
