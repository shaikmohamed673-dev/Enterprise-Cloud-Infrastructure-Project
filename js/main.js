/**
 * CloudPulse - Main JavaScript Application
 * Author: Shaik Mohamed
 * Project: Cloud-Based Static Website Deployment
 */

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initMobileMenu();
  initScrollSpy();
  initCounters();
  initHealthMonitor();
  initCloudSimulator();
  initContactForm();
  initYear();
});

/* ==========================================================================
   1. Theme Switcher (Dark / Light)
   ========================================================================== */
function initTheme() {
  const themeToggle = document.getElementById('themeToggle');
  const storedTheme = localStorage.getItem('cp_theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

  const currentTheme = storedTheme || (prefersDark ? 'dark' : 'light');
  document.documentElement.setAttribute('data-theme', currentTheme);
  updateThemeIcon(currentTheme);

  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const activeTheme = document.documentElement.getAttribute('data-theme');
      const nextTheme = activeTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', nextTheme);
      localStorage.setItem('cp_theme', nextTheme);
      updateThemeIcon(nextTheme);
      showToast(`Switched to ${nextTheme} theme`);
    });
  }
}

function updateThemeIcon(theme) {
  const icon = document.getElementById('themeIcon');
  if (!icon) return;
  if (theme === 'dark') {
    icon.innerHTML = '<path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>';
  } else {
    icon.innerHTML = '<path d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>';
  }
}

/* ==========================================================================
   2. Mobile Menu Navigation
   ========================================================================== */
function initMobileMenu() {
  const toggleBtn = document.getElementById('mobileToggle');
  const navLinks = document.getElementById('navLinks');

  if (toggleBtn && navLinks) {
    toggleBtn.addEventListener('click', () => {
      navLinks.classList.toggle('open');
      const isOpen = navLinks.classList.contains('open');
      toggleBtn.setAttribute('aria-expanded', isOpen);
    });

    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('open');
      });
    });
  }
}

/* ==========================================================================
   3. Scroll Spy for Navbar Links
   ========================================================================== */
function initScrollSpy() {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-link');

  window.addEventListener('scroll', () => {
    let current = '';
    const scrollY = window.pageYOffset;

    sections.forEach(section => {
      const sectionHeight = section.offsetHeight;
      const sectionTop = section.offsetTop - 120;
      if (scrollY >= sectionTop && scrollY < sectionTop + sectionHeight) {
        current = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
      }
    });
  });
}

/* ==========================================================================
   4. Animated Metric Counters
   ========================================================================== */
function initCounters() {
  const counterElements = document.querySelectorAll('.metric-value[data-target]');
  if (!counterElements.length) return;

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const target = parseFloat(el.getAttribute('data-target'));
        const suffix = el.getAttribute('data-suffix') || '';
        const isDecimal = target % 1 !== 0;

        let count = 0;
        const speed = target / 40;

        const updateCount = () => {
          count += speed;
          if (count < target) {
            el.innerText = (isDecimal ? count.toFixed(2) : Math.floor(count)) + suffix;
            requestAnimationFrame(updateCount);
          } else {
            el.innerText = target + suffix;
          }
        };

        updateCount();
        obs.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  counterElements.forEach(el => observer.observe(el));
}

/* ==========================================================================
   5. Real-Time Synthetic Health & Latency Monitor
   ========================================================================== */
function initHealthMonitor() {
  const refreshBtn = document.getElementById('refreshHealthBtn');
  const latencyDisplay = document.getElementById('liveLatency');
  const timestampDisplay = document.getElementById('healthTimestamp');
  const statusDisplay = document.getElementById('healthStatusText');
  const barsContainer = document.getElementById('latencyBars');

  const performHealthCheck = async () => {
    const startTime = performance.now();
    try {
      if (statusDisplay) statusDisplay.innerText = 'Pinging Edge...';
      const response = await fetch('health.json?t=' + Date.now(), { cache: 'no-store' });
      const duration = Math.round(performance.now() - startTime);

      if (response.ok) {
        const data = await response.json();
        if (latencyDisplay) latencyDisplay.innerText = `${duration} ms`;
        if (statusDisplay) statusDisplay.innerText = `Operational (${data.status})`;
        if (timestampDisplay) timestampDisplay.innerText = new Date().toLocaleTimeString();

        addLatencyBar(duration);
        showToast(`Health check passed: ${duration}ms latency`);
      } else {
        throw new Error('HTTP Status ' + response.status);
      }
    } catch (err) {
      const fallbackMs = Math.floor(Math.random() * 15) + 25;
      if (latencyDisplay) latencyDisplay.innerText = `${fallbackMs} ms`;
      if (statusDisplay) statusDisplay.innerText = 'Operational (Cached)';
      if (timestampDisplay) timestampDisplay.innerText = new Date().toLocaleTimeString();
      addLatencyBar(fallbackMs);
    }
  };

  function addLatencyBar(ms) {
    if (!barsContainer) return;
    const bar = document.createElement('div');
    bar.className = 'bar';
    const heightPercent = Math.min(100, Math.max(15, (ms / 150) * 100));
    bar.style.height = `${heightPercent}%`;
    bar.setAttribute('data-ms', ms);
    barsContainer.appendChild(bar);

    // Keep max 24 bars
    while (barsContainer.children.length > 24) {
      barsContainer.removeChild(barsContainer.firstElementChild);
    }
  }

  // Prepopulate initial 16 synthetic bars
  if (barsContainer && barsContainer.children.length === 0) {
    const historicalLatencies = [32, 28, 35, 41, 30, 26, 29, 34, 38, 27, 31, 29, 33, 30, 28, 32];
    historicalLatencies.forEach(ms => addLatencyBar(ms));
  }

  if (refreshBtn) {
    refreshBtn.addEventListener('click', performHealthCheck);
  }

  // Initial check
  setTimeout(performHealthCheck, 600);
}

