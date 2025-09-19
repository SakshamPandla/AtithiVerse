from flask import Flask, render_template, request, jsonify, url_for, session, redirect, flash
from flask_cors import CORS
import os
import sqlite3
import hashlib
import secrets
from datetime import datetime, timedelta
import json
from functools import wraps

# Create Flask app instance
app = Flask(__name__, 
            static_folder='static',
            template_folder='templates')

app.secret_key = 'incredible_india_secret_key_2025'
CORS(app)

# Database configuration
DATABASE = 'atithiverse.db'

def get_db_connection():
    """Create database connection"""
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initialize database with tables"""
    conn = get_db_connection()
    
    # Users table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            phone TEXT,
            country TEXT,
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Bookings table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            booking_id TEXT UNIQUE NOT NULL,
            user_id INTEGER NOT NULL,
            destination_id INTEGER NOT NULL,
            destination_name TEXT NOT NULL,
            check_in_date DATE NOT NULL,
            check_out_date DATE,
            adults INTEGER DEFAULT 1,
            children INTEGER DEFAULT 0,
            total_people INTEGER DEFAULT 1,
            total_price REAL NOT NULL,
            final_price REAL NOT NULL,
            status TEXT DEFAULT 'confirmed',
            payment_status TEXT DEFAULT 'pending',
            special_requests TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Wishlist table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS wishlist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            destination_id INTEGER NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id),
            UNIQUE(user_id, destination_id)
        )
    ''')
    
    # Reviews table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            destination_id INTEGER NOT NULL,
            rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
            title TEXT,
            comment TEXT NOT NULL,
            is_verified BOOLEAN DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Contact messages table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS contact_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT,
            subject TEXT NOT NULL,
            message TEXT NOT NULL,
            status TEXT DEFAULT 'new',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Newsletter subscriptions table
    conn.execute('''
        CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            is_subscribed BOOLEAN DEFAULT 1,
            subscription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()

# Initialize database on startup
init_db()

# Authentication decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return jsonify({
                'success': False,
                'message': 'Authentication required',
                'redirect': '/login'
            }), 401
        return f(*args, **kwargs)
    return decorated_function

def hash_password(password):
    """Hash password using SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()

def generate_booking_id():
    """Generate unique booking ID"""
    timestamp = datetime.now().strftime("%Y%m%d%H%M")
    random_str = secrets.token_hex(4).upper()
    return f"ATI{timestamp}{random_str}"

