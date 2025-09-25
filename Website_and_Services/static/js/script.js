// ===== GLOBAL VARIABLES =====
let isLoading = true;
let currentUser = null;
let chatInitialized = false;
let connectionRetries = 0;
const MAX_RETRIES = 3;

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
    initializeAIChatbot();
    
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
    const isRating = target.includes('★') || target.includes('⭐');
    const numericValue = parseFloat(target.replace(/[^\d.]/g, ''));
    
    let current = 0;
    const increment = numericValue / 60;
    const timer = setInterval(() => {
        current += increment;
        if (current >= numericValue) {
            current = numericValue;
            clearInterval(timer);
        }
        
        if (isRating) {
            element.textContent = current.toFixed(1) + '⭐';
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
    fetch('/api/logout', { method: 'POST' })
    .then(response => response.json())
    .then(result => {
        showNotification('You have been logged out successfully.', 'info');
    })
    .catch(error => {
        console.error('Logout error:', error);
        showNotification('Logged out.', 'info');
    })
    .finally(() => {
        currentUser = null;
        updateAuthUI(false);
        localStorage.removeItem('user');
        setTimeout(() => {
            window.location.reload();
        }, 1500);
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

    if (searchBtn) {
        searchBtn.addEventListener('click', performSearch);
    }

    if (searchDestination) {
        searchDestination.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                performSearch();
            }
        });
    }

    if (searchDate) {
        const today = new Date().toISOString().split('T')[0];
        searchDate.setAttribute('min', today);
        searchDate.value = today;
    }

    initializeSearchSuggestions();
}

function initializeSearchSuggestions() {
    const searchDestination = document.getElementById('searchDestination');
    if (!searchDestination) return;

    const suggestionBox = document.createElement('div');
    suggestionBox.className = 'search-suggestions';
    searchDestination.parentElement.style.position = 'relative';
    searchDestination.parentElement.appendChild(suggestionBox);

    let debounceTimer;
    searchDestination.addEventListener('input', function() {
        const query = this.value.trim();
        clearTimeout(debounceTimer);
        if (!query) {
            suggestionBox.style.display = 'none';
            suggestionBox.innerHTML = '';
            return;
        }
        debounceTimer = setTimeout(async () => {
            try {
                const resp = await fetch(`/api/google-search?q=${encodeURIComponent(query)}&num=6`);
                const data = await resp.json();
                if (!data.success || !data.results || data.results.length === 0) {
                    suggestionBox.style.display = 'none';
                    return;
                }
                suggestionBox.innerHTML = data.results.map(item => `
                    <div class="suggestion-item" data-value="${(item.title || '').replace(/"/g, '&quot;')}">
                        <i class="fas fa-location-dot me-2"></i>${item.title}
                        <small class="text-muted d-block">${item.displayLink || ''}</small>
                    </div>
                `).join('');
                suggestionBox.style.display = 'block';
            } catch (e) {
                suggestionBox.style.display = 'none';
            }
        }, 300);
    });

    suggestionBox.addEventListener('click', function(e) {
        const item = e.target.closest('.suggestion-item');
        if (item) {
            searchDestination.value = item.getAttribute('data-value') || '';
            suggestionBox.style.display = 'none';
        }
    });

    document.addEventListener('click', function(e) {
        if (!suggestionBox.contains(e.target) && e.target !== searchDestination) {
            suggestionBox.style.display = 'none';
        }
    });
}

function performSearch() {
    const destination = document.getElementById('searchDestination')?.value;
    const date = document.getElementById('searchDate')?.value;
    const guests = document.getElementById('searchGuests')?.value;

    if (!destination?.trim()) {
        showNotification('Please enter a destination to search.', 'warning');
        return;
    }

    const searchBtn = document.querySelector('.search-btn');
    const originalText = searchBtn.innerHTML;
    searchBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Searching...';
    searchBtn.disabled = true;

    setTimeout(() => {
        showNotification(`Searching for "${destination}" on ${date} for ${guests}...`, 'info');
        
        const destinationsSection = document.getElementById('destinations');
        destinationsSection?.scrollIntoView({ behavior: 'smooth' });

        loadDestinations('all', destination);

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
            
            filterBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
            
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
    
    grid.innerHTML = `
        <div class="col-12 text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3">Loading incredible destinations...</p>
        </div>
    `;

    const params = new URLSearchParams();
    if (category !== 'all') params.append('category', category);
    if (searchTerm) params.append('search', searchTerm);
    const queryString = params.toString();
    const url = `/api/destinations${queryString ? '?' + queryString : ''}`;
    
    fetch(url)
        .then(response => {
            console.log('📡 API Response status:', response.status);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return response.json();
        })
        .then(data => {
            console.log('📦 Raw API Response:', data);
            
            let destinations;
            if (data.success && Array.isArray(data.destinations)) {
                destinations = data.destinations;
                console.log('✅ Using new API format');
            } else if (Array.isArray(data)) {
                destinations = data;
                console.log('✅ Using old API format');
            } else {
                throw new Error('Invalid response format');
            }
            
            console.log(`✅ Found ${destinations.length} destinations`);
            displayDestinations(destinations);
        })
        .catch(error => {
            console.error('❌ Error loading destinations:', error);
            showErrorMessage('Failed to load destinations. Please try again.');
        });
}

function displayDestinations(destinations) {
    const grid = document.getElementById('destinationsGrid');
    if (!grid) {
        console.error('❌ Grid element not found!');
        return;
    }
    
    console.log(`🎨 Displaying destinations:`, destinations);
    
    if (!Array.isArray(destinations)) {
        showErrorMessage('Invalid destinations data format');
        return;
    }
    
    if (destinations.length === 0) {
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
                <img src="${dest.image || 'https://placehold.co/400x250/f8f9fa/6c757d?text=' + encodeURIComponent(dest.name)}" 
                     alt="${dest.name}" 
                     class="img-fluid" 
                     onerror="this.onerror=null;this.src='https://placehold.co/400x250/f8f9fa/6c757d?text=Image+Error'"
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
                ${dest.in_wishlist ? `<div class="wishlist-badge"><i class="fas fa-heart text-danger"></i></div>` : ''}
            </div>
            <div class="destination-content">
                <div class="destination-location">
                    <i class="fas fa-map-marker-alt me-1"></i>
                    ${dest.location || 'India'}
                </div>
                <h4 class="destination-title">${dest.name}</h4>
                <p class="destination-description">${dest.description}</p>
                <div class="destination-features">
                    ${(dest.features || ['Popular', 'Recommended']).slice(0, 2).map(feature => `<span class="feature-tag">${feature}</span>`).join('')}
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
    
    console.log('✅ Cards displayed successfully!');
    
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
    console.log(`🔗 Opening destination detail page for ID: ${destinationId}`);
    
    if (!destinationId) {
        console.error('❌ No destination ID provided');
        showNotification('Invalid destination ID', 'error');
        return;
    }
    
    showNotification('Opening destination details...', 'info');
    window.location.href = `/destination/${destinationId}`;
}


function showDestinationModal(destination) {
    const existingModal = document.getElementById('destinationModal');
    if (existingModal) {
        existingModal.remove();
    }

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
                                     onerror="this.src='https://placehold.co/400x250/f8f9fa/6c757d?text=${encodeURIComponent(destination.name)}'">
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
                                    ${(destination.features || []).map(feature => `<li><i class="fas fa-check text-success me-2"></i>${feature}</li>`).join('')}
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

    document.body.insertAdjacentHTML('beforeend', modalHtml);
    const modal = new bootstrap.Modal(document.getElementById('destinationModal'));
    modal.show();
    document.getElementById('destinationModal').addEventListener('hidden.bs.modal', function() {
        this.remove();
    });
}

function toggleWishlist(destinationId, button) {
    if (!currentUser) {
        showNotification('Please log in to save to your wishlist.', 'warning');
        return;
    }

    console.log(`💖 Toggling wishlist for destination ID: ${destinationId}`);

    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>...';
    button.disabled = true;

    fetch('/api/wishlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ destination_id: destinationId })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            const inWishlist = result.in_wishlist;
            
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
        button.innerHTML = originalText;
    })
    .finally(() => {
        button.disabled = false;
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
}

function initializeNewsletterForm() {
    const newsletterForm = document.querySelector('.newsletter-form');
    if (!newsletterForm) return;

    const subscribeBtn = newsletterForm.querySelector('.btn');
    const emailInput = newsletterForm.querySelector('input[type="email"]');

    const handleSubscription = () => {
        const email = emailInput?.value.trim();
        if (!email || !isValidEmail(email)) {
            showNotification('Please enter a valid email address.', 'warning');
            return;
        }

        const originalText = subscribeBtn.innerHTML;
        subscribeBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Subscribing...';
        subscribeBtn.disabled = true;

        fetch('/api/newsletter', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: email })
        })
        .then(response => response.json())
        .then(result => {
            showNotification(result.message || (result.success ? 'Successfully subscribed!' : 'Subscription failed'), result.success ? 'success' : 'error');
            if (result.success) emailInput.value = '';
        })
        .catch(error => {
            console.error('Newsletter error:', error);
            showNotification('Subscription failed. Please try again.', 'error');
        })
        .finally(() => {
            subscribeBtn.innerHTML = originalText;
            subscribeBtn.disabled = false;
        });
    };

    subscribeBtn?.addEventListener('click', handleSubscription);
    emailInput?.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleSubscription();
    });
}

