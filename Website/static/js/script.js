// ===== GLOBAL VARIABLES =====
let isLoading = true;
let currentUser = null;

// ===== INITIALIZATION =====
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    console.log('🚀 Initializing AtithiVerse...');
    
    // Hide loading screen after a short delay
    setTimeout(() => {
        const loadingScreen = document.getElementById('loading-screen');
        if (loadingScreen) {
            loadingScreen.classList.add('hide');
            setTimeout(() => {
                loadingScreen.style.display = 'none';
                isLoading = false;
            }, 500);
        } else {
            isLoading = false;
        }
    }, 800);

    // Initialize all components
    initializeNavigation();
    initializeScrollEffects();
    initializeAnimations();
    initializeUserAuth();
    initializeBackToTop();
    initializeSearch();
    
    // Page-specific initialization
    const currentPage = window.location.pathname;
    if (currentPage === '/' || currentPage === '/index.html') {
        initializeHomePage();
    }
}

// ===== NAVIGATION =====
function initializeNavigation() {
    const navbar = document.getElementById('mainNavbar');
    const navLinks = document.querySelectorAll('.nav-link');
    
    // Navbar scroll effect
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar?.classList.add('scrolled');
        } else {
            navbar?.classList.remove('scrolled');
        }
    });

    // Smooth scrolling for anchor links
    navLinks.forEach(link => {
        if (link.getAttribute('href')?.startsWith('#')) {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const targetId = this.getAttribute('href').substring(1);
                const targetElement = document.getElementById(targetId);
                
                if (targetElement) {
                    const offsetTop = targetElement.offsetTop - 80;
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                }
            });
        }
    });
}

// ===== SCROLL EFFECTS =====
function initializeScrollEffects() {
    // Scroll progress bar
    const scrollProgress = document.getElementById('scrollProgress');
    
    window.addEventListener('scroll', function() {
        const scrolled = (window.pageYOffset / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
        if (scrollProgress) {
            scrollProgress.style.width = scrolled + '%';
        }
    });
}

// ===== ANIMATIONS =====
function initializeAnimations() {
    // Initialize AOS (Animate On Scroll)
    if (typeof AOS !== 'undefined') {
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true,
            offset: 100
        });
    }

    // Counter animation for stats
    const statNumbers = document.querySelectorAll('.stat-number');
    const observerOptions = {
        threshold: 0.7,
        rootMargin: '0px 0px -100px 0px'
    };

    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                statsObserver.unobserve(entry.target);
            }
        });
    }, observerOptions);

    statNumbers.forEach(stat => {
        statsObserver.observe(stat);
    });
}

function animateCounter(element) {
    const target = element.textContent;
    const isRating = target.includes('★');
    const numericValue = parseFloat(target.replace(/[^\d.]/g, ''));
    const suffix = target.replace(/[\d.]/g, '');
    
    let current = 0;
    const increment = numericValue / 60;
    const timer = setInterval(() => {
        current += increment;
        if (current >= numericValue) {
            current = numericValue;
            clearInterval(timer);
        }
        
        if (isRating) {
            element.textContent = current.toFixed(1) + '★';
        } else if (target.includes('K')) {
            element.textContent = Math.floor(current) + 'K+';
        } else {
            element.textContent = Math.floor(current) + '+';
        }
    }, 16);
}

// ===== USER AUTHENTICATION =====
function initializeUserAuth() {
    // Check if user is logged in via API
    fetch('/api/user')
        .then(response => response.json())
        .then(result => {
            if (result.success && result.user) {
                currentUser = result.user;
                updateAuthUI(true);
                console.log('✅ User logged in:', currentUser);
            } else {
                updateAuthUI(false);
                console.log('ℹ️ No user logged in');
            }
        })
        .catch(error => {
            console.log('⚠️ Auth check failed:', error);
            updateAuthUI(false);
        });

    // Logout functionality
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
    }
}

function updateAuthUI(isLoggedIn) {
    const authNav = document.getElementById('authNav');
    const userNav = document.getElementById('userNav');
    const userName = document.getElementById('userName');

    if (isLoggedIn && currentUser) {
        authNav?.classList.add('d-none');
        userNav?.classList.remove('d-none');
        if (userName) {
            userName.textContent = currentUser.name || currentUser.email;
        }
    } else {
        authNav?.classList.remove('d-none');
        userNav?.classList.add('d-none');
    }
}

