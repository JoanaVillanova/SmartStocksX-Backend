from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

# SQL Server Connection
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=GRWILBANKS;'
    'DATABASE=SmartStocksX;'
    'Trusted_Connection=yes;'
)

# === Page Routes ===
@app.route('/')
def login_page():
    return render_template('login.html')

@app.route('/Dashboard')
def dashboard():
    return render_template('Dashboard.html')

@app.route('/products')
def products():
    return render_template('products.html')

@app.route('/suppliers')
def suppliers():
    return render_template('suppliers.html')

@app.route('/supplierdetail')
def supplierdetails():
    return render_template('supplierdetail.html')

@app.route('/User')
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
    
# === Products API ===
@app.route('/api/products', methods=['GET'])
def get_products():
    cursor = conn.cursor()
    cursor.execute("SELECT ProductID, ProductName, Category, Brand, Quantity, Threshold, StockStatus FROM Products")
    rows = cursor.fetchall()

    product_list = []
    for row in rows:
        product_list.append({
            'ProductID': row[0],
            'ProductName': row[1],
            'Category': row[2],
            'Brand': row[3],
            'Quantity': row[4],
            'Threshold': row[5],
            'StockStatus': row[6]
        })

    return jsonify(product_list)

@app.route('/api/add-product', methods=['POST'])
def add_product():
    data = request.json
    name = data.get('ProductName')
    category = data.get('Category')
    brand = data.get('Brand')
    quantity = data.get('Quantity')
    threshold = data.get('Threshold')

    cursor = conn.cursor()
    cursor.execute("EXEC AddProduct ?, ?, ?, ?, ?", (name, category, brand, quantity, threshold))
    conn.commit()

    return jsonify({'message': 'Product added successfully using stored procedure'}), 201


@app.route('/api/update-product/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    data = request.json
    name = data.get('ProductName')
    category = data.get('Category')
    brand = data.get('Brand')
    quantity = data.get('Quantity')
    threshold = data.get('Threshold')

    # Calculate stock status
    if quantity == 0 and threshold == 0:
        stock_status = 'Out of Stock'
    elif quantity <= threshold:
        stock_status = 'Low Stock'
    else:
        stock_status = 'In Stock'

    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Products
        SET ProductName = ?, Category = ?, Brand = ?, Quantity = ?, Threshold = ?, StockStatus = ?
        WHERE ProductID = ?
    """, (name, category, brand, quantity, threshold, stock_status, product_id))
    conn.commit()

    return jsonify({'message': 'Product updated successfully'})

@app.route('/api/delete-product/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Products WHERE ProductID = ?", (product_id,))
    conn.commit()

    return jsonify({'message': 'Product deleted successfully'})

@app.route('/api/dashboard-counts')
def dashboard_counts():
    cursor = conn.cursor()

    # Get total product count
    cursor.execute("SELECT COUNT(*) FROM Products")
    total_products = cursor.fetchone()[0]

    # Low Stock
    cursor.execute("SELECT COUNT(*) FROM Products WHERE Quantity <= Threshold AND NOT (Quantity = 0 AND Threshold = 0)")
    low_stock = cursor.fetchone()[0]

    # In Stock
    cursor.execute("SELECT COUNT(*) FROM Products WHERE Quantity > Threshold")
    in_stock = cursor.fetchone()[0]

    # Out of Stock
    cursor.execute("SELECT COUNT(*) FROM Products WHERE Quantity = 0 AND Threshold = 0")
    out_of_stock = cursor.fetchone()[0]

    return jsonify({
        'total': total_products,
        'low': low_stock,
        'in': in_stock,
        'out': out_of_stock
    })

# === Suppliers API ===
@app.route('/api/suppliers', methods=['GET'])
def get_suppliers():
    cursor = conn.cursor()
    cursor.execute("SELECT SupplierID, Name, Contact, Website, CreatedAt FROM Suppliers")
    rows = cursor.fetchall()

    suppliers = []
    for row in rows:
        suppliers.append({
            "SupplierID": row.SupplierID,
            "Name": row.Name,
            "Contact": row.Contact,
            "Website": row.Website,
            "CreatedAt": row.CreatedAt.strftime('%Y-%m-%d %H:%M') if row.CreatedAt else ""
        })

    return jsonify(suppliers)

@app.route('/api/add-supplier', methods=['POST'])
def add_supplier():
    data = request.get_json()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Suppliers (Name, Contact, Website, CreatedAt)
        VALUES (?, ?, ?, ?)
    """, (
        data.get('SupplierName'),
        data.get('ContactInfo'),
        data.get('Website'),
        data.get('CreatedAt')
    ))
    conn.commit()
    return jsonify({'message': 'Supplier added successfully'}), 201

@app.route('/api/update-supplier/<int:supplier_id>', methods=['PUT'])
def update_supplier(supplier_id):
    data = request.get_json()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Suppliers SET
        Name = ?,
        Contact = ?,
        Website = ?,
        CreatedAt = ?
        WHERE SupplierID = ?
    """, (
        data.get('SupplierName'),
        data.get('ContactInfo'),
        data.get('Website'),
        data.get('CreatedAt'),
        supplier_id
    ))
    conn.commit()
    return jsonify({'message': 'Supplier updated successfully'})

@app.route('/api/delete-supplier/<int:supplier_id>', methods=['DELETE'])
def delete_supplier(supplier_id):
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Suppliers WHERE SupplierID = ?", supplier_id)
    conn.commit()
    return jsonify({'message': 'Supplier deleted successfully'})



if __name__ == '__main__':
    app.run(debug=True)

