from flask import Flask, render_template, request
import pymysql
import os
from dotenv import load_dotenv

app = Flask(__name__)

# 🔐 Load environment variables
load_dotenv()

# 🔥 Database connection (AWS RDS MySQL)
def get_db_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

# 🔥 Auto-create table if not exists
def create_table():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL
        )
    """)

    conn.commit()
    conn.close()

    print("✅ users table checked/created successfully")

# 🔥 Home page
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM users')
    users = cursor.fetchall()

    conn.close()

    return render_template('index.html', users=users)

# 🔥 Add user
@app.route('/add', methods=['POST'])
def add_user():
    name = request.form['name']

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        'INSERT INTO users (name) VALUES (%s)',
        (name,)
    )

    conn.commit()
    conn.close()

    return '✅ User added successfully!'

# 🔥 Delete user
@app.route('/delete/<int:user_id>', methods=['POST'])
def delete_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        'DELETE FROM users WHERE id = %s',
        (user_id,)
    )

    conn.commit()
    conn.close()

    return '🗑️ User deleted successfully!'

# 🔥 Run app
if __name__ == '__main__':

    print("DB_HOST =", os.environ.get("DB_HOST"))

    # 🔥 Automatically create table
    create_table()

    app.run(
        host="0.0.0.0",
        port=5050,
        debug=True
    )