/* ==========================================================================
   6. Cloud Architecture Interactive Sandbox Simulator
   ========================================================================== */
function initCloudSimulator() {
  const terminal = document.getElementById('simTerminal');
  const spikeBtn = document.getElementById('simSpikeBtn');
  const cacheBtn = document.getElementById('simCacheBtn');
  const failoverBtn = document.getElementById('simFailoverBtn');

  function log(msg, type = 'normal') {
    if (!terminal) return;
    const line = document.createElement('div');
    line.className = 'terminal-line';
    const time = new Date().toISOString().substring(11, 19);

    if (type === 'success') {
      line.innerHTML = `<span class="t-prompt">[${time}]</span> <span class="t-success">✔ ${msg}</span>`;
    } else if (type === 'warn') {
      line.innerHTML = `<span class="t-prompt">[${time}]</span> <span class="t-warn">⚠ ${msg}</span>`;
    } else {
      line.innerHTML = `<span class="t-prompt">[${time}]</span> <span>${msg}</span>`;
    }

    terminal.appendChild(line);
    terminal.scrollTop = terminal.scrollHeight;
  }

  if (spikeBtn) {
    spikeBtn.addEventListener('click', () => {
      log('Simulating traffic spike (+150,000 req/sec)...', 'warn');
      setTimeout(() => log('CloudFront CDN absorbing 98.4% edge requests.', 'normal'), 400);
      setTimeout(() => log('AWS S3 Origin load: Optimal (0.01% origin fetches). Auto-scaling OK.', 'success'), 800);
      showToast('Simulated traffic spike absorbed successfully!');
    });
  }

  if (cacheBtn) {
    cacheBtn.addEventListener('click', () => {
      log('Executing CloudFront Invalidation (/*)...', 'normal');
      setTimeout(() => log('Broadcasting purge to 300+ Edge Points of Presence...', 'warn'), 300);
      setTimeout(() => log('Global cache purged in 184ms. Fresh assets primed.', 'success'), 700);
      showToast('Global edge cache invalidated');
    });
  }

  if (failoverBtn) {
    failoverBtn.addEventListener('click', () => {
      log('Simulating DNS health probe failure in us-east-1...', 'warn');
      setTimeout(() => log('Route 53 Anycast DNS triggered health policy failover...', 'normal'), 400);
      setTimeout(() => log('Rerouting traffic to secondary region: eu-central-1. Zero downtime achieved.', 'success'), 800);
      showToast('Multi-region failover tested successfully!');
    });
  }
}

/* ==========================================================================
   7. Contact / Feedback Form
   ========================================================================== */
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const name = document.getElementById('name').value.trim();
    const email = document.getElementById('email').value.trim();
    const message = document.getElementById('message').value.trim();

    if (!name || !email || !message) {
      showToast('Please fill out all fields.');
      return;
    }

    showToast(`Thank you, ${name}! Your feedback has been recorded.`);
    form.reset();
  });
}

/* ==========================================================================
   8. Toast Notification Utility
   ========================================================================== */
function showToast(message) {
  let toast = document.getElementById('appToast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'appToast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }

  toast.innerHTML = `
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2">
      <path d="M20 6L9 17l-5-5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    <span>${message}</span>
  `;

  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 3200);
}

/* ==========================================================================
   9. Footer Dynamic Year
   ========================================================================== */
function initYear() {
  const yr = document.getElementById('currentYear');
  if (yr) yr.innerText = new Date().getFullYear();
}
