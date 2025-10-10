// Wait for all dependencies to load
window.addEventListener('load', function() {
    // Initialize animations
    if (typeof AOS !== 'undefined') {
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true
        });
    }

    // Initialize Vanta.js globe in hero section
    if (typeof VANTA !== 'undefined' && document.getElementById('vanta-globe')) {
        VANTA.GLOBE({
            el: '#vanta-globe',
            mouseControls: true,
            touchControls: true,
            gyroControls: false,
            minHeight: 200.00,
            minWidth: 200.00,
            scale: 1.00,
            scaleMobile: 1.00,
            color: 0x3a86ff,
            backgroundColor: 0x1e3c72
        });
    }

    // Initialize feather icons
    if (typeof feather !== 'undefined') {
        feather.replace();
    }
});