// ===== ENHANCED AI CHATBOT FUNCTIONALITY =====
function initializeAIChatbot() {
    if (chatInitialized) return;
    chatInitialized = true;
    
    console.log('🤖 Initializing AI Chatbot...');
    
    const chatButton = document.getElementById('chatButton');
    const chatWindow = document.getElementById('chatWindow');
    const chatClose = document.getElementById('chatClose');
    const chatInput = document.getElementById('chatInput');
    const sendButton = document.getElementById('sendButton');
    const quickActionsContainer = document.getElementById('quickActions');

    let conversationHistory = [];
    let isConnected = false;

    testAIConnection();

    function testAIConnection() {
        fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_input: 'test connection' })
        })
        .then(response => response.json())
        .then(data => { isConnected = data.success; })
        .catch(() => { isConnected = false; })
        .finally(() => {
            console.log(isConnected ? '✅ AI Service Connected' : '⚠️ AI Service Offline');
            updateConnectionStatus();
        });
    }

    function updateConnectionStatus() {
        const statusElement = document.querySelector('.chat-header .status');
        if (statusElement) {
            statusElement.innerHTML = isConnected ? '<i class="fas fa-brain"></i> AI Powered' : '<i class="fas fa-exclamation-circle"></i> Limited Mode';
            statusElement.className = `status ${isConnected ? 'ai-powered' : 'offline-mode'}`;
        }
    }

    chatButton?.addEventListener('click', () => {
        chatWindow.classList.add('open');
        chatInput?.focus();
        if (!isConnected) testAIConnection();
    });

    chatClose?.addEventListener('click', () => {
        chatWindow.classList.remove('open');
    });
    
    const sendMessage = () => {
        const message = chatInput?.value.trim();
        if (!message) return;
        addMessage(message, 'user');
        chatInput.value = '';
        showTypingIndicator();
        callAIService(message);
    };

    function callAIService(message, retryCount = 0) {
        console.log(`🤖 Calling AI service: "${message}" (attempt ${retryCount + 1})`);
        
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 30000);
        
        fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_input: message,
                conversation_history: conversationHistory.slice(-5),
                user_id: currentUser?.id,
                timestamp: new Date().toISOString()
            }),
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return response.json();
        })
        .then(data => {
            hideTypingIndicator();
            if (data.success) {
                addMessage(data.response, 'bot');
                conversationHistory.push({ user: message, bot: data.response, timestamp: new Date().toISOString() });
                if (conversationHistory.length > 10) conversationHistory.shift();
                if (data.suggestions) updateQuickActions(data.suggestions);
                isConnected = data.ai_powered || false;
                updateConnectionStatus();
            } else {
                throw new Error(data.error || 'Unknown error');
            }
        })
        .catch(error => {
            clearTimeout(timeoutId);
            hideTypingIndicator();
            console.error(`❌ AI API Error:`, error);
            
            if (retryCount < MAX_RETRIES && error.name !== 'AbortError') {
                setTimeout(() => callAIService(message, retryCount + 1), 2000 * (retryCount + 1));
                return;
            }
            
            isConnected = false;
            updateConnectionStatus();
            addMessage(getFallbackResponse(message), 'bot');
            const errorMsg = error.name === 'AbortError' ? 'Response timed out.' : 'AI service temporarily unavailable.';
            showNotification(errorMsg, 'warning');
        })
        .finally(() => {
            chatInput.disabled = false;
            sendButton.disabled = false;
            chatInput.focus();
        });
    }
    
    function getFallbackResponse(message) {
        const input = message.toLowerCase();
        const responses = {
            'hello|hi|hey': "👋 Hello! I'm AtithiBot, your travel assistant for Incredible India! How can I help you today?",
            'taj mahal|agra': "🏛️ The Taj Mahal is a must-see! Best visited at sunrise. Don't miss the nearby Agra Fort!",
            'goa|beach': "🏖️ Goa is famous for its beaches! North Goa is for parties, South Goa is for relaxing. What's your style?",
            'kerala|backwater': "🌴 Kerala's backwaters are serene! A houseboat trip in Alleppey is an unforgettable experience.",
            'budget|cheap|cost': "💰 India can be very budget-friendly! A comfortable trip can range from ₹1,500-3,000 per day.",
            'plan|trip|itinerary': "✈️ I can help plan your trip! Just tell me your interests, duration, and budget.",
            'best time|when|weather': "🌤️ The best time to visit most of India is from October to March when the weather is pleasant.",
        };
        for (const [keywords, response] of Object.entries(responses)) {
            if (keywords.split('|').some(keyword => input.includes(keyword))) {
                return response;
            }
        }
        return "🇮🇳 India has so much to offer! From majestic mountains to pristine beaches. What would you like to know more about?";
    }

    sendButton?.addEventListener('click', sendMessage);
    chatInput?.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    const setupQuickActions = () => {
        quickActionsContainer.addEventListener('click', e => {
            if(e.target.classList.contains('quick-btn')) {
                const message = e.target.dataset.message;
                addMessage(message, 'user');
                showTypingIndicator();
                callAIService(message);
            }
        });
    };
    setupQuickActions();

    function addMessage(text, sender) {
        const messagesContainer = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;
        const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        let formattedText = text.replace(/\n/g, '<br>')
                                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                                .replace(/\*(.*?)\*/g, '<em>$1</em>');
        
        messageDiv.innerHTML = `
            <div class="message-avatar"><i class="fas fa-${sender === 'bot' ? 'robot' : 'user'}"></i></div>
            <div class="message-content">
                <div class="message-text">${formattedText}</div>
                <span class="message-time">${time}</span>
            </div>
        `;
        messagesContainer.appendChild(messageDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function showTypingIndicator() {
        hideTypingIndicator(); // Remove any existing one first
        const messagesContainer = document.getElementById('chatMessages');
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message bot-message typing-indicator';
        typingDiv.id = 'typingIndicator';
        typingDiv.innerHTML = `
            <div class="message-avatar"><i class="fas fa-robot"></i></div>
            <div class="message-content">
                <div class="typing-animation">
                    <div class="typing-dots">
                        <div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div>
                    </div>
                    <span class="typing-text">${isConnected ? 'AtithiBot is thinking...' : 'Processing...'}</span>
                </div>
            </div>
        `;
        messagesContainer.appendChild(typingDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function hideTypingIndicator() {
        document.getElementById('typingIndicator')?.remove();
    }

    function updateQuickActions(suggestions) {
        if (suggestions?.length > 0 && quickActionsContainer) {
            quickActionsContainer.innerHTML = suggestions.slice(0, 4).map(s => `<button class="quick-btn" data-message="${s}">${s}</button>`).join('');
        }
    }
}

// ===== UTILITY FUNCTIONS =====
function showNotification(message, type = 'info') {
    document.querySelectorAll('.custom-notification').forEach(n => n.remove());
    const notification = document.createElement('div');
    notification.className = `custom-notification alert alert-${getAlertClass(type)} alert-dismissible fade show`;
    notification.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas fa-${getNotificationIcon(type)} me-2"></i>
            <div class="flex-grow-1">${message}</div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    document.body.appendChild(notification);
    setTimeout(() => notification.remove(), 5000);
}

function getAlertClass(type) { return { success: 'success', error: 'danger', warning: 'warning', info: 'info' }[type] || 'info'; }
function getNotificationIcon(type) { return { success: 'check-circle', error: 'exclamation-triangle', warning: 'exclamation-circle', info: 'info-circle' }[type] || 'info-circle'; }
function isValidEmail(email) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }

// ===== ERROR HANDLING =====
window.addEventListener('error', (event) => {
    console.error('❌ JavaScript Error:', event.error);
    if (!isLoading) showNotification('Something went wrong. Please refresh.', 'error');
});
window.addEventListener('unhandledrejection', (event) => {
    console.error('❌ Unhandled Promise Rejection:', event.reason);
    if (!isLoading) showNotification('Network error. Check your connection.', 'error');
});

// ===== DYNAMIC STYLES =====
(function addEnhancedAIStyles() {
    if (document.getElementById('enhanced-ai-styles')) return;
    const style = document.createElement('style');
    style.id = 'enhanced-ai-styles';
    style.innerHTML = `
        .custom-notification { position: fixed; top: 100px; right: 20px; z-index: 10000; min-width: 320px; box-shadow: 0 8px 32px rgba(0,0,0,0.15); border-radius: 15px; }
        .ai-powered, .offline-mode { padding: 4px 12px !important; border-radius: 15px !important; font-weight: 600 !important; font-size: 11px !important; }
        .ai-powered { background: linear-gradient(45deg, #4ade80, #22c55e) !important; animation: pulse-glow 2s ease-in-out infinite alternate; }
        .offline-mode { background: linear-gradient(45deg, #fbbf24, #f59e0b) !important; }
        @keyframes pulse-glow { 0% { box-shadow: 0 0 5px rgba(74, 222, 128, 0.5); } 100% { box-shadow: 0 0 20px rgba(74, 222, 128, 0.8); } }
        .typing-animation { display: flex; align-items: center; gap: 10px; }
        .typing-text { font-size: 11px; color: #666; font-style: italic; }
        .message-text code { background: rgba(0,0,0,0.1); padding: 2px 6px; border-radius: 4px; font-family: monospace; }
        .quick-btn { font-size: 11px !important; padding: 8px 12px !important; white-space: nowrap !important; overflow: hidden !important; text-overflow: ellipsis !important; transition: all 0.2s ease !important; border-radius: 20px !important; }
        .quick-btn:hover { transform: translateY(-2px) !important; box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important; }
    `;
    document.head.appendChild(style);
})();


// ===== WEATHER WIDGET =====
function loadWeatherForLocation() {
    const select = document.getElementById('weatherLocationSelect');
    if(!select) return;
    const city = select.value;
    const content = document.getElementById('weatherWidgetContent');
    
    console.log('🌤️ Loading weather for:', city);
    content.innerHTML = `<div class="weather-loading"><i class="fas fa-spinner fa-spin"></i><span>Loading...</span></div>`;
    
    fetch(`/api/weather/${encodeURIComponent(city)}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displayWeatherWidget(data);
            } else {
                showWeatherError();
            }
        })
        .catch(error => {
            console.error('Weather fetch error:', error);
            showWeatherError();
        });
}

function displayWeatherWidget(data) {
    const content = document.getElementById('weatherWidgetContent');
    content.innerHTML = `
        <div class="weather-content">
            <div class="weather-main">
                <img src="https://openweathermap.org/img/wn/${data.weather_icon}@2x.png" alt="${data.weather_description}" class="weather-icon">
                <div class="weather-temp">${data.temperature}°C</div>
                <div class="weather-desc">${data.weather_description}</div>
            </div>
            <div class="weather-details">
                <div class="weather-detail"><i class="fas fa-tint"></i><span>Humidity: ${data.humidity}%</span></div>
                <div class="weather-detail"><i class="fas fa-wind"></i><span>Wind: ${data.wind_speed} m/s</span></div>
                <div class="weather-detail"><i class="fas fa-thermometer-half"></i><span>Feels like: ${data.feels_like}°C</span></div>
                <div class="weather-detail"><i class="fas fa-eye"></i><span>Visibility: ${data.visibility} km</span></div>
            </div>
        </div>
    `;
}

function showWeatherError() {
    const content = document.getElementById('weatherWidgetContent');
    content.innerHTML = `<div class="weather-error"><i class="fas fa-exclamation-triangle"></i><span>Weather unavailable</span></div>`;
}

document.addEventListener('DOMContentLoaded', function() {
    setTimeout(() => {
        if (document.getElementById('weatherLocationSelect')) {
            loadWeatherForLocation();
        }
    }, 2000);
});

console.log('✅ AtithiVerse JavaScript initialized successfully!');