function logout() {
    fetch('/api/logout', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(result => {
        currentUser = null;
        updateAuthUI(false);
        showNotification('You have been logged out successfully.', 'info');
        
        // Remove user data from localStorage
        localStorage.removeItem('user');
        
        // Reload page to clear any user-specific data
        setTimeout(() => {
            window.location.reload();
        }, 1500);
    })
    .catch(error => {
        console.error('Logout error:', error);
        // Force logout on client side even if server request fails
        currentUser = null;
        updateAuthUI(false);
        localStorage.removeItem('user');
        window.location.reload();
    });
}

// ===== BACK TO TOP BUTTON =====
function initializeBackToTop() {
    const backToTopBtn = document.getElementById('backToTop');
    
    if (backToTopBtn) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 300) {
                backToTopBtn.classList.add('show');
            } else {
                backToTopBtn.classList.remove('show');
            }
        });

        backToTopBtn.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
}

// ===== SEARCH FUNCTIONALITY =====
function initializeSearch() {
    const searchBtn = document.querySelector('.search-btn');
    const searchDestination = document.getElementById('searchDestination');
    const searchDate = document.getElementById('searchDate');
    const searchGuests = document.getElementById('searchGuests');

    if (searchBtn) {
        searchBtn.addEventListener('click', function() {
            performSearch();
        });
    }

    // Search on enter key
    if (searchDestination) {
        searchDestination.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                performSearch();
            }
        });
    }

    // Set minimum date to today
    if (searchDate) {
        const today = new Date().toISOString().split('T')[0];
        searchDate.setAttribute('min', today);
        searchDate.value = today;
    }
}

function performSearch() {
    const destination = document.getElementById('searchDestination')?.value;
    const date = document.getElementById('searchDate')?.value;
    const guests = document.getElementById('searchGuests')?.value;

    if (!destination?.trim()) {
        showNotification('Please enter a destination to search.', 'warning');
        return;
    }

    // Show loading state
    const searchBtn = document.querySelector('.search-btn');
    const originalText = searchBtn.innerHTML;
    searchBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Searching...';
    searchBtn.disabled = true;

    // Simulate search delay
    setTimeout(() => {
        showNotification(`Searching for "${destination}" on ${date} for ${guests}...`, 'info');
        
        // Scroll to destinations section
        const destinationsSection = document.getElementById('destinations');
        if (destinationsSection) {
            destinationsSection.scrollIntoView({ behavior: 'smooth' });
        }

        // Filter destinations based on search
        loadDestinations('all', destination);

        // Reset button
        searchBtn.innerHTML = originalText;
        searchBtn.disabled = false;
    }, 1500);
}

// ===== HOME PAGE SPECIFIC =====
function initializeHomePage() {
    console.log('🏠 Initializing home page...');
    loadDestinations('all');
    initializeDestinationFilters();
    initializeNewsletterForm();
}

function initializeDestinationFilters() {
    const filterBtns = document.querySelectorAll('.filter-btn');
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const category = this.dataset.category;
            
            // Update active filter
            filterBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Add loading effect
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
            
            // Load destinations
            loadDestinations(category);
        });
    });
}