# Enhanced destinations data
destinations = [
    {
        'id': 1,
        'name': 'Taj Mahal, Agra',
        'category': 'mustsees',
        'rating': 4.9,
        'reviews': 12450,
        'price': 500,
        'original_price': 650,
        'image': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'UNESCO World Heritage site and symbol of eternal love',
        'long_description': 'The Taj Mahal is an ivory-white marble mausoleum on the right bank of the river Yamuna in the Indian city of Agra. It was commissioned in 1632 by the Mughal emperor Shah Jahan to house the tomb of his favourite wife, Mumtaz Mahal.',
        'features': ['UNESCO World Heritage', 'Guided Tours', 'Photography Allowed', 'Night Viewing'],
        'location': 'Agra, Uttar Pradesh',
        'duration': '3-4 hours',
        'max_people': 50,
        'included': ['Entry Ticket', 'Guide Service', 'Transportation'],
        'excluded': ['Food', 'Personal Expenses'],
        'best_season': 'October to March'
    },
    {
        'id': 2,
        'name': 'Goa Beach Paradise',
        'category': 'mustsees',
        'rating': 4.7,
        'reviews': 8320,
        'price': 350,
        'original_price': 450,
        'image': 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'Pristine beaches with vibrant nightlife and water sports',
        'long_description': 'Goa is a state in western India with coastlines stretching along the Arabian Sea. Its long history as a Portuguese colony prior to 1961 is evident in its preserved 17th-century churches and the area\'s tropical spice plantations.',
        'features': ['Beach Activities', 'Water Sports', 'Nightlife', 'Seafood'],
        'location': 'Goa',
        'duration': '2-3 days',
        'max_people': 30,
        'included': ['Beach Access', 'Water Sports Equipment', 'Accommodation'],
        'excluded': ['Meals', 'Personal Expenses', 'Alcohol'],
        'best_season': 'November to March'
    },
    {
        'id': 3,
        'name': 'Jaipur City Palace',
        'category': 'cityviews',
        'rating': 4.8,
        'reviews': 6890,
        'price': 400,
        'original_price': 500,
        'image': 'https://images.unsplash.com/photo-1477587458883-47145ed94245?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'Royal heritage in the magnificent Pink City of Rajasthan',
        'long_description': 'The City Palace in Jaipur, Rajasthan was established at the same time as the city of Jaipur, by Maharaja Sawai Jai Singh II, who moved his court to Jaipur from Amber, in 1727.',
        'features': ['Royal Architecture', 'Museum', 'Cultural Shows', 'Shopping'],
        'location': 'Jaipur, Rajasthan',
        'duration': '4-5 hours',
        'max_people': 40,
        'included': ['Palace Entry', 'Museum Access', 'Guide Service'],
        'excluded': ['Transportation', 'Food', 'Shopping'],
        'best_season': 'October to March'
    },
    {
        'id': 4,
        'name': 'Kerala Backwaters',
        'category': 'tours',
        'rating': 4.9,
        'reviews': 5670,
        'price': 1200,
        'original_price': 1500,
        'image': 'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'Serene houseboat experience in God\'s Own Country',
        'long_description': 'The Kerala backwaters are a network of brackish lagoons and lakes lying parallel to the Arabian Sea coast of Kerala state in southern India.',
        'features': ['Houseboat Stay', 'Ayurvedic Spa', 'Local Cuisine', 'Bird Watching'],
        'location': 'Alleppey, Kerala',
        'duration': '1-2 days',
        'max_people': 8,
        'included': ['Houseboat Stay', 'All Meals', 'Local Guide', 'Transfers'],
        'excluded': ['Personal Expenses', 'Spa Treatments'],
        'best_season': 'September to March'
    },
    {
        'id': 5,
        'name': 'Himalayan Adventure',
        'category': 'tours',
        'rating': 4.8,
        'reviews': 4230,
        'price': 2500,
        'original_price': 3000,
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'Breathtaking mountain views and trekking experiences',
        'long_description': 'Experience the majestic Himalayas with guided trekking, mountain climbing, and breathtaking views of snow-capped peaks.',
        'features': ['Trekking', 'Mountain Views', 'Adventure Sports', 'Camping'],
        'location': 'Himachal Pradesh',
        'duration': '5-7 days',
        'max_people': 12,
        'included': ['Trekking Equipment', 'Guide', 'Camping', 'Meals'],
        'excluded': ['Personal Equipment', 'Insurance', 'Emergency Evacuation'],
        'best_season': 'April to October'
    },
    {
        'id': 6,
        'name': 'Udaipur Lake Palace',
        'category': 'hotels',
        'rating': 4.9,
        'reviews': 2340,
        'price': 15000,
        'original_price': 18000,
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        'description': 'Luxury palace hotel floating on Lake Pichola',
        'long_description': 'The Lake Palace is a luxury hotel, which has 83 rooms and suites featuring white marble walls, lotus leaves and elaborate glass work.',
        'features': ['Luxury Stay', 'Lake Views', 'Royal Dining', 'Spa Services'],
        'location': 'Udaipur, Rajasthan',
        'duration': '1-3 nights',
        'max_people': 4,
        'included': ['Luxury Suite', 'All Meals', 'Spa Access', 'Boat Transfers'],
        'excluded': ['Personal Expenses', 'Additional Treatments'],
        'best_season': 'October to March'
    }
]

# ===== AUTHENTICATION ROUTES =====

