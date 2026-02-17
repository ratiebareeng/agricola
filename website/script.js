// Language Toggle Functionality
let currentLanguage = 'en';

function toggleLanguage() {
    currentLanguage = currentLanguage === 'en' ? 'sn' : 'en';
    updateLanguage();
}

function updateLanguage() {
    const elements = document.querySelectorAll('[data-en][data-sn]');
    const langToggle = document.getElementById('lang-text');
    
    elements.forEach(element => {
        if (currentLanguage === 'en') {
            element.textContent = element.getAttribute('data-en');
        } else {
            element.textContent = element.getAttribute('data-sn');
        }
    });
    
    // Update language toggle button text
    if (langToggle) {
        langToggle.textContent = currentLanguage === 'en' ? 'Setswana' : 'English';
    }
    
    // Update document language attribute
    document.documentElement.lang = currentLanguage;
}

// Smooth Scrolling for Navigation Links
function initSmoothScrolling() {
    const navLinks = document.querySelectorAll('a[href^="#"]');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 80; // Account for fixed navbar
                
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Animate Progress Bar on Scroll
function initProgressBarAnimation() {
    const progressBar = document.querySelector('.progress-fill');
    
    if (progressBar) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.width = entry.target.style.width || '70%';
                }
            });
        });
        
        observer.observe(progressBar);
    }
}

// Navbar Background on Scroll
function initNavbarScroll() {
    const navbar = document.querySelector('.navbar');
    
    window.addEventListener('scroll', () => {
        if (window.scrollY > 100) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.borderBottom = '1px solid #ECF0F1';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.borderBottom = '1px solid #ECF0F1';
        }
    });
}

// Animate Cards on Scroll
function initCardAnimations() {
    const cards = document.querySelectorAll('.feature-card, .impact-item');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });
    
    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
}

// Animate Hero Stats Counter
function initStatsAnimation() {
    const statNumbers = document.querySelectorAll('.stat-number, .impact-number');
    
    const animateValue = (element, start, end, duration, suffix = '') => {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const value = Math.floor(progress * (end - start) + start);
            element.textContent = value + suffix;
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const element = entry.target;
                const text = element.textContent;
                
                // Extract number and suffix
                const match = text.match(/^(\d+)(.*)$/);
                if (match) {
                    const number = parseInt(match[1]);
                    const suffix = match[2];
                    animateValue(element, 0, number, 2000, suffix);
                }
                
                observer.unobserve(element);
            }
        });
    });
    
    statNumbers.forEach(stat => {
        observer.observe(stat);
    });
}

// Phone Mockup Tilt Effect
function initPhoneTiltEffect() {
    const phones = document.querySelectorAll('.phone-frame');
    
    phones.forEach(phone => {
        phone.addEventListener('mousemove', (e) => {
            const rect = phone.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;
            
            const rotateX = (y / rect.height) * 30;
            const rotateY = -(x / rect.width) * 30;
            
            phone.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.05)`;
        });
        
        phone.addEventListener('mouseleave', () => {
            phone.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale(1)';
        });
    });
}

// Handle External Links
function initExternalLinks() {
    const externalLinks = document.querySelectorAll('a[href^="http"]');
    
    externalLinks.forEach(link => {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener noreferrer');
    });
}

// Mobile Menu Toggle (for future enhancement)
function initMobileMenu() {
    // Placeholder for mobile menu functionality
    // Can be expanded if needed
}

// Loading Screen
function initLoadingScreen() {
    // Hide loading screen when page is fully loaded
    window.addEventListener('load', () => {
        document.body.classList.add('loaded');
    });
}

// Form Validation (if contact forms are added later)
function initFormValidation() {
    // Placeholder for form validation
    // Can be expanded when contact forms are added
}

// Cookie Consent (for GDPR compliance if needed)
function initCookieConsent() {
    // Placeholder for cookie consent
    // Can be expanded for privacy compliance
}

// Analytics Tracking (placeholder)
function initAnalytics() {
    // Placeholder for analytics initialization
    // e.g., Google Analytics, Facebook Pixel, etc.
    console.log('Analytics initialized');
}

// Error Handling
function initErrorHandling() {
    window.addEventListener('error', (e) => {
        console.error('JavaScript error:', e.error);
        // Could send error to logging service
    });
    
    window.addEventListener('unhandledrejection', (e) => {
        console.error('Unhandled promise rejection:', e.reason);
        // Could send error to logging service
    });
}

// Performance Monitoring
function initPerformanceMonitoring() {
    // Monitor page load performance
    window.addEventListener('load', () => {
        const navigationTiming = performance.getEntriesByType('navigation')[0];
        const loadTime = navigationTiming.loadEventEnd - navigationTiming.loadEventStart;
        
        console.log(`Page load time: ${loadTime}ms`);
        
        // Could send to analytics service
    });
}

// Initialize all features when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Core functionality
    initSmoothScrolling();
    initNavbarScroll();
    initProgressBarAnimation();
    initCardAnimations();
    initStatsAnimation();
    initPhoneTiltEffect();
    initExternalLinks();
    
    // Additional features
    initMobileMenu();
    initLoadingScreen();
    initFormValidation();
    initCookieConsent();
    initAnalytics();
    initErrorHandling();
    initPerformanceMonitoring();
    
    // Set initial language
    updateLanguage();
    
    console.log('Agricola website initialized successfully');
});

// Expose functions globally for inline event handlers
window.toggleLanguage = toggleLanguage;

// Service Worker Registration (for PWA features)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // navigator.serviceWorker.register('/sw.js')
        //     .then((registration) => {
        //         console.log('SW registered: ', registration);
        //     })
        //     .catch((registrationError) => {
        //         console.log('SW registration failed: ', registrationError);
        //     });
    });
}

// Utility Functions
const utils = {
    // Debounce function for performance optimization
    debounce: (func, wait, immediate) => {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                timeout = null;
                if (!immediate) func(...args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func(...args);
        };
    },
    
    // Throttle function for scroll events
    throttle: (func, limit) => {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    },
    
    // Format numbers with commas
    formatNumber: (num) => {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    
    // Get user's preferred language
    getPreferredLanguage: () => {
        const saved = localStorage.getItem('agricola-language');
        if (saved) return saved;
        
        const browserLang = navigator.language || navigator.userLanguage;
        return browserLang.startsWith('tn') ? 'sn' : 'en'; // 'tn' is Tswana language code
    },
    
    // Save user's language preference
    saveLanguagePreference: (lang) => {
        localStorage.setItem('agricola-language', lang);
    }
};

// Export utils for other potential scripts
window.agricolaUtils = utils;