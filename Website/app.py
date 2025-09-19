from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
from flask_cors import CORS
import os

# Create Flask app instance
app = Flask(__name__)
app.secret_key = 'your_secret_key_here_change_in_production'

# Enable CORS for frontend-backend communication
CORS(app)

# Configure static files
app.static_folder = 'static'

# Sample data (In production, use a database like MongoDB or SQLite)
destinations = [
    {
        'id': 1,
        'name': 'Taj Mahal, Agra',
        'category': 'mustsees',
        'rating': 4.9,
        'reviews': 12450,
        'price': 500,
        'image': '/static/images/tajmahal.jpg',
        'description': 'UNESCO World Heritage site and symbol of love',
        'features': ['UNESCO World Heritage', 'Guided Tours Available', 'Photography Allowed']
    },
    {
        'id': 2,
        'name': 'Goa Beach Paradise',
        'category': 'mustsees',
        'rating': 4.7,
        'reviews': 8320,
        'price': 350,
        'image': '/static/images/goa.jpg',
        'description': 'Beautiful beaches with water sports and nightlife',
        'features': ['Beach Activities', 'Water Sports', 'Nightlife']
    },
    {
        'id': 3,
        'name': 'Jaipur City Palace',
        'category': 'cityviews',
        'rating': 4.8,
        'reviews': 6890,
        'price': 400,
        'image': '/static/images/jaipur.jpg',
        'description': 'Royal heritage in the Pink City',
        'features': ['Royal Architecture', 'Museum', 'Cultural Shows']
    },
    {
        'id': 4,
        'name': 'Kerala Backwaters',
        'category': 'tours',
        'rating': 4.9,
        'reviews': 5670,
        'price': 1200,
        'image': '/static/images/kerala.jpg',
        'description': 'Houseboat experience in God\'s Own Country',
        'features': ['Houseboat Stay', 'Ayurvedic Spa', 'Local Cuisine']
    }
]

# Main routes
@app.route('/')
def index():
    return render_template('index.html', destinations=destinations)

@app.route('/login')
def login():
    return render_template('login.html')

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

# API routes for frontend-backend communication
@app.route('/api/destinations')
def get_destinations():
    category = request.args.get('category', 'all')
    if category == 'all':
        return jsonify(destinations)
    filtered = [d for d in destinations if d['category'] == category]
    return jsonify(filtered)

@app.route('/api/destinations/<int:dest_id>')
def get_destination(dest_id):
    destination = next((d for d in destinations if d['id'] == dest_id), None)
    if destination:
        return jsonify(destination)
    return jsonify({'error': 'Destination not found'}), 404

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    # Simple validation (In production, use proper authentication)
    if email and password:
        # Here you would validate against database
        if email == 'admin@incredibleindia.com' and password == 'admin123':
            return jsonify({
                'success': True,
                'message': 'Login successful',
                'user': {'name': 'Admin User', 'email': email}
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Invalid credentials'
            }), 401
    
    return jsonify({
        'success': False,
        'message': 'Email and password required'
    }), 400

@app.route('/api/signup', methods=['POST'])
def api_signup():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    
    if name and email and password:
        # Here you would save to database
        return jsonify({
            'success': True,
            'message': 'Account created successfully',
            'user': {'name': name, 'email': email}
        })
    
    return jsonify({
        'success': False,
        'message': 'All fields are required'
    }), 400

@app.route('/api/contact', methods=['POST'])
def api_contact():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    message = data.get('message')
    
    if name and email and message:
        # Here you would save to database or send email
        return jsonify({
            'success': True,
            'message': 'Thank you for your message. We will get back to you soon!'
        })
    
    return jsonify({
        'success': False,
        'message': 'All fields are required'
    }), 400

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('500.html'), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
