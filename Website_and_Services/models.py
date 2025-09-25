from flask_sqlalchemy import SQLAlchemy
from flask_user import UserMixin
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
import uuid

db = SQLAlchemy()

# User Model
class User(db.Model, UserMixin):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    uuid = db.Column(db.String(36), unique=True, default=lambda: str(uuid.uuid4()))
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    phone = db.Column(db.String(20))
    country = db.Column(db.String(50))
    date_of_birth = db.Column(db.Date)
    profile_image = db.Column(db.String(255))
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    bookings = db.relationship('Booking', backref='user', lazy=True)
    reviews = db.relationship('Review', backref='user', lazy=True)
    wishlists = db.relationship('Wishlist', backref='user', lazy=True)
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def to_dict(self):
        return {
            'id': self.id,
            'uuid': self.uuid,
            'username': self.username,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'phone': self.phone,
            'country': self.country,
            'is_verified': self.is_verified
        }

# Destination Model
class Destination(db.Model):
    __tablename__ = 'destinations'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    state = db.Column(db.String(100))
    country = db.Column(db.String(100), default='India')
    description = db.Column(db.Text)
    long_description = db.Column(db.Text)
    price = db.Column(db.Float, nullable=False)
    original_price = db.Column(db.Float)
    currency = db.Column(db.String(5), default='INR')
    image_url = db.Column(db.String(500))
    image_gallery = db.Column(db.JSON)  # Store multiple images
    duration = db.Column(db.String(50))
    max_people = db.Column(db.Integer, default=50)
    min_age = db.Column(db.Integer, default=0)
    difficulty_level = db.Column(db.String(20))  # Easy, Moderate, Hard
    features = db.Column(db.JSON)  # Store features as JSON array
    included_services = db.Column(db.JSON)
    excluded_services = db.Column(db.JSON)
    best_season = db.Column(db.String(100))
    rating = db.Column(db.Float, default=0.0)
    total_reviews = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    is_featured = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    bookings = db.relationship('Booking', backref='destination', lazy=True)
    reviews = db.relationship('Review', backref='destination', lazy=True)
    wishlists = db.relationship('Wishlist', backref='destination', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'category': self.category,
            'location': self.location,
            'state': self.state,
            'country': self.country,
            'description': self.description,
            'price': self.price,
            'original_price': self.original_price,
            'currency': self.currency,
            'image': self.image_url,
            'image_gallery': self.image_gallery,
            'duration': self.duration,
            'max_people': self.max_people,
            'difficulty_level': self.difficulty_level,
            'features': self.features,
            'included_services': self.included_services,
            'excluded_services': self.excluded_services,
            'best_season': self.best_season,
            'rating': round(self.rating, 1),
            'reviews': self.total_reviews,
            'is_featured': self.is_featured
        }

# Booking Model
class Booking(db.Model):
    __tablename__ = 'bookings'
    
    id = db.Column(db.Integer, primary_key=True)
    booking_id = db.Column(db.String(50), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    destination_id = db.Column(db.Integer, db.ForeignKey('destinations.id'), nullable=False)
    
    # Booking Details
    check_in_date = db.Column(db.Date, nullable=False)
    check_out_date = db.Column(db.Date)
    adults = db.Column(db.Integer, default=1)
    children = db.Column(db.Integer, default=0)
    total_people = db.Column(db.Integer, default=1)
    
    # Pricing
    base_price = db.Column(db.Float, nullable=False)
    total_price = db.Column(db.Float, nullable=False)
    discount_amount = db.Column(db.Float, default=0)
    tax_amount = db.Column(db.Float, default=0)
    final_price = db.Column(db.Float, nullable=False)
    currency = db.Column(db.String(5), default='INR')
    
    # Status
    status = db.Column(db.String(20), default='pending')  # pending, confirmed, cancelled, completed
    payment_status = db.Column(db.String(20), default='pending')  # pending, paid, failed, refunded
    payment_method = db.Column(db.String(50))
    payment_id = db.Column(db.String(100))
    
    # Additional Info
    special_requests = db.Column(db.Text)
    booking_notes = db.Column(db.Text)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def generate_booking_id(self):
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d%H%M")
        import random
        random_num = random.randint(1000, 9999)
        return f"ATI{timestamp}{random_num}"
    
    def __init__(self, **kwargs):
        super(Booking, self).__init__(**kwargs)
        if not self.booking_id:
            self.booking_id = self.generate_booking_id()
    
    def to_dict(self):
        return {
            'id': self.id,
            'booking_id': self.booking_id,
            'destination': self.destination.to_dict() if self.destination else None,
            'check_in_date': self.check_in_date.isoformat() if self.check_in_date else None,
            'check_out_date': self.check_out_date.isoformat() if self.check_out_date else None,
            'adults': self.adults,
            'children': self.children,
            'total_people': self.total_people,
            'total_price': self.total_price,
            'final_price': self.final_price,
            'currency': self.currency,
            'status': self.status,
            'payment_status': self.payment_status,
            'created_at': self.created_at.isoformat()
        }

# Review Model
class Review(db.Model):
    __tablename__ = 'reviews'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    destination_id = db.Column(db.Integer, db.ForeignKey('destinations.id'), nullable=False)
    booking_id = db.Column(db.Integer, db.ForeignKey('bookings.id'))
    
    rating = db.Column(db.Integer, nullable=False)  # 1-5 stars
    title = db.Column(db.String(200))
    comment = db.Column(db.Text)
    images = db.Column(db.JSON)  # Store review images
    
    # Rating categories
    service_rating = db.Column(db.Integer)
    value_rating = db.Column(db.Integer)
    location_rating = db.Column(db.Integer)
    cleanliness_rating = db.Column(db.Integer)
    
    is_verified = db.Column(db.Boolean, default=False)
    is_featured = db.Column(db.Boolean, default=False)
    helpful_count = db.Column(db.Integer, default=0)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'user': {
                'name': f"{self.user.first_name} {self.user.last_name}",
                'username': self.user.username,
                'profile_image': self.user.profile_image
            },
            'rating': self.rating,
            'title': self.title,
            'comment': self.comment,
            'images': self.images,
            'service_rating': self.service_rating,
            'value_rating': self.value_rating,
            'location_rating': self.location_rating,
            'cleanliness_rating': self.cleanliness_rating,
            'is_verified': self.is_verified,
            'helpful_count': self.helpful_count,
            'created_at': self.created_at.isoformat()
        }

# Wishlist Model
class Wishlist(db.Model):
    __tablename__ = 'wishlists'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    destination_id = db.Column(db.Integer, db.ForeignKey('destinations.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Unique constraint to prevent duplicate wishlist entries
    __table_args__ = (db.UniqueConstraint('user_id', 'destination_id', name='unique_user_destination'),)

# Contact Form Model
class ContactMessage(db.Model):
    __tablename__ = 'contact_messages'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(20))
    subject = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default='new')  # new, read, replied, closed
    admin_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'subject': self.subject,
            'message': self.message,
            'status': self.status,
            'created_at': self.created_at.isoformat()
        }

# Newsletter Subscription Model
class Newsletter(db.Model):
    __tablename__ = 'newsletter_subscriptions'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    is_subscribed = db.Column(db.Boolean, default=True)
    subscription_date = db.Column(db.DateTime, default=datetime.utcnow)
    unsubscribe_token = db.Column(db.String(100), unique=True)
    
    def __init__(self, **kwargs):
        super(Newsletter, self).__init__(**kwargs)
        if not self.unsubscribe_token:
            self.unsubscribe_token = str(uuid.uuid4())