@app.route('/api/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['email', 'password', 'first_name', 'last_name']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field.replace("_", " ").title()} is required'
                }), 400
        
        conn = get_db_connection()
        
        # Check if user already exists
        existing_user = conn.execute(
            'SELECT id FROM users WHERE email = ?',
            (data['email'],)
        ).fetchone()
        
        if existing_user:
            conn.close()
            return jsonify({
                'success': False,
                'message': 'Email already registered'
            }), 400
        
        # Hash password and create user
        password_hash = hash_password(data['password'])
        
        conn.execute('''
            INSERT INTO users (email, password_hash, first_name, last_name, phone, country)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            data['email'],
            password_hash,
            data['first_name'],
            data['last_name'],
            data.get('phone', ''),
            data.get('country', '')
        ))
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Registration successful! Please log in.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Registration failed. Please try again.'
        }), 500

@app.route('/api/login', methods=['POST'])
def api_login():
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return jsonify({
                'success': False,
                'message': 'Email and password are required'
            }), 400
        
        # Check for demo account
        if email == 'demo@atithiverse.com' and password == 'demo123':
            session['user_id'] = 999
            session['user_email'] = email
            session['user_name'] = 'Demo User'
            
            return jsonify({
                'success': True,
                'message': 'Welcome to the demo!',
                'user': {
                    'id': 999,
                    'email': email,
                    'name': 'Demo User',
                    'first_name': 'Demo',
                    'last_name': 'User'
                }
            })
        
        conn = get_db_connection()
        user = conn.execute(
            'SELECT * FROM users WHERE email = ? AND is_active = 1',
            (email,)
        ).fetchone()
        conn.close()
        
        if user and user['password_hash'] == hash_password(password):
            # Set session
            session['user_id'] = user['id']
            session['user_email'] = user['email']
            session['user_name'] = f"{user['first_name']} {user['last_name']}"
            
            return jsonify({
                'success': True,
                'message': f'Welcome back, {user["first_name"]}!',
                'user': {
                    'id': user['id'],
                    'email': user['email'],
                    'name': f"{user['first_name']} {user['last_name']}",
                    'first_name': user['first_name'],
                    'last_name': user['last_name']
                }
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Invalid email or password'
            }), 401
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Login failed. Please try again.'
        }), 500

@app.route('/api/logout', methods=['POST'])
def api_logout():
    session.clear()
    return jsonify({
        'success': True,
        'message': 'Logged out successfully'
    })

@app.route('/api/user')
def get_current_user():
    if 'user_id' in session:
        return jsonify({
            'success': True,
            'user': {
                'id': session['user_id'],
                'email': session['user_email'],
                'name': session['user_name']
            }
        })
    else:
        return jsonify({
            'success': False,
            'message': 'Not logged in'
        }), 401

# ===== DESTINATION ROUTES =====

@app.route('/api/destinations')
def get_destinations():
    try:
        category = request.args.get('category', 'all')
        search = request.args.get('search', '')
        min_price = request.args.get('min_price', type=float)
        max_price = request.args.get('max_price', type=float)
        rating = request.args.get('rating', type=float)
        
        filtered_destinations = destinations.copy()
        
        # Apply filters
        if category != 'all':
            filtered_destinations = [d for d in filtered_destinations if d['category'] == category]
        
        if search:
            search_lower = search.lower()
            filtered_destinations = [d for d in filtered_destinations 
                                   if search_lower in d['name'].lower() 
                                   or search_lower in d['location'].lower()
                                   or search_lower in d['description'].lower()]
        
        if min_price is not None:
            filtered_destinations = [d for d in filtered_destinations if d['price'] >= min_price]
        
        if max_price is not None:
            filtered_destinations = [d for d in filtered_destinations if d['price'] <= max_price]
        
        if rating is not None:
            filtered_destinations = [d for d in filtered_destinations if d['rating'] >= rating]
        
        # Add wishlist status if user is logged in
        if 'user_id' in session:
            conn = get_db_connection()
            user_wishlist = conn.execute(
                'SELECT destination_id FROM wishlist WHERE user_id = ?',
                (session['user_id'],)
            ).fetchall()
            conn.close()
            
            wishlist_ids = {row['destination_id'] for row in user_wishlist}
            
            for dest in filtered_destinations:
                dest['in_wishlist'] = dest['id'] in wishlist_ids
        else:
            for dest in filtered_destinations:
                dest['in_wishlist'] = False
        
        return jsonify({
            'success': True,
            'destinations': filtered_destinations,
            'total': len(filtered_destinations)
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Error fetching destinations'
        }), 500

@app.route('/api/destinations/<int:dest_id>')
def get_destination(dest_id):
    try:
        destination = next((d for d in destinations if d['id'] == dest_id), None)
        
        if not destination:
            return jsonify({
                'success': False,
                'message': 'Destination not found'
            }), 404
        
        dest_copy = destination.copy()
        
        # Check if user has this in wishlist
        if 'user_id' in session:
            conn = get_db_connection()
            wishlist_item = conn.execute(
                'SELECT id FROM wishlist WHERE user_id = ? AND destination_id = ?',
                (session['user_id'], dest_id)
            ).fetchone()
            
            # Get reviews for this destination
            reviews = conn.execute('''
                SELECT r.*, u.first_name, u.last_name 
                FROM reviews r 
                JOIN users u ON r.user_id = u.id 
                WHERE r.destination_id = ? 
                ORDER BY r.created_at DESC LIMIT 10
            ''', (dest_id,)).fetchall()
            conn.close()
            
            dest_copy['in_wishlist'] = wishlist_item is not None
            dest_copy['reviews'] = [dict(review) for review in reviews]
        else:
            dest_copy['in_wishlist'] = False
            dest_copy['reviews'] = []
        
        return jsonify({
            'success': True,
            'destination': dest_copy
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Error fetching destination details'
        }), 500

# ===== WISHLIST ROUTES =====

@app.route('/api/wishlist', methods=['POST'])
@login_required
def toggle_wishlist():
    try:
        data = request.get_json()
        destination_id = data.get('destination_id')
        
        if not destination_id:
            return jsonify({
                'success': False,
                'message': 'Destination ID is required'
            }), 400
        
        destination_id = int(destination_id)
        destination = next((d for d in destinations if d['id'] == destination_id), None)
        
        if not destination:
            return jsonify({
                'success': False,
                'message': 'Destination not found'
            }), 404
        
        conn = get_db_connection()
        
        # Check if already in wishlist
        existing_wishlist = conn.execute(
            'SELECT id FROM wishlist WHERE user_id = ? AND destination_id = ?',
            (session['user_id'], destination_id)
        ).fetchone()
        
        if existing_wishlist:
            # Remove from wishlist
            conn.execute(
                'DELETE FROM wishlist WHERE user_id = ? AND destination_id = ?',
                (session['user_id'], destination_id)
            )
            conn.commit()
            conn.close()
            
            return jsonify({
                'success': True,
                'message': 'Removed from wishlist',
                'in_wishlist': False
            })
        else:
            # Add to wishlist
            conn.execute(
                'INSERT INTO wishlist (user_id, destination_id) VALUES (?, ?)',
                (session['user_id'], destination_id)
            )
            conn.commit()
            conn.close()
            
            return jsonify({
                'success': True,
                'message': 'Added to wishlist',
                'in_wishlist': True
            })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Error updating wishlist'
        }), 500

# ===== CONTACT & NEWSLETTER =====

@app.route('/api/contact', methods=['POST'])
def api_contact():
    try:
        data = request.get_json()
        
        required_fields = ['name', 'email', 'subject', 'message']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'message': f'{field.title()} is required'
                }), 400
        
        # Save contact message
        conn = get_db_connection()
        conn.execute('''
            INSERT INTO contact_messages (name, email, phone, subject, message)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            data['name'],
            data['email'],
            data.get('phone', ''),
            data['subject'],
            data['message']
        ))
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Thank you for your message! We\'ll get back to you within 24 hours.'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Error sending message. Please try again.'
        }), 500