function loadDestinations(category = 'all', searchTerm = '') {
    const grid = document.getElementById('destinationsGrid');
    if (!grid) {
        console.log('⚠️ Destinations grid not found');
        return;
    }

    console.log(`📡 Loading destinations for category: ${category}${searchTerm ? `, search: ${searchTerm}` : ''}`);
    
    // Show loading state
    grid.innerHTML = `
        <div class="col-12 text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3">Loading incredible destinations...</p>
        </div>
    `;

    let url = '/api/destinations';
    const params = new URLSearchParams();
    
    if (category !== 'all') {
        params.append('category', category);
    }
    if (searchTerm) {
        params.append('search', searchTerm);
    }
    
    if (params.toString()) {
        url += '?' + params.toString();
    }
    
    fetch(url)
        .then(response => {
            console.log('📡 API Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('📦 API Response data:', data);
            
            if (data.success && Array.isArray(data.destinations)) {
                displayDestinations(data.destinations);
            } else if (Array.isArray(data)) {
                // Fallback for old format
                displayDestinations(data);
            } else {
                console.error('❌ Invalid destinations data format:', data);
                showErrorMessage('Invalid data format received');
            }
        })
        .catch(error => {
            console.error('❌ Error loading destinations:', error);
            showErrorMessage('Failed to load destinations. Please try again.');
        });
}

function displayDestinations(destinations) {
    const grid = document.getElementById('destinationsGrid');
    if (!grid) return;
    
    console.log(`🎨 Displaying ${destinations.length} destinations`);
    
    if (!destinations || destinations.length === 0) {
        grid.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="fas fa-search fa-3x text-muted mb-3"></i>
                <h3>No destinations found</h3>
                <p class="text-muted">Try selecting a different category or search term.</p>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = destinations.map((dest, index) => `
        <div class="destination-card" data-aos="fade-up" data-aos-delay="${index * 100}">
            <div class="destination-image">
                <img src="${dest.image || 'https://via.placeholder.com/400x250/f8f9fa/6c757d?text=' + encodeURIComponent(dest.name)}" 
                     alt="${dest.name}" 
                     class="img-fluid" 
                     onerror="this.src='https://via.placeholder.com/400x250/f8f9fa/6c757d?text=${encodeURIComponent(dest.name)}'"
                     loading="lazy">
                <div class="destination-overlay">
                    <button class="btn btn-primary btn-sm" onclick="viewDestinationDetails(${dest.id})">
                        <i class="fas fa-eye me-1"></i>View Details
                    </button>
                </div>
                <div class="destination-badge">
                    <i class="fas fa-star"></i>
                    ${dest.rating || 4.5}
                </div>
                ${dest.in_wishlist ? `
                <div class="wishlist-badge">
                    <i class="fas fa-heart text-danger"></i>
                </div>
                ` : ''}
            </div>
            <div class="destination-content">
                <div class="destination-location">
                    <i class="fas fa-map-marker-alt me-1"></i>
                    ${dest.location || 'India'}
                </div>
                <h4 class="destination-title">${dest.name}</h4>
                <p class="destination-description">${dest.description}</p>
                <div class="destination-features">
                    ${(dest.features || ['Popular', 'Recommended']).slice(0, 2).map(feature => `
                        <span class="feature-tag">${feature}</span>
                    `).join('')}
                </div>
                <div class="destination-footer">
                    <div class="destination-price">
                        <span class="price-label">From</span>
                        <span class="price-value">₹${(dest.price || 0).toLocaleString()}</span>
                        <span class="price-unit">per person</span>
                    </div>
                    <button class="btn btn-outline-primary btn-sm wishlist-btn" 
                            onclick="toggleWishlist(${dest.id}, this)"
                            data-in-wishlist="${dest.in_wishlist || false}">
                        <i class="fas fa-heart me-1"></i>
                        ${dest.in_wishlist ? 'Saved' : 'Save'}
                    </button>
                </div>
            </div>
        </div>
    `).join('');
    
    // Reinitialize AOS for new elements
    if (typeof AOS !== 'undefined') {
        AOS.refresh();
    }
}

function showErrorMessage(message) {
    const grid = document.getElementById('destinationsGrid');
    if (grid) {
        grid.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="fas fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                <h3>Oops! Something went wrong</h3>
                <p class="text-muted">${message}</p>
                <button class="btn btn-primary" onclick="window.location.reload()">
                    <i class="fas fa-redo me-2"></i>Try Again
                </button>
            </div>
        `;
    }
}

function viewDestinationDetails(destinationId) {
    console.log(`👁️ Viewing details for destination ID: ${destinationId}`);
    
    // Show loading notification
    showNotification('Loading destination details...', 'info');
    
    fetch(`/api/destinations/${destinationId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.destination) {
                showDestinationModal(data.destination);
            } else {
                throw new Error(data.message || 'Destination not found');
            }
        })
        .catch(error => {
            console.error('Error loading destination details:', error);
            showNotification('Error loading destination details.', 'error');
        });
}

function showDestinationModal(destination) {
    // Create modal HTML
    const modalHtml = `
        <div class="modal fade" id="destinationModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">${destination.name}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6">
                                <img src="${destination.image}" alt="${destination.name}" 
                                     class="img-fluid rounded mb-3"
                                     onerror="this.src='https://via.placeholder.com/400x250/f8f9fa/6c757d?text=${encodeURIComponent(destination.name)}'">
                                <div class="d-flex align-items-center mb-3">
                                    <span class="badge bg-primary me-2">
                                        <i class="fas fa-star"></i> ${destination.rating}
                                    </span>
                                    <small class="text-muted">${destination.reviews} reviews</small>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <h6><i class="fas fa-map-marker-alt me-2"></i>${destination.location}</h6>
                                <p class="mb-3">${destination.long_description || destination.description}</p>
                                
                                <h6>Features:</h6>
                                <ul class="list-unstyled">
                                    ${(destination.features || []).map(feature => `
                                        <li><i class="fas fa-check text-success me-2"></i>${feature}</li>
                                    `).join('')}
                                </ul>
                                
                                <div class="pricing-info mt-4">
                                    <h4 class="text-primary">₹${destination.price?.toLocaleString()}</h4>
                                    <p class="text-muted">per person</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-primary" onclick="toggleWishlist(${destination.id}, this)">
                            <i class="fas fa-heart me-1"></i>${destination.in_wishlist ? 'Remove from Wishlist' : 'Add to Wishlist'}
                        </button>
                        <button type="button" class="btn btn-primary" onclick="bookNow(${destination.id})">
                            <i class="fas fa-calendar-check me-1"></i>Book Now
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;

    // Remove existing modal if any
    const existingModal = document.getElementById('destinationModal');
    if (existingModal) {
        existingModal.remove();
    }

    // Add modal to body
    document.body.insertAdjacentHTML('beforeend', modalHtml);

    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('destinationModal'));
    modal.show();

    // Clean up on hide
    document.getElementById('destinationModal').addEventListener('hidden.bs.modal', function() {
        this.remove();
    });
}

function toggleWishlist(destinationId, button) {
    if (!currentUser) {
        showNotification('Please log in to save destinations to your wishlist.', 'warning');
        return;
    }

    console.log(`💖 Toggling wishlist for destination ID: ${destinationId}`);

    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>...';
    button.disabled = true;

    fetch('/api/wishlist', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            destination_id: destinationId
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            const inWishlist = result.in_wishlist;
            
            // Update button
            button.innerHTML = `<i class="fas fa-heart me-1"></i>${inWishlist ? 'Saved' : 'Save'}`;
            button.classList.toggle('btn-danger', inWishlist);
            button.classList.toggle('btn-outline-primary', !inWishlist);
            button.dataset.inWishlist = inWishlist;
            
            showNotification(result.message, 'success');
        } else {
            showNotification(result.message || 'Error updating wishlist', 'error');
        }
    })
    .catch(error => {
        console.error('Wishlist error:', error);
        showNotification('Error updating wishlist. Please try again.', 'error');
    })
    .finally(() => {
        button.disabled = false;
        if (button.innerHTML.includes('spinner')) {
            button.innerHTML = originalText;
        }
    });
}

function bookNow(destinationId) {
    if (!currentUser) {
        showNotification('Please log in to make a booking.', 'warning');
        setTimeout(() => {
            window.location.href = '/login?redirect=' + encodeURIComponent(window.location.pathname);
        }, 2000);
        return;
    }

    showNotification('Booking feature coming soon!', 'info');
    // TODO: Implement booking functionality
}

function initializeNewsletterForm() {
    const newsletterForm = document.querySelector('.newsletter-form');
    if (!newsletterForm) return;

    const subscribeBtn = newsletterForm.querySelector('.btn');
    const emailInput = newsletterForm.querySelector('input[type="email"]');

    subscribeBtn?.addEventListener('click', function(e) {
        e.preventDefault();
        const email = emailInput?.value.trim();

        if (!email) {
            showNotification('Please enter your email address.', 'warning');
            return;
        }

        if (!isValidEmail(email)) {
            showNotification('Please enter a valid email address.', 'warning');
            return;
        }

        // Show loading state
        const originalText = subscribeBtn.innerHTML;
        subscribeBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Subscribing...';
        subscribeBtn.disabled = true;

        fetch('/api/newsletter', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email: email })
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                showNotification(result.message || 'Successfully subscribed!', 'success');
                emailInput.value = '';
            } else {
                showNotification(result.message || 'Subscription failed', 'error');
            }
        })
        .catch(error => {
            console.error('Newsletter subscription error:', error);
            showNotification('Subscription failed. Please try again.', 'error');
        })
        .finally(() => {
            // Reset button
            subscribeBtn.innerHTML = originalText;
            subscribeBtn.disabled = false;
        });
    });

    // Subscribe on Enter key
    emailInput?.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            subscribeBtn?.click();
        }
    });
}

// ===== UTILITY FUNCTIONS =====
function showNotification(message, type = 'info') {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.custom-notification');
    existingNotifications.forEach(notification => notification.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `custom-notification alert alert-${getAlertClass(type)} alert-dismissible fade show`;
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        z-index: 10000;
        min-width: 320px;
        max-width: 400px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.15);
        border: none;
        border-radius: 15px;
        backdrop-filter: blur(10px);
    `;
    
    notification.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas fa-${getNotificationIcon(type)} me-2"></i>
            <div class="flex-grow-1">${message}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }
    }, 5000);
}

function getAlertClass(type) {
    const classes = {
        'success': 'success',
        'error': 'danger', 
        'warning': 'warning',
        'info': 'info'
    };
    return classes[type] || 'info';
}

function getNotificationIcon(type) {
    const icons = {
        'success': 'check-circle',
        'error': 'exclamation-triangle',
        'warning': 'exclamation-circle', 
        'info': 'info-circle'
    };
    return icons[type] || 'info-circle';
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// ===== ERROR HANDLING =====
window.addEventListener('error', function(event) {
    console.error('❌ JavaScript Error:', event.error);
    if (!isLoading) {
        showNotification('Something went wrong. Please refresh the page.', 'error');
    }
});

window.addEventListener('unhandledrejection', function(event) {
    console.error('❌ Unhandled Promise Rejection:', event.reason);
    if (!isLoading) {
        showNotification('Network error. Please check your connection.', 'error');
    }
});
