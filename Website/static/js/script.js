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
            console.log('📦 Raw API Response:', data);
            
            // Handle different response formats
            let destinations;
            
            if (data.success && Array.isArray(data.destinations)) {
                destinations = data.destinations;
                console.log('✅ Using new API format');
            } else if (Array.isArray(data)) {
                destinations = data;
                console.log('✅ Using old API format');
            } else {
                console.error('❌ Invalid API response format:', data);
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
        console.error('❌ destinations is not an array:', typeof destinations, destinations);
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
    
    // Navigate to destination detail page (same tab)
    window.location.href = `/destination/${destinationId}`;
    
    // OR open in new tab (uncomment the line below if you prefer new tab)
    // window.open(`/destination/${destinationId}`, '_blank');
    
    // Show loading notification while navigating
    showNotification('Opening destination details...', 'info');
}


function showDestinationModal(destination) {
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

    const existingModal = document.getElementById('destinationModal');
    if (existingModal) {
        existingModal.remove();
    }

    document.body.insertAdjacentHTML('beforeend', modalHtml);

    const modal = new bootstrap.Modal(document.getElementById('destinationModal'));
    modal.show();

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
            subscribeBtn.innerHTML = originalText;
            subscribeBtn.disabled = false;
        });
    });

    emailInput?.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            subscribeBtn?.click();
        }
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
    const chatMessages = document.getElementById('chatMessages');
    const quickActions = document.querySelectorAll('.quick-btn');

    let conversationHistory = [];
    let isConnected = false;

    // Test AI connection on initialization
    testAIConnection();

    function testAIConnection() {
        fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_input: 'test connection' })
        })
        .then(response => response.json())
        .then(data => {
            isConnected = data.success;
            console.log(isConnected ? '✅ AI Service Connected' : '⚠️ AI Service Offline');
            updateConnectionStatus();
        })
        .catch(() => {
            isConnected = false;
            console.log('❌ AI Service Connection Failed');
            updateConnectionStatus();
        });
    }

    function updateConnectionStatus() {
        const statusElement = document.querySelector('.chat-header .status');
        if (statusElement) {
            if (isConnected) {
                statusElement.innerHTML = '<i class="fas fa-brain"></i> AI Powered';
                statusElement.classList.add('ai-powered');
            } else {
                statusElement.innerHTML = '<i class="fas fa-exclamation-circle"></i> Limited Mode';
                statusElement.classList.add('offline-mode');
            }
        }
    }

    // Toggle chat window
    chatButton?.addEventListener('click', function() {
        chatWindow.classList.add('open');
        chatInput?.focus();
        console.log('💬 Chatbot opened');
        
        // Test connection when opening
        if (!isConnected) {
            testAIConnection();
        }
    });

    chatClose?.addEventListener('click', function() {
        chatWindow.classList.remove('open');
    });

    // Send message functionality
    function sendMessage() {
        const message = chatInput?.value.trim();
        if (!message) return;

        addMessage(message, 'user');
        chatInput.value = '';
        
        chatInput.disabled = true;
        sendButton.disabled = true;

        showTypingIndicator();
        callAIService(message);
    }

    // Enhanced AI service call with retry logic
    function callAIService(message, retryCount = 0) {
        console.log(`🤖 Calling AI service with: "${message}" (attempt ${retryCount + 1})`);
        
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 30000); // 30 second timeout
        
        fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_input: message,
                conversation_history: conversationHistory.slice(-5), // Last 5 exchanges
                user_id: currentUser?.id,
                timestamp: new Date().toISOString()
            }),
            signal: controller.signal
        })
        .then(response => {
            clearTimeout(timeoutId);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            return response.json();
        })
        .then(data => {
            hideTypingIndicator();
            
            if (data.success) {
                const aiResponse = data.response;
                addMessage(aiResponse, 'bot');
                
                // Update conversation history
                conversationHistory.push({
                    user: message,
                    bot: aiResponse,
                    timestamp: new Date().toISOString()
                });
                
                // Keep only last 10 conversations for memory management
                if (conversationHistory.length > 10) {
                    conversationHistory = conversationHistory.slice(-10);
                }
                
                // Update quick actions
                if (data.suggestions && data.suggestions.length > 0) {
                    updateQuickActions(data.suggestions);
                }
                
                // Update connection status
                isConnected = data.ai_powered || false;
                updateConnectionStatus();
                
                connectionRetries = 0; // Reset retry count on success
            } else {
                throw new Error(data.error || 'Unknown error occurred');
            }
        })
        .catch(error => {
            clearTimeout(timeoutId);
            hideTypingIndicator();
            
            console.error(`❌ AI API Error (attempt ${retryCount + 1}):`, error);
            
            // Retry logic
            if (retryCount < MAX_RETRIES && !error.name === 'AbortError') {
                console.log(`🔄 Retrying... (${retryCount + 1}/${MAX_RETRIES})`);
                setTimeout(() => {
                    showTypingIndicator();
                    callAIService(message, retryCount + 1);
                }, 2000 * (retryCount + 1)); // Exponential backoff
                return;
            }
            
            // Fallback response after all retries failed
            isConnected = false;
            updateConnectionStatus();
            
            const fallbackResponse = getFallbackResponse(message);
            addMessage(fallbackResponse, 'bot');
            
            // Show error notification for connection issues
            if (error.name === 'AbortError') {
                showNotification('Response timed out. The AI service might be busy.', 'warning');
            } else {
                showNotification('AI service temporarily unavailable. Using fallback responses.', 'warning');
            }
        })
        .finally(() => {
            chatInput.disabled = false;
            sendButton.disabled = false;
            chatInput.focus();
        });
    }

    // Enhanced fallback responses
    function getFallbackResponse(message) {
        const input = message.toLowerCase();
        
        const responses = {
            'hello|hi|hey': "👋 Hello! I'm AtithiBot, your travel assistant for Incredible India! I can help you with destinations, travel tips, and planning your perfect trip. What would you like to explore today?",
            
            'taj mahal|agra': "🏛️ The Taj Mahal is absolutely stunning! Entry costs ₹500 for Indians, ₹1100 for foreigners. Best visited at sunrise (6 AM) or sunset. Don't miss the Agra Fort nearby! Planning a visit?",
            
            'goa|beach': "🏖️ Goa is perfect year-round! North Goa (Baga, Calangute) for nightlife, South Goa (Palolem, Arambol) for peace. November-March is ideal weather. Budget ₹2,000-4,000/day. What interests you most?",
            
            'kerala|backwater': "🌴 Kerala backwaters are magical! Alleppey houseboats cost ₹3,000-12,000/night. October-March is perfect. Must-try: Ayurvedic massage, appam with curry, coconut water fresh from trees!",
            
            'rajasthan|jaipur|udaipur': "🏰 Royal Rajasthan awaits! Jaipur (Pink City), Udaipur (Lake Palace), Jodhpur (Blue City). Palace hotels from ₹5,000/night. October-March best. Camel safaris, folk dances, incredible architecture!",
            
            'budget|cheap|cost': "💰 India is incredibly budget-friendly! Daily costs: Hostels ₹500-1,500, Food ₹200-800, Transport ₹100-500, Attractions ₹50-500. Total ₹1,500-3,000/day comfortably!",
            
            'plan|trip|itinerary': "✈️ I'd love to help plan your trip! Tell me: How many days? What interests you (history, beaches, mountains, culture)? Your budget range? Then I can suggest the perfect itinerary!",
            
            'book|booking|reserve': "📅 You can book amazing experiences right here on AtithiVerse! We offer destination tours, hotel bookings, and complete travel packages. What would you like to book?",
            
            'best time|when|weather': "🌤️ India's best travel times:\n• Oct-Mar: Pleasant weather, perfect for most places\n• Apr-Jun: Hot, ideal for hill stations\n• Jul-Sep: Monsoon, great for Kerala backwaters\nWhere are you planning to go?"
        };
        
        for (const [keywords, response] of Object.entries(responses)) {
            const keywordArray = keywords.split('|');
            if (keywordArray.some(keyword => input.includes(keyword))) {
                return response;
            }
        }
        
        const defaultResponses = [
            "🇮🇳 India offers incredible diversity! From the iconic Taj Mahal to serene Kerala backwaters, vibrant Goa beaches to royal Rajasthan palaces. What type of experience calls to you?",
            "✨ I'm here to help make your India journey unforgettable! Ask me about destinations, travel tips, budgets, or let me help plan your perfect itinerary. What interests you most?",
            "🗺️ Incredible India has something for everyone! History buffs love Delhi & Agra, beach lovers choose Goa, nature enthusiasts pick Kerala, adventure seekers head to Himalayas. What's your travel style?"
        ];
        
        return defaultResponses[Math.floor(Math.random() * defaultResponses.length)];
    }

    // Event listeners
    sendButton?.addEventListener('click', sendMessage);

    chatInput?.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Enhanced quick actions
    quickActions.forEach(btn => {
        btn.addEventListener('click', function() {
            const message = this.dataset.message;
            addMessage(message, 'user');
            chatInput.disabled = true;
            sendButton.disabled = true;
            showTypingIndicator();
            callAIService(message);
        });
    });

    // Add message with enhanced formatting
    function addMessage(text, sender) {
        const messagesContainer = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}-message`;
        
        const time = new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
        
        // Enhanced text formatting
        let formattedText = text
            .replace(/\n/g, '<br>')
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\*(.*?)\*/g, '<em>$1</em>')
            .replace(/`(.*?)`/g, '<code>$1</code>');
        
        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-${sender === 'bot' ? 'robot' : 'user'}"></i>
            </div>
            <div class="message-content">
                <div class="message-text">${formattedText}</div>
                <span class="message-time">${time}</span>
            </div>
        `;
        
        messagesContainer.appendChild(messageDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        
        // Smooth animation
        messageDiv.style.opacity = '0';
        messageDiv.style.transform = 'translateY(20px)';
        setTimeout(() => {
            messageDiv.style.transition = 'all 0.3s ease';
            messageDiv.style.opacity = '1';
            messageDiv.style.transform = 'translateY(0)';
        }, 100);
    }

    function showTypingIndicator() {
        const messagesContainer = document.getElementById('chatMessages');
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message bot-message typing-indicator';
        typingDiv.id = 'typingIndicator';
        
        typingDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <div class="typing-animation">
                    <div class="typing-dots">
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                    </div>
                    <span class="typing-text">${isConnected ? 'AtithiBot is thinking...' : 'Processing your request...'}</span>
                </div>
            </div>
        `;
        
        messagesContainer.appendChild(typingDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function hideTypingIndicator() {
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }

    function updateQuickActions(suggestions) {
        const quickActionsContainer = document.getElementById('quickActions');
        if (suggestions && suggestions.length > 0 && quickActionsContainer) {
            quickActionsContainer.innerHTML = suggestions.slice(0, 4).map(suggestion => `
                <button class="quick-btn" data-message="${suggestion}">
                    ${suggestion}
                </button>
            `).join('');
            
            // Re-attach event listeners
            quickActionsContainer.querySelectorAll('.quick-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const message = this.dataset.message;
                    addMessage(message, 'user');
                    showTypingIndicator();
                    callAIService(message);
                });
            });
        }
    }
}

// ===== UTILITY FUNCTIONS =====
function showNotification(message, type = 'info') {
    const existingNotifications = document.querySelectorAll('.custom-notification');
    existingNotifications.forEach(notification => notification.remove());

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

// ===== ENHANCED CSS FOR AI FEATURES =====
const enhancedAIStyles = `
<style>
.ai-powered {
    background: linear-gradient(45deg, #4ade80, #22c55e) !important;
    padding: 4px 12px !important;
    border-radius: 15px !important;
    font-weight: 600 !important;
    font-size: 11px !important;
    animation: pulse-glow 2s ease-in-out infinite alternate;
}

.offline-mode {
    background: linear-gradient(45deg, #fbbf24, #f59e0b) !important;
    padding: 4px 12px !important;
    border-radius: 15px !important;
    font-weight: 600 !important;
    font-size: 11px !important;
}

@keyframes pulse-glow {
    0% { box-shadow: 0 0 5px rgba(74, 222, 128, 0.5); }
    100% { box-shadow: 0 0 20px rgba(74, 222, 128, 0.8); }
}

.typing-animation {
    display: flex;
    align-items: center;
    gap: 10px;
}

.typing-text {
    font-size: 11px;
    color: #666;
    font-style: italic;
}

.message-text {
    font-size: 14px;
    line-height: 1.5;
    margin-bottom: 4px;
}

.message-text strong {
    font-weight: 600;
    color: inherit;
}

.message-text em {
    font-style: italic;
    color: inherit;
}

.message-text code {
    background: rgba(0,0,0,0.1);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: monospace;
    font-size: 12px;
}

.quick-btn {
    font-size: 11px !important;
    padding: 8px 12px !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
    transition: all 0.3s ease !important;
    border-radius: 20px !important;
}

.quick-btn:hover {
    transform: translateY(-1px) !important;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
}

.typing-indicator .message-content {
    background: rgba(0,0,0,0.05) !important;
    border-radius: 20px !important;
}

.message-time {
    font-size: 10px;
    opacity: 0.7;
    color: inherit;
}
</style>
`;



// Add enhanced styles to document
if (!document.getElementById('enhanced-ai-styles')) {
    const styleElement = document.createElement('div');
    styleElement.id = 'enhanced-ai-styles';
    styleElement.innerHTML = enhancedAIStyles;
    document.head.appendChild(styleElement);
}

console.log('✅ AtithiVerse JavaScript initialized successfully!');