@app.route('/api/newsletter', methods=['POST'])
def subscribe_newsletter():
    try:
        data = request.get_json()
        email = data.get('email')
        
        if not email:
            return jsonify({
                'success': False,
                'message': 'Email is required'
            }), 400
        
        conn = get_db_connection()
        
        # Check if already subscribed
        existing_sub = conn.execute(
            'SELECT id, is_subscribed FROM newsletter_subscriptions WHERE email = ?',
            (email,)
        ).fetchone()
        
        if existing_sub:
            if existing_sub['is_subscribed']:
                conn.close()
                return jsonify({
                    'success': False,
                    'message': 'Email already subscribed to newsletter'
                }), 400
            else:
                # Resubscribe
                conn.execute(
                    'UPDATE newsletter_subscriptions SET is_subscribed = 1 WHERE email = ?',
                    (email,)
                )
        else:
            # New subscription
            conn.execute(
                'INSERT INTO newsletter_subscriptions (email) VALUES (?)',
                (email,)
            )
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Successfully subscribed to our newsletter!'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'Subscription failed. Please try again.'
        }), 500

# ===== TEMPLATE ROUTES =====

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login')
def login():
    if 'user_id' in session:
        return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/register')
def register_page():
    if 'user_id' in session:
        return redirect(url_for('index'))
    return render_template('register.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/destination/<int:dest_id>')
def destination_detail(dest_id):
    destination = next((d for d in destinations if d['id'] == dest_id), None)
    if not destination:
        return render_template('404.html'), 404
    return render_template('destination.html', destination=destination)

# ===== ERROR HANDLERS =====

@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('500.html'), 500

if __name__ == '__main__':
    print("🚀 Starting AtithiVerse with Enhanced Functionality...")
    print("📊 Database: SQLite with full user management")
    print("🔐 Features: Authentication, Booking, Reviews, Wishlist")
    print("📱 API: RESTful endpoints for all features")
    print("📍 Visit: http://127.0.0.1:5000")
    print("👤 Demo Login: demo@atithiverse.com / demo123")
    app.run(debug=True, host='127.0.0.1', port=5000)
