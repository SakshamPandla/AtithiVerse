from flask import Flask, render_template, request, jsonify, url_for, session, redirect, flash
import requests
from datetime import datetime
import requests
from datetime import datetime
from flask_cors import CORS
import os
import sqlite3
import hashlib
import secrets
from datetime import datetime, timedelta
import json
from functools import wraps
import numpy as np
from dotenv import load_dotenv
from pathlib import Path

# Create Flask app instance
app = Flask(__name__, 
            static_folder='static',
            template_folder='templates')

app.secret_key = 'incredible_india_secret_key_2025'
CORS(app)

# Load environment variables
load_dotenv()
GOOGLE_MAPS_API_KEY = os.getenv('GOOGLE_MAPS_API_KEY', '')
GOOGLE_SEARCH_API_KEY = os.getenv('GOOGLE_SEARCH_API_KEY', '')
GOOGLE_SEARCH_CX = os.getenv('GOOGLE_SEARCH_CX', '')

# Database configuration
DATABASE = 'atithiverse.db'

# ===== WEATHER API INTEGRATION =====
WEATHER_API_KEY = "f3892078c6b88350c7dca2235e640010"  # Your actual API key

@app.route('/api/weather/<city>')
def get_weather(city):
    """Get current weather data for a city"""
    try:
        # OpenWeatherMap API endpoint
        url = f"http://api.openweathermap.org/data/2.5/weather"
        params = {
            'q': city,
            'appid': WEATHER_API_KEY,
            'units': 'metric'  # for Celsius
        }
        
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Extract relevant weather data
            weather_data = {
                'success': True,
                'city': data['name'],
                'country': data['sys']['country'],
                'temperature': round(data['main']['temp']),
                'feels_like': round(data['main']['feels_like']),
                'humidity': data['main']['humidity'],
                'pressure': data['main']['pressure'],
                'visibility': data.get('visibility', 0) // 1000,  # Convert to km
                'wind_speed': data['wind']['speed'],
                'wind_direction': data['wind'].get('deg', 0),
                'weather_main': data['weather'][0]['main'],
                'weather_description': data['weather'][0]['description'].title(),
                'weather_icon': data['weather'][0]['icon'],
                'sunrise': datetime.fromtimestamp(data['sys']['sunrise']).strftime('%H:%M'),
                'sunset': datetime.fromtimestamp(data['sys']['sunset']).strftime('%H:%M'),
                'timestamp': datetime.now().strftime('%H:%M, %B %d')
            }
            
            return jsonify(weather_data)
        else:
            return jsonify({
                'success': False,
                'error': 'Weather data not available'
            }), 404
            
    except requests.RequestException as e:
        return jsonify({
            'success': False,
            'error': 'Failed to fetch weather data'
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500

@app.route('/api/weather/forecast/<city>')
def get_weather_forecast(city):
    """Get 5-day weather forecast for a city"""
    try:
        # OpenWeatherMap API endpoint for 5-day forecast
        url = f"http://api.openweathermap.org/data/2.5/forecast"
        params = {
            'q': city,
            'appid': WEATHER_API_KEY,
            'units': 'metric'  # for Celsius
        }
        
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Process forecast data - group by day and get daily summaries
            daily_forecasts = {}
            
            for item in data['list']:
                date = datetime.fromtimestamp(item['dt']).strftime('%Y-%m-%d')
                time = datetime.fromtimestamp(item['dt']).strftime('%H:%M')
                
                if date not in daily_forecasts:
                    daily_forecasts[date] = {
                        'date': date,
                        'day_name': datetime.fromtimestamp(item['dt']).strftime('%A'),
                        'temps': [],
                        'weather_conditions': [],
                        'humidity': [],
                        'wind_speed': [],
                        'times': []
                    }
                
                daily_forecasts[date]['temps'].append(item['main']['temp'])
                daily_forecasts[date]['weather_conditions'].append({
                    'main': item['weather'][0]['main'],
                    'description': item['weather'][0]['description'],
                    'icon': item['weather'][0]['icon']
                })
                daily_forecasts[date]['humidity'].append(item['main']['humidity'])
                daily_forecasts[date]['wind_speed'].append(item['wind']['speed'])
                daily_forecasts[date]['times'].append(time)
            
            # Convert to list and calculate daily summaries
            forecast_list = []
            for date, day_data in list(daily_forecasts.items())[:5]:  # Limit to 5 days
                # Calculate min/max temperatures
                min_temp = round(min(day_data['temps']))
                max_temp = round(max(day_data['temps']))
                
                # Get most common weather condition for the day
                weather_counts = {}
                for condition in day_data['weather_conditions']:
                    key = condition['main']
                    if key not in weather_counts:
                        weather_counts[key] = {'count': 0, 'data': condition}
                    weather_counts[key]['count'] += 1
                
                most_common_weather = max(weather_counts.items(), key=lambda x: x[1]['count'])[1]['data']
                
                # Calculate averages
                avg_humidity = round(sum(day_data['humidity']) / len(day_data['humidity']))
                avg_wind_speed = round(sum(day_data['wind_speed']) / len(day_data['wind_speed']), 1)
                
                forecast_list.append({
                    'date': date,
                    'day_name': day_data['day_name'],
                    'min_temp': min_temp,
                    'max_temp': max_temp,
                    'weather_main': most_common_weather['main'],
                    'weather_description': most_common_weather['description'].title(),
                    'weather_icon': most_common_weather['icon'],
                    'humidity': avg_humidity,
                    'wind_speed': avg_wind_speed
                })
            
            return jsonify({
                'success': True,
                'city': data['city']['name'],
                'country': data['city']['country'],
                'forecast': forecast_list
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Forecast data not available'
            }), 404
            
    except requests.RequestException as e:
        return jsonify({
            'success': False,
            'error': 'Failed to fetch forecast data'
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500

# ===== GOOGLE CUSTOM SEARCH (Programmable Search) =====
@app.route('/api/google-search')
def google_search():
    """Proxy to Google Custom Search JSON API for safer client usage.
    Requires env GOOGLE_SEARCH_API_KEY and GOOGLE_SEARCH_CX.
    Query params: q (required), num (optional, default 5)
    """
    if not GOOGLE_SEARCH_API_KEY or not GOOGLE_SEARCH_CX:
        return jsonify({'success': False, 'error': 'Search API not configured'}), 500

    query = request.args.get('q', '').strip()
    num = int(request.args.get('num', '5'))
    if not query:
        return jsonify({'success': False, 'error': 'Missing query'}), 400

    try:
        url = 'https://www.googleapis.com/customsearch/v1'
        params = {
            'key': GOOGLE_SEARCH_API_KEY,
            'cx': GOOGLE_SEARCH_CX,
            'q': query,
            'num': max(1, min(num, 10))
        }
        resp = requests.get(url, params=params, timeout=10)
        data = resp.json()

        results = []
        for item in data.get('items', [])[:num]:
            img = None
            try:
                img = item.get('pagemap', {}).get('cse_image', [{}])[0].get('src')
            except Exception:
                img = None
            results.append({
                'title': item.get('title'),
                'link': item.get('link'),
                'snippet': item.get('snippet'),
                'displayLink': item.get('displayLink'),
                'image': img
            })

        return jsonify({'success': True, 'query': query, 'results': results})
    except Exception as e:
        return jsonify({'success': False, 'error': 'Search failed'}), 500

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

# Enhanced destinations data with weather-friendly locations
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
        'location': 'Panaji, Goa',
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
        'location': 'Kochi, Kerala',
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
        'location': 'Shimla, Himachal Pradesh',
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
        'image': 'https://images.unsplash.com/photo-1526772662000-3f88f10405ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        'image': 'https://images.unsplash.com/photo-1526772662000-3f88f10405ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
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
    

# ===== ENHANCED AI CHAT WITH OLLAMA INTEGRATION =====

# Add these imports at the top of your app.py (if not already present)
import numpy as np
from dotenv import load_dotenv

# Try to import SentenceTransformer
try:
    from sentence_transformers import SentenceTransformer
    USE_EMBEDDINGS = True
    print("✅ SentenceTransformer available")
except ImportError:
    USE_EMBEDDINGS = False
    print("⚠️ SentenceTransformer not available, using keyword search")

# Load environment variables
load_dotenv()

# Ollama configuration
OLLAMA_SERVER = os.getenv("OLLAMA_SERVER", "http://127.0.0.1:11434")
OLLAMA_CHAT_MODEL = os.getenv("OLLAMA_CHAT_MODEL", "llama2")

# Initialize embedding model
embedder = None
if USE_EMBEDDINGS:
    try:
        print("📥 Loading SentenceTransformer model...")
        embedder = SentenceTransformer("all-MiniLM-L6-v2", device='cpu')
        print("✅ SentenceTransformer loaded successfully!")
    except Exception as e:
        print(f"❌ Error loading SentenceTransformer: {e}")
        embedder = None

# Load travel data
def read_travel_data():
    """Load travel data from JSON file"""
    try:
        with open("data.json", "r", encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print("⚠️ data.json not found, using built-in travel data")
        return [
            {
                "name": "Taj Mahal",
                "location": "Agra, India",
                "description": "Iconic white marble mausoleum, symbol of love",
                "price": "₹500 for Indians, ₹1100 for foreigners",
                "best_time": "October to March",
                "tips": "Visit at sunrise for best experience, closed on Fridays"
            },
            {
                "name": "Goa Beaches",
                "location": "Goa, India", 
                "description": "Pristine beaches with vibrant nightlife",
                "price": "₹2000-5000 per day",
                "best_time": "November to March",
                "tips": "North Goa for parties, South Goa for peace"
            },
            {
                "name": "Kerala Backwaters",
                "location": "Kerala, India",
                "description": "Serene houseboat experience in God's Own Country",
                "price": "₹4000-12000 per night",
                "best_time": "September to March", 
                "tips": "Book houseboat in advance, try local cuisine"
            }
        ]
    except Exception as e:
        print(f"Error reading travel data: {e}")
        return []

# Load travel documents
travel_data = read_travel_data()
travel_documents = []
for item in travel_data:
    doc = f"Name: {item.get('name', '')}\nLocation: {item.get('location', '')}\nDescription: {item.get('description', '')}\nPrice: {item.get('price', '')}\nBest Time: {item.get('best_time', '')}\nTips: {item.get('tips', '')}"
    travel_documents.append(doc)

print(f"📚 Loaded {len(travel_documents)} travel documents")

# Search functions
def get_embedding(text: str):
    if embedder:
        return embedder.encode(text, convert_to_tensor=False).tolist()
    return None

def keyword_search(query, docs, top_k=3):
    """Fallback keyword-based search"""
    if not docs:
        return []
    
    query_words = set(query.lower().split())
    scores = []
    
    for doc in docs:
        doc_words = set(doc.lower().split())
        exact_matches = len(query_words.intersection(doc_words))
        partial_matches = sum(1 for qw in query_words 
                            if any(qw in dw for dw in doc_words))
        total_score = exact_matches + (partial_matches * 0.5)
        scores.append((doc, total_score))
    
    scored_docs = sorted(scores, key=lambda x: x[1], reverse=True)
    return [doc for doc, score in scored_docs[:top_k] if score > 0]

def search_travel_docs(query, top_k=3):
    """Search travel documents using embeddings or keywords"""
    if embedder and travel_documents:
        try:
            query_emb = get_embedding(query)
            if query_emb:
                doc_embeddings = [get_embedding(doc) for doc in travel_documents]
                scores = []
                for doc_emb in doc_embeddings:
                    if doc_emb:
                        similarity = np.dot(query_emb, doc_emb) / (np.linalg.norm(query_emb) * np.linalg.norm(doc_emb))
                        scores.append(similarity)
                    else:
                        scores.append(0)
                
                ranked = sorted(zip(travel_documents, scores), key=lambda x: x[1], reverse=True)
                return [doc for doc, _ in ranked[:top_k]]
        except Exception as e:
            print(f"Embedding search failed: {e}")
    
    # Fallback to keyword search
    return keyword_search(query, travel_documents, top_k)

# Replace your existing /api/chat route with this enhanced version
@app.route('/api/chat', methods=['POST'])
def enhanced_ai_chat():
    """Enhanced AI Chat with Ollama integration and travel context"""
    try:
        data = request.get_json()
        user_input = data.get('user_input', '').strip()
        
        if not user_input:
            return jsonify({
                'success': False,
                'error': 'Please enter a message'
            }), 400
        
        print(f"🤖 Enhanced AI Chat request: {user_input}")
        
        # Search for relevant travel documents
        relevant_docs = search_travel_docs(user_input)
        context = "\n".join(relevant_docs) if relevant_docs else ""
        
        # Enhanced system prompt for travel assistance
        system_prompt = f"""You are AtithiBot, an expert Indian travel assistant for AtithiVerse platform.

CONTEXT INFORMATION:
{context}

INSTRUCTIONS:
- Provide specific, actionable travel advice for India
- Include approximate costs in Indian Rupees (₹) when relevant
- Mention best times to visit and practical tips
- Be enthusiastic about Indian culture and destinations
- Keep responses under 250 words for better readability
- Use emojis to make responses engaging
- Always end with a helpful question to continue the conversation

If the user asks about destinations, provide specific details about costs, timing, and insider tips.
If no context is available, provide general travel advice for India."""

        # Try Ollama AI first
        ai_response = None
        try:
            payload = {
                "model": OLLAMA_CHAT_MODEL,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_input}
                ],
                "stream": False
            }
            
            print(f"🔗 Calling Ollama at {OLLAMA_SERVER}")
            response = requests.post(f"{OLLAMA_SERVER}/api/chat", json=payload, timeout=25)
            
            if response.status_code == 200:
                completion = response.json()
                ai_response = completion["message"]["content"]
                print(f"✅ Ollama response received: {len(ai_response)} chars")
            else:
                print(f"❌ Ollama error: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"⚠️ Ollama connection failed: {e}")
        except Exception as e:
            print(f"❌ Ollama error: {e}")
        
        # Use AI response or enhanced fallback
        if ai_response:
            final_response = ai_response
            ai_powered = True
        else:
            final_response = get_smart_travel_fallback(user_input, context)
            ai_powered = False
        
        # Generate smart suggestions
        suggestions = get_contextual_suggestions(user_input, relevant_docs)
        
        return jsonify({
            'success': True,
            'response': final_response,
            'suggestions': suggestions,
            'timestamp': datetime.now().isoformat(),
            'ai_powered': ai_powered,
            'context_used': len(relevant_docs) > 0,
            'search_method': 'embeddings' if embedder else 'keyword'
        })
        
    except Exception as e:
        print(f"❌ Enhanced chat error: {e}")
        return jsonify({
            'success': False,
            'error': 'AI chat service temporarily unavailable'
        }), 500

def get_smart_travel_fallback(user_input, context):
    """Enhanced fallback responses with travel context"""
    input_lower = user_input.lower()
    
    # Use context if available
    if context and any(word in input_lower for word in ['taj mahal', 'goa', 'kerala']):
        return f"🏛️ Based on our travel database:\n\n{context[:400]}...\n\nWould you like more specific information about visiting times or costs? 🤔"
    
    # Context-aware responses
    if 'popular' in input_lower and 'destination' in input_lower:
        return """🏛️ **India's Most Popular Destinations:**

✨ **Golden Triangle**:
• **Delhi**: Red Fort, India Gate (₹30-500)
• **Agra**: Taj Mahal (₹500 Indians, ₹1100 foreigners)  
• **Jaipur**: City Palace, Amber Fort (₹400-500)

🏖️ **Beach Paradise**:
• **Goa**: ₹2,000-5,000/day (Nov-Mar best)
• **Kerala**: Backwaters ₹4,000-12,000/night
• **Andaman**: Crystal waters, diving

🏔️ **Mountain Escapes**:
• **Himachal**: Shimla, Manali (Apr-Jun)
• **Kashmir**: Dal Lake, houseboats
• **Uttarakhand**: Rishikesh yoga retreats

Which type excites you most? 🗺️"""

    elif any(word in input_lower for word in ['hello', 'hi', 'namaste']):
        return """👋 **Namaste! I'm AtithiBot, your AI travel guide!**

🇮🇳 I specialize in **Indian travel** with real-time insights and personalized recommendations!

🎯 **I can help with**:
• 🏛️ **Destination guides** with costs & timing
• ✈️ **Trip planning** & custom itineraries
• 💰 **Budget optimization** & money-saving tips
• 📅 **Seasonal advice** & weather insights
• 🍛 **Cultural experiences** & local secrets

✨ **Try asking**:
• "Show me popular destinations"
• "Plan a 7-day North India trip"
• "Best time to visit Kerala?"

What adventure can I help you plan? 🗺️"""

    elif any(word in input_lower for word in ['plan', 'trip', 'itinerary']):
        return """✈️ **Let's Create Your Perfect Indian Journey!**

🎯 **Tell me about**:

📅 **Duration**: How many days?
• 3-5 days: Single city/region
• 7-10 days: Golden Triangle or regional tour
• 2+ weeks: Multi-region exploration

🎨 **Interests**:
• 🏛️ **Heritage**: Palaces, forts, temples
• 🏖️ **Relaxation**: Beaches, backwaters
• 🏔️ **Adventure**: Trekking, mountains
• 🕉️ **Spirituality**: Varanasi, Rishikesh

💰 **Budget**: 
• Budget: ₹2,000-4,000/day
• Comfort: ₹5,000-10,000/day
• Luxury: ₹15,000+/day

Share your preferences for a personalized itinerary! 🌟"""

    else:
        return """🇮🇳 **Welcome to Incredible India with AtithiBot!**

I'm your **AI-powered travel expert** with access to real travel data and current insights! 🤖✨

🎯 **Instant Help With**:
• 📍 **Destination Info**: Costs, timing, tips
• 🗓️ **Trip Planning**: Custom itineraries
• 💰 **Budget Advice**: Money-saving strategies
• 🌤️ **Weather Guidance**: Best travel times
• 🍛 **Cultural Tips**: Local experiences

**🎪 Popular Queries**:
• "Popular destinations in India"
• "Plan a ₹50,000 budget trip"
• "Best time for Kerala backwaters"

What aspect of India would you like to explore? 🗺️🎉"""

def get_contextual_suggestions(user_input, docs):
    """Generate smart suggestions based on input and context"""
    input_lower = user_input.lower()
    
    # Context-based suggestions
    if docs and any('taj mahal' in doc.lower() for doc in docs):
        return ["2-day Agra itinerary", "Best Taj Mahal timings", "Agra Fort combo", "Photography tips"]
    elif docs and any('goa' in doc.lower() for doc in docs):
        return ["North vs South Goa", "Beach activities", "Nightlife spots", "Monsoon travel"]
    elif docs and any('kerala' in doc.lower() for doc in docs):
        return ["Houseboat booking", "Hill stations", "Ayurveda spas", "Cuisine guide"]
    
    # Input-based suggestions
    if 'popular' in input_lower:
        return ["Golden Triangle tour", "Beach destinations", "Mountain retreats", "Cultural circuits"]
    elif any(word in input_lower for word in ['plan', 'trip']):
        return ["7-day itineraries", "Budget planning", "Best seasons", "Transportation"]
    elif any(word in input_lower for word in ['budget', 'cost']):
        return ["Money-saving tips", "Budget destinations", "Free attractions", "Local transport"]
    else:
        return ["Popular destinations", "Trip planning", "Best travel time", "Cultural experiences"]

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

# ===== AI CHATBOT ROUTES =====

@app.route('/api/chat', methods=['POST'])
def api_chat():
    """AI Chatbot endpoint - integrates with travel_bot.py service"""
    try:
        data = request.get_json()
        
        if not data or 'user_input' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing user_input in request'
            }), 400
        
        user_input = data['user_input']
        conversation_history = data.get('conversation_history', [])
        user_id = data.get('user_id')
        
        # Try to connect to the AI service (travel_bot.py on port 5001)
        try:
            ai_response = requests.post(
                'http://127.0.0.1:5001/travel-chat',
                json={
                    'user_input': user_input,
                    'context': {
                        'user_id': user_id,
                        'conversation_history': conversation_history
                    }
                },
                timeout=30
            )
            
            if ai_response.status_code == 200:
                ai_data = ai_response.json()
                return jsonify({
                    'success': True,
                    'response': ai_data.get('response', 'Sorry, I could not generate a response.'),
                    'ai_powered': ai_data.get('ai_powered', True),
                    'suggestions': ai_data.get('suggestions', [])
                })
            else:
                raise Exception(f"AI service returned status {ai_response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"⚠️ AI service connection failed: {e}")
            # Fallback to local responses
            fallback_response = get_local_fallback_response(user_input)
            return jsonify({
                'success': True,
                'response': fallback_response,
                'ai_powered': False,
                'suggestions': get_local_suggestions(user_input)
            })
        
    except Exception as e:
        print(f"❌ Error in /api/chat endpoint: {e}")
        return jsonify({
            'success': False,
            'error': 'Internal server error'
        }), 500

def get_local_fallback_response(user_input):
    """Local fallback responses when AI service is unavailable"""
    input_lower = user_input.lower()
    
    if any(word in input_lower for word in ['hello', 'hi', 'hey']):
        return "👋 Hello! I'm AtithiBot, your travel assistant for Incredible India! I can help you with destinations, travel tips, and planning your perfect trip. What would you like to explore today?"
    
    elif any(word in input_lower for word in ['taj mahal', 'agra']):
        return "🏛️ The Taj Mahal is absolutely stunning! Entry costs ₹500 for Indians, ₹1100 for foreigners. Best visited at sunrise (6 AM) or sunset. Don't miss the Agra Fort nearby! Planning a visit?"
    
    elif any(word in input_lower for word in ['goa', 'beach']):
        return "🏖️ Goa is perfect year-round! North Goa (Baga, Calangute) for nightlife, South Goa (Palolem, Arambol) for peace. November-March is ideal weather. Budget ₹2,000-4,000/day. What interests you most?"
    
    elif any(word in input_lower for word in ['kerala', 'backwater']):
        return "🌴 Kerala backwaters are magical! Alleppey houseboats cost ₹3,000-12,000/night. October-March is perfect. Must-try: Ayurvedic massage, appam with curry, coconut water fresh from trees!"
    
    elif any(word in input_lower for word in ['rajasthan', 'jaipur', 'udaipur']):
        return "🏰 Royal Rajasthan awaits! Jaipur (Pink City), Udaipur (Lake Palace), Jodhpur (Blue City). Palace hotels from ₹5,000/night. October-March best. Camel safaris, folk dances, incredible architecture!"
    
    elif any(word in input_lower for word in ['budget', 'cheap', 'cost']):
        return "💰 India is incredibly budget-friendly! Daily costs: Hostels ₹500-1,500, Food ₹200-800, Transport ₹100-500, Attractions ₹50-500. Total ₹1,500-3,000/day comfortably!"
    
    elif any(word in input_lower for word in ['plan', 'trip', 'itinerary']):
        return "✈️ I'd love to help plan your trip! Tell me: How many days? What interests you (history, beaches, mountains, culture)? Your budget range? Then I can suggest the perfect itinerary!"
    
    elif any(word in input_lower for word in ['book', 'booking', 'reserve']):
        return "📅 You can book amazing experiences right here on AtithiVerse! We offer destination tours, hotel bookings, and complete travel packages. What would you like to book?"
    
    elif any(word in input_lower for word in ['best time', 'when', 'weather']):
        return "🌤️ India's best travel times:\n• Oct-Mar: Pleasant weather, perfect for most places\n• Apr-Jun: Hot, ideal for hill stations\n• Jul-Sep: Monsoon, great for Kerala backwaters\nWhere are you planning to go?"
    
    else:
        return "🇮🇳 India offers incredible diversity! From the iconic Taj Mahal to serene Kerala backwaters, vibrant Goa beaches to royal Rajasthan palaces. What type of experience calls to you?"

def get_local_suggestions(user_input):
    """Generate local suggestions when AI service is unavailable"""
    input_lower = user_input.lower()
    
    if any(word in input_lower for word in ['taj mahal', 'agra']):
        return [
            "Best time to visit Taj Mahal",
            "Agra itinerary for 2 days",
            "Hotels near Taj Mahal",
            "Book Taj Mahal tour"
        ]
    elif any(word in input_lower for word in ['goa', 'beach']):
        return [
            "Best beaches in Goa",
            "Goa nightlife guide",
            "Water sports in Goa",
            "Book Goa package"
        ]
    elif any(word in input_lower for word in ['budget']):
        return [
            "Budget India itinerary",
            "Cheap places to stay",
            "Free attractions in India",
            "Budget food options"
        ]
    else:
        return [
            "Popular destinations",
            "Best time to visit India",
            "Budget travel tips",
            "Plan my trip"
        ]

# ===== TEMPLATE ROUTES =====

@app.route('/')
def index():
    return render_template('index.html', google_maps_api_key=GOOGLE_MAPS_API_KEY)

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
    """Show detailed destination page with weather widget"""
    try:
        print(f"🔍 Requesting destination ID: {dest_id}")
        
        # Find destination in your hardcoded data
        destination = next((d for d in destinations if d.get('id') == dest_id), None)
        
        if not destination:
            print(f"❌ Destination {dest_id} not found")
            flash('Destination not found', 'error')
            return redirect(url_for('index'))
        
        print(f"✅ Found destination: {destination['name']}")
        print(f"📊 Destination data keys: {list(destination.keys())}")
        
        return render_template('destination_detail.html', destination=destination)
        
    except Exception as e:
        print(f"❌ ERROR in destination_detail: {e}")
        print(f"📍 Error type: {type(e).__name__}")
        import traceback
        traceback.print_exc()
        
        flash('Error loading destination page', 'error')
        return redirect(url_for('index'))

# ===== ERROR HANDLERS =====

@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    return render_template('500.html'), 500

if __name__ == '__main__':
    print("🚀 Starting AtithiVerse with Weather Integration...")
    print("📊 Database: SQLite with full user management")
    print("🌤️ Weather: OpenWeatherMap API integration")
    print("🔐 Features: Authentication, Booking, Reviews, Wishlist")
    print("📱 API: RESTful endpoints for all features")
    print("📍 Visit: http://127.0.0.1:5000")
    print("👤 Demo Login: demo@atithiverse.com / demo123")
    app.run(debug=True, host='127.0.0.1', port=5000)
